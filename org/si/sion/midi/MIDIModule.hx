






package org.si.sion.midi ;
    import org.si.sion.SiONDriver;
    import org.si.sion.effector.SiEffectStereoReverb;
	import org.si.sion.effector.SiEffectStereoChorus;
	import org.si.sion.effector.SiEffectStereoDelay;
    import org.si.sion.events.SiONMIDIEvent;
    import org.si.sion.sequencer.SiMMLTrack;
    import org.si.sion.module.SiOPMWaveSamplerTable;
    import org.si.sion.module.channels.SiOPMChannelBase;
    import org.si.sion.utils.SiONPresetVoice;
    import flash.utils.ByteArray;
    
    
    
    class MIDIModule
    {
    
    
        
        static public var GM_MODE:String = "GMmode";
        
        static public var GS_MODE:String = "GSmode";
        
        static public var XG_MODE:String = "XGmode";
        
        
        
    
    
        
        public var voiceSet: Array<SiONVoice>;
        
        public var drumVoiceSet: Array<SiONVoice>;
        
        public var midiChannels: Array<MIDIModuleChannel>;
        
        public var onNRPN:Dynamic = null;
        
        public var onSysEx:Dynamic = null;
        
        public var onFinishSequence:Dynamic = null;
        
        private var _sionDriver:SiONDriver = null;
        
        private var _polyphony:Int;
        
        private var _freeOperators:MIDIModuleOperator;
        private var _activeOperators:MIDIModuleOperator;
        
        private var _drumExclusiveGroupID: Array<Int>;
        private var _drumExclusiveOperator: Array<MIDIModuleOperator>;
        private var _drumNoteOffAvailable: Array<Int>;

        private var _effectorSet: Array<Array<Dynamic>>;
        
        private var _dataEntry:Int;
        private var _rpnNumber:Int;
        private var _isNRPN:Bool;
        private var _portOffset:Int;
        private var _portNumber:Int;
        private var _systemExclusiveMode:String;

        private var _dispatchFlags:Int = 0;
        
        
    
    
        
        public function get_polyphony() : Int { return _polyphony; }
        public function polyphony(poly:Int) : Void { 
            _polyphony = poly;
        }
        
        public function get_midiChannelCount() : Int { return midiChannels.length; }
        public function midiChannelCount(count:Int) : Void {
           // midiChannels.length = count;
           var ch:Int=0;
 while( ch<count){
                if (midiChannels[ch] == null) midiChannels[ch] = new MIDIModuleChannel();
                midiChannels[ch].eventTriggerID = ch;
             ch++;
}
            _portOffset = 0;
        }
        
        public function freeOperatorCount() : Int { return _freeOperators.length; }
        
        public function activeOperatorCount() : Int { return _activeOperators.length; }
        
        public function get_portNumber() : Int { return _portNumber; }
        public function portNumber(portNum:Int) : Void {
            _portNumber = portNum;
            if (midiChannels.length > (portNum<<4)+15) _portOffset = portNum<<4;
            else _portOffset = (midiChannels.length-15) >> 4;
        }
        
        public function get_systemExclusiveMode() : String { return _systemExclusiveMode; }
        public function systemExclusiveMode(mode:String) : Void { 
            _systemExclusiveMode = mode;
        }
        
        
        
        
        
    
    
        
        public function new(polyphony:Int=32, midiChannelCount:Int=16, systemExclusiveMode:String="")
        {
            var slot:Int, i:Int;
            _systemExclusiveMode = systemExclusiveMode;
            _polyphony = polyphony;
            _freeOperators = new MIDIModuleOperator(null);
            _activeOperators = new MIDIModuleOperator(null);
            midiChannels = new Array<MIDIModuleChannel>();
            
            voiceSet = new Array<SiONVoice>();
            drumVoiceSet = new Array<SiONVoice>();
            _drumExclusiveGroupID = new Array<Int>();
            _drumExclusiveOperator = new Array<MIDIModuleOperator>();
            _drumNoteOffAvailable = new Array<Int>();
            _effectorSet = new Array<Array<Dynamic>>();
           slot=0;
 while( slot<8){ _effectorSet[slot] = null; slot++;
}
            _effectorSet[1] = [new SiEffectStereoReverb(0.7,0.4,0.8,1)];
            _effectorSet[2] = [new SiEffectStereoChorus(20,0.1,4,20,1)];
            _effectorSet[3] = [new SiEffectStereoDelay(250,0.25,false,1)];
            setDrumExclusiveGroup(1, [42,44,46]); 
            setDrumExclusiveGroup(2, [80,81]);    
            enableDrumNoteOff([71, 72]);          
            
            
            this.midiChannelCount(midiChannelCount);
            
            var preset:SiONPresetVoice = SiONPresetVoice.mutex();
            if ( preset == null || !preset.dynProperties.exists("svmidi") || !preset.dynProperties.exists("svmidi.drum")) {
                preset = new SiONPresetVoice(SiONPresetVoice.INCLUDE_WAVETABLE | SiONPresetVoice.INCLUDE_SINGLE_DRUM);
            }
           i=0;
 while( i<128){
                voiceSet[i] = preset.dynProperties.get("svmidi")[i];
             i++;
}
           i=0;
 while( i<60){
                drumVoiceSet[i + 24] = preset.dynProperties.get("svmidi.drum")[i];
             i++;
}
        }
        
        
        
        
    
    
        
        public function _initialize(useMIDIModuleEffector:Bool) : Bool
        {
            var i:Int, ope:MIDIModuleOperator;
            _sionDriver = SiONDriver.mutex();
            if (_sionDriver == null) return false;
            
            resetAllChannels();
            _freeOperators.clear();
            _activeOperators.clear();
           i=0;
 while( i<_polyphony){
                _freeOperators.push(new MIDIModuleOperator(_sionDriver.newUserControlableTrack(i)));
             i++;
}
           i=0;
 while( i<16){
                _drumExclusiveOperator[i] = null;
             i++;
}
            
            _dataEntry = 0;
            _rpnNumber = 0;
            _isNRPN = false;
            _portOffset = 0;
            
            if (useMIDIModuleEffector) {
               i=0;
 while( i<8){
                    if (_effectorSet[i] != null) _sionDriver.effector.setEffectorList(i, _effectorSet[i]);
                 i++;
}
            }
            
            _dispatchFlags = _sionDriver._checkMIDIEventListeners();
            
            return true;
        }
        
        
        
        public function setDrumSamplerTable(table:SiOPMWaveSamplerTable) : Void
        {
            var voice:SiONVoice = new SiONVoice(), i:Int;
            voice.setSamplerTable(table);
           i=0;
 while( i<128){ drumVoiceSet[i] = voice; i++;
}
        }
        
        
        
        public function setDrumExclusiveGroup(groupID:Int, voiceNumbers:Array<Dynamic>) : Void
        {
           var i:Int=0;
 while( i<voiceNumbers.length){ _drumExclusiveGroupID[voiceNumbers[i]] = groupID; i++;
}
        }
        
        
        
        public function setDefaultEffector(slot:Int, effectorList:Array<Dynamic>) : Void 
        {
            _effectorSet[slot] = effectorList;
        }
        
        
        public function enableDrumNoteOff(voiceNumbers:Array<Dynamic>, enable:Bool=true) : Void
        {
           var i:Int=0;
 while( i<voiceNumbers.length){ _drumNoteOffAvailable[voiceNumbers[i]] = (enable)?1:0; i++;
}
        }
        
        
        public function resetAllChannels() : Void
        {
           var ch:Int=0;
 while( ch<midiChannels.length){
                midiChannels[ch].reset();
                if ((ch & 15) == 9) midiChannels[ch].drumMode = 1;
             ch++;
}
        }
        
        
        
        public function noteOn(channelNum:Int, note:Int, velocity:Int=64) : Void
        {
            channelNum += _portOffset;
            var midiChannel:MIDIModuleChannel = midiChannels[channelNum], voice:SiONVoice, 
                ope:MIDIModuleOperator, track:SiMMLTrack, channel:SiOPMChannelBase,
                drumExcID:Int = 0, 
                sionTrackNote:Int = note;
            
            if (midiChannel.mute) return;
            
            
            if (midiChannel.activeOperatorCount >= midiChannel.maxOperatorCount) {
               ope=_activeOperators.next;
 while( ope!=_activeOperators){
                    if (ope.channel == channelNum) {
                        _activeOperators.remove(ope);
                        break;
                    }
                 ope=ope.next;
}
            } else {
				var tmpope:MIDIModuleOperator = _freeOperators.shift();
                ope = (tmpope != null) ? tmpope : _activeOperators.shift();
            }
            
            if (ope.isNoteOn) {
                ope.sionTrack.dispatchEventTrigger(false);
                midiChannels[ope.channel].activeOperatorCount--;
            }
            
            
            if (midiChannel.drumMode == 0) {
                if (ope.programNumber != midiChannel.programNumber) {
                    ope.programNumber = midiChannel.programNumber;
                    voice = voiceSet[ope.programNumber];
                    if (voice != null) {
                        ope.sionTrack.quantRatio = 1;
                        voice.updateTrackVoice(ope.sionTrack);
                    } else {
                        _freeOperators.push(ope);
                        return;
                    }
                }
            } else {
                ope.programNumber = -1;
                voice = drumVoiceSet[note];
                if (voice != null) {
                    drumExcID = _drumExclusiveGroupID[note];
                    sionTrackNote = (voice.preferableNote == -1) ? 60 : voice.preferableNote;
                    if (drumExcID > 0) {
                        var excOpe:MIDIModuleOperator = _drumExclusiveOperator[drumExcID];
                        if (excOpe != null && excOpe.drumExcID == drumExcID) {
                            if (excOpe.isNoteOn) _noteOffOperator(excOpe);
                            excOpe.sionTrack.keyOff(0, true);
                        }
                        _drumExclusiveOperator[drumExcID] = ope;
                    }
                    ope.sionTrack.quantRatio = 1;
                    voice.updateTrackVoice(ope.sionTrack);
                } else {
                    _freeOperators.push(ope);
                    return;
                }
            }
            
            
            track = ope.sionTrack;
            channel = track.channel;
            
            track.noteShift = midiChannel.masterCoarseTune;
            track.pitchShift = midiChannel.masterFineTune;
            track.pitchBend ((midiChannel.pitchBend * midiChannel.pitchBendSensitivity) >> 7); 
            track.setPortament(midiChannel.portamentoTime);
            track.setEventTrigger(midiChannel.eventTriggerID, midiChannel.eventTriggerTypeOn, midiChannel.eventTriggerTypeOff);
            track.velocity (Std.int(velocity * 1.5) + 64);
            channel.setAllStreamSendLevels(midiChannel._sionVolumes);
            channel.pan ( midiChannel.pan);
            channel.setLFOCycleTime(midiChannel.modulationCycleTime);
            channel.setPitchModulation(midiChannel.modulation>>2);            
            channel.setAmplitudeModulation(midiChannel.channelAfterTouch>>2); 
            track.keyOn(sionTrackNote);
            
            ope.isNoteOn = true;
            ope.note = note;
            ope.channel = channelNum;
            ope.drumExcID = drumExcID;
            _activeOperators.push(ope);
            midiChannel.activeOperatorCount++;
            if ((_dispatchFlags & 1) != 0) _sionDriver._dispatchMIDIEvent(SiONMIDIEvent.NOTE_ON, track, channelNum, note, velocity);
        }
        
        
        
        public function noteOff(channelNum:Int, note:Int, velocity:Int=0) : Void
        {
            channelNum += _portOffset;
            if (midiChannels[channelNum].mute) return;
            
            var ope:MIDIModuleOperator, i:Int=0;
           ope=_activeOperators.next;
 while( ope!=_activeOperators){
                if (ope.note == note && ope.channel == channelNum && ope.isNoteOn) {
                    _noteOffOperator(ope);
                    return;
                }
             ope=ope.next;
}
        }
        
        
        private function _noteOffOperator(ope:MIDIModuleOperator) : Void
        {
            var channelNum:Int = ope.channel, note:Int = ope.note,
                midiChannel:MIDIModuleChannel = midiChannels[channelNum];
            if (midiChannel.sustainPedal) ope.sionTrack.dispatchEventTrigger(false);
            else if (midiChannel.drumMode == 0 || _drumNoteOffAvailable[note] != 0) ope.sionTrack.keyOff();
            ope.isNoteOn = false;
            ope.note = -1;
            ope.channel = -1;
            midiChannel.activeOperatorCount--;
            _activeOperators.remove(ope);
            _freeOperators.push(ope);
            if ((_dispatchFlags & 2) != 0) _sionDriver._dispatchMIDIEvent(SiONMIDIEvent.NOTE_OFF, ope.sionTrack, channelNum, note, 0);
        }
        
        
        
        public function programChange(channelNum:Int, programNumber:Int) : Void
        {
            channelNum += _portOffset;
            var midiChannel:MIDIModuleChannel = midiChannels[channelNum];
            midiChannel.programNumber = programNumber;
            
            if ((_dispatchFlags & 8) != 0) _sionDriver._dispatchMIDIEvent(SiONMIDIEvent.PROGRAM_CHANGE, null, channelNum, 0, programNumber);
        }
        
        
        
        public function channelAfterTouch(channelNum:Int, value:Int) : Void
        {
            channelNum += _portOffset;
            var midiChannel:MIDIModuleChannel = midiChannels[channelNum];
            midiChannel.channelAfterTouch = value;
            
           var ope:MIDIModuleOperator=_activeOperators.next;
 while( ope!=_activeOperators){
                if (ope.channel == channelNum) {
                    ope.sionTrack.channel.setAmplitudeModulation(midiChannel.channelAfterTouch>>2);
                }
             ope=ope.next;
}
        }
        
        
        
        public function pitchBend(channelNum:Int, bend:Int) : Void
        {
            channelNum += _portOffset;
            var midiChannel:MIDIModuleChannel = midiChannels[channelNum];
            midiChannel.pitchBend = bend;
            
           var ope:MIDIModuleOperator=_activeOperators.next;
 while( ope!=_activeOperators){
                if (ope.channel == channelNum) {
                    ope.sionTrack.pitchBend ((midiChannel.pitchBend * midiChannel.pitchBendSensitivity) >> 7); 
                }
             ope=ope.next;
}
            if ((_dispatchFlags & 16) != 0) _sionDriver._dispatchMIDIEvent(SiONMIDIEvent.PITCH_BEND, null, channelNum, 0, bend);
        }
        
        
        
        public function controlChange(channelNum:Int, controlerNumber:Int, data:Int) : Void
        {
            channelNum += _portOffset;
            var midiChannel:MIDIModuleChannel = midiChannels[channelNum];
			
			var S:Dynamic =  function(func:Dynamic) : Void {
               var ope:MIDIModuleOperator=_activeOperators.next;
 while( ope!=_activeOperators){
                    if (ope.channel == channelNum) func(ope);
                 ope=ope.next;
}
            }
            
            switch (controlerNumber) {
            case SMFEvent.CC_BANK_SELECT_MSB:
                midiChannel.bankNumber = (data & 0x7f) << 7;
                
                if (_systemExclusiveMode == XG_MODE) {
                    if ((data & 0x7f) == 127) midiChannel.drumMode = 1;
                    else if (channelNum != 9) midiChannel.drumMode = 0;
                }
         
            case SMFEvent.CC_BANK_SELECT_LSB:
                midiChannel.bankNumber |= data & 0x7f;
          
                
            case SMFEvent.CC_MODULATION:
                midiChannel.modulation = data;
                S(function(ope:MIDIModuleOperator):Void { ope.sionTrack.channel.setPitchModulation(midiChannel.modulation>>2); });
           
            case SMFEvent.CC_PORTAMENTO_TIME:
                midiChannel.portamentoTime = data;
                S(function(ope:MIDIModuleOperator):Void { ope.sionTrack.setPortament(midiChannel.portamentoTime); });
        

            case SMFEvent.CC_VOLUME:
                midiChannel.masterVolume( data );
                S(function(ope:MIDIModuleOperator):Void { ope.sionTrack.channel.setAllStreamSendLevels(midiChannel._sionVolumes); });
       
            
            case SMFEvent.CC_PANPOD:
                midiChannel.pan = data - 64;
                S(function(ope:MIDIModuleOperator):Void { ope.sionTrack.channel.pan (midiChannel.pan); });
   
            case SMFEvent.CC_EXPRESSION:
                midiChannel.expression( data );
                S(function(ope:MIDIModuleOperator):Void { ope.sionTrack.channel.setAllStreamSendLevels(midiChannel._sionVolumes); });
            
                
            case SMFEvent.CC_SUSTAIN_PEDAL:
                midiChannel.sustainPedal = (data > 64);
      
            case SMFEvent.CC_PORTAMENTO:
                midiChannel.portamento = (data > 64);
            
            
            
            
            
            
            
            
            
            case SMFEvent.CC_REVERB_SEND:
                midiChannel.setEffectSendLevel(1, data);
                S(function(ope:MIDIModuleOperator):Void { ope.sionTrack.channel.setAllStreamSendLevels(midiChannel._sionVolumes); });
              
            case SMFEvent.CC_CHORUS_SEND:
                midiChannel.setEffectSendLevel(2, data);
                S(function(ope:MIDIModuleOperator):Void { ope.sionTrack.channel.setAllStreamSendLevels(midiChannel._sionVolumes); });
           
            case SMFEvent.CC_DELAY_SEND:
                midiChannel.setEffectSendLevel(3, data);
                S(function(ope:MIDIModuleOperator):Void { ope.sionTrack.channel.setAllStreamSendLevels(midiChannel._sionVolumes); });
           
                
            case SMFEvent.CC_NRPN_MSB: _rpnNumber =  (data & 0x7f) << 7; 
            case SMFEvent.CC_NRPN_LSB: _rpnNumber |= (data & 0x7f); _isNRPN = true;
            case SMFEvent.CC_RPN_MSB:  _rpnNumber  =  (data & 0x7f) << 7;  
            case SMFEvent.CC_RPN_LSB:  _rpnNumber  |= (data & 0x7f); _isNRPN = false;
            case SMFEvent.CC_DATA_ENTRY_MSB:
                _dataEntry = (data & 0x7f) << 7;
                if (!_isNRPN) _onRPN(midiChannel);
                else if (onNRPN != null) onNRPN(channelNum, _rpnNumber, _dataEntry);
              
            case SMFEvent.CC_DATA_ENTRY_LSB:
                _dataEntry |= (data & 0x7f);
                if (!_isNRPN) _onRPN(midiChannel);
                else if (onNRPN != null) onNRPN(channelNum, _rpnNumber, _dataEntry);
             
            }
            
            if ((_dispatchFlags & 4) != 0) _sionDriver._dispatchMIDIEvent(SiONMIDIEvent.CONTROL_CHANGE, null, channelNum, controlerNumber, data);
            
           
        }
        
        
        
        public function systemExclusive(channelNum:Int, bytes:ByteArray) : Void
        {
                 if (checkByteArray(bytes, _GM_RESET, 0)) { _systemExclusiveMode = GM_MODE; resetAllChannels(); }
            else if (checkByteArray(bytes, _GS_RESET, 0)) { _systemExclusiveMode = GS_MODE; resetAllChannels(); } 
            else if (checkByteArray(bytes, _XG_RESET, 0)) { _systemExclusiveMode = XG_MODE; resetAllChannels(); }
            else if (checkByteArray(bytes, _GS_EXIT, 0)) { _systemExclusiveMode = ""; }
            
            else if (_systemExclusiveMode == GS_MODE) {
                if (checkByteArray(bytes, _GS_UFRP_CMD, 0)) {
                    var trackNum:Int = bytes.readUnsignedByte(),
                        c0x15:Int    = bytes.readUnsignedByte(),
                        mapNum:Int   = bytes.readUnsignedByte();
                    if ((trackNum & 0xf0) != 0x10 || c0x15 != 0x15 || mapNum > 2) return;
                    trackNum = (trackNum & 15) + _portOffset;
                    if (trackNum < midiChannels.length) midiChannels[trackNum].drumMode = mapNum;
                }
            }
            if (onSysEx != null) onSysEx(channelNum, bytes);
        }
        static private var _GM_RESET:Array<Dynamic>    = [0xf0,0x7e,0x7f,0x09,0x01,0xf7];
        static private var _GS_RESET:Array<Dynamic>    = [0xf0,0x41,0x10,0x42,0x12,0x40,0x00,0x7f,0x00,0x41,0xf7];
        static private var _GS_EXIT :Array<Dynamic>    = [0xf0,0x41,0x10,0x42,0x12,0x40,0x00,0x7f,0x7f,0x41,0xf7];
        static private var _XG_RESET:Array<Dynamic>    = [0xf0,0x43,0x10,0x4c,0x00,0x00,0x7e,0x00,0xf7];
        static private var _GS_UFRP_CMD:Array<Dynamic> = [0xf0,0x41,0x10,0x42,0x12,0x40];
        
        
        
        static public function checkByteArray(bytes:ByteArray, checkPattern:Array<Dynamic>, position:Int=-1) : Bool
        {
            if (position != -1) bytes.position = position;
            var i:Int, imax:Int = checkPattern.length;
           i=0;
 while( i<imax){
                var ch:Int = bytes.readUnsignedByte();
                if (checkPattern[i] != ch) return false;
             i++;
}
            return true;
        }
        
        
        
        public function _onFinishSequence() : Void 
        {
            if (onFinishSequence != null) onFinishSequence();
        }
        
        
        
        private function _onRPN(midiChannel:MIDIModuleChannel) : Void
        {
            switch (_rpnNumber) {
            case SMFEvent.RPN_PITCHBEND_SENCE:
                midiChannel.pitchBendSensitivity = _dataEntry >> 7;
 
            case SMFEvent.RPN_FINE_TUNE:
                midiChannel.masterFineTune = (_dataEntry >> 7) - 64;
       
            case SMFEvent.RPN_COARSE_TUNE:
                midiChannel.masterCoarseTune = (_dataEntry >> 7) - 64;
            
            }
        }
    }


