





package org.si.sion.utils.soundfont ;
    import flash.events.*;
    import flash.net.*;
    import flash.display.Loader;
    import flash.system.LoaderContext;
    import flash.utils.ByteArray;
    import org.si.sion.*;
    import org.si.sion.utils.*;
    import org.si.sion.module.*;
    import org.si.sion.sequencer.*;
	import flash.errors.Error;
    
    
    
    class SiONSoundFontLoader extends EventDispatcher
    {
    
    
        
        public var soundFont:SiONSoundFont;
        
        
        private var _binloader:URLLoader;
        private var _swfloader:Loader;
        
        
        
        
    
    
        
        public function bytesLoaded() : Float 
        {
            return (_swfloader != null) ? _swfloader.contentLoaderInfo.bytesLoaded : (_binloader != null) ? _binloader.bytesLoaded : 0;
        }
        
        
        
        public function bytesTotal() : Float 
        {
            return (_swfloader != null) ? _swfloader.contentLoaderInfo.bytesTotal : (_binloader != null) ? _binloader.bytesTotal : 0;
        }
        
        
        
        
    
    
        
        public function new()
        {
            soundFont = null;
            _binloader = null;
            _swfloader = null;
			super();
        }
        
        
        
        
    
    
        
        public function load(url:URLRequest, loadAsBinary:Bool=true, checkPolicyFile:Bool=false) : Void
        {
            if (loadAsBinary) {
                _addAllListeners(_binloader = new URLLoader());
                _binloader.dataFormat = URLLoaderDataFormat.BINARY;
                _binloader.load(url);
            } else {
                _swfloader = new Loader();
                _addAllListeners(_swfloader.contentLoaderInfo);
                _swfloader.load(url, new LoaderContext(checkPolicyFile));
            }
        }
        
        
        
        public function loadBytes(bytes:ByteArray) : Void {
            _binloader = null;
            _swfloader = new Loader();
            _addAllListeners(_swfloader.contentLoaderInfo);
            _swfloader.loadBytes(bytes);
        }
        
        
        
        
    
    
        private function _addAllListeners(dispatcher:EventDispatcher) : Void 
        {
            dispatcher.addEventListener(Event.COMPLETE, _onComplete);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, _onProgress);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, _onError);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onError);
        }
        
        
        private function _removeAllListeners() : Void 
        {
            var dispatcher:EventDispatcher = (_binloader != null) ?  _binloader : _swfloader.contentLoaderInfo;
            dispatcher.removeEventListener(Event.COMPLETE, _onComplete);
            dispatcher.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
            dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, _onError);
            dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _onError);
        }
        
        
        private function _onComplete(e:Event) : Void
        {
            _removeAllListeners();
            if (_binloader != null) loadBytes(_binloader.data);
            else {
                _analyze();
                dispatchEvent(e.clone());
            }
        }
        
        
        private function _onProgress(e:Event) : Void { dispatchEvent(e.clone()); }
        private function _onError(e:ErrorEvent) : Void { _removeAllListeners(); dispatchEvent(e.clone()); }
        
        
        
        
    
    
        private function _analyze() : Void
        {
            var container:SiONSoundFontContainer = cast(_swfloader.content,SiONSoundFontContainer);
            if (container == null) _onError(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "The sound font file is not valid."));
            
            
            soundFont = new SiONSoundFont(container.sounds);
            
            
            switch (container.version) {
            case "1":
                _compileSystemCommand(Translator.extractSystemCommand(container.mml));
            }
        }
        
        
        
        private function _compileSystemCommand(systemCommands:Array<Dynamic>) : Void
        {
            var i:Int, imax:Int = systemCommands.length, cmd:Dynamic, num:Int = 0, dat:String = null, pfx:String = null, bank:Int, 
                env:SiMMLEnvelopTable, voice:SiONVoice, samplerTable:SiOPMWaveSamplerTable, pcmTable:SiOPMWavePCMTable;
				
				
			var __parseToneParam:Dynamic =  function (func:Dynamic) : Void {
                voice = new SiONVoice();
                func(voice.channelParam, dat);
                if (pfx.length > 0) Translator.parseVoiceSetting(voice, pfx);
                soundFont.fmVoices[num] = voice;
            }
				
            
           i=0;
 while( i<imax){
                cmd = systemCommands[i];
                num = cmd.number;
                dat = cmd.content;
                pfx = cmd.postfix;
                
                switch (cmd.command) {
                
                case '#@':    { __parseToneParam(Translator.parseParam);    break; }
                case '#OPM@': { __parseToneParam(Translator.parseOPMParam); break; }
                case '#OPN@': { __parseToneParam(Translator.parseOPNParam); break; }
                case '#OPL@': { __parseToneParam(Translator.parseOPLParam); break; }
                case '#OPX@': { __parseToneParam(Translator.parseOPXParam); break; }
                case '#MA@':  { __parseToneParam(Translator.parseMA3Param); break; }
                case '#AL@':  { __parseToneParam(Translator.parseALParam);  break; }
                    
                
                case '#FPS':   { soundFont.defaultFPS = (num>0) ? num : ((dat == "") ? 60 : Std.parseInt(dat)); break; }
                case '#VMODE': { _parseVCommansSubMML(dat); break; }

                
                case '#TABLE': {
                    if (num < 0 || num > 254) throw _errorParameterNotValid("#TABLE", Std.string(num));
                    env = new SiMMLEnvelopTable().parseMML(dat, pfx);
                    if (env.head == null) throw _errorParameterNotValid("#TABLE", dat);
                    soundFont.envelopes[num] = env;
    
                }
                case '#WAV': {
                    if (num < 0 || num > 255) throw _errorParameterNotValid("#WAV", Std.string(num));
                    soundFont.waveTables[num] = _newWaveTable(Translator.parseWAV(dat, pfx));
     
                }
                case '#WAVB': {
                    if (num < 0 || num > 255) throw _errorParameterNotValid("#WAVB", Std.string(num));
                    soundFont.waveTables[num] = _newWaveTable(Translator.parseWAVB((dat=="") ? pfx : dat));
            
                }
        
                
                case '#SAMPLER': {
                    if (num < 0 || num > 255) throw _errorParameterNotValid("#SAMPLER", Std.string(num));
                    bank = (num>>SiOPMTable.NOTE_BITS) & (SiOPMTable.SAMPLER_TABLE_MAX-1);
                    num &= (SiOPMTable.NOTE_TABLE_SIZE-1);
                    if (soundFont.samplerTables[bank] == null) soundFont.samplerTables[bank] = new SiOPMWaveSamplerTable();
                    samplerTable = soundFont.samplerTables[bank];
                    if (!Translator.parseSamplerWave(samplerTable, num, dat, soundFont.sounds)) _errorParameterNotValid("#SAMPLER", Std.string(num));
      
                }
                case '#PCMWAVE': {
                    if (num < 0 || num > 255) throw _errorParameterNotValid("#PCMWAVE", Std.string(num));
                    if (soundFont.pcmVoices[num] == null) soundFont.pcmVoices[num] = new SiONVoice();
                    voice = soundFont.pcmVoices[num];
                    if (!(Std.is(voice.waveData,SiOPMWavePCMTable))) voice.waveData = new SiOPMWavePCMTable();
                    pcmTable = cast(voice.waveData,SiOPMWavePCMTable);
                    if (!Translator.parsePCMWave(pcmTable, dat, soundFont.sounds)) _errorParameterNotValid("#PCMWAVE", Std.string(num));
             
                }
                case '#PCMVOICE': {
                    if (num < 0 || num > 255) throw _errorParameterNotValid("#PCMVOICE", Std.string(num));
                    if (soundFont.pcmVoices[num] == null) soundFont.pcmVoices[num] = new SiONVoice();
                    voice = soundFont.pcmVoices[num];
                    if (!Translator.parsePCMVoice(voice, dat, pfx, soundFont.envelopes)) _errorParameterNotValid("#PCMVOICE", Std.string(num));
                    break;
                }
                default:
      
                }
             i++;
}
            
            
           
        }
        
        
        
        private function _parseVCommansSubMML(dat:String) : Void
        {
            var tcmdrex:EReg = ~/(n88|mdx|psg|mck|tss|%[xv])(\d*)(\s*,?\s*(\d?))/g;
            var res:Dynamic, num:Float, i:Int;
            while (res = tcmdrex.match(dat)) {
                switch(Std.string(res[1])) {
                case "%v":
                    i = Std.int(res[2]);
                    soundFont.defaultVelocityMode = (i>=0 && i<SiOPMTable.VM_MAX) ? i : 0;
                    i = (res[4] != "") ? Std.int(res[4]) : 4;
                    soundFont.defaultVCommandShift = (i>=0 && i<8) ? i : 0;
        
                case "%x":
                    i = Std.int(res[2]);
                    soundFont.defaultExpressionMode = (i>=0 && i<SiOPMTable.VM_MAX) ? i : 0;
      
                case "n88" ,"mdx":
                    soundFont.defaultVelocityMode = SiOPMTable.VM_DR32DB;
                    soundFont.defaultExpressionMode = SiOPMTable.VM_DR48DB;
            
                case "psg":
                    soundFont.defaultVelocityMode = SiOPMTable.VM_DR48DB;
                    soundFont.defaultExpressionMode = SiOPMTable.VM_DR48DB;
         
                default: 
                    soundFont.defaultVelocityMode = SiOPMTable.VM_LINEAR;
                    soundFont.defaultExpressionMode = SiOPMTable.VM_LINEAR;
            
                }
            }
        }
        
        
        
        private function _newWaveTable(data: Array<Float>) : SiOPMWaveTable
        {
            var i:Int, imax:Int=data.length, table: Array<Int> = new Array<Int>();
           i=0;
 while( i<imax){ table[i] = SiOPMTable.calcLogTableIndex(data[i]); i++;
}
            return SiOPMWaveTable.alloc(table);
        }
        
        
        private function _errorParameterNotValid(cmd:String, param:String) : Error
        {
            return new Error("SiMMLSequencer error : Parameter not valid. '" + param + "' in " + cmd);
        }
    }


