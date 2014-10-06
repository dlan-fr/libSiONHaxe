





package org.si.sion.events ;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.utils.ByteArray;
    import org.si.sion.SiONDriver;
    import org.si.sion.SiONData;
    import org.si.sion.sequencer.SiMMLTrack;
    
    
    
    class SiONTrackEvent extends SiONEvent 
    {
    
    
        
        inline public static var NOTE_ON_STREAM:String = 'noteOnStream';
        
        
        
        inline public static var NOTE_OFF_STREAM:String = 'noteOffStream';

        
        
        inline public static var NOTE_ON_FRAME:String = 'noteOnFrame';

        
        
        inline public static var NOTE_OFF_FRAME:String = 'noteOffFrame';
        
        
        
        inline public static var BEAT:String = 'beat';

        
        
        inline public static var CHANGE_BPM:String = 'changeBPM';        

        
        
        inline public static var USER_DEFINED:String = 'userDefined';        
        
        
        
        
    
    
        
        var _track:SiMMLTrack;
        
        
        var _eventTriggerID:Int;
        
        
        var _note:Int;
        
        
        var _bufferIndex:Int;
        
         
        var _frameTriggerDelay:Float;
        
        
        var _frameTriggerTimer:Int;
        
        
        
        
    
    
        
        public function  track() : SiMMLTrack { return _track; }
        
        
        public function  eventTriggerID() : Int { return _eventTriggerID; }
        
        
        public function  note() : Int { return _note; }
        
        
        public function  bufferIndex() : Int { return _bufferIndex; }
        
        
        public function  frameTriggerDelay() : Float { return _frameTriggerDelay; }
        
        
        
        
    
    
        
        public function new(type:String, driver:SiONDriver, track:SiMMLTrack, bufferIndex:Int=0, note:Int=0, id:Int=0)
        {
            super(type, driver, null, true);
            _track = track;
            if (track != null) {
                _note = track.note();
                _eventTriggerID = track.eventTriggerID();
                _bufferIndex = track.channel.bufferIndex();
                _frameTriggerDelay = track.channel.bufferIndex() / driver.sequencer.sampleRate + driver.latency();
                _frameTriggerTimer = Std.int(_frameTriggerDelay);
            } else {
                _note = note;
                _eventTriggerID = id;
                _bufferIndex = bufferIndex;
                _frameTriggerDelay = bufferIndex / driver.sequencer.sampleRate + driver.latency();
                _frameTriggerTimer = Std.int(_frameTriggerDelay);
            }
        }
        
        
        
        override public function clone() : Event
        { 
            var event:SiONTrackEvent = new SiONTrackEvent(type, _driver, _track);
            event._eventTriggerID = _eventTriggerID;
            event._note = _note;
            event._bufferIndex = _bufferIndex;
            event._frameTriggerDelay = _frameTriggerDelay;
            event._frameTriggerTimer = _frameTriggerTimer;
            return event;
        }
        
        
        
        public function _decrementTimer(frameRate:Int) : Bool
        {
            _frameTriggerTimer -= frameRate;
            return (_frameTriggerTimer <= 0);
        }
    }


