





package org.si.sion.module.channels ;
    import org.si.utils.SLLNumber;
    import org.si.utils.SLLint;
    import org.si.sion.sequencer.SiMMLTable;
    import org.si.sion.sequencer.SiMMLVoice;
	import org.si.sion.module.SiOPMTable;
	import org.si.sion.module.SiOPMModule;
    
    
    
    class SiOPMChannelKS extends SiOPMChannelFM
    {
    
    
        private var KS_BUFFER_SIZE:Int = 5400;     
        
        inline static private var KS_SEED_DEFAULT:Int = 0;
        inline static private var ks_seed_fm:Int = 1;
        inline static private var ks_seed_pcm:Int = 2;
        
        private static inline var INT_MAX_VALUE = 2147483647;
		private static inline var INT_MIN_VALUE = -2147483648;
        
    
    
        private var _ks_delayBuffer: Array<Int>;   
        private var _ks_delayBufferIndex:Int;       
        private var _ks_pitchIndex:Int;             
        private var _ks_decay_lpf:Float;           
        private var _ks_decay:Float;               
        private var _ks_mute_decay_lpf:Float;      
        private var _ks_mute_decay:Float;          
        
        private var _output:Float;                 
        private var _decay_lpf:Float;              
        private var _decay:Float;                  
        private var _expression:Float;             
        
        private var _ks_seedType:Int;               
        private var _ks_seedIndex:Int;              
        
        
        
    
    
        
        override public function toString() : String
        {
			 var str:String = "SiOPMChannelKS : operatorCount=";
            str += Std.string(_operatorCount) + "\n";
			
			var S:Dynamic = function (p:String, i:Dynamic) : Void { str += "  " + p + "=" + Std.string(i) + "\n"; }
            var S2:Dynamic = function (p:String, i:Dynamic, q:String, j:Dynamic) : Void { str += "  " + p + "=" + Std.string(i) + " / " + q + "=" + Std.string(j) + "\n"; }
			
           
            S("fb ", _inputLevel-6);
            S2("vol", _volumes[0],  "pan", _pan-64);
            if (operator[0] != null) str += Std.string(operator[0]) + "\n";
            if (operator[1] != null) str += Std.string(operator[1]) + "\n";
            if (operator[2] != null) str += Std.string(operator[2]) + "\n";
            if (operator[3] != null) str += Std.string(operator[3]) + "\n";
            return str;
           
        }
        
        
        
        
    
    
        
        function new(chip:SiOPMModule)
        {
            super(chip);
            _ks_delayBuffer = new Array<Int>();
        }
        
        
        
        
    
    
        
        override function _lfoSwitch(sw:Bool) : Void
        {
            _lfo_on = 0;
        }
        
        
        
        
    
    
        
        public function setKarplusStrongParam(ar:Int=48, dr:Int=48, tl:Int=0, fixedPitch:Int=0, ws:Int=SiOPMTable.PG_NOISE_PINK, tension:Int=8) : Void
        {
            _ks_seedType = KS_SEED_DEFAULT;
            setAlgorism(1, 0);
            setFeedBack(0, 0);
            setSiOPMParameters(ar, dr, 0, 63, 15, tl, 0, 0, 1, 0, 0, 0, 0, fixedPitch);
            activeOperator.pgType(ws);
            activeOperator.ptType(_table.getWaveTable(activeOperator.get_pgType()).defaultPTType);
            setAllReleaseRate(tension);
        }
        
        
        
        
        
    
    
        
        override public function setParameters(param: Array<Int>) : Void
        {
            _ks_seedType = (param[0] == INT_MIN_VALUE ) ? 0 : param[0];
            _ks_seedIndex =(param[1] == INT_MIN_VALUE ) ? 0 : param[1];
            
            switch (_ks_seedType) {
            case ks_seed_fm:
                if (_ks_seedIndex>=0 && _ks_seedIndex<SiMMLTable.VOICE_MAX) {
                    var voice:SiMMLVoice = SiMMLTable.instance().getSiMMLVoice(_ks_seedIndex);
                    if (voice != null) setSiOPMChannelParam(voice.channelParam, false);
                }
 
            case ks_seed_pcm:
                if (_ks_seedIndex>=0 && _ks_seedIndex<SiOPMTable.PCM_DATA_MAX) {
                    var pcm:SiOPMWavePCMTable = _table.getPCMData(_ks_seedIndex);
                    if (pcm!=null) setWaveData(pcm);
                }

            default:
                _ks_seedType = KS_SEED_DEFAULT;
                
                
                setSiOPMParameters(param[1], param[2], 0, 63, 15, param[3], 0, 0, 1, 0, 0, 0, 0, param[4]);
                activeOperator.pgType((param[5] == INT_MIN_VALUE) ? SiOPMTable.PG_NOISE_PINK : param[5]);
                activeOperator.ptType(_table.getWaveTable(activeOperator.get_pgType()).defaultPTType);

            }
        }
        
        
        
        override public function setType(pgType:Int, ptType:Int) : Void
        {
            _ks_seedType = pgType;
            _ks_seedIndex = 0;
        }
        
        
        
        override public function setAllAttackRate(ar:Int) : Void 
        {
            var ope:SiOPMOperator = operator[0];
            ope.ar(ar);
            ope.dr((ar>48) ? 48 : ar);
            ope.tl((ar>48) ? 0 : (48-ar));
        }
        
        
        
        override public function setAllReleaseRate(rr:Int) : Void 
        {
            _ks_decay_lpf = 1 - rr * 0.015625; 
        }
        
        
        
        
    
    
        
        override public function get_pitch() : Int { return _ks_pitchIndex; }
        override public function pitch(p:Int) : Void {
            _ks_pitchIndex = p;
        }
        
        
        override public function  rr(i:Int) : Void {
            _ks_decay_lpf = 1 - i * 0.015625; 
        }
        
        
        override public function  fixedPitch(i:Int) : Void { 
           var i:Int=0;
 while( i<_operatorCount){ operator[i].fixedPitchIndex(i); i++;
}
        }
        
        
        
        
    
    
        
        override public function offsetVolume(expression:Int, velocity:Int) : Void
        {
            _expression = expression * 0.0078125;
            super.offsetVolume(128, velocity);
        }
        
        
        
        
    
    
        
        override public function initialize(prev:SiOPMChannelBase, bufferIndex:Int) : Void
        {
            _ks_delayBufferIndex = 0;
            _ks_pitchIndex = 0;
            _ks_decay_lpf = 0.875;
            _ks_decay = 0.98;
            _ks_mute_decay_lpf = 0.5;
            _ks_mute_decay = 0.75;
            
            _output = 0;
            _decay_lpf = _ks_mute_decay_lpf;
            _decay     = _ks_mute_decay;
            _expression = 1;
            
            super.initialize(prev, bufferIndex);
            
            _ks_seedType = 0;
            _ks_seedIndex = 0;
            setSiOPMParameters(48, 48, 0, 63, 15, 0, 0, 0, 1, 0, 0, 0, -1, 0);
            activeOperator.pgType(SiOPMTable.PG_NOISE_PINK);
            activeOperator.ptType(SiOPMTable.PT_PCM);
        }
        
        
        
        override public function reset() : Void
        {
           var i:Int =0;
 while( i<KS_BUFFER_SIZE){ _ks_delayBuffer[i] = 0; i++;
}
            super.reset();
        }
        
        
        
        override public function noteOn() : Void
        {
            _output    = 0;
           var i:Int =0;
 while( i<KS_BUFFER_SIZE){ _ks_delayBuffer[i] =  Std.int(cast(_ks_delayBuffer[i],Float) * 0.3); i++;
}
            _decay_lpf = _ks_decay_lpf;
            _decay     = _ks_decay;
            
            super.noteOn();
        }
        
        
        
        override public function noteOff() : Void
        {
            _decay_lpf = _ks_mute_decay_lpf;
            _decay     = _ks_mute_decay;
        }
        
        
        
        override public function resetChannelBufferStatus() : Void
        {
            _bufferIndex = 0;
            _isIdling = false;
        }
        
        
        
        
        override public function buffer(len:Int) : Void
        {
            var i:Int, stream:SiOPMStream;
            
            if (_isIdling) {
                
                _nop(len);
            } else {
                
                var monoOut:SLLint = _outPipe;
                
                
                _funcProcess(len);
                
                
                if (_ringPipe != null) _applyRingModulation(monoOut, len);
                
                
                _applyKarplusStrong(monoOut, len);
                
                
                if (_filterOn) _applySVFilter(monoOut, len);
                
                
                if (_outputMode == SiOPMChannelBase.OUTPUT_STANDARD && !_mute) {
                    if (_hasEffectSend) {
                       i=0;
 while( i<SiOPMModule.STREAM_SEND_SIZE){
                            if (_volumes[i]>0) {
                                stream = (_streams[i] != null) ? _streams[i] :  _chip.streamSlot[i];
                                if (stream != null) stream.write(monoOut, _bufferIndex, len, _volumes[i]*_expression, _pan);
                            }
                         i++;
}
                    } else {
                        stream = (_streams[0] != null) ? _streams[0] : _chip.outputStream;
                        stream.write(monoOut, _bufferIndex, len, _volumes[0]*_expression, _pan);
                    }
                }
            }
            
            
            _bufferIndex += len;
        }
        
        
        
        private function _applyKarplusStrong(pointer:SLLint, len:Int) : Void
        {
            var i:Int, t:Int, indexMax:Int, tmax:Int = SiOPMTable.PITCH_TABLE_SIZE-1;
            t = _ks_pitchIndex + operator[0]._pitchIndexShift + _pm_out;
            if (t<0) t=0;
            else if (t>tmax) t=tmax;
            indexMax = _table.pitchSamplingCount[t];
            
           i=0;
 while( i<len){
                
                _lfo_timer -= _lfo_timer_step;
                if (_lfo_timer < 0) {
                    _lfo_phase = (_lfo_phase+1) & 255;
                    t = _lfo_waveTable[_lfo_phase];
                    
                    _pm_out = (((t<<1)-255) * _pm_depth) >> 8;
                    t = _ks_pitchIndex + operator[0]._pitchIndexShift + _pm_out;
                    if (t<0) t=0;
                    else if (t>tmax) t=tmax;
                    indexMax = _table.pitchSamplingCount[t];
                    _lfo_timer += _lfo_timer_initial;
                }
                
                
                if (++_ks_delayBufferIndex >= indexMax) _ks_delayBufferIndex = 0;
                _output *= _decay;
                _output += (_ks_delayBuffer[_ks_delayBufferIndex] - _output) * _decay_lpf + pointer.i;
                _ks_delayBuffer[_ks_delayBufferIndex] = Std.int(_output);
                pointer.i = Std.int(_output);
                pointer = pointer.next;
             i++;
}
        }
    }


