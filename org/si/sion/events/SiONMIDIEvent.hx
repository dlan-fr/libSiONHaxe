





package org.si.sion.events ;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.utils.ByteArray;
    import org.si.sion.SiONDriver;
    import org.si.sion.SiONData;
    import org.si.sion.sequencer.SiMMLTrack;
    import org.si.sion.midi.MIDIModule;
    import org.si.sion.midi.MIDIModuleChannel;
    
    
    
    class SiONMIDIEvent extends SiONTrackEvent 
    {
    
    
        
       inline public static var NOTE_ON:String = 'midiNoteOn';
        
        
        
	   inline public static var NOTE_OFF:String = 'midiNoteOff';

        
        
	   inline public static var CONTROL_CHANGE:String = 'midiControlChange';

        
        
	   inline public static var PROGRAM_CHANGE:String = 'midiProgramChange';
        
        
        
       inline  public static var PITCH_BEND:String = 'midiPitchBend';
        
        
        
        
    
    
        
        private var _2ndValue:Int;
        
        private var _midiChannel:MIDIModuleChannel;
        
        
        
        
    
    
        
        public function controllerNumber() : Int { return _note; }
        
        
        public function value() : Int { return _2ndValue; }
        
        
        public function midiModule() : MIDIModule { return _driver.midiModule(); }
        
        
        public function midiChannel() : MIDIModuleChannel { return _midiChannel; }
        
        
        public function midiChannelNumber() : Int { return _eventTriggerID; }
        
        
        
        
    
    
        
        public function new(type:String, driver:SiONDriver, track:SiMMLTrack, channelNumber:Int, bufferIndex:Int, note:Int, value:Int)
        {
            super(type, driver, track, bufferIndex);
            _midiChannel = _driver.midiModule().midiChannels[channelNumber];
            _eventTriggerID = channelNumber;
            _note = note;
            _2ndValue = value;
        }
        
        
        
        override public function clone() : Event
        { 
            var event:SiONMIDIEvent = new SiONMIDIEvent(type, _driver, _track, midiChannelNumber(), _bufferIndex, _note, _2ndValue);
            event._bufferIndex = _bufferIndex;
            event._frameTriggerDelay = _frameTriggerDelay;
            event._frameTriggerTimer = _frameTriggerTimer;
            return event;
        }
    }


