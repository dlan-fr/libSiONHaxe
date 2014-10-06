





package org.si.sion.module.channels ;
    import org.si.utils.SLLint;
    import org.si.utils.SLLNumber;
    import org.si.sion.module.SiOPMTable;
	import org.si.sion.module.SiOPMStream;
    import org.si.sion.module.SiOPMModule;
    
    
    class SiOPMChannelBase
    {
    
    
         inline static public var OUTPUT_STANDARD:Int = 0;
         inline static public var OUTPUT_OVERWRITE:Int = 1;
         inline static public var OUTPUT_ADD:Int = 2;
        
         inline static public var INPUT_ZERO:Int = 0;
         inline static public var INPUT_PIPE:Int = 1;
         inline static public var INPUT_FEEDBACK:Int = 2;
        
         inline static public var FILTER_LP:Int = 0;
         inline static public var FILTER_BP:Int = 1;
         inline static public var FILTER_HP:Int = 2;
        
        
		 inline static private var EG_ATTACK:Int = 0;
		 inline static private var EG_DECAY1:Int = 1;
		 inline static private var EG_DECAY2:Int = 2;
		 inline static private var EG_SUSTAIN:Int = 3;
		 inline static private var EG_RELEASE:Int = 4;
		 inline static private var EG_OFF:Int = 5;
        
        
        
        
    
    
        
        var _table:SiOPMTable;
        
        var _chip:SiOPMModule;
        
        var _funcProcess:Dynamic;
        
        var _isNoteOn:Bool;
        
        
          var _bufferIndex:Int;
              var _inputLevel:Int;
            var _ringmodLevel:Float;
              var _inputMode:Int;
              var _outputMode:Int;
                  var _inPipe  :SLLint;
             var _ringPipe:SLLint;
                var _basePipe:SLLint;
                 var _outPipe :SLLint;
        
        
                   var _streams: Array<SiOPMStream>;
                   var _volumes: Array<Float>;
              var _isIdling:Bool;
                      var _pan:Int;
         var _hasEffectSend:Bool;
                     var _mute:Bool;
            var _veocityTable: Array<Int>;
         var _expressionTable: Array<Int>;
        
        
            var _filterOn:Bool;
              var _filterType:Int;
         var _cutoff:Int;
         var _cutoff_offset:Int;
                var _resonance:Float;
         var _filterVriables: Array<Float>;
          var _prevStepRemain:Int;
                  var _filter_eg_step:Int;
         var _filter_eg_next:Int;
             var _filter_eg_cutoff_inc:Int;
                 var _filter_eg_state:Int;
                  var _filter_eg_time: Array<Int>;
                 var _filter_eg_cutoff: Array<Int>;
        
        
          var _freq_ratio:Int;
               var _lfo_on:Int;
                var _lfo_timer:Int;
           var _lfo_timer_step:Int;
          var _lfo_timer_step_:Int;
                var _lfo_phase:Int;
           var _lfo_waveTable: Array<Int>;
           var _lfo_waveShape:Int;
        

        
        
    
    
        
	   public function new(chip:SiOPMModule)
        {
            _table = SiOPMTable.instance();
            _chip = chip;
            _isFree = true;
			
			_funcProcess = _nop;
            
            _filterVriables = new Array<Float>();
            _streams = new Array<SiOPMStream>();
            _volumes = new Array<Float>();
            _filter_eg_time   = new Array<Int>();
            _filter_eg_cutoff = new Array<Int>();
        }
        
        
        
        
    
    
        
        public function setSiOPMChannelParam(param:SiOPMChannelParam, withVolume:Bool, withModulation:Bool=true) : Void {}
        
        public function getSiOPMChannelParam(param:SiOPMChannelParam) : Void {}
        
        public function setWaveData(waveData:SiOPMWaveBase) : Void {}
        
        
        public function setChannelNumber(channelNum:Int) : Void {}
        
        public function setAlgorism(cnt:Int, alg:Int) : Void {}
        
        public function setFeedBack(fb:Int, fbc:Int) : Void {}
        
        public function setParameters(param: Array<Int>) : Void {}
        
        public function setType(pgType:Int, ptType:Int) : Void {}
        
        public function setAllAttackRate(ar:Int) : Void {}
        
        public function setAllReleaseRate(rr:Int) : Void {}
        
        
        public function  get_masterVolume() : Int { return Std.int(_volumes[0])*128; }
        public function  masterVolume(v:Int) : Void {
            v = (v<0) ? 0 : (v>128) ? 128 : v;
            _volumes[0] = v * 0.0078125;     
        }
        
        
        public function  get_pan() : Int { return _pan-64; }
        public function  pan(p:Int) : Void {
            _pan = (p<-64) ? 0 : (p>64) ? 128 : (p+64);
        }
        
        
        public function  get_mute() : Bool { return _mute; }
        public function  mute(m:Bool) : Void {
            _mute = m;
        }
        
        
        
        public function  activeOperatorIndex(i:Int) : Void { }
        
        public function  rr(r:Int) : Void {}
        
        public function  tl(i:Int) : Void {}
        
        public function  fmul(i:Int) : Void {}
        
        public function  phase(i:Int) : Void {}
        
        public function  detune(i:Int) : Void {}
        
        public function  fixedPitch(i:Int) : Void {}
        
        public function  ssgec(i:Int) : Void {}
        
        public function  erst(b:Bool) : Void {}
        
        
        public function  get_pitch()      : Int  { return 0; }
        public function  pitch(i:Int) : Void {}
        
        
        public function  bufferIndex() : Int { return _bufferIndex; }
        
        
        public function  isNoteOn() : Bool { return _isNoteOn; }
        
        
        public function  isIdling() : Bool { return _isIdling; }
        
        
        public function  isFilterActive() : Bool { return _filterOn; }
        
        
        
        public function  get_filterType() : Int { return _filterType; }
        public function  filterType(mode:Int) : Void
        {
            _filterType = (mode<0 || mode>2) ? 0 : mode;
        }
        
        
        
        
    
    
        
        public function setAllStreamSendLevels(param: Array<Int>) : Void
        {
            var i:Int, imax:Int = SiOPMModule.STREAM_SEND_SIZE, v:Int;
           i=0;
 while( i<imax){
                v = param[i];
                _volumes[i] = (v != -2147483648) ? (v * 0.0078125) : 0;
             i++;
}
           _hasEffectSend=false; i=1;
 while( i<imax){
                if (_volumes[i] > 0) _hasEffectSend = true;
             i++;
}
        }
        
        
        
        public function setStreamBuffer(streamNum:Int, stream:SiOPMStream = null) : Void
        {
            _streams[streamNum] = stream;
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
        
        
        
        public function offsetVolume(expression:Int, velocity:Int) : Void
        {
        }
        
        
        
        
    
    
        
        public function setFrequencyRatio(ratio:Int) : Void
        {
            _freq_ratio = ratio;
        }
        
        
        
        public function initializeLFO(waveform:Int, customWaveTable: Array<Int>=null) : Void
        {
            if (waveform == -1 && customWaveTable != null && customWaveTable.length == 256) {
                _lfo_waveShape = -1;
                _lfo_waveTable = customWaveTable;
            } else {
                _lfo_waveShape = (0<=waveform && waveform<=SiOPMTable.LFO_WAVE_MAX) ? waveform : SiOPMTable.LFO_WAVE_TRIANGLE;
                _lfo_waveTable = _table.lfo_waveTables[_lfo_waveShape];
            }
            _lfo_timer = 1;
            _lfo_timer_step_ = _lfo_timer_step = 0;
            _lfo_phase = 0;
        }
        
        
        
        public function setLFOCycleTime(ms:Float) : Void
        {
            _lfo_timer = 0;
            
            _lfo_timer_step_ = _lfo_timer_step = Std.int(SiOPMTable.LFO_TIMER_INITIAL/Std.int(ms*0.17294117647058824)) << _table.sampleRatePitchShift;
            
            
            
            
        }
        
        
        
        public function setAmplitudeModulation(depth:Int) : Void {}
        
        
        
        public function setPitchModulation(depth:Int) : Void {}
        
        
        
        
    
    
        
        public function activateFilter(b:Bool) : Void
        {
            _filterOn = b;
        }
        
        
        
        public function setSVFilter(cutoff:Int=128, resonance:Int=0, ar:Int=0, dr1:Int=0, dr2:Int=0, rr:Int=0, dc1:Int=128, dc2:Int=128, sc:Int=128, rc:Int=128) : Void
        {
            _filter_eg_cutoff[EG_ATTACK]  = (cutoff<0)  ? 0 : (cutoff>128)  ? 128 : cutoff;
            _filter_eg_cutoff[EG_DECAY1]  = (dc1<0) ? 0 : (dc1>128) ? 128 : dc1;
            _filter_eg_cutoff[EG_DECAY2]  = (dc2<0) ? 0 : (dc2>128) ? 128 : dc2;
            _filter_eg_cutoff[EG_SUSTAIN] = (sc<0)  ? 0 : (sc>128)  ? 128 : sc;
            _filter_eg_cutoff[EG_RELEASE] = 0;
            _filter_eg_cutoff[EG_OFF]     = (rc<0) ? 0 : (rc>128) ? 128 : rc;
            _filter_eg_time  [EG_ATTACK]  = _table.filter_eg_rate[ar & 63];
            _filter_eg_time  [EG_DECAY1]  = _table.filter_eg_rate[dr1 & 63];
            _filter_eg_time  [EG_DECAY2]  = _table.filter_eg_rate[dr2 & 63];
            _filter_eg_time  [EG_SUSTAIN] = Std.int(2147483648);
            _filter_eg_time  [EG_RELEASE] = _table.filter_eg_rate[rr & 63];
            _filter_eg_time  [EG_OFF]     = Std.int(2147483648);
            
            var res:Int = (resonance<0) ? 0 : (resonance>9) ? 9 : resonance;
            _resonance = (1 << (9 - res)) * 0.001953125;   
            
            _filterOn = (cutoff<128 || resonance>0 || ar>0 || rr>0);
        }
        
        
        
        public function offsetFilter(i:Int) : Void
        {
            _cutoff_offset = i-128;
        }
        
        
        
        
    
    
        
        public function setInput(level:Int, pipeIndex:Int) : Void
        {
            
            pipeIndex &= 3;
            
            
            if (level > 0) {
                _inPipe = _chip.getPipe(pipeIndex, _bufferIndex);
                _inputMode = INPUT_PIPE;
                _inputLevel = level + 10;
            } else {
                _inPipe = _chip.zeroBuffer;
                _inputMode = INPUT_ZERO;
                _inputLevel = 0;
            }
        }
        
        
        
        public function setRingModulation(level:Int, pipeIndex:Int) : Void
        {
            var i:Int;

            
            pipeIndex &= 3;
            
            
            _ringmodLevel = level*4/cast(1<<SiOPMTable.LOG_VOLUME_BITS,Float);
            
            
            _ringPipe = (level > 0) ? _chip.getPipe(pipeIndex, _bufferIndex) : null;
        }
        
        
        
        public function setOutput(outputMode:Int, pipeIndex:Int) : Void
        {
            var i:Int, flagAdd:Bool;
            
            
            pipeIndex &= 3;

            
            if (outputMode == OUTPUT_STANDARD) {
                pipeIndex = 4;      
                flagAdd = false;    
            } else {
                flagAdd = (outputMode == OUTPUT_ADD);  
            }

            
            _outputMode = outputMode;

            
            _outPipe = _chip.getPipe(pipeIndex, _bufferIndex);

            
            _basePipe = (flagAdd) ? (_outPipe) : (_chip.zeroBuffer);
        }
        
        
        
        public function setVolumeTables(vtable: Array<Int>, xtable: Array<Int>) : Void
        {
            _veocityTable = vtable;
            _expressionTable = xtable;
        }
        
        
        
        
    
    
        
        public function initialize(prev:SiOPMChannelBase, bufferIndex:Int) : Void
        {
            
            var i:Int, imax:Int = SiOPMModule.STREAM_SEND_SIZE;
            if (prev != null) {
               i=0;
 while( i<imax){
                    _volumes[i] = prev._volumes[i];
                    _streams[i] = prev._streams[i];
                 i++;
}
                _pan = prev._pan;
                _hasEffectSend = prev._hasEffectSend;
                _mute = prev._mute;
                _veocityTable = prev._veocityTable;
                _expressionTable = prev._expressionTable;
            } else {
                _volumes[0] = 0.5;
                _streams[0] = null;
               i=1;
 while( i<imax){
                    _volumes[i] = 0;
                    _streams[i] = null;
                 i++;
}
                _pan = 64;
                _hasEffectSend = false;
                _mute = false;
                _veocityTable = _table.eg_tlTableLine;
                _expressionTable = _table.eg_tlTableLine;
            }
            
            
            _isNoteOn = false;
            _isIdling = true;
            _bufferIndex  = bufferIndex;
            
            
            initializeLFO(SiOPMTable.LFO_WAVE_TRIANGLE);
            setLFOCycleTime(333);
            setFrequencyRatio(100);
            
            
            setInput(0, 0);
            setRingModulation(0, 0);
            setOutput(OUTPUT_STANDARD, 0);
            
            
            _filterVriables[0] = _filterVriables[1] = _filterVriables[2] = 0;
            _cutoff_offset = 0;
            _filterType = FILTER_LP;
            setSVFilter();
            shiftSVFilterState(EG_OFF);
        }
        
        
        
        public function reset() : Void
        {
            _isNoteOn = false;
            _isIdling = true;
        }
        
        
        
        public function noteOn() : Void
        {
            _lfo_phase = 0;     
            if (_filterOn) {    
                resetSVFilterState();
                shiftSVFilterState(EG_ATTACK);
            }
            _isNoteOn = true;
        }
        
        
        
        public function noteOff() : Void
        {
            if (_filterOn) {    
                shiftSVFilterState(EG_RELEASE);
            }
            _isNoteOn = false;
        }
        
        
        
        public function setRegister(addr:Int, data:Int) : Void
        {
            
        }
        
        
        
        
    
    
        
        public function resetChannelBufferStatus() : Void
        {
            _bufferIndex = 0;
        }
        
        
        
        public function buffer(len:Int) : Void
        {
            var i:Int, stream:SiOPMStream;
            
            if (_isIdling) {
                
                _nop(len);
            } else {
                
                var monoOut:SLLint = _outPipe;
                
                
                _funcProcess(len);
                
                
                if (_ringPipe != null) _applyRingModulation(monoOut, len);
                if (_filterOn) _applySVFilter(monoOut, len);
                
                
                if (_outputMode == OUTPUT_STANDARD && !_mute) {
                    if (_hasEffectSend) {
                       i=0;
 while( i<SiOPMModule.STREAM_SEND_SIZE){
                            if (_volumes[i]>0) {
                                stream = (_streams[i] != null) ? _streams[i] :  _chip.streamSlot[i];
                                if (stream != null) stream.write(monoOut, _bufferIndex, len, _volumes[i], _pan);
                            }
                         i++;
}
                    } else {
                        stream = (_streams[0] != null) ?  _streams[0] : _chip.outputStream;
                        stream.write(monoOut, _bufferIndex, len, _volumes[0], _pan);
                    }
                }
            }
            
            
            _bufferIndex += len;
        }
        
        
        
        public function nop(len:Int) : Void
        {
            _nop(len);
            _bufferIndex += len;
        }
        
        
        
        function _applyRingModulation(pointer:SLLint, len:Int) : Void
        {
            var i:Int, rp:SLLint = _ringPipe;
           i=0;
 while( i<len){
                pointer.i *= rp.i * Std.int(_ringmodLevel);
                rp = rp.next;
                pointer = pointer.next;
             i++;
}
            _ringPipe = rp;
        }
        
        
        
        function _applySVFilter(pointer:SLLint, len:Int, variables: Array<Float>=null) : Void
        {
            var i:Int, imax:Int, step:Int, out:Int, cut:Float, fb:Float;
            
            
            if (variables == null) variables = _filterVriables;
            out = _cutoff + _cutoff_offset;
            if (out<0) out=0 
            else if (out>128) out=128;
            cut = _table.filter_cutoffTable[out];
            fb  = _resonance;

            
            step = _prevStepRemain;

            while (len >= step) {
                
               i=0;
 while( i<step){
                    variables[2] = cast(pointer.i,Float) - variables[0] - variables[1] * fb;
                    variables[1] += variables[2] * cut;
                    variables[0] += variables[1] * cut;
                    pointer.i = Std.int(variables[_filterType]);
                    pointer   = pointer.next;
                 i++;
}
                len -= step;
                
                
                _cutoff += _filter_eg_cutoff_inc;
                out = _cutoff + _cutoff_offset;
                if (out<0) out=0 
                else if (out>128) out=128;
                cut = _table.filter_cutoffTable[out];
                fb  = _resonance;
                if (_cutoff == _filter_eg_next) shiftSVFilterState(_filter_eg_state+1);

                
                step = _filter_eg_step;
            }
            
            
           i=0;
 while( i<len){
                variables[2] = cast(pointer.i,Float) - variables[0] - variables[1] * fb;
                variables[1] += variables[2] * cut;
                variables[0] += variables[1] * cut;
                pointer.i = Std.int(variables[_filterType]);
                pointer   = pointer.next;
             i++;
}
            
            
            _prevStepRemain = _filter_eg_step - len;
        }

        
        
        function resetSVFilterState() : Void
        {
            _cutoff = _filter_eg_cutoff[EG_ATTACK];
        }
        
        
        
        function shiftSVFilterState(state:Int) : Void
        {
			 var __shift:Dynamic = function() : Bool
            {
                if (_filter_eg_time[state] == 0) return false;
                _filter_eg_state = state;
                _filter_eg_step  = _filter_eg_time[state];
                _filter_eg_next  = _filter_eg_cutoff[state + 1];
                _filter_eg_cutoff_inc = (_cutoff < _filter_eg_next) ? 1 : -1;
                return (_cutoff != _filter_eg_next);
            }
			
            switch (state) {
            case EG_ATTACK:
                if (!__shift())
					state++;
                
            case EG_DECAY1:
                if (!__shift())
					state++;
                
            case EG_DECAY2:
                if (!__shift())
					state++;
                
            case EG_SUSTAIN:
                
                _filter_eg_state = EG_SUSTAIN;
                _filter_eg_step  = Std.int(2147483648);
                _filter_eg_next  = _cutoff + 1;
                _filter_eg_cutoff_inc = 0;
   
            case EG_RELEASE:
                if (!__shift())
					state++;
                
            case EG_OFF:
                
                _filter_eg_state = EG_OFF;
                _filter_eg_step  = Std.int(2147483648);
                _filter_eg_next  = _cutoff + 1;
                _filter_eg_cutoff_inc = 0;
       
            }
            _prevStepRemain = _filter_eg_step;
            
          
        }
        
        

        
        function _nop(len:Int) : Void
        {
            var i:Int, p:SLLint;
            
            
            if (_outputMode == OUTPUT_STANDARD) {
                _outPipe = _chip.getPipe(4, (_bufferIndex + len) & (_chip.bufferLength()-1));
            } else {
               p=_outPipe; i=0;
 while( i<len){ p = p.next; i++;
}
                _outPipe  = p;
                _basePipe = (_outputMode == OUTPUT_ADD) ? p : _chip.zeroBuffer;
            }
            
            
            if (_inputMode == INPUT_PIPE) {
               p=_inPipe; i=0;
 while( i<len){ p = p.next; i++;
}
                _inPipe = p;
            }
            
            
            if (_ringPipe != null) {
               p=_ringPipe; i=0;
 while( i<len){ p = p.next; i++;
}
                _ringPipe = p;
            }
        }
        
        
        
        
    
    
        
        public var _isFree:Bool = true;
        
        public var _channelType:Int = -1;
        
        public var _next:SiOPMChannelBase = null;
        
        public var _prev:SiOPMChannelBase = null;
        
        
        public function  channelType() : Int { return _channelType; }
    }



