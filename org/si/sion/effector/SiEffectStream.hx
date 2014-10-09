





package org.si.sion.effector ;
	import flash.display.DisplayObjectContainer;
    import org.si.sion.module.SiOPMModule;
    import org.si.sion.module.SiOPMStream;
    
    
    
    class SiEffectStream
    {
    
    
        
        public var chain: Array<SiEffectBase> = new Array<SiEffectBase>();
        
        
       public var _stream:SiOPMStream;
        
       public  var _depth:Int;
        
        
        private var _module:SiOPMModule;
        
        private var _pan:Int;
        
        private var _hasEffectSend:Bool;
        
        private var _volumes: Array<Float> = new Array<Float>();
        
        private var _outputStreams: Array<SiOPMStream> = new Array<SiOPMStream>();
        
        
        
        
    
    
        
        public function stream() : SiOPMStream { return _stream; }
        
        
        
        public function get_pan() : Int { return _pan-64; }
        public function pan(p:Int) : Void {
            _pan = p+64;
            if (_pan < 0) _pan = 0;
            else if (_pan > 128) _pan = 128;
        }
        
        
        
        public function _outputDirectly() : Bool {
            return (!_hasEffectSend && _volumes[0] == 1 && _pan == 64);
        }
        
        
        
        
    
    
        
        
        public function new(module:SiOPMModule, stream:SiOPMStream = null) 
        {
            _depth = 0;
            _module = module;
            _stream = (stream != null) ? stream : new SiOPMStream();
        }
        
        
        
        
    
    
        
        public function setAllStreamSendLevels(param: Array<Int>) : Void
        {
            var i:Int, imax:Int = SiOPMModule.STREAM_SEND_SIZE, v:Int;
           i=0;
 while( i<imax){
                v = param[i];
                _volumes[i] = (v != -2147483648 ) ? (v * 0.0078125) : 0;
             i++;
}
           _hasEffectSend=false; i=1;
 while( i<imax){
                if (_volumes[i] > 0) _hasEffectSend = true;
             i++;
}
        }
        
        
        
        public function setStreamSend(streamNum:Int, volume:Float) : Void
        {
            _volumes[streamNum] = volume;
            if (streamNum == 0) return;
            if (volume > 0) _hasEffectSend = true;
            else {
                var i:Int, imax:Int = SiOPMModule.STREAM_SEND_SIZE;
               _hasEffectSend=false; i=1;
 while( i<imax){
                    if (_volumes[i] > 0) _hasEffectSend = true;
                 i++;
}
            }
        }
        

         
        public function getStreamSend(streamNum:Int) : Float
        {
            return _volumes[streamNum];
        }        
        
        
        
        
    
    
        
        public function initialize(depth:Int) : Void
        {
            free();
            reset();
           var i:Int=0;
 while( i<SiOPMModule.STREAM_SEND_SIZE){
                _volumes[i] = 0;
                _outputStreams[i] = null;
             i++;
}
            _volumes[0] = 1;
            _pan = 64;
            _hasEffectSend = false;
            _depth = depth;
        }
        
        
        
        public function reset() : Void
        {
            //_stream.buffer.length = _module.bufferLength<<1; HAXE PORT
            _stream.clear();
        }
        
        
        
        public function free() : Void
        {
            for (e in chain) e._isFree = true;
			
			chain.splice(0, chain.length);
        }
        
        
        
        public function connectTo(output:SiOPMStream = null) : Void
        {
            _outputStreams[0] = output;
        }
        
        
        
        public function prepareProcess() : Int
        {
            if (chain.length == 0) return 0;
            _stream.channels = chain[0].prepareProcess();
           var i:Int=1;
 while( i<chain.length){ chain[i].prepareProcess(); i++;
}
            return _stream.channels;
        }
        
        
        
        public function process(startIndex:Int, length:Int, writeInStream:Bool=true) : Int
        {
            var i:Int, imax:Int, effect:SiEffectBase, stream:SiOPMStream,
                buffer: Array<Float> = _stream.buffer, channels:Int = _stream.channels;
            imax = chain.length;
           i=0;
 while( i<imax){
                channels = chain[i].process(channels, buffer, startIndex, length);
             i++;
}
            
            
            if (writeInStream) {
                if (_hasEffectSend) {
                   i=0;
 while( i<SiOPMModule.STREAM_SEND_SIZE){
                        if (_volumes[i]>0) {
                            stream = (_outputStreams[i] != null) ? _outputStreams[i] :  _module.streamSlot[i];
                            if (stream != null) stream.writeVectorNumber(buffer, startIndex, startIndex, length, _volumes[i], _pan, 2);
                        }
                     i++;
}
                } else {
                    stream = (_outputStreams[0] != null) ? _outputStreams[0] :  _module.outputStream;
                    stream.writeVectorNumber(buffer, startIndex, startIndex, length, _volumes[0], _pan, 2);
                }
            }
            
            return channels;
        }
        
        
        
        
    
    
        
        public function parseMML(slot:Int, mml:String, postfix:String) : Void
        {
            var res:Dynamic, i:Int, cmd:String = "", argc:Int = 0, args: Array<Float> = new Array<Float>(),
				rexMML:EReg = new EReg("([a-zA-Z_]+|,)\\s*([.\\-\\d]+)?", "g"),
                rexPost:EReg = new EReg("(p|@p|@v|,)\\s*([.\\-\\d]+)?", "g");
				
			 var _connectEffect:Dynamic =  function () : Void {
                if (argc == 0) return;
                var e:SiEffectBase = SiEffectModule.getInstance(cmd);
                if (e != null) {
                    e.mmlCallback(args);
                    chain.push(e);
                }
            }
            
            
           var _setVolume:Dynamic =  function () : Void {
                var v:Float, i:Int;
                if (argc == 0) return;
                switch (cmd) {
                case 'p':
                    pan(((Std.int (args[0]))<<4)-64);
               
                case '@p':
                    pan(Std.int(args[0]));
                    
                case '@v':
                    v = Std.int(args[0]) * 0.0078125;
                    setStreamSend(0, (v < 0) ? 0 : (v > 1) ? 1 : v);
                    if (argc+slot >= SiOPMModule.STREAM_SEND_SIZE) argc = SiOPMModule.STREAM_SEND_SIZE - slot - 1;
                   i = 1;
 while( i < argc){
                        v = Std.int(args[i]) * 0.0078125;
                        setStreamSend(i+slot, (v < 0) ? 0 : (v > 1) ? 1 : v);
                     i++;
}
                }
            }
            
            
            var _clearArgs:Dynamic =  function () : Void {
               var i:Int=0;
 while( i<16){ args[i]=Math.NaN; i++;
}
                argc = 0;
            }
                
                
            
            initialize(0);
            _clearArgs();
            
            
            res = rexMML.match(mml);
            while (res) {
                if (res[1] == ",") {
                    args[argc++] = Std.parseFloat(res[2]);
                } else {
                    _connectEffect();
                    _clearArgs();
                    cmd = res[1];
                    args[0] = Std.parseFloat(res[2]);
                    argc = 1;
                }
                res = rexMML.match(mml);
            }
            _connectEffect();
            _clearArgs();
            
            
            res = rexPost.match(postfix);
            while (res) {
                if (res[1] == ",") {
                    args[argc++] = Std.parseFloat(res[2]);
                } else {
                    _setVolume();
                    _clearArgs();
                    cmd = res[1];
                    args[0] = Std.parseFloat(res[2]);
                    argc = 1;
                }
                res = rexPost.match(postfix);
            }
            _setVolume();
            
            
           
        }
    }


