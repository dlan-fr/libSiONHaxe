












package org.si.sion.midi ;
    import flash.utils.ByteArray;
	import flash.errors.Error;
    
    
    
    class SMFTrack
    {
    
    
        
        public var sequence: Array<SMFEvent> = new Array<SMFEvent>();
        
        public var totalTime:Int;
        
        
        private var _smfData:SMFData;
        
        private var _exitLoop:Bool;
        
        private var _trackIndex:Int;
        
        
        
    
    
        
        public function trackIndex() : Int { return _trackIndex; }
        
        
        public function toString() : String
        {
            var text:String = totalTime + "\n";
			
            var i:Int = 0;
            while( i < sequence.length) {
                text += sequence[i].toString() + "\n";
				 i++;
            }
            
            return text;
        }
        
        
        
        
    
    
        
        public function new(smfData:SMFData, index:Int, bytes:ByteArray)
        {
            _trackIndex = index + 1;
            _smfData = smfData;
            
            var eventType:Int, code:Int, value:Int = 0;
            var deltaTime:Int, time:Int = 0;
            
            _exitLoop = false;
            eventType = -1;
            bytes.position = 0;

            while (bytes.bytesAvailable > 0 && !_exitLoop) {
                deltaTime = _readVariableLength(bytes);
                time += deltaTime;
                
                code = bytes.readUnsignedByte();
                if (!_readMetaEvent(code, bytes, deltaTime, time))
                if (!_readSystemExclusive(code, bytes, deltaTime, time))
                {
                    if ((code & 0x80) != 0) {
                        eventType = code;
                    } else {
                        if (eventType == -1) throw _errorIncorrectData();
                        bytes.position--;
                    }
                    
                    switch (eventType & 0xf0) {
                    case SMFEvent.PROGRAM_CHANGE:
                    case SMFEvent.CHANNEL_PRESSURE:
                        value = bytes.readUnsignedByte();
                        break;
                    case SMFEvent.NOTE_OFF:
                    case SMFEvent.NOTE_ON:
                    case SMFEvent.KEY_PRESSURE:
                    case SMFEvent.CONTROL_CHANGE:
                        value = (bytes.readUnsignedByte()<<16) | bytes.readUnsignedByte();
                        break;
                    case SMFEvent.PITCH_BEND:
                        value = (bytes.readUnsignedByte() | (bytes.readUnsignedByte()<<7)) - 8192;
                        break;
                    }
                    
                    sequence.push(new SMFEvent(eventType, value, deltaTime, time));
                }
            }
            
            totalTime = time;
        }
        
        
        
        private function _readMetaEvent(eventType:Int, bytes:ByteArray, deltaTime:Int, time:Int) : Bool
        {
            if (eventType != SMFEvent.META) return false;
            
            var event:SMFEvent, value:Int, text:String, 
                metaEventType:Int = bytes.readUnsignedByte() | 0xff00,
                len:Int = _readVariableLength(bytes);

            if ((metaEventType & 0x00f0) == 0) {
                
                event = new SMFEvent(metaEventType, len, deltaTime, time);
                text = bytes.readMultiByte(len, "Shift-JIS");
                event.text(text);
                switch (metaEventType) {
                case SMFEvent.META_TEXT:   _smfData.text   = text;
                case SMFEvent.META_TITLE:  if (_smfData.title == null)  _smfData.title  = text;
                case SMFEvent.META_AUTHOR: if (_smfData.author == null) _smfData.author = text;
                }
                sequence.push(event);
            } else {
                switch (metaEventType) {
                case SMFEvent.META_TEMPO:
                    value = (bytes.readUnsignedByte()<<16) | bytes.readUnsignedShort();
                    
                    event = new SMFEvent(SMFEvent.META_TEMPO, Std.int(60000000 / value), deltaTime, time);
                    if (_smfData.bpm == 0) _smfData.bpm = event.value;
                    sequence.push(event);
                case SMFEvent.META_TIME_SIGNATURE:
                    value = (bytes.readUnsignedByte()<<16) | (1<<bytes.readUnsignedByte());
                    event = new SMFEvent(SMFEvent.META_TIME_SIGNATURE, value, deltaTime, time);
                    if (_smfData.signature_d == 0) {
                        _smfData.signature_n = value>>16;
                        _smfData.signature_d = value & 0xffff;
                    }
                    bytes.position += 2;
                    sequence.push(event);
 
                case SMFEvent.META_PORT:
                    value = bytes.readUnsignedByte();
            
                case SMFEvent.META_TRACK_END:  
                    _exitLoop = true;
        
                default:
                    bytes.position += len;
      
                }
            }
            return true;
        }
        
        
        
        private function _readSystemExclusive(eventType:Int, bytes:ByteArray, deltaTime:Int, time:Int) : Bool
        {
            if (eventType != SMFEvent.SYSTEM_EXCLUSIVE && eventType != SMFEvent.SYSTEM_EXCLUSIVE_SHORT) return false;
            
            var i:Int, b:Int, event:SMFEvent = new SMFEvent(eventType, 0, deltaTime, time),
                len:Int = _readVariableLength(bytes);

            
            event.byteArray = new ByteArray();
            event.byteArray.writeByte(0xf0); 
           i=0;
 while( i<len){
                b = bytes.readUnsignedByte();
                event.byteArray.writeByte(b);
             i++;
}
            
            sequence.push(event);
            
            return true;
        }
        
        
        
        private function _readVariableLength(bytes:ByteArray, time:Int = 0) : Int
        {
            var t:Int = bytes.readUnsignedByte();
            time += t & 0x7F;
            return ((t & 0x80) != 0) ? _readVariableLength(bytes, time<<7) : time;
        }
        
        
        
        
    
    
        private function _errorIncorrectData() : Error {
            return new Error("The SMF File is not good.");
        }
    }


