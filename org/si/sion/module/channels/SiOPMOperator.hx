





package org.si.sion.module.channels ;
    import org.si.utils.SLLint;
    import org.si.sion.module.SiOPMTable;
	import org.si.sion.module.SiOPMModule;
	import org.si.sion.module.SiOPMOperatorParam;
    
    
    
    class SiOPMOperator
    {
    
    
        
        inline static public var EG_ATTACK :Int = 0;
        inline static public var EG_DECAY  :Int = 1;
        inline static public var EG_SUSTAIN:Int = 2;
        inline static public var EG_RELEASE:Int = 3;
        inline static public var EG_OFF    :Int = 4;
        
        
        
        inline static private var PCM_waveFixedBits:Int = 11;
        
        
        
                
    
    
    
    
    
    
    
        
        public var _table:SiOPMTable;
        
        public var _chip:SiOPMModule;
        
        
    
        
        public var _ar:Int;
        
        public var _dr:Int;
        
        public var _sr:Int;
        
        public var _rr:Int;
        
        public var _sl:Int;
        
        public var _tl:Int;
        
        public var _ks:Int;
        
        public var _ksl:Int;
        
        public var _multiple:Int;
        
        public var _dt1:Int;
        
        public var _dt2:Int;
        
        public var _ams:Int;
        
        public var _kc:Int;
        
        public var _ssg_type:Int;
        
        public var _mute:Int;
        
        public var _erst:Bool;
        
        
    
        
        public var _pgType:Int;
        
        public var _ptType:Int;
        
        public var _waveTable: Array<Int>;
        
        public var _waveFixedBits:Int;
        
        public var _wavePhaseStepShift:Int;
        
        public var _pitchTable: Array<Int>;
        
        public var _pitchTableFilter:Int;
        
        public var _phase:Int;
        
        public var _phase_step:Int;
        
        public var _keyon_phase:Int;
        
        public var _pitchFixed:Bool;
        
        public var _dt1Table: Array<Int>;

        
        
        public var _pitchIndex:Int;
        
        public var _pitchIndexShift:Int;
        
        public var _pitchIndexShift2:Int;
        
        public var _fmShift:Int;
        
        
    
        
        public var _eg_state:Int;
        
        public var _eg_timer:Int;
        
        public var _eg_timer_step:Int;
        
        public var _eg_counter:Int;
        
        public var _eg_sustain_level :Int;
        
        public var _eg_total_level:Int;
        
        public var _eg_tl_offset:Int;
        
        public var _eg_key_scale_rate:Int;
        
        public var _eg_key_scale_level_rshift:Int;
        
        public var _eg_level:Int;
        
        public var _eg_out:Int;
        
        public var _eg_ssgec_ar:Int;
        
        public var _eg_ssgec_state:Int;
        
        
        public var _eg_incTable: Array<Int>;
        
        public var _eg_stateShiftLevel:Int;
        
        public var _eg_nextState: Array<Int>;
        
        public var _eg_levelTable: Array<Int>;
        
        static private var _table_nextState:Array<Dynamic> = [
            
            [EG_DECAY,   EG_SUSTAIN, EG_OFF,     EG_OFF,     EG_OFF], 
            [EG_DECAY,   EG_SUSTAIN, EG_ATTACK,  EG_OFF,     EG_OFF]  
        ];
        
        
    
        
        public var _final:Bool;
        
        public var _inPipe:SLLint;
        
        public var _basePipe:SLLint;
        
        public var _outPipe:SLLint;
        
        public var _feedPipe:SLLint;
        
    
        
        public var _pcm_channels:Int;
        
        public var _pcm_startPoint:Int;
        
        public var _pcm_endPoint:Int;
        
        public var _pcm_loopPoint:Int;
        
        
        
    
    
        
        public function  ar(i:Int) : Void { 
            _ar = i & 63;
            _eg_ssgec_ar = (_ssg_type == 8 || _ssg_type == 12) ? ((_ar>=56)?1:0) : ((_ar>=60)?1:0);
        }
        
        public function dr(i:Int) : Void { _dr = i & 63; }
        
        public function sr(i:Int) : Void { _sr = i & 63; }
        
        public function rr(i:Int) : Void { _rr = i & 63; }
        
        public function sl(i:Int) : Void {
            _sl = i & 15;
            _eg_sustain_level = _table.eg_slTable[i];
        }
        
        public function tl(i:Int) : Void {
            _tl = (i < 0) ? 0 : (i > 127) ? 127 : i;
            _updateTotalLevel();
        }
        
        public function ks(i:Int) : Void {
            _ks = 5-(i&3);
            _eg_key_scale_rate = _kc >> _ks;
        }
        
        public function mul(m:Int) : Void {
            m &= 15;
            _multiple = (m != 0) ? (m<<7) : 64;
            _updatePitch();
        }
        
        public function  dt1(d:Int) : Void {
            _dt1 = d & 7;
            _dt1Table = _table.dt1Table[_dt1];
            _updatePitch();
        }
        
        public function  dt2(d:Int) : Void {
            _dt2 = d & 3;
            _pitchIndexShift = _table.dt2Table[_dt2];
            _updatePitch();
        }
        
        public function  ame(b:Bool) : Void {
            _ams = (b) ? 2 : 16;
        }
        
        public function  ams(s:Int) : Void {
            _ams = (s != 0) ? (3-s) : 16;
        }
        
        public function  ksl(i:Int) : Void {
            _ksl = i;
            
            _eg_key_scale_level_rshift = (i==0) ? 8 : (5-i);
            _updateTotalLevel();
        }
        
        public function  ssgec(i:Int) : Void {
            if (i > 7) {
                _eg_nextState = _table_nextState[1];
                _ssg_type = i;
                if (_ssg_type > 17) _ssg_type = 9;
            } else {
                _eg_nextState  = _table_nextState[0];
                _ssg_type = 0;
            }
            
        }
        
        public function  mute(b:Bool) : Void {
            _mute = (b) ? SiOPMTable.ENV_BOTTOM : 0;
            _updateTotalLevel();
        }
        
        public function  erst(b:Bool) : Void {
            _erst = b;
        }
        
        
        public function get_ar() : Int { return _ar; }
        public function get_dr() : Int { return _dr; }
        public function get_sr() : Int { return _sr; }
        public function get_rr() : Int { return _rr; }
        public function get_sl() : Int { return _sl; }
        public function get_tl() : Int { return _tl; }
        public function get_ks() : Int { return 5-_ks; }
        public function get_mul() : Int { return (_multiple>>7); }
        public function get_dt1() : Int { return _dt1; }
        public function get_dt2() : Int { return _dt2; }
        public function get_ame() : Bool { return (_ams!=16); }
        public function get_ams() : Int { return (_ams==16) ? 0 : (3-_ams); }
        public function get_ksl() : Int { return _ksl; }
        public function get_ssgec() : Int { return _ssg_type; }
        public function get_mute() : Bool { return (_mute != 0); }
        public function get_erst() : Bool { return _erst; }
        
        
    
    
        
        public function kc(i:Int) : Void {
            if (_pitchFixed) return;
            _updateKC(i & 127);
            _pitchIndex = ((_kc-(_kc>>2)) << 6) | (_pitchIndex & 63);
            _updatePitch();
        }
        
        public function kf(f:Int) : Void {
            _pitchIndex = (_pitchIndex & 0xffc0) | (f & 63);
            _updatePitch();
        }
        
        public function fnum(f:Int) : Void {
            
            _updateKC((f >> 7) & 127);
            _dt2 = 0;
            _pitchIndex = 0;
            _pitchIndexShift = 0;
            _updatePhaseStep((f & 2047) << ((f >> 11) & 7));
        }

        
        public function get_kc() : Int { return _kc; }
        public function get_kf() : Int { return (_pitchIndex & 63); }
        public function get_pitchFixed() : Bool { return _pitchFixed; }
        
        
    
    
        
        public function fixedPitchIndex(i:Int) : Void {
            if (i>0) {
                _pitchIndex = i;
                _updateKC(_table.nnToKC[(i>>6)&127]);
                _updatePitch();
                _pitchFixed = true;
            } else {
                _pitchFixed = false;
            }
        }
        
        public function pitchIndex(i:Int) : Void
        {
            if (_pitchFixed) return;
            _pitchIndex = i;
            _updateKC(_table.nnToKC[(i>>6)&127]);
            _updatePitch();
        }
        
        public function detune(d:Int) : Void {
            _dt2 = 0;
            _pitchIndexShift = d;
            _updatePitch();
        }
        
        public function detune2(d:Int) : Void {
            _pitchIndexShift2 = d;
            _updatePitch();
        }
        
        public function fmul(m:Int) : Void {
            _multiple = m;
            _updatePitch();
        }
        
        public function keyOnPhase(p:Int) : Void {
            if (p == 255) _keyon_phase = -2;
            else if (p == -1) _keyon_phase = -1;
            else _keyon_phase = (p & 255) << (SiOPMTable.PHASE_BITS - 8);
        }
        
        public function pgType(n:Int) : Void
        {
            _pgType = n & SiOPMTable.PG_FILTER;
            var waveTable:SiOPMWaveTable = _table.getWaveTable(_pgType);
            _waveTable     = waveTable.wavelet;
            _waveFixedBits = waveTable.fixedBits;
        }
        
        public function ptType(n:Int) : Void
        {
            _ptType = n;
            _wavePhaseStepShift = (SiOPMTable.PHASE_BITS - _waveFixedBits) & _table.phaseStepShiftFilter[n];
            _pitchTable         = _table.pitchTable[n];
            _pitchTableFilter   = _pitchTable.length - 1;
        }
        
        public function modLevel(m:Int) : Void {
            _fmShift = (m != 0) ? (m + 10) : 0;
        }
        
        
        public function get_pitchIndex() : Int { return _pitchIndex; }
        public function get_detune()     : Int { return _pitchIndexShift; }
        public function get_detune2()    : Int { return _pitchIndexShift2; }
        public function get_fmul()       : Int { return _multiple; }
        public function get_keyOnPhase() : Int { return (_keyon_phase>=0) ? (_keyon_phase >> (SiOPMTable.PHASE_BITS - 8)) : (_keyon_phase == -1) ? -1 : 255; }
        public function get_pgType()     : Int { return _pgType; }
        public function get_modLevel()   : Int { return (_fmShift>10) ? (_fmShift-10) : 0; }
        
        
        
        public function _tlOffset(i:Int) : Void {
            _eg_tl_offset = i;
            _updateTotalLevel();
        }
        
        
        public function toString() : String
        {
            var str:String = "SiOPMOperator : ";
            str += Std.string(pgType) + "/";
            str += Std.string(ar) + "/";
            str += Std.string(dr) + "/";
            str += Std.string(sr) + "/";
            str += Std.string(rr) + "/";
            str += Std.string(sl) + "/";
            str += Std.string(tl) + "/";
            str += Std.string(ks) + "/";
            str += Std.string(ksl) + "/";
            str += Std.string(fmul) + "/";
            str += Std.string(dt1) + "/";
            str += Std.string(detune) + "/";
            str += Std.string(ams) + "/";
            str += Std.string(ssgec) + "/";
            str += Std.string(keyOnPhase) + "/";
            str += Std.string(get_pitchFixed());
            return str;
        }
        
        
        
        
    
    
        
        public function new(chip:SiOPMModule)
        {
            _table = SiOPMTable.instance();
            _chip = chip;
            _feedPipe = SLLint.allocRing(1);
            _eg_incTable   = _table.eg_incTables[17];
            _eg_levelTable = _table.eg_levelTables[0];
            _eg_nextState  = _table_nextState[0];
        }
        
        
        
        
    
    
        
        public function initialize() : Void
        {
            
            _final = true;
            _inPipe   = _chip.zeroBuffer;
            _basePipe = _chip.zeroBuffer;
            _feedPipe.i = 0;
            
            
            setSiOPMOperatorParam(_chip.initOperatorParam);
            
            
            _eg_tl_offset     = 0;  
            _pitchIndexShift2 = 0;  
            _pcm_channels   = 0;
            _pcm_startPoint = 0;
            _pcm_endPoint   = 0;
            _pcm_loopPoint  = -1;
            
            
            reset();
        }
        
        
        
        public function reset() : Void
        {
            _eg_shiftState(EG_OFF);
            _eg_out = (_eg_levelTable[_eg_level] + _eg_total_level)<<3;
            _eg_timer = SiOPMTable.ENV_TIMER_INITIAL;
            _eg_counter = 0;
            _eg_ssgec_state = 0;
            _phase = 0;
        }
        
        
        
        public function setSiOPMOperatorParam(param:SiOPMOperatorParam) : Void
        {
            pgType(param.pgType);
            ptType(param.ptType);
            
            if (param.phase == 255) _keyon_phase = -2;
            else if (param.phase == -1) _keyon_phase = -1;
            else _keyon_phase = (param.phase & 255) << (SiOPMTable.PHASE_BITS - 8);
            
            _ar = param.ar & 63;
            _dr = param.dr & 63;
            _sr = param.sr & 63;
            _rr = param.rr & 63;
            _ks = 5 - (param.ksr & 3);
            _ksl = param.ksl & 3;
            _ams = (param.ams != 0) ? (3-param.ams) : 16;
            _multiple = param.fmul;
            _fmShift = (param.modLevel & 7) + 10;
            _dt1 = param.dt1 & 7;
            _dt1Table = _table.dt1Table[_dt1];
            _pitchIndexShift = param.detune;
            ssgec(param.ssgec);
            _mute = (param.mute) ? SiOPMTable.ENV_BOTTOM : 0;
            _erst = param.erst;
            
            
            if (param.fixedPitch == 0) {
                
                
                _pitchFixed = false;
            } else {
                _pitchIndex = param.fixedPitch;
                _updateKC(_table.nnToKC[(_pitchIndex>>6)&127]);
                _pitchFixed = true;
            }
            
            _eg_key_scale_level_rshift = (_ksl==0) ? 8 : (5-_ksl);
            
            _eg_ssgec_ar = (_ssg_type == 8 || _ssg_type == 12) ? ((_ar>=56)?1:0) : ((_ar>=60)?1:0);
            
            sl(param.sl & 15);
            tl(param.tl);
            
            _updatePitch();
        }
        
        
        
        public function getSiOPMOperatorParam(param:SiOPMOperatorParam) : Void
        {
            param.pgType = _pgType;
            param.ptType = _ptType;
            
            param.ar = _ar;
            param.dr = _dr;
            param.sr = _sr;
            param.rr = _rr;
            param.sl = get_sl();
            param.tl = get_tl();
            param.ksr = get_ks();
            param.ksl = get_ksl();
            param.fmul = get_fmul();
            param.dt1 = _dt1;
            param.detune = get_detune();
            param.ams = get_ams();
            param.ssgec = get_ssgec();
            param.phase = get_keyOnPhase();
            param.modLevel = (_fmShift>10) ? (_fmShift - 10) : 0;
            param.erst = _erst;
        }
        
        
        
        public function setWaveTable(waveTable:SiOPMWaveTable) : Void
        {
            _pgType = SiOPMTable.PG_USER_CUSTOM; 
            _waveTable     = waveTable.wavelet;
            _waveFixedBits = waveTable.fixedBits;
            ptType(waveTable.defaultPTType);
        }
        
        
        
        public function setPCMData(pcmData:SiOPMWavePCMData) : Void
        {
            if (pcmData != null && pcmData.wavelet != null) {
                _pgType = SiOPMTable.PG_USER_PCM; 
                _waveTable      = pcmData.wavelet;
                _waveFixedBits  = PCM_waveFixedBits;
                _pcm_channels   = pcmData.channelCount;
                _pcm_startPoint = pcmData.startPoint();
                _pcm_endPoint   = pcmData.endPoint();
                _pcm_loopPoint  = pcmData.loopPoint();
                _keyon_phase = _pcm_startPoint << PCM_waveFixedBits;
                ptType(SiOPMTable.PT_PCM);
            } else {
                
                _pcm_endPoint = _pcm_loopPoint = 0;
                _pcm_loopPoint = -1;
            }
        }
        
        
        
        public function noteOn() : Void
        {
            if (_keyon_phase >= 0) _phase = _keyon_phase;
            else if (_keyon_phase == -1) _phase = Std.int(Math.random() * SiOPMTable.PHASE_MAX);
            _eg_ssgec_state = -1;
            _eg_shiftState(EG_ATTACK);
            _eg_out = (_eg_levelTable[_eg_level] + _eg_total_level)<<3;
        }
        
        
        
        public function noteOff() : Void
        {
            _eg_shiftState(EG_RELEASE);
            _eg_out = (_eg_levelTable[_eg_level] + _eg_total_level)<<3;
        }
        
                
        
        public function _setPipes(outPipe:SLLint, modPipe:SLLint=null, finalOsc:Bool=false) : Void
        {
            _final    = finalOsc;
            _basePipe = (outPipe == modPipe) ? _chip.zeroBuffer : outPipe;
            _outPipe  = outPipe;
            _inPipe   = (modPipe != null) ? modPipe : _chip.zeroBuffer;
            _fmShift  = 15;
        }
        
        
        
    
    
        
        function eg_update() : Void
        {
            _eg_timer -= _eg_timer_step;
            if (_eg_timer < 0) {
                if (_eg_state == EG_ATTACK) {
                    if (_eg_incTable[_eg_counter] > 0) {
                        _eg_level -= 1 + (_eg_level >> _eg_incTable[_eg_counter]);
                        if (_eg_level <= 0) _eg_shiftState(_eg_nextState[_eg_state]);
                    }
                } else {
                    _eg_level += _eg_incTable[_eg_counter];
                    if (_eg_level >= _eg_stateShiftLevel) _eg_shiftState(_eg_nextState[_eg_state]);
                }
                _eg_out = (_eg_levelTable[_eg_level] + _eg_total_level)<<3;
                _eg_counter = (_eg_counter+1)&7;
                _eg_timer += SiOPMTable.ENV_TIMER_INITIAL;
            }
        }
        
        
        
        function pg_update() : Void
        {
            _phase += _phase_step;
            var p:Int = ((_phase + (_inPipe.i << _fmShift)) & SiOPMTable.PHASE_FILTER) >> _waveFixedBits;
            var l:Int = _waveTable[p];
            l += _eg_out; 
            _feedPipe.i = _table.logTable[l];
            _outPipe.i  = _feedPipe.i + _basePipe.i;
        }
        
        
        
        public function _eg_shiftState(state:Int) : Void
        {
            var r:Int;
            
            switch (state) {
            case EG_ATTACK:
                
                if (++_eg_ssgec_state == 3) _eg_ssgec_state = 1;
                if (_ar + _eg_key_scale_rate < 62) {
                    if (_erst) _eg_level = SiOPMTable.ENV_BOTTOM;
                    _eg_state = EG_ATTACK;
                    r = (_ar != 0) ? (_ar + _eg_key_scale_rate) : 96;
                    _eg_incTable = _table.eg_incTablesAtt[_table.eg_tableSelector[r]];
                    _eg_timer_step = _table.eg_timerSteps[r];
                    _eg_levelTable = _table.eg_levelTables[0];

                }
                
            case EG_DECAY:
                if (_eg_sustain_level != 0) {
                    _eg_state = EG_DECAY;
                    if (_ssg_type != 0) {
                        _eg_level = 0;
                        _eg_stateShiftLevel = _eg_sustain_level>>2;
                        if (_eg_stateShiftLevel > SiOPMTable.ENV_BOTTOM_SSGEC) _eg_stateShiftLevel = SiOPMTable.ENV_BOTTOM_SSGEC;
                        _eg_levelTable = _table.eg_levelTables[_table.eg_ssgTableIndex[_ssg_type-8][_eg_ssgec_ar][_eg_ssgec_state]];
                    } else {
                        _eg_level = 0;
                        _eg_stateShiftLevel = _eg_sustain_level;
                        _eg_levelTable = _table.eg_levelTables[0];
                    }
                    r = (_dr != 0) ? (_dr + _eg_key_scale_rate) : 96;
                    _eg_incTable = _table.eg_incTables[_table.eg_tableSelector[r]];
                    _eg_timer_step = _table.eg_timerSteps[r];

                }
                
            case EG_SUSTAIN:
                {   
                    _eg_state = EG_SUSTAIN;
                    if (_ssg_type != 0) {
                        _eg_level = _eg_sustain_level>>2;
                        _eg_stateShiftLevel = SiOPMTable.ENV_BOTTOM_SSGEC;
                        _eg_levelTable = _table.eg_levelTables[_table.eg_ssgTableIndex[_ssg_type-8][_eg_ssgec_ar][_eg_ssgec_state]];
                    } else {
                        _eg_level = _eg_sustain_level;
                        _eg_stateShiftLevel = SiOPMTable.ENV_BOTTOM;
                        _eg_levelTable = _table.eg_levelTables[0];
                    }
                    r = (_sr != 0) ? (_sr + _eg_key_scale_rate) : 96;
                    _eg_incTable = _table.eg_incTables[_table.eg_tableSelector[r]];
                    _eg_timer_step = _table.eg_timerSteps[r];

                }
                
            case EG_RELEASE:
                if (_eg_level < SiOPMTable.ENV_BOTTOM) {
                    _eg_state = EG_RELEASE;
                    _eg_stateShiftLevel = SiOPMTable.ENV_BOTTOM;
                    r = _rr + _eg_key_scale_rate;
                    _eg_incTable = _table.eg_incTables[_table.eg_tableSelector[r]];
                    _eg_timer_step = _table.eg_timerSteps[r];
                    _eg_levelTable = _table.eg_levelTables[(_ssg_type != 0)?1:0];
     
                }
                
            case EG_OFF:
            default:
                
                _eg_state = EG_OFF;
                _eg_level = SiOPMTable.ENV_BOTTOM;
                _eg_stateShiftLevel = SiOPMTable.ENV_BOTTOM+1;
                _eg_incTable = _table.eg_incTables[17];     
                _eg_timer_step = _table.eg_timerSteps[96];  
                _eg_levelTable = _table.eg_levelTables[0];

            }
        }
        
        
        
        private function _updateKC(i:Int) : Void
        {
            
            _kc = i;
            
            _eg_key_scale_rate = _kc >> _ks;
            
            _updateTotalLevel();
        }
        
        
        
        private function _updatePitch() : Void
        {
            var n:Int = (_pitchIndex + _pitchIndexShift + _pitchIndexShift2) & _pitchTableFilter;
            _updatePhaseStep(_pitchTable[n] >> _wavePhaseStepShift);
        }
        
        
        
        private function _updatePhaseStep(ps:Int) : Void
        {
            _phase_step = ps;
            _phase_step += _dt1Table[_kc];
            _phase_step *= _multiple;
            _phase_step >>= (7 - _table.sampleRatePitchShift);  
        }
        
        
        
        private function _updateTotalLevel() : Void
        {
            _eg_total_level = ((_tl+(_kc>>_eg_key_scale_level_rshift))<<SiOPMTable.ENV_LSHIFT) + _eg_tl_offset + _mute;
            if (_eg_total_level > SiOPMTable.ENV_BOTTOM) _eg_total_level = SiOPMTable.ENV_BOTTOM;
            _eg_total_level -= SiOPMTable.ENV_TOP;       
            _eg_out = (_eg_levelTable[_eg_level] + _eg_total_level)<<3;
        }
    }


