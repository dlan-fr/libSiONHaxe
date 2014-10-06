





package org.si.sion.module.channels ;
    
    import org.si.utils.SLLNumber;
    import org.si.utils.SLLint;
    import org.si.sion.module.*;
    
    
    
    class SiOPMChannelPCM extends SiOPMChannelBase
    {
    
    
         static var idlingThreshold:Int = 5120; 
        
        
          public var operator:SiOPMOperator;
        
        
                 var _pcmTable:SiOPMWavePCMTable;
         var _filterVriables2: Array<Float>;

        
                 var _am_depth:Int;    
          var _am_out:Int;
                 var _pm_depth:Int;    
          var _pm_out:Int;
        
        
        
          var _eg_timer_initial:Int;
          var _lfo_timer_initial:Int;
        
        
		  var registerMapType:Int;
		  var registerMapChannel:Int;
        
        
        private var _samplePitchShift:Int;
        
        private var _sampleVolume:Float;
        
        private var _samplePan:Int;
        
        private var _outPipe2:SLLint;
        
        static private var PCM_waveFixedBits:Int = 11; 
        
        
        
        
    
    
        
        public function toString() : String
        {
            var str:String = "SiOPMChannelPCM : \n";
			var s:Dynamic = function (p:String, i:Dynamic) : Void { str += "  " + p + "=" + Std.string(i) + "\n"; }
            var s2:Dynamic = function (p:String, i:Dynamic, q:String, j:Dynamic) : Void { str += "  " + p + "=" + Std.string(i) + " / " + q + "=" + Std.string(j) + "\n"; }
            s2("vol", _volumes[0],  "pan", _pan-64);
            str += Std.string(operator) + "\n";
            return str;
          
        }
        
        
        
        
    
    
        
        function new(chip:SiOPMModule)
        {
            super(chip);
            
            operator = new SiOPMOperator(chip);
            _filterVriables2 = new Array<Float>();
            
            initialize(null, 0);
        }
        
        
        
        
    
    
        
        override public function setFrequencyRatio(ratio:Int) : Void
        {
            _freq_ratio = ratio;
            var r:Float = (ratio!=0) ? (100/ratio) : 1;
            _eg_timer_initial  = Std.int(SiOPMTable.ENV_TIMER_INITIAL * r);
            _lfo_timer_initial = Std.int(SiOPMTable.LFO_TIMER_INITIAL * r);
        }
        
        
        
        
    
    
        
        override public function initializeLFO(waveform:Int, customWaveTable: Array<Int>=null) : Void
        {
            super.initializeLFO(waveform, customWaveTable);
            _lfoSwitch(false);
            _am_depth = 0;
            _pm_depth = 0;
            _am_out = 0;
            _pm_out = 0;
            _pcmTable = null;
            operator.detune2(0);
        }
        
        
        
        override public function setAmplitudeModulation(depth:Int) : Void
        {
            _am_depth = depth<<2;
            _am_out = (_lfo_waveTable[_lfo_phase] * _am_depth) >> 7 << 3;
            _lfoSwitch(_pm_depth != 0 || _am_depth > 0);
        }
        
        
        
        override public function setPitchModulation(depth:Int) : Void
        {
            _pm_depth = depth;
            _pm_out = (((_lfo_waveTable[_lfo_phase]<<1)-255) * _pm_depth) >> 8;
            _lfoSwitch(_pm_depth != 0 || _am_depth > 0);
            if (_pm_depth == 0) {
                operator.detune2(0);
            }
        }
        
        
        
        function _lfoSwitch(sw:Bool) : Void
        {
            _lfo_on = (sw) ? 1 : 0;
            _lfo_timer_step = (sw) ? _lfo_timer_step_ : 0;
        }
        
        
        
        
    
    
        
        override public function setSiOPMChannelParam(param:SiOPMChannelParam, withVolume:Bool, withModulation:Bool=true) : Void
        {
            var i:Int;
            if (param.opeCount == 0) return;
            
            if (withVolume) {
                var imax:Int = SiOPMModule.STREAM_SEND_SIZE;
               i=0;
 while( i<imax){ _volumes[i] = param.volumes[i]; i++;
}
               _hasEffectSend=false; i=1;
 while( i<imax){ if (_volumes[i] > 0) _hasEffectSend = true; i++;
}
                _pan = param.pan;
            }
            setFrequencyRatio(param.fratio);
            setAlgorism(param.opeCount, param.alg);
            
            if (withModulation) {
                initializeLFO(param.lfoWaveShape);
                _lfo_timer = (param.lfoFreqStep>0) ? 1 : 0;
                _lfo_timer_step_ = _lfo_timer_step = param.lfoFreqStep;
                setAmplitudeModulation(param.amd);
                setPitchModulation(param.pmd);
            }
            filterType(param.filterType);
            setSVFilter(param.cutoff, param.resonance, param.far, param.fdr1, param.fdr2, param.frr, param.fdc1, param.fdc2, param.fsc, param.frc);
            operator.setSiOPMOperatorParam(param.operatorParam[0]);
        }
        
        
        
        override public function getSiOPMChannelParam(param:SiOPMChannelParam) : Void
        {
            var i:Int, imax:Int = SiOPMModule.STREAM_SEND_SIZE;
           i=0;
 while( i<imax){ param.volumes[i] = _volumes[i]; i++;
}
            param.pan = _pan;
            param.fratio = _freq_ratio;
            param.opeCount = 1;
            param.alg = 0;
            param.fb = 0;
            param.fbc = 0;
            param.lfoWaveShape = _lfo_waveShape;
            param.lfoFreqStep  = _lfo_timer_step_;
            param.amd = _am_depth;
            param.pmd = _pm_depth;
            operator.getSiOPMOperatorParam(param.operatorParam[0]);
        }
        
        
        
        public function setSiOPMParameters(ar:Int, dr:Int, sr:Int, rr:Int, sl:Int, tl:Int, ksr:Int, ksl:Int, mul:Int, dt1:Int, detune:Int, ams:Int, phase:Int, fixNote:Int) : Void
        {
            var ope:SiOPMOperator = operator;
            if (ar      != -2147483648 ) ope.ar(ar);
            if (dr      != -2147483648 ) ope.dr(dr);
            if (sr      != -2147483648 ) ope.sr(sr);
            if (rr      != -2147483648 ) ope.rr(rr);
            if (sl      != -2147483648 ) ope.sl(sl);
            if (tl      != -2147483648 ) ope.tl(tl);
            if (ksr     != -2147483648 ) ope.ks(ksr);
            if (ksl     != -2147483648 ) ope.ksl(ksl);
            if (mul     != -2147483648 ) ope.mul(mul);
            if (dt1     != -2147483648 ) ope.dt1(dt1);
            if (detune  != -2147483648 ) ope.detune(detune);
            if (ams     != -2147483648 ) ope.ams(ams);
            if (phase   != -2147483648 ) ope.keyOnPhase(phase);
            if (fixNote != -2147483648 ) ope.fixedPitchIndex(fixNote<<6);
        }
        
        
        
        override public function setWaveData(waveData:SiOPMWaveBase) : Void
        {
            var pcm:SiOPMWavePCMData;
            if (Std.is(waveData,SiOPMWavePCMTable)) {
                _pcmTable = cast(waveData,SiOPMWavePCMTable);
                pcm = _pcmTable._table[60];
            } else {
                _pcmTable = null;
                pcm = cast(waveData,SiOPMWavePCMData);
            }
            if (pcm != null) _samplePitchShift = pcm.samplingPitch - 4416;
            operator.setPCMData(pcm);
        }
        
        
        
        override public function setChannelNumber(channelNum:Int) : Void 
        {
            registerMapChannel = channelNum;
        }
        
        
        
        override public function setRegister(addr:Int, data:Int) : Void
        {
        }
        
        
        
        
    
    
        
        override public function setAlgorism(cnt:Int, alg:Int) : Void
        {
        }
        
        
        
        override public function setFeedBack(fb:Int, fbc:Int) : Void
        {
        }
        
        
        
        override public function setParameters(param: Array<Int>) : Void
        {
            setSiOPMParameters(param[1],  param[2],  param[3],  param[4],  param[5], 
                               param[6],  param[7],  param[8],  param[9],  param[10], 
                               param[11], param[12], param[13], param[14]);
        }
        
        
        
        override public function setType(pgType:Int, ptType:Int) : Void
        {
            var pcmTable:SiOPMWavePCMTable = _table.getPCMData(pgType);
            if (pcmTable != null) {
                setWaveData(pcmTable);
            } else {
                _samplePitchShift = 0;
                operator.setPCMData(null);
            }
        }
        
        
        
        override public function setAllAttackRate(ar:Int) : Void 
        {
            operator.ar(ar);
        }
        
        
        
        override public function setAllReleaseRate(rr:Int) : Void 
        {
            operator.rr(rr);
        }
        
        
        
        
    
    
        
        override public function get_pitch() : Int { return operator.get_pitchIndex() + _samplePitchShift; }
        override public function pitch(p:Int) : Void {
            if (_pcmTable != null) {
                var note:Int = p>>6;
                var pcm:SiOPMWavePCMData = _pcmTable._table[note];
                if (pcm != null) {
                    _samplePitchShift = pcm.samplingPitch - 4416; 
                    _sampleVolume = _pcmTable._volumeTable[note];
                    _samplePan = _pcmTable._panTable[note];
                }
                operator.setPCMData(pcm);
            }
            operator.pitchIndex(p - _samplePitchShift);
        }
        
        
        override public function activeOperatorIndex(i:Int) : Void {
        }
        
        
        override public function rr(i:Int) : Void { operator.rr(i); }
        
        
        override public function tl(i:Int) : Void { operator.tl(i); }
        
        
        override public function fmul(i:Int) : Void { operator.fmul(i); }
        
        
        override public function phase(i:Int) : Void { operator.keyOnPhase(i); }
        
        
        override public function detune(i:Int) : Void { operator.detune(i); }
        
        
        override public function fixedPitch(i:Int) : Void { operator.fixedPitchIndex(i); }
        
        
        override public function ssgec(i:Int) : Void { operator.ssgec(i); }
        
        
        override public function erst(b:Bool) : Void { operator.erst(b); }
        
        
        
        
    
    
        
        override public function offsetVolume(expression:Int, velocity:Int) : Void
        {
            var i:Int, ope:SiOPMOperator, tl:Int, x:Int = expression<<1;
            tl = _expressionTable[x] + _veocityTable[velocity];
            operator._tlOffset(tl);
        }
        
        
        
        
    
    
        
        override public function initialize(prev:SiOPMChannelBase, bufferIndex:Int) : Void
        {
            
            operator.initialize();
            _isNoteOn = false;
            registerMapType = 0;
            registerMapChannel = 0;
            _outPipe2 = _chip.getPipe(3, bufferIndex);
            _filterVriables2[0] = _filterVriables2[1] = _filterVriables2[2] = 0;
            _samplePitchShift = 0;
            _sampleVolume = 1;
            _samplePan = 0;
            
            
            super.initialize(prev, bufferIndex);
        }
        
        
        
        override public function reset() : Void
        {
            
            operator.reset();
            _isNoteOn = false;
            _isIdling = true;
        }
        
        
        
        override public function noteOn() : Void
        {
            
            operator.noteOn();
            _isNoteOn = true;
            _isIdling = false;
            super.noteOn();
        }
        
        
        
        override public function noteOff() : Void
        {
            
            operator.noteOff();
            _isNoteOn = false;
            super.noteOff();
        }
        
        
        
        override public function resetChannelBufferStatus() : Void
        {
            _bufferIndex = 0;
            
            
            _isIdling = operator._eg_out > idlingThreshold && operator._eg_state != SiOPMOperator.EG_ATTACK;
        }
        
        
        
        override public function buffer(len:Int) : Void
        {
            if (_isIdling) {
                _nop(len);
            } else {
                _proc(len, operator, false, true);
            }
            _bufferIndex += len;
        }
        
        

        
        override function _nop(len:Int) : Void
        {
            
            _outPipe  = _chip.getPipe(4, (_bufferIndex + len) & (_chip.bufferLength()-1));
            _outPipe2 = _chip.getPipe(3, (_bufferIndex + len) & (_chip.bufferLength()-1));
        }
        
        
        
        
    
    
    
    
    
        private function _proc(len:Int, ope:SiOPMOperator, mix:Bool, finalOutput:Bool) : Void
        {
            var t:Int, l:Int, i:Int, n:Float;
            var log: Array<Int> = _table.logTable,
                phase_filter:Int = SiOPMTable.PHASE_FILTER,
                op:SLLint = _outPipe, op2:SLLint = _outPipe2,
                bp:SLLint = _outPipe, bp2:SLLint = _outPipe2;
            if (!mix) bp = bp2 = _chip.zeroBuffer;

            if (ope._pcm_channels == 1) {
                
                
                if (ope._pcm_endPoint > 0) {
                    
                   i=0;
 while( i<len){
                        
                        
                        _lfo_timer -= _lfo_timer_step;
                        if (_lfo_timer < 0) {
                            _lfo_phase = (_lfo_phase+1) & 255;
                            t = _lfo_waveTable[_lfo_phase];
                            _am_out = (t * _am_depth) >> 7 << 3;
                            _pm_out = (((t<<1)-255) * _pm_depth) >> 8;
                            ope.detune2(_pm_out);
                            _lfo_timer += _lfo_timer_initial;
                        }
                        
                        
                        
                        ope._eg_timer -= ope._eg_timer_step;
                        if (ope._eg_timer < 0) {
                            if (ope._eg_state == SiOPMOperator.EG_ATTACK) {
                                t = ope._eg_incTable[ope._eg_counter];
                                if (t > 0) {
                                    ope._eg_level -= 1 + (ope._eg_level >> t);
                                    if (ope._eg_level <= 0) ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                                }
                            } else {
                                ope._eg_level += ope._eg_incTable[ope._eg_counter];
                                if (ope._eg_level >= ope._eg_stateShiftLevel) ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                            }
                            ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level)<<3;
                            ope._eg_counter = (ope._eg_counter+1)&7;
                            ope._eg_timer += _eg_timer_initial;
                        }

                        
                        
                        ope._phase += ope._phase_step;
                        t = ope._phase >>> PCM_waveFixedBits;
                        if (t >= ope._pcm_endPoint) {
                            if (ope._pcm_loopPoint == -1) {
                                ope._eg_shiftState(SiOPMOperator.EG_OFF);
                                ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level)<<3;
                               
 while(i<len){
                                    op.i = 0;
                                    op = op.next;
                                 i++;
}
                                break;
                            } else {
                                t -=  ope._pcm_endPoint - ope._pcm_loopPoint;
                                ope._phase -= (ope._pcm_endPoint - ope._pcm_loopPoint) << PCM_waveFixedBits;
                            }
                        }
                        l = ope._waveTable[t];
                        l += ope._eg_out + (_am_out>>ope._ams);
                        
                        
                        
                        op.i = log[l] + bp.i;
                        op = op.next;
                        bp = bp.next;
                     i++;
}
                } else {
                    
                   i=0;
 while( i<len){
                        op.i = bp.i;
                        op = op.next;
                        bp = bp.next;
                     i++;
}
                }
                
                if (finalOutput) {
                    
                    if (!_mute) _mwrite(_outPipe, len);
                    
                    _outPipe = op;
                }
            } else {
                
                
                if (ope._pcm_endPoint > 0) {
                    
                   i=0;
 while( i<len){
                        
                        
                        _lfo_timer -= _lfo_timer_step;
                        if (_lfo_timer < 0) {
                            _lfo_phase = (_lfo_phase+1) & 255;
                            t = _lfo_waveTable[_lfo_phase];
                            _am_out = (t * _am_depth) >> 7 << 3;
                            _pm_out = (((t<<1)-255) * _pm_depth) >> 8;
                            ope.detune2(_pm_out);
                            _lfo_timer += _lfo_timer_initial;
                        }
                        
                        
                        
                        ope._eg_timer -= ope._eg_timer_step;
                        if (ope._eg_timer < 0) {
                            if (ope._eg_state == SiOPMOperator.EG_ATTACK) {
                                t = ope._eg_incTable[ope._eg_counter];
                                if (t > 0) {
                                    ope._eg_level -= 1 + (ope._eg_level >> t);
                                    if (ope._eg_level <= 0) ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                                }
                            } else {
                                ope._eg_level += ope._eg_incTable[ope._eg_counter];
                                if (ope._eg_level >= ope._eg_stateShiftLevel) ope._eg_shiftState(ope._eg_nextState[ope._eg_state]);
                            }
                            ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level)<<3;
                            ope._eg_counter = (ope._eg_counter+1)&7;
                            ope._eg_timer += _eg_timer_initial;
                        }

                        
                        
                        ope._phase += ope._phase_step;
                        t = ope._phase >>> PCM_waveFixedBits;
                        if (t >= ope._pcm_endPoint) {
                            if (ope._pcm_loopPoint == -1) {
                                ope._eg_shiftState(SiOPMOperator.EG_OFF);
                                ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level)<<3;
                               
 while(i<len){
                                    op.i = 0;
                                    op2.i = 0;
                                    op  = op.next;
                                    op2 = op2.next;
                                 i++;
}
                                break;
                            } else {
                                t -=  ope._pcm_endPoint - ope._pcm_loopPoint;
                                ope._phase -= (ope._pcm_endPoint - ope._pcm_loopPoint) << PCM_waveFixedBits;
                            }
                        }
                        
                        
                        
                        
                        t <<= 1;
                        l = ope._waveTable[t];
                        l += ope._eg_out + (_am_out>>ope._ams);
                        op.i = bp.i;
                        op.i += log[l];
                        op = op.next;
                        bp = bp.next;
                        
                        t++;
                        l = ope._waveTable[t];
                        l += ope._eg_out + (_am_out>>ope._ams);
                        op2.i = bp2.i;
                        op2.i += log[l];
                        op2 = op2.next;
                        bp2 = bp2.next;
                     i++;
}
                } else {
                    
                   i=0;
 while( i<len){
                        op.i = bp.i;
                        op = op.next;
                        bp = bp.next;
                        op2.i = bp2.i;
                        op2 = op2.next;
                        bp2 = bp2.next;
                     i++;
}
                }
                
                if (finalOutput) {
                    
                    if (!_mute) _swrite(_outPipe, _outPipe2, len);
                    
                    _outPipe = op;
                    _outPipe2 = op2;
                }
            }
        }
        
        
        
        private function _mwrite(input:SLLint, len:Int) : Void 
        {
            var i:Int, stream:SiOPMStream, vol:Float = _sampleVolume * _chip.pcmVolume, pan:Int = _pan + _samplePan;
            if (pan < 0) pan = 0;
            else if (pan > 128) pan = 128;
            
            if (_filterOn) _applySVFilter(input, len);
            if (_hasEffectSend) {
               i=0;
 while( i<SiOPMModule.STREAM_SEND_SIZE){
                    if (_volumes[i]>0) {
                        stream = (_streams[i] != null) ?  _streams[i] :  _chip.streamSlot[i];
                        if (stream != null) stream.write(input, _bufferIndex, len, _volumes[i] * vol, pan);
                    }
                 i++;
}
            } else {
                stream = (_streams[0] != null) ?  _streams[0] :  _chip.outputStream;
                stream.write(input, _bufferIndex, len, _volumes[0] * vol, pan);
            }
        }
        
        
        
        private function _swrite(inputL:SLLint, inputR:SLLint, len:Int) : Void 
        {
            var i:Int, stream:SiOPMStream, vol:Float = _sampleVolume * _chip.pcmVolume, pan:Int = _pan + _samplePan;
            if (pan < 0) pan = 0;
            else if (pan > 128) pan = 128;
            
            if (_filterOn) {
                _applySVFilter(inputL, len, _filterVriables);
                _applySVFilter(inputR, len, _filterVriables2);
            }
            if (_hasEffectSend) {
               i=0;
 while( i<SiOPMModule.STREAM_SEND_SIZE){
                    if (_volumes[i]>0) {
                        stream = (_streams[i] != null) ? _streams[i] : _chip.streamSlot[i];
                        if (stream != null) stream.writeStereo(inputL, inputR, _bufferIndex, len, _volumes[i] * vol, pan);
                    }
                 i++;
}
            } else {
                stream = (_streams[0] != null) ? _streams[0] : _chip.outputStream;
                stream.writeStereo(inputL, inputR, _bufferIndex, len, _volumes[0] * vol, pan);
            }
        }
    }


