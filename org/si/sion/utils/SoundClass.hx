





package org.si.sion.utils;
    import flash.display.Loader;
    import flash.events.*;
	import flash.net.DynamicPropertyOutput;
    import flash.utils.ByteArray;
    import flash.media.Sound;
	import flash.errors.Error;
	import flash.utils.Endian;
    
    
    
    class SoundClass
    {
        static private var _header: Array<Int> = [ 
            0x09535746, 0xFFFFFFFF, 0x5f050078, 0xa00f0000, 0x010c0000, 0x08114400, 0x43000000, 0xffffff02, 
            0x000b15bf, 0x00010000, 0x6e656353, 0x00312065, 0xc814bf00, 0x00000000, 0x00000000, 0x002e0010, 
            0x08000000, 0x756f530a, 0x6c43646e, 0x00737361, 0x616c660b, 0x6d2e6873, 0x61696465, 0x756f5305, 
            0x4f06646e, 0x63656a62, 0x76450f74, 0x44746e65, 0x61707369, 0x65686374, 0x6c660c72, 0x2e687361, 
            0x6e657665, 0x05067374, 0x16021601, 0x16011803, 0x07050007, 0x03070102, 0x05020704, 0x03060507, 
            0x00020000, 0x00020000, 0x00020000, 0x02010100, 0x01000408, 0x01000000, 0x04010102, 0x00030001, 
            0x06050101, 0x4730d003, 0x01010000, 0x06070601, 0x49d030d0, 0x00004700, 0x01010202, 0x30d01f05, 
            0x035d0065, 0x5d300366, 0x30046604, 0x0266025d, 0x66025d30, 0x1d005802, 0x01681d1d, 0xbf000047,
            0xFFFFFF03, 0x3f0001FF  
        ];
        static private var _footer: Array<Int> = [ 
            0x000f133f, 0x00010000, 0x6f530001, 0x43646e75, 0x7373616c, 0x0f0b4400, 0x40000000
        ];
        
        
        static private var _bitRateList: Array<Int> = [
            0,32,40,48,56,64,80,96,112,128,160,192,224,256,320,0,0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,0
        ];
        static private var _frequencyList: Array<Int> = [44100,48000,32000,0];
        
        
        function new()
		{
			
		}
        
        
        static public function loadMP3FromByteArray(bytes:ByteArray, onComplete:Dynamic) : Void {
            var head:Int, version:Int, bitrate:Int, frequency:Int = 0, padding:Int, channels:Int = 0, frameLength:Int;
            bytes.position = 0;
            var id:String;
            if (bytes.readMultiByte(3,"us-ascii") == "ID3") {
                bytes.position += 3; 
                bytes.position += ((bytes.readByte()&127)<<21)|((bytes.readByte()&127)<<14)|((bytes.readByte()&127)<<7)|(bytes.readByte()&127);
            } else {
                bytes.position -= 3;
            }
            var frameCount:Int = 0, byteCount:Int = 0, headPosition:Int = bytes.position;
            while (bytes.bytesAvailable != 0) {
                head = bytes.readUnsignedInt();
                if ((Std.int (head & 0xffe60000)) != 0xffe20000) throw new Error("frame data broken"); 
                version = [2,-1,1,0][(head>>19) & 3]; 
                bitrate = _bitRateList[((head>>12) & 15) + ((version == 0) ? 0 : 16)];
                frequency = _frequencyList[((head>>10) & 3)] >> version;
                padding = (head>>9) & 1;
                channels = (((head>>6) & 3) > 2) ? 1 : 2;
                frameLength = ((version == 0) ? 144000 : 72000) * Std.int(bitrate / frequency + padding);
                byteCount += frameLength;
                bytes.position += frameLength - 4;
                frameCount++;
            }
            var src:ByteArray = new ByteArray();
            src.endian = Endian.LITTLE_ENDIAN;
            src.writeInt(frameCount*1152);
            src.writeShort(0);
            src.writeBytes(bytes, headPosition, byteCount);
            loadPCMFromByteArray(src, onComplete, true, frequency, 16, channels);
        }
        
        
        
        static public function loadPCMFromByteArray(src:ByteArray, onComplete:Dynamic, compressed:Bool=false, sampleRate:Int=44100, bitRate:Int=16, channels:Int=2) : Void {
            var size:Int = src.length - ((compressed) ? 4 : 0), typeDef:Int;
			 var bytes:ByteArray = new ByteArray();
			 
			var _write:Dynamic =  function (vu: Array<Int>) : Void {
               var i:Int=0;
				 while ( i < vu.length) { 
					 bytes.writeUnsignedInt(vu[i]); i++;
				}
            }
			
			
            typeDef  = (compressed) ? 0x20 : 0x30;
            typeDef |= (channels==2) ? 0x01: 0x00;
            switch (sampleRate) {
            case 44100: typeDef |= 0xc;
            case 22050: typeDef |= 0x8;
            case 11025: typeDef |= 0x4;
            case  5512: 
            default: throw new Error("sampleRate not valid.");
            }
            switch (bitRate) {
            case 16: typeDef |= 0x2;
            case 8:
            default: throw new Error("bitRate not valid.");
            }
           
            bytes.endian = Endian.LITTLE_ENDIAN;
            bytes.position = 0;
            _write(_header);
            bytes.position = 257;
            bytes.writeInt(size + 7);
            bytes.position = 263;
            bytes.writeByte(typeDef);
            bytes.writeBytes(src);
            _write(_footer);
            bytes.writeByte(0);
            bytes.writeByte(0);
            bytes.writeByte(0);
            bytes.position = 4;
            bytes.writeInt(bytes.length);
            bytes.position = 0;
            
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event) : Void {
                onComplete(cast(new SoundClass(),Sound));
            });
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event) : Void {
                throw new Error(e.toString());
            });
            loader.loadBytes(bytes);
            

            
        }
        
        
        
        static public function create(samples: Array<Float>, onComplete:Dynamic) : Void {
            var size:Int = samples.length * 2; 
            var bytes:ByteArray = new ByteArray();
			
		   var _write:Dynamic =  function (vu: Array<Int>) : Void { for (ui in vu) { bytes.writeUnsignedInt(ui); } }
			
            bytes.endian = Endian.LITTLE_ENDIAN;
            bytes.length = size + 295;
            bytes.position = 0;
            _write(_header);
            bytes.position = 4;
            bytes.writeInt(size + 295);
            bytes.position = 257;
            bytes.writeInt(size + 7);
            bytes.position = 264;
			
			var i:Int, imax:Int;
            imax = samples.length;
            
           i=0;
 while( i<imax){ bytes.writeShort(Std.int(samples[i]*32767));  i++;
}
            _write(_footer);
            bytes.writeByte(0);
            bytes.writeByte(0);
            bytes.writeByte(0);
            bytes.position = 0;
            
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event) : Void {
                //*var soundClass:Class = loader.contentLoaderInfo.applicationDomain.getDefinition(cast("SoundClass"),Class);
                onComplete(cast(new SoundClass(),Sound));
            });
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event) : Void {
                throw new Error(e.toString());
            });
            loader.loadBytes(bytes);
            
          
        }
    }


