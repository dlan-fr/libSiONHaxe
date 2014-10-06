





package org.si.sion.sequencer.base ;
    import flash.utils.ByteArray;
    
    
    
    class MMLSequence
    {
    
    
        
        public var headEvent:MMLEvent;
        
        public var tailEvent:MMLEvent;
        
        public var isActive:Bool;
        
        
        private var _mmlString:String;
        
        private var _mmlLength:Int;
        
        private var _hasRepeatAll:Bool;
        
        
        private var _prevSequence:MMLSequence;
        
        private var _nextSequence:MMLSequence;
        
        private var _isTerminal:Bool;
        
        
		public var  _callbackInternalCall:Array<Dynamic>;
        
         public var  _owner:MMLData;
        
        
        
    
    
        
        public function nextSequence() : MMLSequence
        {
            return (!_nextSequence._isTerminal) ? _nextSequence : null;
        }
        
        
        public function mmlString() : String { return _mmlString; }
        
        
        public function mmlLength() : Int {
            if (_mmlLength == -1) _updateMMLLength();
            return _mmlLength;
        }
        
        
        public function hasRepeatAll() : Bool {
            if (_mmlLength == -1) _updateMMLLength();
            return _hasRepeatAll;
        }
        
        
    
    
        
        public function new(term:Bool = false)
        {
            _owner = null;
            headEvent = null;
            tailEvent = null;
            isActive = true;
            _mmlString = "";
            _mmlLength = -1;
            _hasRepeatAll = false;
            _prevSequence = (term) ? this : null;
            _nextSequence = (term) ? this : null;
            _isTerminal = term;
            _callbackInternalCall = [];
        }
        
        
        
        public function toString() : String
        {
            if (_isTerminal) return "terminator";
            var e:MMLEvent = headEvent.next;
            var str:String = "";
           var i:Int=0;
 while( i<32){
                str += Std.string(e.id) + " ";
                e = e.next;
                if (e == null) break;
             i++;
}
            return str;
        }
        
        
        
        public function toVector(lengthLimit:Int=0, offset:Int=0, eventID:Int=-1) : Array<MMLEvent>
        {
            if (headEvent == null) return null;
            var e:MMLEvent, i:Int=0, result: Array<MMLEvent> = new Array<MMLEvent>();
           e=headEvent.next;
 while( e!=null && e.id!=MMLEvent.SEQUENCE_TAIL){
                if (eventID == -1 || eventID == e.id) {
                    if (i >= offset) result.push(e);
                    if (lengthLimit > 0 && i >= lengthLimit) break;
                    i++;
                }
             e=e.next;
}
            return result;
        }
        
        
        
        public function fromVector(events: Array<MMLEvent>) : MMLSequence
        {
            initialize();
            for (e in events) push(e);
            return this;
        }
        
        
        
        
        
    
    
        
        public function initialize() : MMLSequence
        {
            if (!isEmpty()) {
                headEvent.jump.next = tailEvent;
                MMLParser._freeAllEvents(this);
                _callbackInternalCall = [];
            }
            headEvent = MMLParser._allocEvent(MMLEvent.SEQUENCE_HEAD, 0);
            tailEvent = MMLParser._allocEvent(MMLEvent.SEQUENCE_TAIL, 0);
            headEvent.next = tailEvent;
            headEvent.jump = headEvent;
            isActive = true;
            return this;
        }
        
        
        
        public function free() : Void
        {
            if (headEvent != null) {
                
                headEvent.jump.next = tailEvent;
                MMLParser._freeAllEvents(this);
                _prevSequence = null;
                _nextSequence = null;
            } else 
            if (_isTerminal) {
                _prevSequence = this;
                _nextSequence = this;
            }
            _mmlString = "";
        }
        
        
        
        public function isEmpty() : Bool
        {
            return (headEvent == null);
        }
        
        
        
        public function pack(seq:ByteArray) : Void
        {
            
        }
        
        
        
        public function unpack(seq:ByteArray) : Void
        {
            
        }
        
        
        
        public function appendNewEvent(id:Int, data:Int, length:Int=0) : MMLEvent
        {
            return push(MMLParser._allocEvent(id, data, length));
        }
        
        
        
        public function appendNewCallback(func:Dynamic, data:Int) : MMLEvent
        {
            _callbackInternalCall.push(func);
            return push(MMLParser._allocEvent(MMLEvent.INTERNAL_CALL, _callbackInternalCall.length-1, data));
        }
        
        
        
        public function prependNewEvent(id:Int, data:Int, length:Int=0) : MMLEvent
        {
            return unshift(MMLParser._allocEvent(id, data, length));
        }
        
        
        
        public function push(e:MMLEvent) : MMLEvent
        {
            
            headEvent.jump.next = e;
            e.next = tailEvent;
            headEvent.jump = e;
            return e;
        }
        
        
        
        public function pop() : MMLEvent
        {
            if (headEvent.jump == headEvent) return null;
           var e:MMLEvent=headEvent.next;
 while( e!=null){
                if (e.next == headEvent.jump) {
                    var ret:MMLEvent = e.next;
                    e.next = tailEvent;
                    headEvent.jump = e;
                    ret.next = null;
                    return ret;
                }
             e=e.next;
}
            return null;
        }
        
        
        
        public function unshift(e:MMLEvent) : MMLEvent
        {
            
            e.next = headEvent.next;
            headEvent.next = e;
            if (headEvent.jump == headEvent) headEvent.jump = e;
            return e;
        }
        
        
        
        public function shift() : MMLEvent
        {
            if (headEvent.jump == headEvent) return null;
            var ret:MMLEvent = headEvent.next;
            headEvent.next = ret.next;
            ret.next = null;
            return ret;
        }
        
        
        
        public function connectBefore(secondHead:MMLEvent) : MMLSequence
        {
            
            headEvent.jump.next = (secondHead != null) ? secondHead : (tailEvent != null) ? tailEvent:null;
            return this;
        }
        
        
        
        public function isSystemCommand() : Bool
        {
            return (headEvent.next.id == MMLEvent.SYSTEM_EVENT);
        }
        
        
        
        public function getSystemCommand() : String
        {
            return MMLParser._getSystemEventString(headEvent.next);
        }
        
        
        
        public function _cutout(head:MMLEvent) : MMLEvent
        {
            var last:MMLEvent = head.jump; 
            var next:MMLEvent = last.next; 

            
            headEvent = head;
            tailEvent = MMLParser._allocEvent(MMLEvent.SEQUENCE_TAIL, 0);
            last.next = tailEvent;  
            
            return next;
        }
        
        
        
        public function _updateMMLString() : Void
        {
            if (headEvent.next.id == MMLEvent.DEBUG_INFO) {
                _mmlString = MMLParser._getSequenceMML(headEvent.next);
                headEvent.length = 0;
            }
        }
        
        
        
        public function _insertBefore(next:MMLSequence) : Void
        {
            _prevSequence = next._prevSequence;
            _nextSequence = next;
            _prevSequence._nextSequence = this;
            _nextSequence._prevSequence = this;
        }
        
        
        
        public function _insertAfter(prev:MMLSequence) : Void
        {
            _prevSequence = prev;
            _nextSequence = prev._nextSequence;
            _prevSequence._nextSequence = this;
            _nextSequence._prevSequence = this;
        }
        
        
        
        public function _removeFromChain() : MMLSequence
        {
            var ret:MMLSequence = _prevSequence;
            _prevSequence._nextSequence = _nextSequence;
            _nextSequence._prevSequence = _prevSequence;
            _prevSequence = null;
            _nextSequence = null;
            return (ret == this) ? null : ret;
        }
        
        
        
        private function _updateMMLLength() : Void 
        {
            var exec:MMLExecutor = MMLSequencer._tempExecutor;
			
             var e:MMLEvent = headEvent.next;
             var length:Int = 0;
            
            _hasRepeatAll = false;
            exec.initialize(this);
            while (e != null) {
                if (e.length != 0) {
                    
                    length += e.length;
                    e = e.next;
                } else {
                    
                    switch (e.id) {
                    case MMLEvent.REPEAT_BEGIN:  e = exec._onRepeatBegin(e);    break;
                    case MMLEvent.REPEAT_BREAK:  e = exec._onRepeatBreak(e);    break;
                    case MMLEvent.REPEAT_END:    e = exec._onRepeatEnd(e);      break;
                    case MMLEvent.REPEAT_ALL:    e = null; _hasRepeatAll=true;  break;
                    case MMLEvent.SEQUENCE_TAIL: e = null;                      break;
                    default:                     e = e.next;                    break;
                    }
                }
            }
            
            _mmlLength = length;
        }
    }



