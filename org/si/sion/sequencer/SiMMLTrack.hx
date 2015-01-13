





package org.si.sion.sequencer ;
    import org.si.utils.SLLint;
    import org.si.sion.module.channels.SiOPMChannelBase;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.sequencer.base.MMLData;
    import org.si.sion.sequencer.base.MMLEvent;
    import org.si.sion.sequencer.base.MMLSequence;
    import org.si.sion.sequencer.base.MMLExecutor;
    import org.si.sion.sequencer.base.BeatPerMinutes;
    
    
    
    class SiMMLTrack
    {
    
        
        private static inline var INT_MAX_VALUE = 2147483647;
		private static inline var INT_MIN_VALUE = -2147483648;
        
        
    
    
        
        static private var SWEEP_FINESS:Int = 128;
        
        static private var FIXED_BITS:Int = 16;
        
        static private var SWEEP_MAX:Int = 8192<<FIXED_BITS;
        
        
        
		inline public static var TRACK_ID_FILTER:Int = 0xffff;
        
	   inline static var TRACK_TYPE_FILTER:Int = 0xff0000;
        
        
        static public var MML_TRACK:Int = 0x10000;
        
        static public var MIDI_TRACK:Int = 0x20000;
        
        static public var DRIVER_NOTE:Int = 0x30000;
        
        static public var DRIVER_SEQUENCE:Int = 0x40000;
        
        static public var DRIVER_BACKGROUND:Int = 0x50000;
        
        static public var USER_CONTROLLED:Int = 0x60000;
        
        
        
        static public var NO_MASK:Int = 0;
        
        static public var MASK_VOLUME:Int = 1;
        
        static public var MASK_PAN:Int = 2;
        
        static public var MASK_QUANTIZE:Int = 4;
        
        static public var MASK_OPERATOR:Int = 8;
        
        static public var MASK_ENVELOP:Int = 16;
        
        static public var MASK_MODULATE:Int = 32;
        
        static public var MASK_SLUR:Int = 64;
        
        
        
        inline static private var normal  :Int = 0;
        inline static private var envelop :Int = 2;

        
        
        
    
    
        
        public var channel:SiOPMChannelBase;

        
        public var executor:MMLExecutor;
        
        
        public var noteShift:Int = 0;
        
        public var pitchShift:Int = 0;
        
        public var keyOnDelay:Int = 0;
        
        public var quantRatio:Float = 0;
        
        public var quantCount:Int = 0;
        
        public var eventMask:Int = 0;
        
        
        private var _callbackBeforeNoteOn:Dynamic = null;
        private var _callbackBeforeNoteOff:Dynamic = null;
        public var _callbackUpdateRegister:Dynamic;
        
        
        private var _eventTriggerOn:Dynamic = null;
        private var _eventTriggerOff:Dynamic = null;
        private var _eventTriggerID:Int;
        private var _eventTriggerTypeOn:Int;
        private var _eventTriggerTypeOff:Int;
        
        
        public var _internalTrackID:Int;
        public var _trackNumber:Int;

        
        private var _mmlData:SiMMLData;     
        private var _table:SiMMLTable;      
        private var _keyOnCounter:Int;      
        private var _keyOnLength:Int;       
        private var _flagNoKeyOn:Bool;   
        private var _processMode:Int;       
        private var _trackStartDelay:Int;   
        private var _trackStopDelay:Int;    
        private var _stopWithReset:Bool; 
        private var _isDisposable:Bool;  
        private var _priority:Int;          

        
        private var _channelModuleSetting:SiMMLChannelSetting;  
        private var _velocityMode:Int;   
        private var _expressionMode:Int; 
        private var _velocity:Int;       
        private var _expression:Int;     
        private var _pitchIndex:Int;     
        private var _pitchBend:Int;      
        private var _voiceIndex:Int;     
        private var _note:Int;           
        private var _defaultFPS:Int;     
        
        public var _channelNumber:Int; 
        
        public var _vcommandShift:Int;  
        
        
        private var _set_processMode: Array<Int>;

        
        private var _set_env_exp: Array<SLLint>;
        private var _set_env_voice: Array<SLLint>;
        private var _set_env_note: Array<SLLint>;
        private var _set_env_pitch: Array<SLLint>;
        private var _set_env_filter: Array<SLLint>;
        private var _set_exp_offset: Array<Bool>;
        private var _pns_or: Array<Bool>;
        
        private var _set_cnt_exp: Array<Int>;
        private var _set_cnt_voice: Array<Int>;
        private var _set_cnt_note: Array<Int>;
        private var _set_cnt_pitch: Array<Int>;
        private var _set_cnt_filter: Array<Int>;
        
        private var _table_env_ma: Array<SLLint>;
        private var _table_env_mp: Array<SLLint>;
        private var _set_sweep_step: Array<Int>;
        private var _set_sweep_end: Array<Int>;
        private var _env_internval:Int;
        
        
        private var _env_exp:SLLint;
        private var _env_voice:SLLint;
        private var _env_note:SLLint;
        private var _env_pitch:SLLint;
        private var _env_filter:SLLint;
        
        private var _cnt_exp:Int;
		private var _max_cnt_exp:Int;
        private var _cnt_voice:Int;
		private var _max_cnt_voice:Int;
        private var _cnt_note:Int;
		private var _max_cnt_note:Int;
        private var _cnt_pitch:Int;
		private var _max_cnt_pitch:Int;
        private var _cnt_filter:Int;
		private var _max_cnt_filter:Int;
        
        private var _env_mp:SLLint;
        private var _env_ma:SLLint;
        private var _sweep_step:Int;
        private var _sweep_end:Int;
        private var _sweep_pitch:Int;
        private var _env_exp_offset:Int;
        private var _env_pitch_active:Bool;
        
        private var _residue:Int;   
        
        
        static private var _env_zero_table:SLLint = SLLint.allocRing(1);
        
        
        
        
    
    
        
        public function trackNumber() : Int { return _trackNumber; }
        
        public function trackID() : Int { return _internalTrackID & TRACK_ID_FILTER; }
        
        public function trackTypeID() : Int { return _internalTrackID & TRACK_TYPE_FILTER; }

        
        public function eventTriggerID() : Int { return _eventTriggerID; }
        
        public function eventTriggerTypeOn() : Int { return _eventTriggerTypeOn; }
        
        public function eventTriggerTypeOff() : Int { return _eventTriggerTypeOff; }
        
        
        public function note() : Int { return _note; }
        
        
        public function trackStartDelay() : Int { return _trackStartDelay; }
        
        public function trackStopDelay() : Int { return _trackStopDelay; }
        
        
        public function isActive() : Bool { return !_isDisposable || executor.pointer != null || !channel.isIdling(); }
        
        public function isDisposable() : Bool { return _isDisposable; }
        
        public function isPlaySequence() : Bool { return ((_internalTrackID & TRACK_TYPE_FILTER) != DRIVER_NOTE && executor.pointer != null); }
        
        public function isFinished() : Bool { return (executor.pointer == null && channel.isIdling()); }
        
        
        public function get_velocity()        : Int  { return _velocity; }
        public function velocity(v:Int)   : Void { 
            _velocity = (v<0) ? 0 : (v>512) ? 512 : v;
            channel.offsetVolume(_expression, _velocity);
        }
        
        
        public function get_expression()      : Int  { return _expression; }
        public function expression(x:Int) : Void { 
            _expression = (x<0) ? 0 : (x>128) ? 128 : x;
            channel.offsetVolume(_expression, _velocity);
        }
        
        
        public function get_masterVolume() : Int { return channel.get_masterVolume(); }
        public function masterVolume(v:Int) : Void { 
            channel.masterVolume(v);
        }
        
        
        public function get_effectSend1() : Int { return Std.int(channel.getStreamSend(1)); }
        public function effectSend1(s:Int) : Void {
            channel.setStreamSend(1, (s<0) ? 0 : (s>128) ? 1 : s*0.0078125);
        }
        
        
        public function get_effectSend2() : Int { return Std.int(channel.getStreamSend(2)); }
        public function effectSend2(s:Int) : Void {
            channel.setStreamSend(2, (s<0) ? 0 : (s>128) ? 1 : s*0.0078125);
        }
        
        
        public function get_effectSend3() : Int { return Std.int(channel.getStreamSend(3)); }
        public function effectSend3(s:Int) : Void {
            channel.setStreamSend(3, (s<0) ? 0 : (s>128) ? 1 : s*0.0078125);
        }
        
        
        public function get_effectSend4() : Int { return Std.int(channel.getStreamSend(4)); }
        public function effectSend4(s:Int) : Void {
            channel.setStreamSend(4, (s<0) ? 0 : (s>128) ? 1 : s*0.0078125);
        }
        
        
        public function get_mute() : Bool { return channel.get_mute(); }
        public function mute(b:Bool) : Void {
            channel.mute(b);
        }
        
        
        public function get_pan() : Int { return channel.get_pan(); }
        public function pan(p:Int) : Void { channel.pan(p); }
        
        
        public function get_pitchBend() : Int { return _pitchBend; }
        public function pitchBend(p:Int) : Void {
            _pitchBend = p;
            channel.pitch(_pitchIndex + _pitchBend);
        }
        
        
        public function get_onUpdateRegister() : Dynamic { return _callbackUpdateRegister; }
        public function onUpdateRegister(func:Dynamic) : Void { _callbackUpdateRegister = (func != null) ? func  : _defaultUpdateRegister; }
        
        
        public function get_velocityMode() : Int { return _velocityMode; }
        public function velocityMode(mode:Int) : Void {
            var tlTables: Array<Array<Int>> = SiOPMTable.instance().eg_tlTables;
            _velocityMode = (mode>=0 && mode<SiOPMTable.VM_MAX) ? mode : SiOPMTable.VM_LINEAR;
            channel.setVolumeTables(tlTables[_velocityMode], tlTables[_expressionMode]);
        }
        
        
        public function get_expressionMode() : Int { return _expressionMode; }
        public function expressionMode(mode:Int) : Void {
            var tlTables: Array<Array<Int>> = SiOPMTable.instance().eg_tlTables;
            _expressionMode = (mode>=0 && mode<SiOPMTable.VM_MAX) ? mode : SiOPMTable.VM_LINEAR;
            channel.setVolumeTables(tlTables[_velocityMode], tlTables[_expressionMode]);
        }

        
        
        public function channelNumber() : Int { return _channelNumber; }
        
        public function programNumber() : Int { return _voiceIndex; }
        
        
        public function outputLevel() : Float {
            var vol:Int = channel.get_masterVolume();
            if (vol == 0) return _velocity * _expression * 0.0000152587890625; 
            return vol * _velocity * _expression * 2.384185791015625e-7;       
        }
        
        
        public function mmlData() : SiMMLData { return _mmlData; }
        
        
        public function _bpmSetting() : BeatPerMinutes { 
            return ((_internalTrackID & TRACK_TYPE_FILTER) != MML_TRACK && _mmlData != null) ? _mmlData._initialBPM : null;
        }
        
        
        public function priority() : Int {
            
            if (!_isDisposable || isPlaySequence()) return 0;
            return _priority;
        }
        
        
    
    
        public function new() 
        {
            _table = SiMMLTable.instance();
            executor = new MMLExecutor();
            
            _mmlData = null;
            _set_processMode = new Array<Int>();
            
            _set_env_exp    = new Array<SLLint>();
            _set_env_voice  = new Array<SLLint>();
            _set_env_note   = new Array<SLLint>();
            _set_env_pitch  = new Array<SLLint>();
            _set_env_filter = new Array<SLLint>();
            _pns_or         = new Array<Bool>();
            _set_exp_offset = new Array<Bool>();
            _set_cnt_exp    = new Array<Int>();
            _set_cnt_voice  = new Array<Int>();
            _set_cnt_note   = new Array<Int>();
            _set_cnt_pitch  = new Array<Int>();
            _set_cnt_filter = new Array<Int>();
            _set_sweep_step = new Array<Int>();
            _set_sweep_end  = new Array<Int>();
            _table_env_ma   = new Array<SLLint>();
            _table_env_mp   = new Array<SLLint>();
			_callbackUpdateRegister = _defaultUpdateRegister;
        }
        
        
        
        
    
    
        
        public function setTrackCallback(noteOn:Dynamic=null, noteOff:Dynamic=null) : SiMMLTrack
        {
            _callbackBeforeNoteOn  = noteOn;
            _callbackBeforeNoteOff = noteOff;
            return this;
        }
        
        
        
        public function keyOn(note:Int, tickLength:Int=0, sampleDelay:Int=0) : SiMMLTrack
        {
            _trackStartDelay = sampleDelay;
            executor.singleNote(note, tickLength);
            return this;
        }
        
        
        
        public function keyOff(sampleDelay:Int=0, stopWithReset:Bool=false) : SiMMLTrack
        {
            _stopWithReset = stopWithReset;
            if (sampleDelay != 0) {
                _trackStopDelay = sampleDelay;
            } else {
                _keyOff();
                _note = -1;
                if (_stopWithReset) channel.reset();
            }
            return this;
        }
        
        
        
        public function dispatchEventTrigger(noteOn:Bool) : Bool
        {
            if (noteOn) {
                if (_callbackBeforeNoteOn  != null) return _callbackBeforeNoteOn(this);
            } else {
                if (_callbackBeforeNoteOff != null) return _callbackBeforeNoteOff(this);
            }
            return false;
        }
        
        
        
        public function sequenceOn(seq:MMLSequence, sampleLength:Int=0, sampleDelay:Int=0) : SiMMLTrack
        {
            _trackStartDelay = sampleDelay;
            _trackStopDelay = sampleLength;
            _mmlData = (seq != null) ? (cast(seq._owner,SiMMLData)) : null;
            executor.initialize(seq);
            return this;
        }
        
        
         
        public function sequenceOff(sampleDelay:Int=0, stopWithReset:Bool=false) : SiMMLTrack
        {
            _stopWithReset = stopWithReset;
            if (sampleDelay != 0) {
                _trackStopDelay = sampleDelay;
            } else {
                executor.clear();
                if (_stopWithReset) channel.reset();
            }
            return this;
        }
        
        
        
        public function limitLength(stopDelay:Int) : Void
        {
            var length:Int = stopDelay - _trackStartDelay;
            if (length < _keyOnLength) {
                _keyOnLength = length;
                _keyOnCounter = _keyOnLength;
            }
        }
        
        
        
        public function setDisposable() : Void 
        {
            _isDisposable = true;
        }
        
        
        
        
    
    
        
        public function setNote(note:Int, sampleLength:Int, slur:Bool=false) : Void
        {
            
            if ((quantRatio == 0 || sampleLength > 0) && !slur) {
                _keyOnLength = Std.int(sampleLength * quantRatio) - quantCount - keyOnDelay;
                if (_keyOnLength < 1) _keyOnLength = 1;
            } else {
                
                _keyOnLength = 0;
            }
            _mmlKeyOn(note);
            _flagNoKeyOn = slur;
        }
        
        
        
        public function setPitchBend(noteFrom:Int, tickLength:Int) : Void
        {
            executor.bendingFrom(noteFrom, tickLength);
        }
        
        
        
        public function setChannelModuleType(type:Int, channelNum:Int, toneNum:Int=-1) : Void
        {
            
            _channelModuleSetting = _table.channelModuleSetting[type];
            
            
            _voiceIndex = _channelModuleSetting.initializeTone(this, channelNum, channel.bufferIndex());
            
            
            if (toneNum != -1) {
                _voiceIndex = toneNum;
                _channelModuleSetting.selectTone(this, toneNum);
            }
        }
        
        
        
        public function setPortament(frame:Int) : Void
        {
            _set_sweep_step[1] = frame;
            if (frame != 0) {
                _pns_or[1] = true;
                _envelopOn(1);
            } else {
                _envelopOff(1);
            }
        }
        
        
        
        public function setEventTrigger(id:Int, noteOnType:Int=1, noteOffType:Int=0) : Void
        {
            _eventTriggerID = id;
            _eventTriggerTypeOn  = noteOnType;
            _eventTriggerTypeOff = noteOffType;
            _callbackBeforeNoteOn = (noteOnType != 0) ? _eventTriggerOn : null;
            _callbackBeforeNoteOff = (noteOffType != 0) ? _eventTriggerOff : null;
        }
        
        
        
        public function dispatchNoteOnEvent(id:Int, noteOnType:Int=1) : Void
        {
            if (noteOnType != 0) {
                var currentTID:Int  = _eventTriggerID, 
                    currentType:Int = _eventTriggerTypeOn;
                _eventTriggerID = id;
                _eventTriggerTypeOn = noteOnType;
                _eventTriggerOn(this);
                _eventTriggerID = currentTID;
                _eventTriggerTypeOn = currentType;
            }
        }
        
        
        
        public function setEnvelopFPS(fps:Int) : Void
        {
            _env_internval = Std.int(SiOPMTable.instance().rate / fps);
        }
        
        
        
        public function setReleaseSweep(sweep:Int) : Void
        {
            _set_sweep_step[0] = sweep << FIXED_BITS;
            _set_sweep_end[0]  = (sweep<0) ? 0 : SWEEP_MAX;
            if (sweep != 0) {
                _pns_or[0] = true;
                _envelopOn(0);
            } else {
                _envelopOff(0);
            }
        }
        
        
        
        public function setModulationEnvelop(isPitchMod:Bool, depth:Int, end_depth:Int, delay:Int, term:Int) : Void
        {
            
            var table: Array<SLLint> = (isPitchMod) ? _table_env_mp : _table_env_ma;
            
            
            if (table[1] != null) SLLint.freeList(table[1]);

            if ((0<=depth && depth<end_depth) || (depth<0 && depth>end_depth)) {
                
                table[1] = _makeModulationTable(depth, end_depth, delay, term);
                _envelopOn(1);
            } else {
                
                table[1] = null;
                if (isPitchMod) channel.setPitchModulation(depth);
                else            channel.setAmplitudeModulation(depth);
                _envelopOff(1);
            }
        }
        
        
        
        public function setToneEnvelop(noteOn:Int, table:SiMMLEnvelopTable, step:Int) : Void
        {
            if (table==null || step==0) {
                _set_env_voice[noteOn] = null;
                _envelopOff(noteOn);
            } else {
                _set_env_voice[noteOn] = table.head;
                _set_cnt_voice[noteOn] = step;
                _envelopOn(noteOn);
            }
        }
        
        
        
        public function setAmplitudeEnvelop(noteOn:Int, table:SiMMLEnvelopTable, step:Int, offset:Bool = false) : Void
        {
            if (table==null || step==0) {
                _set_env_exp[noteOn] = null;
                _envelopOff(noteOn);
            } else {
                _set_env_exp[noteOn] = table.head;
                _set_cnt_exp[noteOn] = step;
                _set_exp_offset[noteOn] = offset;
                _envelopOn(noteOn);
            }
        }
        
        
        
        public function setFilterEnvelop(noteOn:Int, table:SiMMLEnvelopTable, step:Int) : Void
        {
            if (table==null || step==0) {
                _set_env_filter[noteOn] = null;
                _envelopOff(noteOn);
            } else {
                _set_env_filter[noteOn] = table.head;
                _set_cnt_filter[noteOn] = step;
                _envelopOn(noteOn);
            }
        }
        
        
        
        public function setPitchEnvelop(noteOn:Int, table:SiMMLEnvelopTable, step:Int) : Void
        {
            if (table==null || step==0) {
                _set_env_pitch[noteOn] = _env_zero_table;
                _envelopOff(noteOn);
            } else {
                _set_env_pitch[noteOn] = table.head;
                _set_cnt_pitch[noteOn] = step;
                _pns_or[noteOn]        = true;
                _envelopOn(noteOn);
            }
        }
        
        
        
        public function setNoteEnvelop(noteOn:Int, table:SiMMLEnvelopTable, step:Int) : Void
        {
            if (table==null || step==0) {
                _set_env_note[noteOn] = _env_zero_table;
                _envelopOff(noteOn);
            } else {
                _set_env_note[noteOn] = table.head;
                _set_cnt_note[noteOn] = step;
                _pns_or[noteOn]       = true;
                _envelopOn(noteOn);
            }
        }
        
        
        
        
    
    
    
    
    
        
        public function _initialize(seq:MMLSequence, fps:Int, internalTrackID:Int, eventTriggerOn:Dynamic, eventTriggerOff:Dynamic, isDisposable:Bool) : SiMMLTrack
        {
            _internalTrackID = internalTrackID;
            _isDisposable = isDisposable;
            _defaultFPS = fps;
            _eventTriggerOn = eventTriggerOn;
            _eventTriggerOff = eventTriggerOff;
            _eventTriggerID = -1;
            _eventTriggerTypeOn = 0;
            _eventTriggerTypeOff = 0;
            _mmlData = (seq != null) ? (cast(seq._owner,SiMMLData)) : null;
            executor.initialize(seq);
            
            return this;
        }
        
        
        
        public function _reset(bufferIndex:Int) : Void
        {
            var i:Int;
            
            
            _channelModuleSetting = _table.channelModuleSetting[SiMMLTable.MT_PSG];
            _channelNumber = 0;
            
            
            if (_mmlData != null) {
                _vcommandShift = _mmlData.defaultVCommandShift;
                _velocityMode = _mmlData.defaultVelocityMode;
                _expressionMode = _mmlData.defaultExpressionMode;
            } else {
                _vcommandShift = 4;
                _velocityMode = SiOPMTable.VM_LINEAR;
                _expressionMode = SiOPMTable.VM_LINEAR;
            }
            _velocity = 256;
            _expression = 128;
            _pitchBend = 0;
            _note = -1;
            channel = null;
            _voiceIndex = _channelModuleSetting.initializeTone(this, 0, bufferIndex);
            var tlTables: Array<Array<Int>> = SiOPMTable.instance().eg_tlTables;
            channel.setVolumeTables(tlTables[_velocityMode], tlTables[_expressionMode]);
            
            
            noteShift = 0;
            pitchShift = 0;
            _keyOnCounter = 0;
            _keyOnLength = 0;
            _flagNoKeyOn = false;
            _processMode = normal;
            _trackStartDelay = 0;
            _trackStopDelay = 0;
            _stopWithReset = false;
            keyOnDelay = 0;
            quantRatio = 1;
            quantCount = 0;
            eventMask = NO_MASK;
            _env_pitch_active = false;
            _pitchIndex = 0;
            _sweep_pitch = 0;
            _env_exp_offset = 0;
            setEnvelopFPS(_defaultFPS);
            _callbackBeforeNoteOn = null;
            _callbackBeforeNoteOff = null;
            _callbackUpdateRegister = _defaultUpdateRegister;
            _residue = 0;
            _priority = 0;
            _env_exp    = null;
            _env_voice  = null;
            _env_note   = _env_zero_table;
            _env_pitch  = _env_zero_table;
            _env_filter = null;
            _env_ma = null;
            _env_mp = null;
            
            
           i=0;
 while( i<2){
                _set_processMode[i] = normal;
                _set_env_exp[i]    = null;
                _set_env_voice[i]  = null;
                _set_env_note[i]   = _env_zero_table;
                _set_env_pitch[i]  = _env_zero_table;
                _set_env_filter[i] = null;
                _pns_or[i]         = false;
                _set_exp_offset[i] = false;
                _set_cnt_exp[i]    = 1;
                _set_cnt_voice[i]  = 1;
                _set_cnt_note[i]   = 1;
                _set_cnt_pitch[i]  = 1;
                _set_cnt_filter[i] = 1;
                _set_sweep_step[i] = 0;
                _set_sweep_end[i]  = 0;
                _table_env_ma[i]   = null;
                _table_env_mp[i]   = null;
             i++;
}
            
            
            executor.resetPointer();
        }
        
        
        
        public function _resetVolumeOffset() : Void
        {
            channel.offsetVolume(_expression, _velocity);
        }
        
        
        
        
    
    
        
        public function _prepareBuffer(bufferingLength:Int) : Int
        {
            
            if (_mmlData != null) _mmlData._registerAllTables();
            else { 
                SiOPMTable._instance.samplerTables[0].stencil = null;
                SiOPMTable._instance._stencilCustomWaveTables = null;
                SiOPMTable._instance._stencilPCMVoices        = null;
                _table._stencilEnvelops = null;
                _table._stencilVoices   = null;
            }
            
            
            if (_trackStartDelay == 0) {
                return bufferingLength;
            }

            
            if (bufferingLength <= _trackStartDelay) {
                _trackStartDelay -= bufferingLength;
                return 0;
            }
            
            
            var len:Int = bufferingLength - _trackStartDelay;
            channel.nop(_trackStartDelay);
            _trackStartDelay = 0;
            
            _priority++;
            
            return len;
        }
        
        
        
        public function _buffer(length:Int) : Void
        {
            
            var trackStop:Bool = false, trackStopResume:Int = 0;
            if (_trackStopDelay > 0) {
                if (_trackStopDelay > length) {
                    _trackStopDelay -= length;
                } else {
                    trackStopResume = length - _trackStopDelay;
                    trackStop = true;
                    length = _trackStopDelay;
                    _trackStopDelay = 0;
                }
            }
            
			var s:Dynamic = function (procLen:Int) : Void {
                switch(_processMode) {
                case normal:    channel.buffer(procLen);                     
                case envelop:   _residue = _bufferEnvelop(procLen, _residue);
                }
            }
			
            
            if (_keyOnCounter == 0) {
                
                s(length);
            } else 
            if (_keyOnCounter > length) {
                
                s(length);
                _keyOnCounter -= length;
            } else {
                
                length -= _keyOnCounter;
                s(_keyOnCounter);
                _toggleKey();
                if (length>0) s(length);
            }
            
            
            if (trackStop) {
                if (executor.pointer != null) {
                    executor.stop();
                    if (_stopWithReset) {
                        _keyOff();
                        _note = -1;
                        channel.reset();
                    }
                } else if (channel.isNoteOn()) {
                    _keyOff();
                    _note = -1;
                    if (_stopWithReset) {
                        channel.reset();
                    }
                }
                if (trackStopResume>0) s(trackStopResume);
            }
            
            
       
        }
        
        
        
        private function _bufferEnvelop(length:Int, step:Int) : Int
        {
            var x:Int;
            
            while (length >= step) {
                
                if (step > 0) channel.buffer(step);
                
                
                if (_env_exp != null && --_cnt_exp == 0) {
                    x = _env_exp_offset + _env_exp.i;
                    if (x<0) {x=0;} else if (x>128) {x=128;}
                    channel.offsetVolume(x, _velocity);
                    _env_exp = _env_exp.next;
                    _cnt_exp = _max_cnt_exp;
                }
                
                
                if (_env_pitch_active) {
                    channel.pitch(_env_pitch.i + (_env_note.i<<6) + (_sweep_pitch>>FIXED_BITS));
                    
                    if (--_cnt_pitch == 0) {
                        _env_pitch = _env_pitch.next;
                        _cnt_pitch = _max_cnt_pitch;
                    }
                    
                    if (--_cnt_note == 0) {
                        _env_note = _env_note.next;
                        _cnt_note = _max_cnt_note;
                    }
                    
                    _sweep_pitch += _sweep_step;
                    if (_sweep_step>0) {
                        if (_sweep_pitch > _sweep_end) {
                            _sweep_pitch = _sweep_end;
                            _sweep_step = 0;
                        }
                    } else {
                        if (_sweep_pitch < _sweep_end) {
                            _sweep_pitch = _sweep_end;
                            _sweep_step = 0;
                        }
                    }
                }
                
                
                if (_env_filter != null && --_cnt_filter == 0) {
                    channel.offsetFilter(_env_filter.i);
                    _env_filter = _env_filter.next;
                    _cnt_filter = _max_cnt_filter;
                }
                
                
                if (_env_voice != null && --_cnt_voice == 0) {
                    _channelModuleSetting.selectTone(this, _env_voice.i);
                    _env_voice = _env_voice.next;
                    _cnt_voice = _max_cnt_voice;
                }
                
                
                if (_env_ma != null) {
                    channel.setAmplitudeModulation(_env_ma.i);
                    _env_ma = _env_ma.next;
                }
                if (_env_mp != null) {
                    channel.setPitchModulation(_env_mp.i);
                    _env_mp = _env_mp.next;
                }
                
                
                length -= step;
                step = _env_internval;
            }

            
            if (length > 0) channel.buffer(length);
            
            
            return _env_internval - length;
        }
        
        
        
        
    
    
        
        private function _toggleKey() : Void
        {
            if (channel.isNoteOn()) {
                _keyOff();
            }else {
                _keyOn();
            }
        }
        
        
        
        private function _keyOn() : Void
        {
            
            if (_callbackBeforeNoteOn != null) {
                if (!_callbackBeforeNoteOn(this)) return;
            }
            
            
            var oldPitch:Int = channel.get_pitch();
            _pitchIndex = ((_note + noteShift)<<6) + pitchShift;
            channel.pitch( _pitchIndex + _pitchBend);

            
            if (!_flagNoKeyOn) {
                
                if (_processMode == envelop) {
                    channel.offsetVolume(_expression, _velocity);
                    _channelModuleSetting.selectTone(this, _voiceIndex);
                    channel.offsetFilter(128);
                }
                
                if (channel.isNoteOn()) {
                    
                    if (_callbackBeforeNoteOff != null) _callbackBeforeNoteOff(this);
                    channel.noteOff();
                }
                
                _updateProcess(1);
                
                channel.noteOn();
            } else {
                
                if (_set_sweep_step[1]>0) {
                    channel.pitch(oldPitch);
                    _sweep_step  = Std.int(((_pitchIndex - oldPitch) << FIXED_BITS) / _set_sweep_step[1]);
                    _sweep_end   = _pitchIndex << FIXED_BITS;
                    _sweep_pitch = oldPitch << FIXED_BITS;
                } else {
                    _sweep_pitch = channel.get_pitch() << FIXED_BITS;
                }
                
                _envelopOff(1);
            }

            _flagNoKeyOn = false;
            
            
            _keyOnCounter = _keyOnLength;
        }
        
        
        
        private function _keyOff() : Void
        {
            
            if (_callbackBeforeNoteOff != null) {
                if (!_callbackBeforeNoteOff(this)) return;
            }
            
            
            channel.noteOff();
            
            _keyOnCounter = 0;
            
            _updateProcess(0);
            
            _priority += 32;
        }
        
        
        private function _updateProcess(keyOn:Int) : Void
        {
            
            _processMode = _set_processMode[keyOn];
            
            if (_processMode == envelop) {
                
                _env_exp    = _set_env_exp[keyOn];
                _env_voice  = _set_env_voice[keyOn];
                _env_note   = _set_env_note[keyOn];
                _env_pitch  = _set_env_pitch[keyOn];
                _env_filter = _set_env_filter[keyOn];
                
                _max_cnt_exp    = _set_cnt_exp[keyOn];
                _max_cnt_voice  = _set_cnt_voice[keyOn];
                _max_cnt_note   = _set_cnt_note[keyOn];
                _max_cnt_pitch  = _set_cnt_pitch[keyOn];
                _max_cnt_filter = _set_cnt_filter[keyOn];
                _cnt_exp    = 1;
                _cnt_voice  = 1;
                _cnt_note   = 1;
                _cnt_pitch  = 1;
                _cnt_filter = 1;
                
                _env_ma = _table_env_ma[keyOn];
                _env_mp = _table_env_mp[keyOn];
                
                _sweep_step = (keyOn != 0) ? 0 : _set_sweep_step[keyOn];
                _sweep_end  = (keyOn != 0) ? 0 : _set_sweep_end[keyOn];
                
                _sweep_pitch = channel.get_pitch() << FIXED_BITS;
                _env_exp_offset   = (_set_exp_offset[keyOn]) ? _expression : 0;
                _env_pitch_active = _pns_or[keyOn];
                
                if (!channel.isFilterActive()) channel.activateFilter((_env_filter != null));
                
                _residue = 0;
            }
        }
        
        
        
        
    
    
        
        public function _onRestEvent() : Void
        {
            _flagNoKeyOn = false;
        }
        

        
		public function _onNoteEvent(note:Int, length:Int) : Void
        {
            _keyOnLength = Std.int(length * quantRatio) - quantCount - keyOnDelay;
            if (_keyOnLength < 1) _keyOnLength = 1;
            _mmlKeyOn(note);
        }
        

        
        public function _onSlur() : Void
        {
            _flagNoKeyOn = true;
            _keyOnCounter = 0;
        }

        
        
        public function _onSlurWeak() : Void
        {
            _keyOnCounter = 0;
        }
        
        
        
        public function _onPitchBend(nextNote:Int, term:Int) : Void
        {
            var startPitch:Int = channel.get_pitch();
			var  endPitch  :Int = ((nextNote + noteShift) << 6);
			
			endPitch = (endPitch != 0 ) ? endPitch + pitchShift : (startPitch & 63) + pitchShift;
			
            _onSlur();
			
            if (startPitch == endPitch) return;
            
            _sweep_step = ((endPitch - startPitch) << FIXED_BITS) * Std.int(_env_internval / term);
            _sweep_end  = endPitch << FIXED_BITS;
            _sweep_pitch = startPitch << FIXED_BITS;
            _env_pitch_active = true;
            _env_note  = _set_env_note[1];
            _env_pitch = _set_env_pitch[1];
            
            _processMode = envelop;
        }
        
        
        
        public function _changeNoteLength(length:Int) : Void
        {
            _keyOnCounter = Std.int(length * quantRatio) - quantCount - keyOnDelay;
            if (_keyOnCounter < 1) _keyOnCounter = 1;
        }
        
        
        
        public function _setChannelParameters(param: Array<Int>) : MMLSequence
        {
            var ret:MMLSequence = null;
            if (param[0] != INT_MIN_VALUE ) {
                ret = _channelModuleSetting.selectTone(this, param[0]);
                _voiceIndex = param[0];
            }
            channel.setParameters(param);
            return ret;
        }
        
        
        public function _mmlVCommand(v:Int) : Void 
        {
            _velocity = v << _vcommandShift;
        }
        
        
        public function _mmlVShift(v:Int) : Void 
        {
			_velocity += v << _vcommandShift;
        }
        
        
        private function _defaultUpdateRegister(addr:Int, data:Int) : Void
        {
            channel.setRegister(addr, data);
        }
        
        
        
        private function _mmlKeyOn(note:Int) : Void
        {
            _note = note;
            _trackStartDelay = 0;
            if (keyOnDelay != 0) {
                _keyOff();
                _keyOnCounter = keyOnDelay;
            } else {
                _keyOn();   
            }
        }
        
        
    
    
        
        private function _envelopOff(noteOn:Int) : Void
        {
            
            if (_set_sweep_step[noteOn] == 0  && 
                _set_env_pitch[noteOn] == _env_zero_table && 
                _set_env_note[noteOn]  == _env_zero_table)
            {
                _pns_or[noteOn] = false;
            }
            
            
            if (!_pns_or[noteOn]         && 
                _table_env_ma[noteOn] == null   && 
                _table_env_mp[noteOn] == null  && 
                _set_env_exp[noteOn] == null   && 
                _set_env_filter[noteOn] == null && 
                _set_env_voice[noteOn] == null)
            {
                _set_processMode[noteOn] = normal;
            }
        }
        
        
        
        private function _envelopOn(noteOn:Int) : Void
        {
            _set_processMode[noteOn] = envelop;
        }
        
        
        
        private function _makeModulationTable(depth:Int, end_depth:Int, delay:Int, term:Int) : SLLint
        {
            
            var list:SLLint = SLLint.allocList(delay + term + 1),
                i:Int, elem:SLLint, step:Int;
            
            
            elem = list;
            if (delay != 0) {
               i=0;
 while( i<delay){
                    elem.i = depth;
                 i++; elem=elem.next;
}
            }
            
            if (term != 0) {
                depth <<= FIXED_BITS;
                step = Std.int(((end_depth<<FIXED_BITS) - depth) / term);
               i=0;
 while( i<term){ 
                    elem.i = (depth >> FIXED_BITS);
                    depth += step;
                 i++; elem=elem.next;
}
            }
            
            elem.i = end_depth;
            
            return list;
        }
    }


