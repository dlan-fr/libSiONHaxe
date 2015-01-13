





package org.si.sion.module.channels ;
    import org.si.utils.SLLNumber;
    import org.si.utils.SLLint;
    import org.si.sion.module.*;
    
    
    
    class SiOPMChannelFM extends SiOPMChannelBase
    {
    
    
        inline static  private var PROC_OP1:Int = 0;
        inline static  private var PROC_OP2:Int = 1;
        inline static  private var PROC_OP3:Int = 2;
        inline static  private var PROC_OP4:Int = 3;
        inline static  private var PROC_ANA:Int = 4;
        inline static  private var PROC_RNG:Int = 5;
        inline static  private var PROC_SYN:Int = 6;
        inline static  private var PROC_AFM:Int = 7;
        inline static  private var PROC_PCM:Int = 8;
		
		private static inline var INT_MAX_VALUE = 2147483647;
		private static inline var INT_MIN_VALUE = -2147483648;
        
        
        
    
    
         static var idlingThreshold:Int = 5120; 
        
        
                public var operator: Array<SiOPMOperator>;
          public var activeOperator:SiOPMOperator;
        
        
                var _operatorCount:Int;
             var _algorism:Int;
        
        
         var _funcProcessList:Array<Dynamic>;
         var _funcProcessType:Int;
        
        
         var _pipe0:SLLint;
         var _pipe1:SLLint;
        
        
                 var _am_depth:Int;    
          var _am_out:Int;
                 var _pm_depth:Int;    
          var _pm_out:Int;
        
        
        
          var _eg_timer_initial:Int;
          var _lfo_timer_initial:Int;
        
        
		  var registerMapType:Int;
		  var registerMapChannel:Int;
        
        
        
    
    
        
        public function toString() : String
        {
            var str:String = "SiOPMChannelFM : operatorCount=";
            str += Std.string(_operatorCount) + "\n";
			
			var s:Dynamic = function (p:String, i:Dynamic) : Void { str += "  " + p + "=" + Std.string(i) + "\n"; }
            var s2:Dynamic = function (p:String, i:Dynamic, q:String, j:Dynamic) : Void { str += "  " + p + "=" + Std.string(i) + " / " + q + "=" + Std.string(j) + "\n"; }
			
			
            s("fb ", _inputLevel-6);
            s2("vol", _volumes[0],  "pan", _pan-64);
            if (operator[0] != null) str += Std.string(operator[0]) + "\n";
            if (operator[1] != null) str += Std.string(operator[1]) + "\n";
            if (operator[2] != null) str += Std.string(operator[2]) + "\n";
            if (operator[3] != null) str += Std.string(operator[3]) + "\n";
            return str;
           
        }
        
        
        
        
    
    
        
        function new(chip:SiOPMModule)
        {
            super(chip);
            
            _funcProcessList = [[_proc1op_loff, _proc2op, _proc3op, _proc4op, _proc2ana, _procring, _procsync, _proc2op, _procpcm_loff], 
                                [_proc1op_lon,  _proc2op, _proc3op, _proc4op, _proc2ana, _procring, _procsync, _proc2op, _procpcm_lon]];
            operator = new Array<SiOPMOperator>();
            operator[0] = _allocFMOperator();
            operator[1] = null;
            operator[2] = null;
            operator[3] = null;
            activeOperator = operator[0];
            
            _operatorCount = 1;
            _funcProcessType = PROC_OP1;
            _funcProcess = _proc1op_loff;
            
            _pipe0 = SLLint.allocRing(1);
            _pipe1 = SLLint.allocRing(1);
            
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
            if (operator[0] != null) operator[0].detune2(0);
            if (operator[1] != null) operator[1].detune2(0);
            if (operator[2] != null) operator[2].detune2(0);
            if (operator[3] != null) operator[3].detune2(0);
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
                if (operator[0] != null) operator[0].detune2(0);
                if (operator[1] != null) operator[1].detune2(0);
                if (operator[2] != null) operator[2].detune2(0);
                if (operator[3] != null) operator[3].detune2(0);
            }
        }
        
        
        
        function _lfoSwitch(sw:Bool) : Void
        {
            _lfo_on = (sw)? 1:0;
            _funcProcess = _funcProcessList[_lfo_on][_funcProcessType];
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
            setFeedBack(param.fb, param.fbc);
            if (withModulation) {
                initializeLFO(param.lfoWaveShape);
                _lfo_timer = (param.lfoFreqStep>0) ? 1 : 0;
                _lfo_timer_step_ = _lfo_timer_step = param.lfoFreqStep;
                setAmplitudeModulation(param.amd);
                setPitchModulation(param.pmd);
            }
            filterType(param.filterType);
            setSVFilter(param.cutoff, param.resonance, param.far, param.fdr1, param.fdr2, param.frr, param.fdc1, param.fdc2, param.fsc, param.frc);
           i=0;
 while( i<_operatorCount){
                operator[i].setSiOPMOperatorParam(param.operatorParam[i]);
             i++;
}
        }
        
        
        
        override public function getSiOPMChannelParam(param:SiOPMChannelParam) : Void
        {
            var i:Int, imax:Int = SiOPMModule.STREAM_SEND_SIZE;
           i=0;
 while( i<imax){ param.volumes[i] = _volumes[i]; i++;
}
            param.pan = _pan;
            param.fratio = _freq_ratio;
            param.opeCount = _operatorCount;
            param.alg = _algorism;
            param.fb = 0;
            param.fbc = 0;
           i=0;
 while( i<_operatorCount){
                if (_inPipe == operator[i]._feedPipe) {
                    param.fb = _inputLevel - 6;
                    param.fbc = i;
                    break;
                }
             i++;
}
            param.lfoWaveShape = _lfo_waveShape;
            param.lfoFreqStep  = _lfo_timer_step_;
            param.amd = _am_depth;
            param.pmd = _pm_depth;
           i=0;
 while( i<_operatorCount){
                operator[i].getSiOPMOperatorParam(param.operatorParam[i]);
             i++;
}
        }
        
        
        
        public function setSiOPMParameters(ar:Int, dr:Int, sr:Int, rr:Int, sl:Int, tl:Int, ksr:Int, ksl:Int, mul:Int, dt1:Int, detune:Int, ams:Int, phase:Int, fixNote:Int) : Void
        {
            var ope:SiOPMOperator = activeOperator;
            if (ar      != INT_MIN_VALUE ) ope.ar(ar);
            if (dr      != INT_MIN_VALUE ) ope.dr(dr);
            if (sr      != INT_MIN_VALUE ) ope.sr(sr);
            if (rr      != INT_MIN_VALUE ) ope.rr(rr);
            if (sl      != INT_MIN_VALUE ) ope.sl(sl);
            if (tl      != INT_MIN_VALUE) ope.tl(tl);
            if (ksr     != INT_MIN_VALUE ) ope.ks(ksr);
            if (ksl     != INT_MIN_VALUE ) ope.ksl(ksl);
            if (mul     != INT_MIN_VALUE ) ope.mul(mul);
            if (dt1     != INT_MIN_VALUE ) ope.dt1(dt1);
            if (detune  != INT_MIN_VALUE ) ope.detune(detune);
            if (ams     != INT_MIN_VALUE ) ope.ams(ams);
            if (phase   != INT_MIN_VALUE ) ope.keyOnPhase(phase);
            if (fixNote != INT_MIN_VALUE ) ope.fixedPitchIndex(fixNote<<6);
        }
        
        
        
        override public function setWaveData(waveData:SiOPMWaveBase) : Void
        {
            var pcmData:SiOPMWavePCMData = cast(waveData,SiOPMWavePCMData);
            if (Std.is(waveData,SiOPMWavePCMTable)) pcmData = (cast(waveData,SiOPMWavePCMTable))._table[60];
            
            if (pcmData != null && pcmData.wavelet != null) {
                _updateOperatorCount(1);
                _funcProcessType = PROC_PCM;
                _funcProcess = _funcProcessList[_lfo_on][_funcProcessType];
                activeOperator.setPCMData(pcmData);
                erst(true);
            } else 
            if (Std.is(waveData,SiOPMWaveTable)) {
                var waveTable:SiOPMWaveTable = cast(waveData,SiOPMWaveTable);
                if (waveTable.wavelet != null) {
                    operator[0].setWaveTable(waveTable);
                    if (operator[1] != null) operator[1].setWaveTable(waveTable);
                    if (operator[2] != null) operator[2].setWaveTable(waveTable);
                    if (operator[3] != null) operator[3].setWaveTable(waveTable);
                }
            }
        }
        
        
        
        override public function setChannelNumber(channelNum:Int) : Void 
        {
            registerMapChannel = channelNum;
        }
        
        
        
        override public function setRegister(addr:Int, data:Int) : Void
        {
            switch(registerMapType) {
            case 0:
                _setByOPMRegister(addr, data);
            case 1: 
            default:
                _setBy2A03Register(addr, data);
            }
        }
        
        
        
        private function _setBy2A03Register(addr:Int, data:Int) : Void
        {
        }
        
        
        
        private var _pmd:Int = 0;
		private var _amd:Int = 0;
        private function _setByOPMRegister(addr:Int, data:Int) : Void
        {
            var i:Int, v:Int, pms:Int, ams:Int, op:SiOPMOperator, 
                channel:Int = registerMapChannel;
            
            if (addr < 0x20) {  
                switch(addr) {
                case 15: 
                    if (channel == 7 && _operatorCount==4 && (data & 128) != 0) {
                        operator[3].pgType(SiOPMTable.PG_NOISE_PULSE);
                        operator[3].ptType(SiOPMTable.PT_OPM_NOISE);
                        operator[3].pitchIndex(((data & 31) << 6) + 2048);
                    }

                case 24: 
                    v = _table.lfo_timerSteps[data];
                    _lfo_timer = (v>0) ? 1 : 0;
                    _lfo_timer_step_ = _lfo_timer_step = v;

                case 25: 
                    if ((data & 128) != 0) _amd = data & 127;
                    else            _pmd = data & 127;

                case 27: 
                    initializeLFO(data & 3);
                }
            } else {
                if (channel == (addr&7)) {
                    if (addr < 0x40) {
                        
                        switch((addr-0x20) >> 3) {
                        case 0: 
                            v = data >> 6;
                            setAlgorism(4, data & 7);
                            setFeedBack((data >> 3) & 7, 0);
                            _volumes[0] = (v != 0) ? 0.5 : 0;
                            _pan = (v==1) ? 128 : (v==2) ? 0 : 64;

                        case 1: 
                           i=0;
 while( i<4){ operator[i].kc(data & 127); i++;
}
                  
                        case 2: 
                           i=0;
 while( i<4){ operator[i].kf(data & 127); i++;
}
        
                        case 3: 
                            pms = (data >> 4) & 7;
                            ams = (data     ) & 3;
                            if ((data & 128) != 0) setPitchModulation((pms<6) ? (_pmd >> (6-pms)) : (_pmd << (pms-5)));
                            else            setAmplitudeModulation((ams>0) ? (_amd << (ams-1)) : 0);

                        }
                    } else {
                        
                        op = operator[[0,2,1,3][(addr >> 3) & 3]]; 
                        switch((addr-0x40) >> 5) {
                        case 0: 
                            op.dt1((data >> 4) & 7);
                            op.mul((data     ) & 15);
                      
                        case 1: 
                            op.tl(data & 127);
                         
                        case 2: 
                            op.ks((data >> 6) & 3);
                            op.ar((data & 31) << 1);
                       
                        case 3: 
                            op.ams(((data >> 7) & 1)<<1);
                            op.dr((data & 31) << 1);
                         
                        case 4: 
                            op.detune([0, 384, 500, 608][(data >> 6) & 3]);
                            op.sr((data & 31) << 1);
                          
                        case 5: 
                            op.sl((data >> 4) & 15);
                            op.rr((data & 15) << 2);
                           
                        }
                    }
                }
            }
        }
        
        
        
        
    
    
        
        override public function setAlgorism(cnt:Int, alg:Int) : Void
        {
            switch (cnt) {
            case 2:  _algorism2(alg);
            case 3:  _algorism3(alg);
            case 4:  _algorism4(alg);
            case 5:  _analog(alg);    
            default: _algorism1(alg);
            }
        }
        
        
        
        override public function setFeedBack(fb:Int, fbc:Int) : Void
        {
            if (fb > 0) {
                
                if (fbc < 0 || fbc >= _operatorCount) fbc = 0;
                _inPipe = operator[fbc]._feedPipe;
                _inPipe.i = 0;
                _inputLevel = fb + 6;
                _inputMode = SiOPMChannelBase.INPUT_FEEDBACK;
            } else {
                
                _inPipe = _chip.zeroBuffer;
                _inputLevel = 0;
                _inputMode = SiOPMChannelBase.INPUT_ZERO;
            }
            
        }
        
        
        
        override public function setParameters(param: Array<Int>) : Void
        {
            setSiOPMParameters(param[1],  param[2],  param[3],  param[4],  param[5], 
                               param[6],  param[7],  param[8],  param[9],  param[10], 
                               param[11], param[12], param[13], param[14]);
        }
        
        
        
        override public function setType(pgType:Int, ptType:Int) : Void
        {
            if (pgType >= SiOPMTable.PG_PCM) {
                var pcm:SiOPMWavePCMTable = _table.getPCMData(pgType-SiOPMTable.PG_PCM);
                
                if (pcm != null) setWaveData(pcm);
            } else {
                activeOperator.pgType(pgType);
                activeOperator.ptType(ptType);
                _funcProcess = _funcProcessList[_lfo_on][_funcProcessType];
            }
        }
        
        
        
        override public function setAllAttackRate(ar:Int) : Void 
        {
            var i:Int, ope:SiOPMOperator;
           i=0;
 while( i<_operatorCount){
                ope = operator[i];
                if (ope._final) ope.ar(ar);
             i++;
}
        }
        
        
        
        override public function setAllReleaseRate(rr:Int) : Void 
        {
            var i:Int, ope:SiOPMOperator;
           i=0;
 while( i<_operatorCount){
                ope = operator[i];
                if (ope._final) ope.rr(rr);
             i++;
}
        }
        
        
    
    
        
        override public function get_pitch() : Int { return operator[_operatorCount-1].get_pitchIndex(); }
        override public function pitch(p:Int) : Void {
           var i:Int=0;
 while( i<_operatorCount){
                operator[i].pitchIndex(p);
             i++;
}
        }
        
        
        override public function activeOperatorIndex(i:Int) : Void {
            var opeIndex:Int = (i<0) ? 0 : (i>=_operatorCount) ? (_operatorCount-1) : i;
            activeOperator = operator[opeIndex];
        }
        
        
        override public function rr(i:Int) : Void { activeOperator.rr(i); }
        
        
        override public function tl(i:Int) : Void { activeOperator.tl(i); }
        
        
        override public function fmul(i:Int) : Void { activeOperator.fmul(i); }
        
        
        override public function phase(i:Int) : Void { activeOperator.keyOnPhase(i); }
        
        
        override public function detune(i:Int) : Void { activeOperator.detune(i); }
        
        
        override public function fixedPitch(i:Int) : Void { activeOperator.fixedPitchIndex( i ); }
        
        
        override public function ssgec(i:Int) : Void { activeOperator.ssgec(i); }
        
        
        override public function erst(b:Bool) : Void {
           var i:Int=0;
 while( i<_operatorCount){ operator[i].erst( b ); i++;
}
        }
        
        
        
        
    
    
        
        override public function offsetVolume(expression:Int, velocity:Int) : Void
        {
            var i:Int, ope:SiOPMOperator, tl:Int, x:Int = expression<<1;
            tl = _expressionTable[x] + _veocityTable[velocity];
           i=0;
 while( i<_operatorCount){
                ope = operator[i];
                if (ope._final) ope._tlOffset(tl);
                else ope._tlOffset(0);
             i++;
}
        }
        
        
        
        
    
    
        
        override public function initialize(prev:SiOPMChannelBase, bufferIndex:Int) : Void
        {
            
            _updateOperatorCount(1);
            operator[0].initialize();
            _isNoteOn = false;
            registerMapType = 0;
            registerMapChannel = 0;
            
            
            super.initialize(prev, bufferIndex);
        }
        
        
        
        override public function reset() : Void
        {
            
           var i:Int=0;
 while( i<_operatorCount){
                operator[i].reset();
             i++;
}
            _isNoteOn = false;
            _isIdling = true;
        }
        
        
        
        override public function noteOn() : Void
        {
            
           var i:Int=0;
 while( i<_operatorCount){
                operator[i].noteOn();
             i++;
}
            _isNoteOn = true;
            _isIdling = false;
            super.noteOn();
        }
        
        
        
        override public function noteOff() : Void
        {
            
           var i:Int=0;
 while( i<_operatorCount){
                operator[i].noteOff();
             i++;
}
            _isNoteOn = false;
            super.noteOff();
        }
        
        
        
        override public function resetChannelBufferStatus() : Void
        {
            _bufferIndex = 0;
            
            
            var i:Int, ope:SiOPMOperator;
            _isIdling = true;
           i=0;
 while( i<_operatorCount){
                ope = operator[i];
                if (ope._final && (ope._eg_out < idlingThreshold || ope._eg_state == SiOPMOperator.EG_ATTACK)) {
                    _isIdling = false;
                    break;
                }
             i++;
}
        }
        
        
        
        
    
    
    
    
    
        
        private function _proc1op_loff(len:Int) : Void
        {
            var t:Int, l:Int, i:Int, n:Float;
            var ope:SiOPMOperator = operator[0],
                log: Array<Int> = _table.logTable,
                phase_filter:Int = SiOPMTable.PHASE_FILTER;

            
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;
           i=0;
 while( i<len){
                
                
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
                t = ((ope._phase + (ip.i<<_inputLevel)) & phase_filter) >> ope._waveFixedBits;
                l = ope._waveTable[t];
                l += ope._eg_out;
                t = log[l];
                ope._feedPipe.i = t;
                
                
                
                op.i = t + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
             i++;
}

            
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        
        
        private function _proc1op_lon(len:Int) : Void
        {
            var t:Int, l:Int, i:Int, n:Float;
            var ope:SiOPMOperator = operator[0],
                log: Array<Int> = _table.logTable,
                phase_filter:Int = SiOPMTable.PHASE_FILTER;

            
            
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;

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
                t = ((ope._phase + (ip.i<<_inputLevel)) & phase_filter) >> ope._waveFixedBits;
                l = ope._waveTable[t];
                l += ope._eg_out + (_am_out>>ope._ams);
                t = log[l];
                ope._feedPipe.i = t;
                
                
                
                op.i = t + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
             i++;
}
            
            
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        
        
        
    
    
        
        private function _proc2op(len:Int) : Void
        {
            var i:Int, t:Int, l:Int, n:Float;
            var phase_filter:Int = SiOPMTable.PHASE_FILTER,
                log: Array<Int> = _table.logTable,
                ope0:SiOPMOperator = operator[0],
                ope1:SiOPMOperator = operator[1];
            
            
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;
           i=0;
 while( i<len){
                
                
                _pipe0.i = 0;

                
                
                _lfo_timer -= _lfo_timer_step;
                if (_lfo_timer < 0) {
                    _lfo_phase = (_lfo_phase+1) & 255;
                    t = _lfo_waveTable[_lfo_phase];
                    _am_out = (t * _am_depth) >> 7 << 3;
                    _pm_out = (((t<<1)-255) * _pm_depth) >> 8;
                    ope0.detune2(_pm_out);
                    ope1.detune2(_pm_out);
                    _lfo_timer += _lfo_timer_initial;
                }
                
                
                
                
                ope0._eg_timer -= ope0._eg_timer_step;
                if (ope0._eg_timer < 0) {
                    if (ope0._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope0._eg_incTable[ope0._eg_counter];
                        if (t > 0) {
                            ope0._eg_level -= 1 + (ope0._eg_level >> t);
                            if (ope0._eg_level <= 0) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                        }
                    } else {
                        ope0._eg_level += ope0._eg_incTable[ope0._eg_counter];
                        if (ope0._eg_level >= ope0._eg_stateShiftLevel) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                    }
                    ope0._eg_out = (ope0._eg_levelTable[ope0._eg_level] + ope0._eg_total_level)<<3;
                    ope0._eg_counter = (ope0._eg_counter+1)&7;
                    ope0._eg_timer += _eg_timer_initial;
                }
                
                ope0._phase += ope0._phase_step;
                t = ((ope0._phase + (ip.i<<_inputLevel)) & phase_filter) >> ope0._waveFixedBits;
                l = ope0._waveTable[t];
                l += ope0._eg_out + (_am_out>>ope0._ams);
                t = log[l];
                ope0._feedPipe.i = t;
                ope0._outPipe.i  = t + ope0._basePipe.i;

                
                
                
                ope1._eg_timer -= ope1._eg_timer_step;
                if (ope1._eg_timer < 0) {
                    if (ope1._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope1._eg_incTable[ope1._eg_counter];
                        if (t > 0) {
                            ope1._eg_level -= 1 + (ope1._eg_level >> t);
                            if (ope1._eg_level <= 0) ope1._eg_shiftState(ope1._eg_nextState[ope1._eg_state]);
                        }
                    } else {
                        ope1._eg_level += ope1._eg_incTable[ope1._eg_counter];
                        if (ope1._eg_level >= ope1._eg_stateShiftLevel) ope1._eg_shiftState(ope1._eg_nextState[ope1._eg_state]);
                    }
                    ope1._eg_out = (ope1._eg_levelTable[ope1._eg_level] + ope1._eg_total_level)<<3;
                    ope1._eg_counter = (ope1._eg_counter+1)&7;
                    ope1._eg_timer += _eg_timer_initial;
                }
                
                ope1._phase += ope1._phase_step;
                t = ((ope1._phase + (ope1._inPipe.i<<ope1._fmShift)) & phase_filter) >> ope1._waveFixedBits;
                l = ope1._waveTable[t];
                l += ope1._eg_out + (_am_out>>ope1._ams);
                t = log[l];
                ope1._feedPipe.i = t;
                ope1._outPipe.i  = t + ope1._basePipe.i;

                
                
                op.i = _pipe0.i + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
             i++;
}
            
            
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        
        
        
    
    
        
        private function _proc3op(len:Int) : Void
        {
            var i:Int, t:Int, l:Int, n:Float;
            var phase_filter:Int = SiOPMTable.PHASE_FILTER,
                log: Array<Int> = _table.logTable,
                ope0:SiOPMOperator = operator[0],
                ope1:SiOPMOperator = operator[1],
                ope2:SiOPMOperator = operator[2];
            
            
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;
           i=0;
 while( i<len){
                
                
                _pipe0.i = 0;
                _pipe1.i = 0;

                
                
                _lfo_timer -= _lfo_timer_step;
                if (_lfo_timer < 0) {
                    _lfo_phase = (_lfo_phase+1) & 255;
                    t = _lfo_waveTable[_lfo_phase];
                    _am_out = (t * _am_depth) >> 7 << 3;
                    _pm_out = (((t<<1)-255) * _pm_depth) >> 8;
                    ope0.detune2(_pm_out);
                    ope1.detune2(_pm_out);
                    ope2.detune2(_pm_out);
                    _lfo_timer += _lfo_timer_initial;
                }
                
                
                
                
                ope0._eg_timer -= ope0._eg_timer_step;
                if (ope0._eg_timer < 0) {
                    if (ope0._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope0._eg_incTable[ope0._eg_counter];
                        if (t > 0) {
                            ope0._eg_level -= 1 + (ope0._eg_level >> t);
                            if (ope0._eg_level <= 0) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                        }
                    } else {
                        ope0._eg_level += ope0._eg_incTable[ope0._eg_counter];
                        if (ope0._eg_level >= ope0._eg_stateShiftLevel) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                    }
                    ope0._eg_out = (ope0._eg_levelTable[ope0._eg_level] + ope0._eg_total_level)<<3;
                    ope0._eg_counter = (ope0._eg_counter+1)&7;
                    ope0._eg_timer += _eg_timer_initial;
                }
                
                ope0._phase += ope0._phase_step;
                t = ((ope0._phase + (ip.i<<_inputLevel)) & phase_filter) >> ope0._waveFixedBits;
                l = ope0._waveTable[t];
                l += ope0._eg_out + (_am_out>>ope0._ams);
                t = log[l];
                ope0._feedPipe.i = t;
                ope0._outPipe.i  = t + ope0._basePipe.i;

                
                
                
                ope1._eg_timer -= ope1._eg_timer_step;
                if (ope1._eg_timer < 0) {
                    if (ope1._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope1._eg_incTable[ope1._eg_counter];
                        if (t > 0) {
                            ope1._eg_level -= 1 + (ope1._eg_level >> t);
                            if (ope1._eg_level <= 0) ope1._eg_shiftState(ope1._eg_nextState[ope1._eg_state]);
                        }
                    } else {
                        ope1._eg_level += ope1._eg_incTable[ope1._eg_counter];
                        if (ope1._eg_level >= ope1._eg_stateShiftLevel) ope1._eg_shiftState(ope1._eg_nextState[ope1._eg_state]);
                    }
                    ope1._eg_out = (ope1._eg_levelTable[ope1._eg_level] + ope1._eg_total_level)<<3;
                    ope1._eg_counter = (ope1._eg_counter+1)&7;
                    ope1._eg_timer += _eg_timer_initial;
                }
                
                ope1._phase += ope1._phase_step;
                t = ((ope1._phase + (ope1._inPipe.i<<ope1._fmShift)) & phase_filter) >> ope1._waveFixedBits;
                l = ope1._waveTable[t];
                l += ope1._eg_out + (_am_out>>ope1._ams);
                t = log[l];
                ope1._feedPipe.i = t;
                ope1._outPipe.i  = t + ope1._basePipe.i;

                
                
                
                ope2._eg_timer -= ope2._eg_timer_step;
                if (ope2._eg_timer < 0) {
                    if (ope2._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope2._eg_incTable[ope2._eg_counter];
                        if (t > 0) {
                            ope2._eg_level -= 1 + (ope2._eg_level >> t);
                            if (ope2._eg_level <= 0) ope2._eg_shiftState(ope2._eg_nextState[ope2._eg_state]);
                        }
                    } else {
                        ope2._eg_level += ope2._eg_incTable[ope2._eg_counter];
                        if (ope2._eg_level >= ope2._eg_stateShiftLevel) ope2._eg_shiftState(ope2._eg_nextState[ope2._eg_state]);
                    }
                    ope2._eg_out = (ope2._eg_levelTable[ope2._eg_level] + ope2._eg_total_level)<<3;
                    ope2._eg_counter = (ope2._eg_counter+1)&7;
                    ope2._eg_timer += _eg_timer_initial;
                }
                
                ope2._phase += ope2._phase_step;
                t = ((ope2._phase + (ope2._inPipe.i<<ope2._fmShift)) & phase_filter) >> ope2._waveFixedBits;
                l = ope2._waveTable[t];
                l += ope2._eg_out + (_am_out>>ope2._ams);
                t = log[l];
                ope2._feedPipe.i = t;
                ope2._outPipe.i  = t + ope2._basePipe.i;

                
                
                op.i = _pipe0.i + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
             i++;
}
            
            
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        
        
        
    
    
        
        private function _proc4op(len:Int) : Void
        {
            var i:Int, t:Int, l:Int, n:Float;
            var phase_filter:Int = SiOPMTable.PHASE_FILTER,
                log: Array<Int> = _table.logTable,
                ope0:SiOPMOperator = operator[0],
                ope1:SiOPMOperator = operator[1],
                ope2:SiOPMOperator = operator[2],
                ope3:SiOPMOperator = operator[3];
            
            
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;
           i=0;
 while( i<len){
                
                
                _pipe0.i = 0;
                _pipe1.i = 0;

                
                
                _lfo_timer -= _lfo_timer_step;
                if (_lfo_timer < 0) {
                    _lfo_phase = (_lfo_phase+1) & 255;
                    t = _lfo_waveTable[_lfo_phase];
                    _am_out = (t * _am_depth) >> 7 << 3;
                    _pm_out = (((t<<1)-255) * _pm_depth) >> 8;
                    ope0.detune2(_pm_out);
                    ope1.detune2(_pm_out);
                    ope2.detune2(_pm_out);
                    ope3.detune2(_pm_out);
                    _lfo_timer += _lfo_timer_initial;
                }
                
                
                
                
                ope0._eg_timer -= ope0._eg_timer_step;
                if (ope0._eg_timer < 0) {
                    if (ope0._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope0._eg_incTable[ope0._eg_counter];
                        if (t > 0) {
                            ope0._eg_level -= 1 + (ope0._eg_level >> t);
                            if (ope0._eg_level <= 0) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                        }
                    } else {
                        ope0._eg_level += ope0._eg_incTable[ope0._eg_counter];
                        if (ope0._eg_level >= ope0._eg_stateShiftLevel) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                    }
                    ope0._eg_out = (ope0._eg_levelTable[ope0._eg_level] + ope0._eg_total_level)<<3;
                    ope0._eg_counter = (ope0._eg_counter+1)&7;
                    ope0._eg_timer += _eg_timer_initial;
                }
                
                ope0._phase += ope0._phase_step;
                t = ((ope0._phase + (ip.i<<_inputLevel)) & phase_filter) >> ope0._waveFixedBits;
                l = ope0._waveTable[t];
                l += ope0._eg_out + (_am_out>>ope0._ams);
                t = log[l];
                ope0._feedPipe.i = t;
                ope0._outPipe.i  = t + ope0._basePipe.i;

                
                
                
                ope1._eg_timer -= ope1._eg_timer_step;
                if (ope1._eg_timer < 0) {
                    if (ope1._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope1._eg_incTable[ope1._eg_counter];
                        if (t > 0) {
                            ope1._eg_level -= 1 + (ope1._eg_level >> t);
                            if (ope1._eg_level <= 0) ope1._eg_shiftState(ope1._eg_nextState[ope1._eg_state]);
                        }
                    } else {
                        ope1._eg_level += ope1._eg_incTable[ope1._eg_counter];
                        if (ope1._eg_level >= ope1._eg_stateShiftLevel) ope1._eg_shiftState(ope1._eg_nextState[ope1._eg_state]);
                    }
                    ope1._eg_out = (ope1._eg_levelTable[ope1._eg_level] + ope1._eg_total_level)<<3;
                    ope1._eg_counter = (ope1._eg_counter+1)&7;
                    ope1._eg_timer += _eg_timer_initial;
                }
                
                ope1._phase += ope1._phase_step;
                t = ((ope1._phase + (ope1._inPipe.i<<ope1._fmShift)) & phase_filter) >> ope1._waveFixedBits;
                l = ope1._waveTable[t];
                l += ope1._eg_out + (_am_out>>ope1._ams);
                t = log[l];
                ope1._feedPipe.i = t;
                ope1._outPipe.i  = t + ope1._basePipe.i;

                
                
                
                ope2._eg_timer -= ope2._eg_timer_step;
                if (ope2._eg_timer < 0) {
                    if (ope2._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope2._eg_incTable[ope2._eg_counter];
                        if (t > 0) {
                            ope2._eg_level -= 1 + (ope2._eg_level >> t);
                            if (ope2._eg_level <= 0) ope2._eg_shiftState(ope2._eg_nextState[ope2._eg_state]);
                        }
                    } else {
                        ope2._eg_level += ope2._eg_incTable[ope2._eg_counter];
                        if (ope2._eg_level >= ope2._eg_stateShiftLevel) ope2._eg_shiftState(ope2._eg_nextState[ope2._eg_state]);
                    }
                    ope2._eg_out = (ope2._eg_levelTable[ope2._eg_level] + ope2._eg_total_level)<<3;
                    ope2._eg_counter = (ope2._eg_counter+1)&7;
                    ope2._eg_timer += _eg_timer_initial;
                }
                
                ope2._phase += ope2._phase_step;
                t = ((ope2._phase + (ope2._inPipe.i<<ope2._fmShift)) & phase_filter) >> ope2._waveFixedBits;
                l = ope2._waveTable[t];
                l += ope2._eg_out + (_am_out>>ope2._ams);
                t = log[l];
                ope2._feedPipe.i = t;
                ope2._outPipe.i  = t + ope2._basePipe.i;
                
                
                
                
                ope3._eg_timer -= ope3._eg_timer_step;
                if (ope3._eg_timer < 0) {
                    if (ope3._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope3._eg_incTable[ope3._eg_counter];
                        if (t > 0) {
                            ope3._eg_level -= 1 + (ope3._eg_level >> t);
                            if (ope3._eg_level <= 0) ope3._eg_shiftState(ope3._eg_nextState[ope3._eg_state]);
                        }
                    } else {
                        ope3._eg_level += ope3._eg_incTable[ope3._eg_counter];
                        if (ope3._eg_level >= ope3._eg_stateShiftLevel) ope3._eg_shiftState(ope3._eg_nextState[ope3._eg_state]);
                    }
                    ope3._eg_out = (ope3._eg_levelTable[ope3._eg_level] + ope3._eg_total_level)<<3;
                    ope3._eg_counter = (ope3._eg_counter+1)&7;
                    ope3._eg_timer += _eg_timer_initial;
                }
                
                ope3._phase += ope3._phase_step;
                t = ((ope3._phase + (ope3._inPipe.i<<ope3._fmShift)) & phase_filter) >> ope3._waveFixedBits;
                l = ope3._waveTable[t];
                l += ope3._eg_out + (_am_out>>ope3._ams);
                t = log[l];
                ope3._feedPipe.i = t;
                ope3._outPipe.i  = t + ope3._basePipe.i;

                
                
                op.i = _pipe0.i + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
             i++;
}
            
            
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        
        
        
    
    
        private function _procpcm_loff(len:Int) : Void
        {
            var t:Int, l:Int, i:Int, n:Float;
            var ope:SiOPMOperator = operator[0],
                log: Array<Int> = _table.logTable,
                phase_filter:Int = SiOPMTable.PHASE_FILTER;

            
            
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;
           i=0;
 while( i<len){
                
                
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
                t = (ope._phase + (ip.i<<_inputLevel)) >>> ope._waveFixedBits;
                if (t >= ope._pcm_endPoint) {
                    if (ope._pcm_loopPoint == -1) {
                        ope._eg_shiftState(SiOPMOperator.EG_OFF);
                        ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level)<<3;
                       
 while(i<len){
                            op.i = bp.i;
                            ip = ip.next;
                            bp = bp.next;
                            op = op.next;
                         i++;
}
                        break;
                    } else {
                        t -=  ope._pcm_endPoint - ope._pcm_loopPoint;
                        ope._phase -= (ope._pcm_endPoint - ope._pcm_loopPoint) << ope._waveFixedBits;
                    }
                }
                l = ope._waveTable[t];
                l += ope._eg_out;
                t = log[l];
                ope._feedPipe.i = t;
                
                
                
                op.i = t + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
             i++;
}
            
            
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        
        private function _procpcm_lon(len:Int) : Void
        {
            var t:Int, l:Int, i:Int, n:Float;
            var ope:SiOPMOperator = operator[0],
                log: Array<Int> = _table.logTable,
                phase_filter:Int = SiOPMTable.PHASE_FILTER;

            
            
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;

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
                t = (ope._phase + (ip.i<<_inputLevel)) >>> ope._waveFixedBits;
                if (t >= ope._pcm_endPoint) {
                    if (ope._pcm_loopPoint == -1) {
                        ope._eg_shiftState(SiOPMOperator.EG_OFF);
                        ope._eg_out = (ope._eg_levelTable[ope._eg_level] + ope._eg_total_level)<<3;
                       
 while(i<len){
                            op.i = bp.i;
                            ip = ip.next;
                            bp = bp.next;
                            op = op.next;
                         i++;
}
                        break;
                    } else {
                        t -=  ope._pcm_endPoint - ope._pcm_loopPoint;
                        ope._phase -= (ope._pcm_endPoint - ope._pcm_loopPoint) << ope._waveFixedBits;
                    }
                }
                l = ope._waveTable[t];
                l += ope._eg_out + (_am_out>>ope._ams);
                t = log[l];
                ope._feedPipe.i = t;
                
                
                
                op.i = t + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
             i++;
}
            
            
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        
        
        
    
    
        private function _proc2ana(len:Int) : Void
        {
            var i:Int, t:Int, out0:Int, out1:Int, l:Int, n:Float;
            var phase_filter:Int = SiOPMTable.PHASE_FILTER,
                log: Array<Int> = _table.logTable,
                ope0:SiOPMOperator = operator[0],
                ope1:SiOPMOperator = operator[1];
            
            
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;
           i=0;
 while( i<len){
                
                
                _lfo_timer -= _lfo_timer_step;
                if (_lfo_timer < 0) {
                    _lfo_phase = (_lfo_phase+1) & 255;
                    t = _lfo_waveTable[_lfo_phase];
                    _am_out = (t * _am_depth) >> 7 << 3;
                    _pm_out = (((t<<1)-255) * _pm_depth) >> 8;
                    ope0.detune2(_pm_out);
                    ope1.detune2(_pm_out);
                    _lfo_timer += _lfo_timer_initial;
                }
                
                
                
                ope0._eg_timer -= ope0._eg_timer_step;
                if (ope0._eg_timer < 0) {
                    if (ope0._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope0._eg_incTable[ope0._eg_counter];
                        if (t > 0) {
                            ope0._eg_level -= 1 + (ope0._eg_level >> t);
                            if (ope0._eg_level <= 0) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                        }
                    } else {
                        ope0._eg_level += ope0._eg_incTable[ope0._eg_counter];
                        if (ope0._eg_level >= ope0._eg_stateShiftLevel) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                    }
                    ope0._eg_out = (ope0._eg_levelTable[ope0._eg_level] + ope0._eg_total_level)<<3;
                    ope1._eg_out = (ope0._eg_levelTable[ope0._eg_level] + ope1._eg_total_level)<<3;
                    ope0._eg_counter = (ope0._eg_counter+1)&7;
                    ope0._eg_timer += _eg_timer_initial;
                }
                
                
                
                ope0._phase += ope0._phase_step;
                t = ((ope0._phase + (ip.i<<_inputLevel)) & phase_filter) >> ope0._waveFixedBits;
                l = ope0._waveTable[t];
                l += ope0._eg_out + (_am_out>>ope0._ams);
                out0 = log[l];

                
                
                ope1._phase += ope1._phase_step;
                t = (ope1._phase & phase_filter) >> ope1._waveFixedBits;
                l = ope1._waveTable[t];
                l += ope1._eg_out + (_am_out>>ope0._ams);
                out1 = log[l];

                
                
                ope0._feedPipe.i = out0;
                op.i = out0 + out1 + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
             i++;
}

            
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        private function _procring(len:Int) : Void
        {
            var i:Int, t:Int, out0:Int, l:Int, n:Float;
            var phase_filter:Int = SiOPMTable.PHASE_FILTER,
                log: Array<Int> = _table.logTable,
                ope0:SiOPMOperator = operator[0],
                ope1:SiOPMOperator = operator[1];
            
            
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;
           i=0;
 while( i<len){
                
                
                _lfo_timer -= _lfo_timer_step;
                if (_lfo_timer < 0) {
                    _lfo_phase = (_lfo_phase+1) & 255;
                    t = _lfo_waveTable[_lfo_phase];
                    _am_out = (t * _am_depth) >> 7 << 3;
                    _pm_out = (((t<<1)-255) * _pm_depth) >> 8;
                    ope0.detune2(_pm_out);
                    ope1.detune2(_pm_out);
                    _lfo_timer += _lfo_timer_initial;
                }
                
                
                
                ope0._eg_timer -= ope0._eg_timer_step;
                if (ope0._eg_timer < 0) {
                    if (ope0._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope0._eg_incTable[ope0._eg_counter];
                        if (t > 0) {
                            ope0._eg_level -= 1 + (ope0._eg_level >> t);
                            if (ope0._eg_level <= 0) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                        }
                    } else {
                        ope0._eg_level += ope0._eg_incTable[ope0._eg_counter];
                        if (ope0._eg_level >= ope0._eg_stateShiftLevel) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                    }
                    ope0._eg_out = (ope0._eg_levelTable[ope0._eg_level] + ope0._eg_total_level)<<3;
                    ope1._eg_out = (ope0._eg_levelTable[ope0._eg_level] + ope1._eg_total_level)<<3;
                    ope0._eg_counter = (ope0._eg_counter+1)&7;
                    ope0._eg_timer += _eg_timer_initial;
                }
                
                
                
                ope0._phase += ope0._phase_step;
                t = ((ope0._phase + (ip.i<<_inputLevel)) & phase_filter) >> ope0._waveFixedBits;
                l = ope0._waveTable[t];

                
                
                ope1._phase += ope1._phase_step;
                t = (ope1._phase & phase_filter) >> ope1._waveFixedBits;
                l += ope1._waveTable[t];
                l += ope1._eg_out + (_am_out>>ope0._ams);
                out0 = log[l];

                
                
                ope0._feedPipe.i = out0;
                op.i = out0 + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
             i++;
}
            
            
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        private function _procsync(len:Int) : Void
        {
            var i:Int, t:Int, out0:Int, out1:Int, l:Int, n:Float;
            var phase_filter:Int = SiOPMTable.PHASE_FILTER,
                log: Array<Int> = _table.logTable,
                phase_overflow:Int = SiOPMTable.PHASE_MAX,
                ope0:SiOPMOperator = operator[0],
                ope1:SiOPMOperator = operator[1];
            
            
            var ip:SLLint = _inPipe,
                bp:SLLint = _basePipe,
                op:SLLint = _outPipe;
           i=0;
 while( i<len){
                
                
                _lfo_timer -= _lfo_timer_step;
                if (_lfo_timer < 0) {
                    _lfo_phase = (_lfo_phase+1) & 255;
                    t = _lfo_waveTable[_lfo_phase];
                    _am_out = (t * _am_depth) >> 7 << 3;
                    _pm_out = (((t<<1)-255) * _pm_depth) >> 8;
                    ope0.detune2(_pm_out);
                    ope1.detune2(_pm_out);
                    _lfo_timer += _lfo_timer_initial;
                }
                
                
                
                ope0._eg_timer -= ope0._eg_timer_step;
                if (ope0._eg_timer < 0) {
                    if (ope0._eg_state == SiOPMOperator.EG_ATTACK) {
                        t = ope0._eg_incTable[ope0._eg_counter];
                        if (t > 0) {
                            ope0._eg_level -= 1 + (ope0._eg_level >> t);
                            if (ope0._eg_level <= 0) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                        }
                    } else {
                        ope0._eg_level += ope0._eg_incTable[ope0._eg_counter];
                        if (ope0._eg_level >= ope0._eg_stateShiftLevel) ope0._eg_shiftState(ope0._eg_nextState[ope0._eg_state]);
                    }
                    ope0._eg_out = (ope0._eg_levelTable[ope0._eg_level] + ope0._eg_total_level)<<3;
                    ope1._eg_out = (ope0._eg_levelTable[ope0._eg_level] + ope1._eg_total_level)<<3;
                    ope0._eg_counter = (ope0._eg_counter+1)&7;
                    ope0._eg_timer += _eg_timer_initial;
                }
                
                
                
                ope0._phase += ope0._phase_step + (ip.i<<_inputLevel);
                if ((ope0._phase  & phase_overflow) != 0) ope1._phase = ope1._keyon_phase;
                ope0._phase = ope0._phase & phase_filter;

                
                
                ope1._phase += ope1._phase_step;
                t = (ope1._phase & phase_filter) >> ope1._waveFixedBits;
                l = ope1._waveTable[t];
                l += ope1._eg_out + (_am_out>>ope0._ams);
                out0 = log[l];

                
                
                ope0._feedPipe.i = out0;
                op.i = out0 + bp.i;
                ip = ip.next;
                bp = bp.next;
                op = op.next;
             i++;
}
            
            
            _inPipe   = ip;
            _basePipe = bp;
            _outPipe  = op;
        }
        
        
        
        
    
    
        
        function _lfo_update() : Void
        {
            _lfo_timer -= _lfo_timer_step;
            if (_lfo_timer < 0) {
                _lfo_phase = (_lfo_phase+1) & 255;
                _am_out = (_lfo_waveTable[_lfo_phase] * _am_depth) >> 7 << 3;
                _pm_out = (((_lfo_waveTable[_lfo_phase]<<1)-255) * _pm_depth) >> 8;
                if (operator[0] != null) operator[0].detune2(_pm_out);
                if (operator[1] != null) operator[1].detune2(_pm_out);
                if (operator[2] != null) operator[2].detune2(_pm_out);
                if (operator[3] != null) operator[3].detune2(_pm_out);
                _lfo_timer += _lfo_timer_initial;
            }
        }
        
        
        
        private function _updateOperatorCount(cnt:Int) : Void
        {
            var i:Int;

            
            if (_operatorCount < cnt) {
                
               i=_operatorCount;
 while( i<cnt){
                    operator[i] = _allocFMOperator();
                    operator[i].initialize();
                 i++;
}
            } else 
            if (_operatorCount > cnt) {
                
               i=cnt;
 while( i<_operatorCount){
                    _freeFMOperator(operator[i]);
                    operator[i] = null;
                 i++;
}
            } 
            
            
            _operatorCount = cnt;
            _funcProcessType = cnt - 1;
            
            _funcProcess = _funcProcessList[_lfo_on][_funcProcessType];
            
            
            activeOperator = operator[_operatorCount-1];

            
            if (_inputMode ==  SiOPMChannelBase.INPUT_FEEDBACK) {
                setFeedBack(0, 0);
            }
        }
        
        
        
        private function _algorism1(alg:Int) : Void
        {
            _updateOperatorCount(1);
            _algorism = alg;
            operator[0]._setPipes(_pipe0, null, true);
        }
        
        
        
        private function _algorism2(alg:Int) : Void
        {
            _updateOperatorCount(2);
            _algorism = alg;
            switch(_algorism) {
            case 0: 
                
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0, true);
                
            case 1: 
                
                operator[0]._setPipes(_pipe0, null, true);
                operator[1]._setPipes(_pipe0, null, true);
                
            case 2: 
                
                operator[0]._setPipes(_pipe0, null,   true);
                operator[1]._setPipes(_pipe0, _pipe0, true);
                operator[1]._basePipe = _pipe0;
                
            default:
                
                operator[0]._setPipes(_pipe0, null, true);
                operator[1]._setPipes(_pipe0, null, true);
                
            }
        }
        
        
        
        private function _algorism3(alg:Int) : Void
        {
            _updateOperatorCount(3);
            _algorism = alg;
            switch(_algorism) {
            case 0: 
                
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0);
                operator[2]._setPipes(_pipe0, _pipe0, true);
                
            case 1: 
                
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0);
                operator[2]._setPipes(_pipe0, _pipe0, true);
                
            case 2: 
                
                operator[0]._setPipes(_pipe0, null,   true);
                operator[1]._setPipes(_pipe1);
                operator[2]._setPipes(_pipe0, _pipe1, true);
                
            case 3: 
                
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0, true);
                operator[2]._setPipes(_pipe0, null,   true);
                
            case 4:
                
                operator[0]._setPipes(_pipe1);
                operator[1]._setPipes(_pipe0, _pipe1, true);
                operator[2]._setPipes(_pipe0, _pipe1, true);
                
            case 5: 
                
                operator[0]._setPipes(_pipe0, null, true);
                operator[1]._setPipes(_pipe0, null, true);
                operator[2]._setPipes(_pipe0, null, true);
                
            case 6: 
                
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0, true);
                operator[1]._basePipe = _pipe0;
                operator[2]._setPipes(_pipe0, null,   true);
                
            default:
                
                operator[0]._setPipes(_pipe0, null, true);
                operator[1]._setPipes(_pipe0, null, true);
                operator[2]._setPipes(_pipe0, null, true);
                
            }
        }
        
        
        
        private function _algorism4(alg:Int) : Void
        {
            _updateOperatorCount(4);
            _algorism = alg;
            switch(_algorism) {
            case 0: 
                
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0);
                operator[2]._setPipes(_pipe0, _pipe0);
                operator[3]._setPipes(_pipe0, _pipe0, true);
                
            case 1: 
                
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0);
                operator[2]._setPipes(_pipe0, _pipe0);
                operator[3]._setPipes(_pipe0, _pipe0, true);
                
            case 2: 
                
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe1);
                operator[2]._setPipes(_pipe0, _pipe1);
                operator[3]._setPipes(_pipe0, _pipe0, true);
                
            case 3: 
                
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0);
                operator[2]._setPipes(_pipe0);
                operator[3]._setPipes(_pipe0, _pipe0, true);
                
            case 4: 
                
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0, true);
                operator[2]._setPipes(_pipe1);
                operator[3]._setPipes(_pipe0, _pipe1, true);
                
            case 5: 
                
                operator[0]._setPipes(_pipe1);
                operator[1]._setPipes(_pipe0, _pipe1, true);
                operator[2]._setPipes(_pipe0, _pipe1, true);
                operator[3]._setPipes(_pipe0, _pipe1, true);
                
            case 6: 
                
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0, true);
                operator[2]._setPipes(_pipe0, null,   true);
                operator[3]._setPipes(_pipe0, null,   true);
                
            case 7: 
                
                operator[0]._setPipes(_pipe0, null, true);
                operator[1]._setPipes(_pipe0, null, true);
                operator[2]._setPipes(_pipe0, null, true);
                operator[3]._setPipes(_pipe0, null, true);
                
            case 8: 
                
                operator[0]._setPipes(_pipe0, null,   true);
                operator[1]._setPipes(_pipe1);
                operator[2]._setPipes(_pipe1, _pipe1);
                operator[3]._setPipes(_pipe0, _pipe1, true);
                
            case 9: 
                
                operator[0]._setPipes(_pipe0, null,   true);
                operator[1]._setPipes(_pipe1);
                operator[2]._setPipes(_pipe0, _pipe1, true);
                operator[3]._setPipes(_pipe0, null,   true);
                
            case 10: 
                
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0);
                operator[2]._setPipes(_pipe0);
                operator[3]._setPipes(_pipe0, _pipe0, true);
                
            case 11: 
                
                operator[0]._setPipes(_pipe0, null,   true);
                operator[1]._setPipes(_pipe1);
                operator[2]._setPipes(_pipe1);
                operator[3]._setPipes(_pipe0, _pipe1, true);
                
            case 12: 
                
                operator[0]._setPipes(_pipe0);
                operator[1]._setPipes(_pipe0, _pipe0, true);
                operator[1]._basePipe = _pipe0;
                operator[2]._setPipes(_pipe1);
                operator[3]._setPipes(_pipe0, _pipe1, true);
                
            default:
                
                operator[0]._setPipes(_pipe0, null, true);
                operator[1]._setPipes(_pipe0, null, true);
                operator[2]._setPipes(_pipe0, null, true);
                operator[3]._setPipes(_pipe0, null, true);
                
            }
        }
        
        
        
        private function _analog(alg:Int) : Void
        {
            _updateOperatorCount(2);
            operator[0]._setPipes(_pipe0, null, true);
            operator[1]._setPipes(_pipe0, null, true);
            
            _algorism = (alg>=0 && alg<=3) ? alg : 0;
            _funcProcessType = PROC_ANA + _algorism;
            _funcProcess = _funcProcessList[_lfo_on][_funcProcessType];
        }
        
        
    
    
        
        static private var _freeOperators: Array<SiOPMOperator> = new Array<SiOPMOperator>();        
        
        
        
        function _allocFMOperator() : SiOPMOperator {
			var tmp = _freeOperators.pop();
            return  (tmp != null) ? tmp : new SiOPMOperator(_chip);
        }

        
        
        function _freeFMOperator(osc:SiOPMOperator) : Void {
            _freeOperators.push(osc);
        }
    }


