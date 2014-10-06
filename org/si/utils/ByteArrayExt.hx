








package org.si.utils ;
	import flash.display.DisplayObjectContainer;
    import flash.net.FileFilter;
    import flash.net.FileReference;
    import flash.net.URLRequest;
    import flash.net.URLLoader;
    import flash.utils.ByteArray;
    import flash.events.Event;
    import flash.display.BitmapData;
	import flash.net.URLLoaderDataFormat;


    
    class ByteArrayExt extends ByteArray {
    
    
        static private var crc32: Array<Int> = null;
        
        
        
        
    
    
        
        public function new(copyFrom:ByteArray = null)
        {
            super();
            if (copyFrom != null) {
                this.writeBytes(copyFrom);
                this.endian = copyFrom.endian;
                this.position = 0;
            }
        }
        
        
        
        
    
    
        
        public function fromBitmapData(bmd:BitmapData) : ByteArrayExt
        {
            var x:Int, y:Int, i:Int, w:Int=bmd.width, h:Int=bmd.height, len:Int, p:Int;
            this.clear();
            len = bmd.getPixel(w-1, h-1);
           y=0; i=0;
 while( y<h && i<len){
			x=0;
	while( x<w && i<len){
                p = bmd.getPixel(x, y);
                this.writeByte(p>>>16);
                if (++i >= len) break;
                this.writeByte(p>>>8);
                if (++i >= len) break;
                this.writeByte(p);
				 x++; i++;
}
			 y++;
}
            this.position = 0;
            return this;
        }
        
        
        
        public function toBitmapData(width:Int=0, height:Int=0, transparent:Bool = true, fillColor:Int = 0xFFFFFFFF) : BitmapData
        {
            var x:Int, y:Int, reqh:Int, bmd:BitmapData, len:Int = this.length, p:Int;
            if (width == 0) width = ((Std.int (Math.sqrt(len)+65535/65536))+15)&(~15);
            reqh = ((Std.int (len/width+65535/65536))+15)&(~15);
            if (height == 0 || reqh > height) height = reqh;
            bmd = new BitmapData(width, height, transparent, fillColor);
            this.position = 0;
           y = 0;
		   x = 0;
			while( y<height){
				x=0;
				while( x<width){
					if (this.bytesAvailable < 3) break;
					bmd.setPixel32(x, y, 0xff000000|((this.readUnsignedShort()<<8)|this.readUnsignedByte()));
					 x++;
				}
			 y++;
			}
            p = 0xff000000;
            if (this.bytesAvailable > 0) p |= this.readUnsignedByte() << 16;
            if (this.bytesAvailable > 0) p |= this.readUnsignedByte() << 8;
            if (this.bytesAvailable > 0) p |= this.readUnsignedByte();
            bmd.setPixel32(x, y, p);
            this.position = 0;
            bmd.setPixel32(x, y, 0xff000000|(Std.int (this.length)));
            return bmd;
        }
        
		function png_writeChunk(png:ByteArrayExt,type:Int, data:ByteArray) : Void {
                png.writeUnsignedInt(data.length);
                var crcStartAt:Int = png.position;
                png.writeUnsignedInt(type);
                png.writeBytes(data);
                png.writeUnsignedInt(calculateCRC32(png, crcStartAt, png.position - crcStartAt));
		}
        
        
        public function toPNGData(width:Int=0, height:Int=0) : ByteArrayExt
        {
            var i:Int, imax:Int, reqh:Int, pixels:Int = Std.int((this.length+2)/3), y:Int, 
                png:ByteArrayExt = new ByteArrayExt(), 
                header:ByteArray = new ByteArray(), 
                content:ByteArray = new ByteArray();
            
            if (width == 0) width = ((Std.int (Math.sqrt(pixels)+65535/65536))+15)&(~15);
            reqh = ((Std.int (pixels/width+65535/65536))+15)&(~15);
            if (height == 0 || reqh > height) height = reqh;
            header.writeInt(width);  
            header.writeInt(height); 
            header.writeUnsignedInt(0x08020000); 
            header.writeByte(0);
            imax = pixels - width;
           y=0; i=0;
 while( i<imax){
                content.writeByte(0);
                content.writeBytes(this, i*3, width*3);
             i+=width; y++;
}
            content.writeByte(0);
            content.writeBytes(this, i*3, this.length-i*3);
            imax = (i + width) * 3;
           i=this.length;
 while( i<imax){
				content.writeByte(0);
			 i++;
}
            imax = width * 3 + 1;
           y++;
 while( y<height){
			i=0;
	while( i<imax){	
					content.writeByte(0);
				 i++;
}
			 y++;
}
            i = this.length;
            content.position -= 3;
            content.writeByte(i>>>16);
            content.writeByte(i>>>8);
            content.writeByte(i);
            content.compress();
            
            
            png.writeUnsignedInt(0x89504e47);
            png.writeUnsignedInt(0x0D0A1A0A);
            png_writeChunk(png,0x49484452, header);
            png_writeChunk(png,0x49444154, content);
            png_writeChunk(png,0x49454E44, new ByteArray());
            png.position = 0;
            
            return png;
            
        }
        
        
        
        
    
    
        
        public function writeChunk(chunkID:String, data:ByteArray, listType:String=null) : Void
        {
            var isList:Bool = (chunkID == "RIFF" || chunkID == "LIST"),
                len:Int = ((data != null) ? data.length : 0) + ((isList) ? 4 : 0);
            this.writeMultiByte((chunkID+"    ").substr(0,4), "us-ascii");
            this.writeInt(len);
            if (isList) {
                if (listType != null) this.writeMultiByte((listType+"    ").substr(0,4), "us-ascii");
                else this.writeMultiByte("    ", "us-ascii");
            }
            if (data != null) {
                this.writeBytes(data);
                if ((len & 1) != 0) this.writeByte(0);
            }
        }
        
        
        
        public function readChunk(bytes:ByteArray, offset:Int=0, searchChunkID:String=null) : Dynamic
        {
            var id:String, len:Int, type:String=null;
            while (this.bytesAvailable > 0) {
                id = this.readMultiByte(4, "us-ascii");
                len = this.readInt();
                if (searchChunkID == null || searchChunkID == id) {
                    if (id == "RIFF" || id == "LIST") {
                        type = this.readMultiByte(4, "us-ascii");
                        this.readBytes(bytes, offset, len-4);
                    } else {
                        this.readBytes(bytes, offset, len);
                    }
                    if ((len & 1) != 0) this.readByte();
                    bytes.endian = this.endian;
                    return {"chunkID":id, "length":len, "listType":type};
                }
                this.position += len + (len & 1);
            }
            return null;
        }
        
        
        
        public function readAllChunks() : Dynamic
        {
            var header:Dynamic, ret:Dynamic = {}, pickup:ByteArrayExt;
            while (header = readChunk(pickup = new ByteArrayExt())) {
				
                if (Reflect.hasField(ret,header.chunkID)) {
                    if (Std.is(ret[header.chunkID],Array)) ret[header.chunkID].push(pickup);
                    else ret[header.chunkID] = [ret[header.chunkID]];
                } else {
                    ret[header.chunkID] = pickup;
                }
            }
            return ret;
        }
        
        
        
        
    
    
        
        public function load(url:String, onComplete:Dynamic=null, onCancel:Dynamic=null, onError:Dynamic=null) : Void
        {
            var loader:URLLoader = new URLLoader(), bae:ByteArrayExt = this;
            loader.dataFormat = URLLoaderDataFormat.BINARY;
			var _onLoadCancel:Dynamic = null;
			var _onLoadError:Dynamic = null;
			var _onLoadComplete:Dynamic = null;
			
			
			var _removeAllEventListeners:Dynamic = function (e:Event, callback:Dynamic) : Void {
                loader.removeEventListener("complete", _onLoadComplete);
                loader.removeEventListener("cancel", _onLoadCancel);
                loader.removeEventListener("ioError", _onLoadError);
                if (callback != null) callback(e);
            }
			
		    _onLoadCancel = function(e:Event)   : Void { _removeAllEventListeners(e, onCancel); }
            _onLoadError = function(e:Event)    : Void { _removeAllEventListeners(e, onError); }
			
		   _onLoadComplete = function(e:Event) : Void { 
                bae.clear();
                bae.writeBytes(e.target.data);
                _removeAllEventListeners(e, null);
                bae.position = 0;
                if (onComplete != null) onComplete(bae);
            }
			

			
            loader.addEventListener("complete", _onLoadComplete);
            loader.addEventListener("cancel", _onLoadCancel);
            loader.addEventListener("ioError", _onLoadError);
            loader.load(new URLRequest(url));

        }
        
        
        
        
    
    
        
        public function browse(onComplete:Dynamic=null, onCancel:Dynamic=null, onError:Dynamic=null, fileFilterName:String=null, extensions:String=null) : Void
        {
            var fr:FileReference = new FileReference(), bae:ByteArrayExt = this;
			var _onBrowseComplete:Dynamic = null;
			var _onBrowseCancel:Dynamic = null;
			var _onBrowseError:Dynamic = null;
			
			var _removeAllEventListeners:Dynamic = function(e:Event, callback:Dynamic) : Void {
                fr.removeEventListener("complete", _onBrowseComplete);
                fr.removeEventListener("cancel", _onBrowseCancel);
                fr.removeEventListener("ioError", _onBrowseError);
                if (callback != null) callback(e);
            }
			
            _onBrowseComplete = function(e:Event) : Void {
                bae.clear();
                bae.writeBytes(e.target.data);
                _removeAllEventListeners(e, null);
                bae.position = 0;
                if (onComplete != null) onComplete(bae);
            }
            _onBrowseCancel = function(e:Event) : Void { _removeAllEventListeners(e, onCancel); }
            _onBrowseError = function(e:Event)  : Void { _removeAllEventListeners(e, onError); }
			
			
            fr.addEventListener("select", function(e:Event) : Void {
                //e.target.removeEventListener(e.type, arguments.callee);HAXE TODO : see consequences
                fr.addEventListener("complete", _onBrowseComplete);
                fr.addEventListener("cancel", _onBrowseCancel);
                fr.addEventListener("ioError", _onBrowseError);
                fr.load();
            });
            fr.browse((fileFilterName != null) ? [new FileFilter(fileFilterName, extensions)] : null);


        }
        
        
        
        public function save(defaultFileName:String=null, onComplete:Dynamic=null, onCancel:Dynamic=null, onError:Dynamic=null) : Void
        {
			var _onSaveComplete:Dynamic = null;
			var _onSaveCancel:Dynamic = null;
			var _onSaveError:Dynamic = null;
			
			var fr:FileReference = new FileReference();
			
			var _removeAllEventListeners:Dynamic = function(e:Event, callback:Dynamic) : Void {
                fr.removeEventListener("complete", _onSaveComplete);
                fr.removeEventListener("cancel", _onSaveCancel);
                fr.removeEventListener("ioError", _onSaveError);
                if (callback != null) callback(e);
            }
			
            _onSaveComplete = function(e:Event) : Void { _removeAllEventListeners(e, onComplete); }
            _onSaveCancel = function(e:Event)   : Void { _removeAllEventListeners(e, onCancel); }
            _onSaveError = function(e:Event)    : Void { _removeAllEventListeners(e, onError); }
			
			
            
            fr.addEventListener("complete", _onSaveComplete);
            fr.addEventListener("cancel", _onSaveCancel);
            fr.addEventListener("ioError", _onSaveError);
            fr.save(this, defaultFileName);


        }
        
        
        
        
    
    
        
        static public function calculateCRC32(byteArray:ByteArray, offset:Int=0, length:Int=0) : Int 
        {
            var i:Int, j:Int, c:Int, currentPosition:Int;
            if (crc32 == null) {
                crc32 = new Array<Int>();
               i=0;
 while( i<256){
                   c=i; j=0;
 while( j<8){
						c = Std.int((((c&1) != 0)?0xedb88320:0)^(c>>>1));
					 j++;
}
                    crc32[i] = c;
                 i++;
}
            }
            
            if (length==0) length = byteArray.length;
            currentPosition = byteArray.position;
            byteArray.position = offset;
           c=0xffffffff; i=0;
 while( i<length){
                j = (c ^ byteArray.readUnsignedByte()) & 255;
                c >>>= 8;
                c ^= crc32[j];
             i++;
}
            byteArray.position = currentPosition;
            
            return c ^ 0xffffffff;
        }
    }


