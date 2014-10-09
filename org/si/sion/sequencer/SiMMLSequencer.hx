





package org.si.sion.sequencer ;
	//import flash.display.ActionScriptVersion;
    import flash.system.System;
    import org.si.utils.SLLint;
    import org.si.sion.sequencer.base.MMLData;
    import org.si.sion.sequencer.base.MMLExecutorConnector;
    import org.si.sion.sequencer.base.MMLSequencer;
    import org.si.sion.sequencer.base.MMLEvent;
    import org.si.sion.sequencer.base.MMLSequenceGroup;
    import org.si.sion.sequencer.base.MMLSequence;
    import org.si.sion.sequencer.base.MMLParser;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.module.SiOPMModule;
    import org.si.sion.module.SiOPMChannelParam;
    import org.si.sion.module.SiOPMWaveSamplerTable;
    import org.si.sion.module.SiOPMWavePCMTable;
    import org.si.sion.utils.Translator;
	//import flash.utils.RegExp;
	import flash.errors.Error;
    
    
    
    class SiMMLSequencer extends MMLSequencer
    {
        
        
        
        
    
    
        static private var PARAM_MAX:Int = 16;                
        static private var MACRO_SIZE:Int = 26;               
        static private var DEFAULT_MAX_TRACK_COUNT:Int = 128; 
        
        
        
        
    
    
        
        public var tracks: Array<SiMMLTrack>;
        
        
        public var _maxTrackCount:Int;
        
        private var _table:SiMMLTable;  
        
        private var _callbackEventNoteOn:Dynamic = null;   
        private var _callbackEventNoteOff:Dynamic = null;  
        private var _callbackTempoChanged:Dynamic = null;  
        private var _callbackTimer:Dynamic = null;         
        private var _callbackBeat:Dynamic = null;          
        private var _callbackParseSysCmd:Dynamic = null;   
        
        private var _module:SiOPMModule;                
        private var _connector:MMLExecutorConnector;    
        private var _currentTrack:SiMMLTrack;           
        private var _macroStrings: Array<String>;      
        private var _flagMacroExpanded:Int;            
        private var _envelopEventID:Int;                
        private var _macroExpandDynamic:Bool;        
        private var _enableChangeBPM:Bool;           
        
        private var _p: Array<Int> = new Array<Int>();  
        private var _internalTableIndex:Int = 0;               
        private var _freeTracks: Array<SiMMLTrack>;                
        private var _isSequenceFinished:Bool;                    
        
        private var _title:String;                      
        private var _processedSampleCount:Int;          
        
        
        
        
    
    
        
        public function isReadyToProcess() : Bool { return (tracks.length>0); }
        
        
        public function title() : String { return _title; }
        
        
        public function processedSampleCount() : Int { return _processedSampleCount; }
        
        
        public function isFinished() : Bool {
            if (!_isSequenceFinished) return false;
            for (trk in tracks) { if (!trk.isFinished()) return false; }
            return true;
        }

        
        public function isSequenceFinished() : Bool { return _isSequenceFinished; }
        
        
        public function isEnableChangeBPM() : Bool { return _enableChangeBPM; }

        
        public function callbackOnParsingSystemCommand(func:Dynamic) : Void { _callbackParseSysCmd = func; }

        
        public function streamWritingBeat() : Int { return Std.int(_globalBeat16); }
        
        public function streamWritingPositionResidue() : Int { return _globalBufferIndex; }
        
        
        public function currentTrack() : SiMMLTrack { return _currentTrack; }
        
         
        public function _setBeatCallbackFilter(filter:Int) : Void { _onBeatCallbackFilter = filter; }
        
        
         public function _setTimerCallback(func:Dynamic) : Void { _callbackTimer = func; }
        
        
         public function _setBeatCallback(func:Dynamic) : Void { _callbackBeat = func; }
        
        
        
        
    
    
        
		 public function new(module:SiOPMModule, eventTriggerOn:Dynamic, eventTriggerOff:Dynamic, tempoChanged:Dynamic)
        {
            super();
            
            var i:Int;
            
            
            _table = SiMMLTable.instance();
            _module = module;
            tracks = new Array<SiMMLTrack>();
            _freeTracks = new Array<SiMMLTrack>();
            _processedSampleCount = 0;
            _connector = new MMLExecutorConnector();
            _macroStrings  = new Array<String> ();
            _callbackEventNoteOn = eventTriggerOn;
            _callbackEventNoteOff = eventTriggerOff;
            _callbackTempoChanged = tempoChanged;
            _currentTrack = null;
           _maxTrackCount = DEFAULT_MAX_TRACK_COUNT;
            _isSequenceFinished = true;
            
            
            newMMLEventListener('k',    _onDetune);
            newMMLEventListener('kt',   _onKeyTrans);
            newMMLEventListener('!@kr', _onRelativeDetune);
            
            
            newMMLEventListener('@mask', _onEventMask);
            setMMLEventListener(MMLEvent.QUANT_RATIO,  _onQuantRatio);
            setMMLEventListener(MMLEvent.QUANT_COUNT,  _onQuantCount);
            
            
            newMMLEventListener('p',  _onPan);
            newMMLEventListener('@p', _onFinePan);
            newMMLEventListener('@f', _onFilter);
            newMMLEventListener('x',  _onExpression);
            setMMLEventListener(MMLEvent.VOLUME,       _onVolume);
            setMMLEventListener(MMLEvent.VOLUME_SHIFT, _onVolumeShift);
            setMMLEventListener(MMLEvent.FINE_VOLUME,  _onMasterVolume);
            newMMLEventListener('%v',  _onVolumeSetting);
            newMMLEventListener('%x',  _onExpressionSetting);
            newMMLEventListener('%f',  _onFilterMode);

            
            newMMLEventListener('@clock', _onClock);
            newMMLEventListener('@al', _onAlgorism);
            newMMLEventListener('@fb', _onFeedback);
            newMMLEventListener('@r',  _onRingModulation);
            setMMLEventListener(MMLEvent.MOD_TYPE,    _onModuleType);
            setMMLEventListener(MMLEvent.INPUT_PIPE,  _onInput);
            setMMLEventListener(MMLEvent.OUTPUT_PIPE, _onOutput);
            newMMLEventListener('%t',  _setEventTrigger);
            newMMLEventListener('%e',  _dispatchEvent);
            
            
            newMMLEventListener('i',   _onSlotIndex);
            newMMLEventListener('@rr', _onOpeReleaseRate);
            newMMLEventListener('@tl', _onOpeTotalLevel);
            newMMLEventListener('@ml', _onOpeMultiple);
            newMMLEventListener('@dt', _onOpeDetune);
            newMMLEventListener('@ph', _onOpePhase);
            newMMLEventListener('@fx', _onOpeFixedNote);
            newMMLEventListener('@se', _onOpeSSGEnvelop);
            newMMLEventListener('@er', _onOpeEnvelopReset);
            setMMLEventListener(MMLEvent.MOD_PARAM, _onOpeParameter);
            newMMLEventListener('s',   _onSustain);
            
            
            newMMLEventListener('@lfo', _onLFO);
            newMMLEventListener('mp', _onPitchModulation);
            newMMLEventListener('ma', _onAmplitudeModulation);
            
            
            newMMLEventListener('@fps', _onEnvelopFPS);
            _envelopEventID = 
            newMMLEventListener('@@', _onToneEnv);
            newMMLEventListener('na', _onAmplitudeEnv);
            newMMLEventListener('np', _onPitchEnv);
            newMMLEventListener('nt', _onNoteEnv);
            newMMLEventListener('nf', _onFilterEnv);
            newMMLEventListener('_@@', _onToneReleaseEnv);
            newMMLEventListener('_na', _onAmplitudeReleaseEnv);
            newMMLEventListener('_np', _onPitchReleaseEnv);
            newMMLEventListener('_nt', _onNoteReleaseEnv);
            newMMLEventListener('_nf', _onFilterReleaseEnv);
            newMMLEventListener('!na', _onAmplitudeEnvTSSCP);
            newMMLEventListener('po',  _onPortament);
            
            
            _registerProcessEvent();
            
            setMMLEventListener(MMLEvent.DRIVER_NOTE, _onDriverNoteOn);
            setMMLEventListener(MMLEvent.REGISTER,    _onRegisterUpdate);

            
            _module.initOperatorParam.ar     = 63;
            _module.initOperatorParam.dr     = 0;
            _module.initOperatorParam.sr     = 0;
            _module.initOperatorParam.rr     = 28;
            _module.initOperatorParam.sl     = 0;
            _module.initOperatorParam.tl     = 0;
            _module.initOperatorParam.ksr    = 0;
            _module.initOperatorParam.ksl    = 0;
            _module.initOperatorParam.fmul   = 128;
            _module.initOperatorParam.dt1    = 0;
            _module.initOperatorParam.detune = 0;
            _module.initOperatorParam.ams    = 1;
            _module.initOperatorParam.phase  = 0;
            _module.initOperatorParam.fixedPitch = 0;
            _module.initOperatorParam.modLevel   = 5;
            _module.initOperatorParam.setPGType(SiOPMTable.PG_SQUARE);
            
            
            setting.defaultBPM        = 120;
            setting.defaultLValue     = 4;
            setting.defaultQuantRatio = 6;
            setting.maxQuantRatio     = 8;
            setting.defaultOctave( 5);
            setting.maxVolume         = 512;
            setting.defaultVolume     = 256;
            setting.maxFineVolume     = 128;
            setting.defaultFineVolume = 64;
        }
        
        
        
        
    
    
        
        private function _freeAllTracks() : Void
        {
            for (trk in tracks) _freeTracks.push(trk);
			tracks.splice(0, tracks.length);
        }
        
        
        
        public function  _resetAllTracks() : Void
        {
            for (trk in tracks) {
                trk._reset(0);
                trk.velocity   ( setting.defaultVolume);
                trk.quantRatio = setting.defaultQuantRatio / setting.maxQuantRatio;
                trk.quantCount = calcSampleCount(setting.defaultQuantCount);
                trk.channel.masterVolume (setting.defaultFineVolume);
            }
            _processedSampleCount = 0;
            _isSequenceFinished = (tracks.length == 0);
        }
        
        
        
        public function  _stopSequence() : Void
        {
            _isSequenceFinished = true;
        }
        
        
        
        
    
    
        
        public function  _findActiveTrack(internalTrackID:Int, delay:Int=-1) : SiMMLTrack
        {
            var result:Array<Dynamic> = [];
            for (trk in tracks) {
                if (trk._internalTrackID == internalTrackID && trk.isActive()) {
                    if (delay == -1) return trk;
                    var diff:Int = trk.trackStartDelay() - delay;
                    if (-8<diff && diff<8) return trk;
                }
            }
            return null;
        }
        
        
        
        public function  _newControlableTrack(internalTrackID:Int=0, isDisposable:Bool=true) : SiMMLTrack
        {
            var i:Int, trk:SiMMLTrack;
           i=tracks.length-1;
 while( i>=0){
                trk = tracks[i];
                if (!trk.isActive()) return _initializeTrack(trk, internalTrackID, isDisposable);
             i--;
}
            
            if (tracks.length < _maxTrackCount) {
				var tmpTrk:SiMMLTrack =  _freeTracks.pop() ;
                trk = (tmpTrk != null) ? tmpTrk : new SiMMLTrack();
                trk._trackNumber = tracks.length;
                tracks.push(trk);
            } else {
                trk = _findLowestPriorityTrack();
                if (trk == null) return null;
            }
            
            return _initializeTrack(trk, internalTrackID, isDisposable);
        }
        
        
        
        private function _initializeTrack(track:SiMMLTrack, internalTrackID:Int, isDisposable:Bool) : SiMMLTrack
        {
            track._initialize(null, 60, (internalTrackID>=0) ? internalTrackID : 0, _callbackEventNoteOn, _callbackEventNoteOff, isDisposable);
            track._reset(_globalBufferIndex);
            track.channel.masterVolume ( setting.defaultFineVolume);
            return track;
        }
        
        
        
        private function _findLowestPriorityTrack() : SiMMLTrack
        {
            var i:Int, p:Int, index:Int = 0, maxPriority:Int=0;
           i=tracks.length-1;
 while( i>=0){
                p = tracks[i].priority();
                if (p >= maxPriority) {
                    index = i;
                    maxPriority = p;
                }
             i--;
}
            return (maxPriority == 0) ? null : tracks[index];
        }
        
        
        
        
    
    
        
        override public function prepareCompile(data:MMLData, mml:String) : Bool
        {
            _freeAllTracks();
            return super.prepareCompile(data, mml);
        }
        
        
        
        
    
    
        
        override public function _prepareProcess(data:MMLData, sampleRate:Int, bufferLength:Int) : Void
        {
            
            _freeAllTracks();
            _processedSampleCount = 0;
            _enableChangeBPM = true;
            
            
            super._prepareProcess(data, sampleRate, bufferLength);
            
            if (mmlData != null) {
                
                var trk:SiMMLTrack,
                    seq:MMLSequence = mmlData.sequenceGroup.headSequence(),
                    idx:Int = 0, internalTrackID:Int;

                while (seq != null) {
                    if (seq.isActive) {
						var tmpTrk:SiMMLTrack = _freeTracks.pop();
                        trk = (tmpTrk != null) ? tmpTrk : new SiMMLTrack();
                        internalTrackID = idx | SiMMLTrack.MML_TRACK;
                        tracks[idx] = trk._initialize(seq, mmlData.defaultFPS, internalTrackID, _callbackEventNoteOn, _callbackEventNoteOff, true);
                        tracks[idx]._trackNumber = idx;
                        idx++;
                    }
                    seq = seq.nextSequence();
                }
            }

            
            _resetAllTracks();
        }
        

        
        override public function _process() : Void
        {
            var bufferingLength:Int, len:Int, trk:SiMMLTrack, data:SiMMLData, finished:Bool;
            
            
            for (trk in tracks) trk.channel.resetChannelBufferStatus();
            
            
            finished = true;
            startGlobalSequence();
            do {
                bufferingLength = executeGlobalSequence();
                _enableChangeBPM = false;
                for  (trk in tracks) {
                    _currentTrack = trk;
                    len = trk._prepareBuffer(bufferingLength);
                    _bpm = (trk._bpmSetting() != null) ? trk._bpmSetting() :   _changableBPM;
                    finished = processMMLExecutor(trk.executor, len) && finished;
                }
                _enableChangeBPM = true;
            } while (!isEndGlobalSequence());
            
            _bpm = _changableBPM;
            _currentTrack = null;
            _processedSampleCount += _module.bufferLength();
            
            _isSequenceFinished = finished;
        }
        

        
        public function dummyProcess(sampleCount:Int) : Void
        {
            var count:Int, bufCount:Int = Std.int(sampleCount / _module.bufferLength());
            if (bufCount == 0) return;
            
            
            _registerDummyProcessEvent();
            
            
           count=0;
 while( count<bufCount){ _process(); count++;
}
            
            
            _registerProcessEvent();
        }
        
        
        
        
    
    
        
        public function calcSampleLength(beat16:Float) : Float {
            return beat16 * _bpm.samplePerBeat16;
        }
        
        
        
        public function calcSampleDelay(sampleOffset:Int=0, beat16Offset:Float=0, quant:Float=0) : Float {
            if (quant == 0) return sampleOffset + beat16Offset * _bpm.samplePerBeat16;
            var iBeats:Int = Std.int(sampleOffset * _bpm.beat16PerSample + _globalBeat16 + beat16Offset + 0.9999847412109375); 
            if (quant != 1) iBeats = Std.int((Std.int ((iBeats+quant-1) / quant)) * quant);
            return (iBeats - _globalBeat16) * _bpm.samplePerBeat16;
        }
        
        
        
        
    
    
    
    
    
        
        override function onBeforeCompile(mml:String) : String
        {
            var codeA:Int = "A".charCodeAt(0);
            var codeH:Int = "-".charCodeAt(0);
            var comrex:EReg = new EReg("/\\*.*?\\*/|//.*?[\\r\\n]+", "gms");
			
            var reprex:EReg = new EReg("!\\[(\\d*)(.*?)(!\\|(.*?))?!\\](\\d*)", "gms");
            var seqrex:EReg = new EReg("[ \\t\\r\\n]*(#([A-Z@\\-]+)(\\+=|=)?)?([^;{]*({.*?})?[^;]*);", "gms"); 
            var midrex:EReg = new EReg("([A-Z])?(-([A-Z])?)?", "g");
            var expmml:String, res:Dynamic, midres:Dynamic, c:Int, i:Int, imax:Int, str1:String, str2:String, concat:Bool, startID:Int, endID:Int;

            
            _resetParserParameters();
            
            
            mml += "\n";
            mml = comrex.replace(mml, "");
            
            
            i = mml.length;
            do {
                if (i == 0) return null;
                str1 = mml.charAt(--i);
            } while (" \t\r\n".indexOf(str1) != -1);
            mml = mml.substring(0, i+1);
            if (str1 != ";") mml += ";";

            
            expmml = "";
            res = seqrex.match(mml);
            while (res) {
                
                if (res[1] == null) {
                    expmml += _expandMacro(res[4]) + ";";
                } else 
                
                
                if (res[3] == null) {
                    if (Std.string(res[2]) == 'END') {
                        
                        break;
                    } else
                    
                    if (!_parseSystemCommandBefore(Std.string(res[1]), res[4])) {
                        
                        expmml += Std.string(res[0]);
                    }
                } else 
                
                
                {
                    str2 = Std.string(res[2]);
                    concat = (res[3] == "+=");
                    
                    //midrex.lastIndex = 0;
                    midres = midrex.match(str2);
                    while (midres[0]) {
                        startID = (midres[1]) ? (Std.string(midres[1]).charCodeAt(0) - codeA) : 0;
                        endID   = (midres[2]) ? ((midres[3]) ? (Std.string(midres[3]).charCodeAt(0)-codeA) : MACRO_SIZE-1) : startID;
                       i=startID;
 while( i<=endID){
                            if (concat) { _macroStrings[i] += (_macroExpandDynamic) ? Std.string(res[4]) : _expandMacro(res[4]); }
                            else        { _macroStrings[i]  = (_macroExpandDynamic) ? Std.string(res[4]) : _expandMacro(res[4]); }
                         i++;
}
                        midres = midrex.match(str2);
                    }
                }
                
                
                res = seqrex.match(mml);
            }
			
			
			
			//TODO : HAXE PORT of this flash specific function, see original code in action before
            reprex.map(expmml,function(er:EReg) : String {
                   /* imax = (arguments[1].length > 0) ? (Std.int (arguments[1])-1) : (arguments[5].length > 0) ? (Std.int (arguments[5])-1) : 1;
                    if (imax > 256) imax = 256;
                    str2 = arguments[2];
                    if (arguments[3]) str2 += arguments[4];
                   i=0; str1="";
					 while( i<imax){ str1 += str2;  i++;
					}
                    str1 += arguments[2];*/
					
					
                   // return str1;
				   return "";
				   
				   
                }
            );
                
            
            
            return expmml;
        }
        
        
        
        override function onAfterCompile(seqGroup:MMLSequenceGroup) : Void
        {
            
            var seq:MMLSequence = seqGroup.headSequence();
            while (seq != null) {
                if (seq.isSystemCommand()) {
                    
                    seq = _parseSystemCommandAfter(seqGroup, seq);
                } else {
                    
                    seq = seq.nextSequence();
                }
            }
        }
        
        
        
        override function onTableParse(prev:MMLEvent, table:String) : Void
        {
            if (prev.id < _envelopEventID || _envelopEventID+10 < prev.id) throw _errorInternalTable();
            
            var rex:EReg = ~/\{([^}]*)\}(.*)/ms;
            var res:Dynamic = rex.match(table);
            var dat:String = Std.string(res[1]);
            var pfx:String = Std.string(res[2]);
            var env:SiMMLEnvelopTable = new SiMMLEnvelopTable().parseMML(dat, pfx);
            if (env.head == null) throw _errorParameterNotValid("{..}", dat);
            cast(mmlData, SiMMLData).setEnvelopTable(_internalTableIndex, env);
            prev.data = _internalTableIndex;
            _internalTableIndex--;

        }
        
        
        
        override function onProcess(sampleLength:Int, e:MMLEvent) : Void
        {
            _currentTrack._buffer(sampleLength);
        }
        
        
        
        override function onTempoChanged(changingRatio:Float) : Void
        {
            for (trk in tracks) {
                if (trk._bpmSetting == null) trk.executor._onTempoChanged(changingRatio);
            }
            if (_callbackTempoChanged != null) _callbackTempoChanged(_globalBufferIndex);
        }

        
        
        override function onTimerInterruption() : Void
        {
            if (_callbackTimer != null) _callbackTimer();
        }
        
        
        
        override function onBeat(delaySamples:Int, beatCounter:Int) : Void
        {
            if (_callbackBeat != null) _callbackBeat(delaySamples, beatCounter);
            
        }
        
        
        
        
    
    
        
        private function _resetParserParameters() : Void
        {
            var i:Int;
            
            
            _internalTableIndex = 511;
            _title = "";
            setting.octavePolarization = 1;
            setting.volumePolarization = 1;
            setting.defaultQuantRatio  = 6;
            setting.maxQuantRatio      = 8;
            _macroExpandDynamic = false;
            MMLParser.keySign("C");
           i=0;
 while( i<_macroStrings.length){
                _macroStrings[i] = "";
             i++;
}
        }
        
        
        
        private function _expandMacro(m:Dynamic, recursive:Bool=false) : String
        {
            if (!recursive) _flagMacroExpanded = 0;
            if (m == null) return "";
            var charCodeA:Int = "A".charCodeAt(0);
			
			
			
			return "haxe not supported";
			
			//Haxe don't have a proper replacement for the as3 string.replace function, need to recode this function
			/*var eregtmp:EReg = ~/([A-Z])(\(([\-\d]+)\))?/g;
			
			return eregtmp.map(Std.string(m),function(params:Array<Dynamic>) : String {
                    var t:Int, i:Int, f:Int;
                    i = Std.string(params[1]).charCodeAt(0) - charCodeA;
                    f = 1 << i;
                    if (_flagMacroExpanded && f) throw _errorCircularReference(m);
                    if (_macroStrings[i]) {
                        if (params[2].length > 0) {
                            if (params[3].length > 0) t = Std.int(params[3]);
                            return "!@ns" + Std.string(t) + ((_macroExpandDynamic) ? _expandMacro(_macroStrings[i], true) : _macroStrings[i]) + "!@ns" + Std.string(-t);
                        }
                        return (_macroExpandDynamic) ? _expandMacro(_macroStrings[i], true) : _macroStrings[i];
                    }
                    return "";
                });*/
        }
        
        
        
        
    
    
        
        private function _parseSystemCommandBefore(cmd:String, prm:String) : Bool
        {
            var i:Int, param:SiOPMChannelParam, env:SiMMLEnvelopTable, commandObject:Dynamic;

            var rex:EReg = ~/\s*(\d*)\s*(\{(.*?)\})?(.*)/ms;
            var res:Dynamic = rex.match(prm);
            
            
            var num:Int        = Std.int(res[1]),                       
                noData:Bool = (res[2] == null),             
                dat:String     = (noData) ? "" : Std.string(res[3]),    
                pfx:String     = Std.string(res[4]);
				
			var __parseToneParam:Dynamic =  function (func:Dynamic) : Void {
                param = cast(mmlData, SiMMLData)._getSiOPMChannelParam(num);
                func(param, dat);
                if (pfx.length > 0) __parseInitSequence(param, pfx);
            }

            
            switch (cmd) {
                
                case '#@':    { __parseToneParam(Translator.parseParam);    return true; }
                case '#OPM@': { __parseToneParam(Translator.parseOPMParam); return true; }
                case '#OPN@': { __parseToneParam(Translator.parseOPNParam); return true; }
                case '#OPL@': { __parseToneParam(Translator.parseOPLParam); return true; }
                case '#OPX@': { __parseToneParam(Translator.parseOPXParam); return true; }
                case '#MA@':  { __parseToneParam(Translator.parseMA3Param); return true; }
                case '#AL@':  { __parseToneParam(Translator.parseALParam);  return true; }
                    
                
                case '#TITLE': { mmlData.title = (noData) ? pfx : dat; return true; }
                case '#FPS':   { mmlData.defaultFPS = (num>0) ? num : ((noData) ? 60 : Std.parseInt(dat)); return true; }
                case '#SIGN':  { MMLParser.keySign((noData) ? pfx : dat); return true; }
                case '#MACRO': { 
                    if (noData) dat = pfx; 
                         if (dat == "dynamic") _macroExpandDynamic = true;
                    else if (dat == "static")  _macroExpandDynamic = false;
                    else throw _errorParameterNotValid("#MACRO", dat);
                    return true;
                }
                case '#QUANT': {
                    if (num>0) {
                        setting.maxQuantRatio     = num;
                        setting.defaultQuantRatio = Std.int(num*0.75);
                    }
                    return true;
                }
                case '#TMODE': {
                    _parseTCommansSubMML(dat);
                    return true;
                }
                case '#VMODE': {
                    _parseVCommansSubMML(dat);
                    return true;
                }
                case '#REV': {
                    if (noData) dat = pfx;
                    if (dat == "") {
                        setting.octavePolarization = -1;
                        setting.volumePolarization = -1;
                    } else 
                    if (dat == "octave") {
                        setting.octavePolarization = -1;
                    } else 
                    if (dat == "volume") {
                        setting.volumePolarization = -1;
                    } else {
                        throw _errorParameterNotValid("#REVERSE", dat);
                    }
                    return true;
                }

                
                case '#TABLE': {
                    if (num < 0 || num > 254) throw _errorParameterNotValid("#TABLE", Std.string(num));
                    env = new SiMMLEnvelopTable().parseMML(dat, pfx);
                    if (env.head == null) throw _errorParameterNotValid("#TABLE", dat);
                    cast(mmlData, SiMMLData).setEnvelopTable(num, env);
                    return true;
                }
                case '#WAV': {
                    if (num < 0 || num > 255) throw _errorParameterNotValid("#WAV", Std.string(num));
                    cast(mmlData, SiMMLData).setWaveTable(num, Translator.parseWAV(dat, pfx));
                    return true;
                }
                case '#WAVB': {
                    if (num < 0 || num > 255) throw _errorParameterNotValid("#WAVB", Std.string(num));
                    cast(mmlData, SiMMLData).setWaveTable(num, Translator.parseWAVB((noData) ? pfx : dat));
                    return true;
                }
                
                
                case '#SAMPLER': {
                    if (num < 0 || num > 255) throw _errorParameterNotValid("#SAMPLE", Std.string(num));
                    __setSamplerWave(num, dat);
                    return true;
                }
                case '#PCMWAVE': {
                    if (num < 0 || num > 255) throw _errorParameterNotValid("#PCMWAVE", Std.string(num));
                    __setPCMWave(num, dat);
                    return true;
                }
                case '#PCMVOICE': {
                    if (num < 0 || num > 255) throw _errorParameterNotValid("#PCMVOICE", Std.string(num));
                    __setPCMVoice(num, dat, pfx);
                    return true;
                }
                    
                
                case '#FM':
                    return false;
                
                
                case '#WAVEXP':
                case '#PCMB':
                case '#PCMC':
                    throw _errorSystemCommand("#" + cmd +"is not supported currently.");
                    
                
                default:
                    commandObject = {command:cmd, number:num, content:dat, postfix:pfx};
                    if (_callbackParseSysCmd == null || !_callbackParseSysCmd(cast(mmlData, SiMMLData), commandObject)) {
                        mmlData.systemCommands().push(commandObject);
                    }
                    return true;
            }
            
            throw _errorUnknown("_parseSystemCommandBefore()");
            
            
            
        }
        
        
        private function _parseTCommansSubMML(dat:String) : Void
        {
            var tcmdrex:EReg = ~/(unit|timerb|fps)=?([\d.]*)/;
            var res:Dynamic = tcmdrex.match(dat), num:Float;
            num = Std.parseFloat(res[2]);
            if (Math.isNaN(num)) num = 0;
            switch(Std.string(res[1])) {
            case "unit":
                mmlData.tcommandMode = MMLData.TCOMMAND_BPM;
                mmlData.tcommandResolution = (num>0) ? 1 / num : 1;
        
            case "timerb":
                mmlData.tcommandMode = MMLData.TCOMMAND_TIMERB;
                mmlData.tcommandResolution = ((num>0) ? num : 4000) * 1.220703125;
     
            case "fps":
                mmlData.tcommandMode = MMLData.TCOMMAND_FRAME;
                mmlData.tcommandResolution = (num>0) ? num * 60 : 3600;
             
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
                    mmlData.defaultVelocityMode = (i>=0 && i<SiOPMTable.VM_MAX) ? i : 0;
                    i = (res[4] != "") ? Std.int(res[4]) : 4;
                    mmlData.defaultVCommandShift = (i>=0 && i<8) ? i : 0;
           
                case "%x":
                    i = Std.int(res[2]);
                    mmlData.defaultExpressionMode = (i>=0 && i<SiOPMTable.VM_MAX) ? i : 0;
               
                case "n88","mdx":
                    mmlData.defaultVelocityMode = SiOPMTable.VM_DR32DB;
                    mmlData.defaultExpressionMode = SiOPMTable.VM_DR48DB;
                 
                case "psg":
                    mmlData.defaultVelocityMode = SiOPMTable.VM_DR48DB;
                    mmlData.defaultExpressionMode = SiOPMTable.VM_DR48DB;
                 
                default: 
                    mmlData.defaultVelocityMode = SiOPMTable.VM_LINEAR;
                    mmlData.defaultExpressionMode = SiOPMTable.VM_LINEAR;
                   
                }
            }
        }
        
        
        private function _parseSystemCommandAfter(seqGroup:MMLSequenceGroup, syscmd:MMLSequence) : MMLSequence
        {
            var letter:String = syscmd.getSystemCommand();
            var rex:EReg = ~/#(FM)[{ \\t\\r\\n]*([^}]*)/;
            var res:Dynamic = rex.match(letter);
            
            
            var seq:MMLSequence = syscmd._removeFromChain();
            
            
            if (res) {
                switch (res[1]) {
                case 'FM':
                    if (res[2] == null) throw _errorSystemCommand(letter);
                    _connector.parse(res[2]);
                    seq = _connector.connect(seqGroup, seq);
                   
                default:
                    throw _errorSystemCommand(letter);
                  
                }
            }
            
            return seq.nextSequence();
        }
        
        
        
        
    
    
        
        private function __parseInitSequence(param:SiOPMChannelParam, mml:String) : Void
        {
            var seq:MMLSequence = param.initSequence;
            var prev:MMLEvent, e:MMLEvent;
            
            MMLParser.prepareParse(setting, mml);
            e = MMLParser.parse();
            
            if (e != null && e.next != null) {
                seq._cutout(e);
               prev = seq.headEvent;
 while( prev.next != null){
                    e = prev.next;
                    
                    if (e.length != 0) throw _errorInitSequence(mml);
                    
                    if (e.id == MMLEvent.MOD_TYPE || e.id == MMLEvent.MOD_PARAM) throw _errorInitSequence(mml);
                    
                    if (e.id == MMLEvent.TABLE_EVENT) {
                        callOnTableParse(prev);
                        e = prev;
                    }
                 prev = e;
}
            }
        }
        
        
        private function __setSamplerWave(index:Int, dat:String) : Void {
            if (SiOPMTable.instance().soundReference == null) return;
            var bank:Int = (index>>SiOPMTable.NOTE_BITS) & (SiOPMTable.SAMPLER_TABLE_MAX-1);
            index &= (SiOPMTable.NOTE_TABLE_SIZE-1);
            var table:SiOPMWaveSamplerTable = cast(mmlData, SiMMLData).samplerTables[bank];
            Translator.parseSamplerWave(table, index, dat, SiOPMTable.instance().soundReference);
        }
        
        
        private function __setPCMWave(index:Int, dat:String) : Void {
            if (SiOPMTable.instance().soundReference == null) return;
            var table:SiOPMWavePCMTable = cast(cast(mmlData, SiMMLData)._getPCMVoice(index).waveData,SiOPMWavePCMTable);
            if (table != null) Translator.parsePCMWave(table, dat, SiOPMTable.instance().soundReference);
        }
        
        
        private function __setPCMVoice(index:Int, dat:String, pfx:String) : Void {
            var voice:SiMMLVoice = cast(mmlData, SiMMLData)._getPCMVoice(index);
            if (voice != null) Translator.parsePCMVoice(voice, dat, pfx, cast(mmlData, SiMMLData).envelopes);
        }
        
        
        
        
    
    
        
        private function _registerProcessEvent() : Void {
            setMMLEventListener(MMLEvent.NOP,       _default_onNoOperation);
            setMMLEventListener(MMLEvent.PROCESS,   _default_onProcess);
            setMMLEventListener(MMLEvent.REST,      _onRest);
            setMMLEventListener(MMLEvent.NOTE,      _onNote);
            setMMLEventListener(MMLEvent.SLUR,      _onSlur);
            setMMLEventListener(MMLEvent.SLUR_WEAK, _onSlurWeak);
            setMMLEventListener(MMLEvent.PITCHBEND, _onPitchBend);
        }
        
        
        private function _registerDummyProcessEvent() : Void {
            setMMLEventListener(MMLEvent.NOP,       _nop);
            setMMLEventListener(MMLEvent.PROCESS,   _dummy_onProcess);
            setMMLEventListener(MMLEvent.REST,      _dummy_onProcessEvent);
            setMMLEventListener(MMLEvent.NOTE,      _dummy_onProcessEvent);
            setMMLEventListener(MMLEvent.SLUR,      _dummy_onProcessEvent);
            setMMLEventListener(MMLEvent.SLUR_WEAK, _dummy_onProcessEvent);
            setMMLEventListener(MMLEvent.PITCHBEND, _dummy_onProcessEvent);
        }
        
        
        private function _dummy_onProcessEvent(e:MMLEvent) : MMLEvent
        {
            return currentExecutor._publishProessingEvent(e);
        }
        
        
    
    
        
        private function _onRest(e:MMLEvent) : MMLEvent
        {
            _currentTrack._onRestEvent();
            return currentExecutor._publishProessingEvent(e);
        }
        
        
        private function _onNote(e:MMLEvent) : MMLEvent
        {
            _currentTrack._onNoteEvent(e.data, calcSampleCount(e.length));
            return currentExecutor._publishProessingEvent(e);
        }
        
        
        private function _onDriverNoteOn(e:MMLEvent) : MMLEvent
        {
            _currentTrack.setNote(e.data, calcSampleCount(e.length));
            return currentExecutor._publishProessingEvent(e);
        }
        
        
        private function _onSlur(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_SLUR) != 0) {
                _currentTrack._changeNoteLength(calcSampleCount(e.length));
            } else {
                _currentTrack._onSlur();
            }
            return currentExecutor._publishProessingEvent(e);
        }
    
        
        private function _onSlurWeak(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_SLUR) != 0) {
                _currentTrack._changeNoteLength(calcSampleCount(e.length));
            } else {
                _currentTrack._onSlurWeak();
            }
            return currentExecutor._publishProessingEvent(e);
        }
        
        
        private function _onPitchBend(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_SLUR) != 0) {
                _currentTrack._changeNoteLength(calcSampleCount(e.length));
            } else {
                if (e.next == null || e.next.id != MMLEvent.NOTE) return e.next;  
                var term:Int = calcSampleCount(e.length);                         
                _currentTrack._onPitchBend(e.next.data, term);                    
            }
            return currentExecutor._publishProessingEvent(e);
        }
        
        
    
    
        
        private function _onQuantRatio(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_QUANTIZE) != 0) return e.next;  
            _currentTrack.quantRatio = e.data / setting.maxQuantRatio;              
            return e.next;
        }
        
        
        private function _onQuantCount(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            _p[0] = (_p[0] == -2147483648 ) ? 0 : (_p[0] * Std.int(setting.resolution / setting.maxQuantCount));
            _p[1] = (_p[1] == -2147483648 ) ? 0 : (_p[1] * Std.int(setting.resolution / setting.maxQuantCount));
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_QUANTIZE) != 0) return e.next;  
            _currentTrack.quantCount = calcSampleCount(_p[0]);           
            _currentTrack.keyOnDelay = calcSampleCount(_p[1]);           
            return e.next;
        }

        
        private function _onEventMask(e:MMLEvent) : MMLEvent
        {
            _currentTrack.eventMask = (e.data != -2147483648 ) ? e.data : 0;
            return e.next;
        }

        
        private function _onDetune(e:MMLEvent) : MMLEvent
        {
            _currentTrack.pitchShift = (e.data == -2147483648 ) ? 0 : e.data;
            return e.next;
        }
    
        
        private function _onKeyTrans(e:MMLEvent) : MMLEvent
        {
            _currentTrack.noteShift = (e.data == -2147483648 ) ? 0 : e.data;
            return e.next;
        }
    
        
        private function _onRelativeDetune(e:MMLEvent) : MMLEvent
        {
            _currentTrack.pitchShift += (e.data == -2147483648 ) ? 0 : e.data;
            return e.next;
        }

    
    
    
        
        private function _onEnvelopFPS(e:MMLEvent) : MMLEvent
        {
            var frame:Int = (e.data == -2147483648  || e.data == 0) ? 60 : e.data;
            if (frame > 1000) frame = 1000;
            _currentTrack.setEnvelopFPS(frame);
            return e.next;
        }
        
        
        private function _onToneEnv(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if((_currentTrack.eventMask & SiMMLTrack.MASK_ENVELOP) != 0) return e.next;   
            if (_p[1] == -2147483648 ) _p[1] = 1;
            var idx:Int = (_p[0]>=0 && _p[0]<255) ? _p[0] : -1;
            _currentTrack.setToneEnvelop(1, _table.getEnvelopTable(idx), _p[1]);
            return e.next;
        }
        
        
        private function _onAmplitudeEnv(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if((_currentTrack.eventMask & SiMMLTrack.MASK_ENVELOP) != 0) return e.next;   
            if (_p[1] == -2147483648 ) _p[1] = 1;
            var idx:Int = (_p[0]>=0 && _p[0]<255) ? _p[0] : -1;
            _currentTrack.setAmplitudeEnvelop(1, _table.getEnvelopTable(idx), _p[1]);
            return e.next;
        }
        
        
        private function _onAmplitudeEnvTSSCP(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if((_currentTrack.eventMask & SiMMLTrack.MASK_ENVELOP) != 0) return e.next;   
            if (_p[1] == -2147483648 ) _p[1] = 1;
            var idx:Int = (_p[0]>=0 && _p[0]<255) ? _p[0] : -1;
            _currentTrack.setAmplitudeEnvelop(1, _table.getEnvelopTable(idx), _p[1], true);
            return e.next;
        }
        
        
        private function _onPitchEnv(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if((_currentTrack.eventMask & SiMMLTrack.MASK_ENVELOP) != 0) return e.next;   
            if (_p[1] == -2147483648 ) _p[1] = 1;
            var idx:Int = (_p[0]>=0 && _p[0]<255) ? _p[0] : -1;
            _currentTrack.setPitchEnvelop(1, _table.getEnvelopTable(idx), _p[1]);
            return e.next;
        }
        
        
        private function _onNoteEnv(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if((_currentTrack.eventMask & SiMMLTrack.MASK_ENVELOP) != 0) return e.next;   
            if (_p[1] == -2147483648 ) _p[1] = 1;
            var idx:Int = (_p[0]>=0 && _p[0]<255) ? _p[0] : -1;
            _currentTrack.setNoteEnvelop(1, _table.getEnvelopTable(idx), _p[1]);
            return e.next;
        }
    
        
        private function _onFilterEnv(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if((_currentTrack.eventMask & SiMMLTrack.MASK_ENVELOP) != 0) return e.next;   
            if (_p[1] == -2147483648 ) _p[1] = 1;
            var idx:Int = (_p[0]>=0 && _p[0]<255) ? _p[0] : -1;
            _currentTrack.setFilterEnvelop(1, _table.getEnvelopTable(idx), _p[1]);
            return e.next;
        }
        
        
        private function _onToneReleaseEnv(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if((_currentTrack.eventMask & SiMMLTrack.MASK_ENVELOP) != 0) return e.next;   
            if (_p[1] == -2147483648 ) _p[1] = 1;
            var idx:Int = (_p[0]>=0 && _p[0]<255) ? _p[0] : -1;
            _currentTrack.setToneEnvelop(0, _table.getEnvelopTable(idx), _p[1]);
            return e.next;
        }
        
        
        private function _onAmplitudeReleaseEnv(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if((_currentTrack.eventMask & SiMMLTrack.MASK_ENVELOP) != 0) return e.next;   
            if (_p[1] == -2147483648 ) _p[1] = 1;
            var idx:Int = (_p[0]>=0 && _p[0]<255) ? _p[0] : -1;
            _currentTrack.setAmplitudeEnvelop(0, _table.getEnvelopTable(idx), _p[1]);
            return e.next;
        }
        
        
        private function _onPitchReleaseEnv(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if((_currentTrack.eventMask & SiMMLTrack.MASK_ENVELOP) != 0) return e.next;   
            if (_p[1] == -2147483648 ) _p[1] = 1;
            var idx:Int = (_p[0]>=0 && _p[0]<255) ? _p[0] : -1;
            _currentTrack.setPitchEnvelop(0, _table.getEnvelopTable(idx), _p[1]);
            return e.next;
        }
        
        
        private function _onNoteReleaseEnv(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if((_currentTrack.eventMask & SiMMLTrack.MASK_ENVELOP) != 0) return e.next;   
            if (_p[1] == -2147483648 ) _p[1] = 1;
            var idx:Int = (_p[0]>=0 && _p[0]<255) ? _p[0] : -1;
            _currentTrack.setNoteEnvelop(0, _table.getEnvelopTable(idx), _p[1]);
            return e.next;
        }
    
        
        private function _onFilterReleaseEnv(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if((_currentTrack.eventMask & SiMMLTrack.MASK_ENVELOP) != 0) return e.next;   
            if (_p[1] == -2147483648 ) _p[1] = 1;
            var idx:Int = (_p[0]>=0 && _p[0]<255) ? _p[0] : -1;
            _currentTrack.setFilterEnvelop(0, _table.getEnvelopTable(idx), _p[1]);
            return e.next;
        }

    
    
    
        
        private function _onFilter(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 10);
            var cut:Int = (_p[0] == -2147483648 ) ? 128 : _p[0],
                res:Int = (_p[1] == -2147483648 ) ?   0 : _p[1],
                ar :Int = (_p[2] == -2147483648 ) ?   0 : _p[2],
                dr1:Int = (_p[3] == -2147483648 ) ?   0 : _p[3],
                dr2:Int = (_p[4] == -2147483648 ) ?   0 : _p[4],
                rr :Int = (_p[5] == -2147483648 ) ?   0 : _p[5],
                dc1:Int = (_p[6] == -2147483648 ) ? 128 : _p[6],
                dc2:Int = (_p[7] == -2147483648 ) ?  64 : _p[7],
                sc :Int = (_p[8] == -2147483648 ) ?  32 : _p[8],
                rc :Int = (_p[9] == -2147483648 ) ? 128 : _p[9];
            _currentTrack.channel.setSVFilter(cut, res, ar, dr1, dr2, rr, dc1, dc2, sc, rc);
            return e.next;
        }
        
        
        private function _onFilterMode(e:MMLEvent) : MMLEvent
        {
            _currentTrack.channel.filterType( e.data );
            return e.next;
        }

        
        private function _onLFO(e:MMLEvent) : MMLEvent
        {
            
            e = e.getParameters(_p, 2);
            if (_p[1] > 7 && _p[1] < 255) { 
                var env:SiMMLEnvelopTable = _table.getEnvelopTable(_p[1]);
                if (env != null) _currentTrack.channel.initializeLFO(-1, env.toVector(256, 0, 255));
                else _currentTrack.channel.initializeLFO(SiOPMTable.LFO_WAVE_TRIANGLE);
            } else {
                _currentTrack.channel.initializeLFO((_p[1] == -2147483648 ) ? SiOPMTable.LFO_WAVE_TRIANGLE : _p[1]);
            }
            _currentTrack.channel.setLFOCycleTime((_p[0] == -2147483648 ) ? 333 : _p[0]*1000/60);
            return e.next;
        }
        
        
        private function _onPitchModulation(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 4);
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_MODULATE) != 0) return e.next;   
            if (_p[0] == -2147483648 ) _p[0] = 0;
            if (_p[1] == -2147483648 ) _p[1] = 0;
            if (_p[2] == -2147483648 ) _p[2] = 0;
            if (_p[3] == -2147483648 ) _p[3] = 0;
            _currentTrack.setModulationEnvelop(true, _p[0], _p[1], _p[2], _p[3]);
            return e.next;
        }
        
        
        private function _onAmplitudeModulation(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 4);
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_MODULATE) != 0) return e.next;   
            if (_p[0] == -2147483648 ) _p[0] = 0;
            if (_p[1] == -2147483648 ) _p[1] = 0;
            if (_p[2] == -2147483648 ) _p[2] = 0;
            if (_p[3] == -2147483648 ) _p[3] = 0;
            _currentTrack.setModulationEnvelop(false, _p[0], _p[1], _p[2], _p[3]);
            return e.next;
        }
        
        
        private function _onPortament(e:MMLEvent) : MMLEvent
        {
            if (e.data == -2147483648 ) e.data = 0;
            _currentTrack.setPortament(e.data);
            return e.next;
        }
        
        
    
    
        
        private function _onVolume(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_VOLUME) != 0) return e.next;  
            _currentTrack._mmlVCommand(e.data);                                   
            return e.next;
        }
        
        
        private function _onVolumeShift(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_VOLUME) != 0) return e.next;  
            _currentTrack._mmlVShift(e.data);                                     
            return e.next;
        }
        
        
        private function _onVolumeSetting(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, SiOPMModule.STREAM_SEND_SIZE);
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_VOLUME) != 0) return e.next;  
            _currentTrack._vcommandShift = (_p[1] == -2147483648 ) ? 4 : _p[1];
            _currentTrack.velocityMode((_p[0] == -2147483648 ) ? 0 : _p[0]);
            return e.next;
        }
    
        
        private function _onExpression(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_VOLUME) != 0) return e.next; 
            var x:Int = (e.data == -2147483648 ) ? 128 : e.data;                
            _currentTrack.expression(x);                                        
            return e.next;
        }
        
        
        private function _onExpressionSetting(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_VOLUME) != 0) return e.next;  
            _currentTrack.expressionMode((e.data == -2147483648 ) ? 0 : e.data);
            return e.next;
        }

        
        private function _onMasterVolume(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, SiOPMModule.STREAM_SEND_SIZE);
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_VOLUME) != 0) return e.next;    
            _currentTrack.channel.setAllStreamSendLevels(_p);                       
            return e.next;
        }
        
        
        private function _onPan(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_PAN) != 0) return e.next;            
            _currentTrack.channel.pan((e.data == -2147483648 ) ? 0 : (e.data<<4)-64);  
            return e.next;
        }

        
        private function _onFinePan(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_PAN) != 0) return e.next;      
            _currentTrack.channel.pan((e.data == -2147483648 ) ? 0 : (e.data));  
            return e.next;
        }
        
        
        private function _onInput(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if (_p[0] == -2147483648 ) _p[0] = 5;
            if (_p[1] == -2147483648 ) _p[1] = 0;
            _currentTrack.channel.setInput(_p[0], _p[1]);
            return e.next;
        }
        
        
        private function _onOutput(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if (_p[0] == -2147483648 ) _p[0] = 2;
            if (_p[1] == -2147483648 ) _p[1] = 0;
            _currentTrack.channel.setOutput(_p[0], _p[1]);
            return e.next;
        }
        
        
        private function _onRingModulation(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if (_p[0] == -2147483648 ) _p[0] = 4;
            if (_p[1] == -2147483648 ) _p[1] = 0;
            _currentTrack.channel.setRingModulation(_p[0], _p[1]);
            return e.next;
        }
        
        
    
    
        
        private function _onModuleType(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if (_p[0] < 0 || _p[0] >= SiMMLTable.MT_MAX) _p[0] = SiMMLTable.MT_ALL;
            _currentTrack.setChannelModuleType(_p[0], _p[1]);
            return e.next;
        }
        
        
        
        private function _setEventTrigger(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 3);
            var id     :Int = (_p[0] != -2147483648 ) ? _p[0] : 0;
            var typeOn :Int = (_p[1] != -2147483648 ) ? _p[1] : 1;
            var typeOff:Int = (_p[2] != -2147483648 ) ? _p[2] : 1;
            _currentTrack.setEventTrigger(id, typeOn, typeOff);
            return e.next;
        }
        
        
        
        private function _dispatchEvent(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            var id     :Int = (_p[0] != -2147483648 ) ? _p[0] : 0;
            var typeOn :Int = (_p[1] != -2147483648 ) ? _p[1] : 1;
            _currentTrack.dispatchNoteOnEvent(id, typeOn);
            return e.next;
        }
        
        
        
        private function _onClock(e:MMLEvent) : MMLEvent
        {
            _currentTrack.channel.setFrequencyRatio((e.data == -2147483648 ) ? 100 : (e.data));
            return e.next;
        }
        
        
        
        private function _onAlgorism(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_OPERATOR) != 0) return e.next;      
            var cnt:Int = (_p[0] != -2147483648 ) ? _p[0] : 0;
            var alg:Int = (_p[1] != -2147483648 ) ? _p[1] : _table.alg_init[cnt];
            _currentTrack.channel.setAlgorism(cnt, alg);
            return e.next;
        }
        
        
        private function _onOpeParameter(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, PARAM_MAX);
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_OPERATOR) != 0) return e.next;      
            var seq:MMLSequence = _currentTrack._setChannelParameters(_p);
            if (seq != null) {
                seq.connectBefore(e.next);
                return seq.headEvent.next;
            }
            return e.next;
        }
        
        
        private function _onFeedback(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_OPERATOR) != 0) return e.next;      
            var fb :Int = (_p[0] != -2147483648 ) ? _p[0] : 0;
            var fbc:Int = (_p[1] != -2147483648 ) ? _p[1] : 0;
            _currentTrack.channel.setFeedBack(fb, fbc);
            return e.next;
        }
        
        
        private function _onSlotIndex(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_OPERATOR) != 0) return e.next;      
            _currentTrack.channel.activeOperatorIndex((e.data == -2147483648 ) ? 4 : e.data);
            return e.next;
        }

        
        
        private function _onOpeReleaseRate(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_OPERATOR) != 0) return e.next;      
            if (_p[0] != -2147483648 ) _currentTrack.channel.rr(_p[0]);
            if (_p[1] == -2147483648 ) _p[1] = 0;
            _currentTrack.setReleaseSweep(_p[1]);
            return e.next;
        }
        
        
        private function _onOpeTotalLevel(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_OPERATOR) != 0) return e.next;      
            _currentTrack.channel.tl((e.data == -2147483648 ) ? 0 : e.data);
            return e.next;
        }
        
        
        private function _onOpeMultiple(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_OPERATOR) != 0) return e.next;      
            if (_p[0] == -2147483648 ) _p[0] = 0;
            if (_p[1] == -2147483648 ) _p[1] = 0;
            _currentTrack.channel.fmul((_p[0] << 7) + _p[1]);
            return e.next;
        }
        
        
        private function _onOpeDetune(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_OPERATOR) != 0) return e.next;      
            _currentTrack.channel.detune ( (e.data == -2147483648 ) ? 0 : e.data);
            return e.next;
        }
        
        
        private function _onOpePhase(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_OPERATOR) != 0) return e.next;     
            var phase:Int = (e.data == -2147483648 ) ? 0 : e.data;
            _currentTrack.channel.phase ( phase);                            
            return e.next;
        }
        
        
        private function _onOpeFixedNote(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_OPERATOR) != 0) return e.next;      
            if (_p[0] == -2147483648 ) _p[0] = 0;
            if (_p[1] == -2147483648 ) _p[1] = 0;
            _currentTrack.channel.fixedPitch ((_p[0] << 6) + _p[1]);
            return e.next;
        }
        
        
        private function _onOpeSSGEnvelop(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_OPERATOR) != 0) return e.next;      
            _currentTrack.channel.ssgec ((e.data == -2147483648 ) ? 0 : e.data);
            return e.next;
        }
        
        
        private function _onOpeEnvelopReset(e:MMLEvent) : MMLEvent
        {
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_OPERATOR) != 0) return e.next;      
            _currentTrack.channel.erst ((e.data == 1));
            return e.next;
        }
        
        
        private function _onSustain(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            if ((_currentTrack.eventMask & SiMMLTrack.MASK_OPERATOR) != 0) return e.next;      
            if (_p[0] != -2147483648 ) _currentTrack.channel.setAllReleaseRate(_p[0]);
            if (_p[1] == -2147483648 ) _p[1] = 0;
            _currentTrack.setReleaseSweep(_p[1]);
            return e.next;
        }
        
        
        
        private function _onRegisterUpdate(e:MMLEvent) : MMLEvent
        {
            e = e.getParameters(_p, 2);
            _currentTrack._callbackUpdateRegister(_p[0], _p[1]);
            return e.next;
        }

        
        
        
        
    
    
        private function _errorSyntax(str:String) : Error
        {
            return new Error("SiMMLSequencer error : Syntax error. " + str);
        }
        
        
        private function _errorOutOfRange(cmd:String, n:Int) : Error
        {
            return new Error("SiMMLSequencer error : Out of range. '" + cmd + "' = " + Std.string(n));
        }
        
        
        private function _errorToneParameterNotValid(cmd:String, chParam:Int, opParam:Int) : Error
        {
            return new Error("SiMMLSequencer error : Parameter count is not valid in '" + cmd + "'. " + Std.string(chParam) + " parameters for channel and " + Std.string(opParam) + " parameters for each operator.");
        }
        
        
        private function _errorParameterNotValid(cmd:String, param:String) : Error
        {
            return new Error("SiMMLSequencer error : Parameter not valid. '" + param + "' in " + cmd);
        }
        
            
        private function _errorInternalTable() : Error
        {
            return new Error("SiMMLSequencer error : Internal table is available only for envelop commands.");
        }
        
        
        private function _errorCircularReference(mcr:String) : Error
        {
            return new Error("SiMMLSequencer error : Circular reference in dynamic macro. " + mcr);
        }
        
        
        private function _errorInitSequence(mml:String) : Error
        {
            return new Error("SiMMLSequencer error : Initializing sequence cannot include note, rest, '%' nor '@'. " + mml);
        }
        
        
        private function _errorSystemCommand(str:String) : Error
        {
            return new Error("SiMMLSequencer error : System command error. "+str);
        }
        
        
        private function _errorUnknown(str:String) : Error
        {
            return new Error("SiMMLSequencer error : Unknown. "+str);
        }
    }


