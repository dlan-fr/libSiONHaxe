





package org.si.sion.sequencer.base ;
    import flash.utils.ByteArray;
    import org.si.utils.SLLint;
    
    
    
    class MMLExecutor
    {
    
        
        
        
        
    
    
        
        public var pointer:MMLEvent;
        
        
        private var _sequence:MMLSequence;
        
        private var _endRepeatCounter:Int;
        
        private  var _repeatPoint:MMLEvent;
        
        private  var _processEvent:MMLEvent;
        
        private  var _bendFrom:MMLEvent;
        
        private  var _bendEvent:MMLEvent;
        
        private  var _noteEvent:MMLEvent;
        
        
        public var _currentTickCount:Int;
        
        public var _repeatCounter:SLLint;
        
        public var _residueSampleCount:Int;
        
        public var _decimalFractionSampleCount:Int;
        
        
        
        
    
    
        
        public function endRepeatCount() : Int { return _endRepeatCounter; }
        
        
        public function sequence() : MMLSequence { return _sequence; }
        
        
        public function currentEvent() : MMLEvent { return (pointer == _processEvent) ? pointer.jump : pointer; }
        
        
        public function noteWaitingFor() : Int { return (pointer == _noteEvent) ? _noteEvent.data : -1; }
        
        
        
        
    
    
        
        public function new()
        {
            _sequence = null;
            pointer = null;
            _endRepeatCounter = 0;
            _repeatPoint = null;
            _processEvent = MMLParser._allocEvent(MMLEvent.PROCESS, 0);
            _noteEvent    = MMLParser._allocEvent(MMLEvent.DRIVER_NOTE, 0);
            _bendFrom     = MMLParser._allocEvent(MMLEvent.NOTE, 0);
            _bendEvent    = MMLParser._allocEvent(MMLEvent.PITCHBEND, 0);
            _bendFrom.next = _bendEvent;
            _bendEvent.next = _noteEvent;
            _repeatCounter = null;
            _currentTickCount = 0;
            _residueSampleCount = 0;
            _decimalFractionSampleCount = 0;
        }
        
        
        
        
    
    
        
        public function initialize(seq:MMLSequence) : Void
        {
            clear();
            if (seq != null) {
                _sequence = seq;
                pointer  = seq.headEvent.next;
            }
        }
        
        
        
        public function clear() : Void
        {
            pointer = null;
            _sequence = null;
            _endRepeatCounter = 0;
            _repeatPoint = null;
            SLLint.freeList(_repeatCounter);
            _repeatCounter = null;
            _currentTickCount = 0;
            _residueSampleCount = 0;
            _decimalFractionSampleCount = 0;
        }
        
        
        
        public function resetPointer() : Void
        {
            if (_sequence != null) {
                pointer = _sequence.headEvent.next;
                _endRepeatCounter = 0;
                _repeatPoint = null;
                SLLint.freeList(_repeatCounter);
                _repeatCounter = null;
                _currentTickCount = 0;
                _residueSampleCount = 0;
                _decimalFractionSampleCount = 0;
            }
        }
        

        
        public function stop() : Void
        {
            if (pointer != null) {
                if (pointer == _processEvent) _processEvent.jump = MMLEvent.nopEvent;
                else pointer = null;
            }
        }
        
        
        
        public function singleNote(note:Int, tickLength:Int) : Void
        {
            _noteEvent.next = null;
            _noteEvent.data = note;
            _noteEvent.length = tickLength;
            pointer = _noteEvent;
            
            _sequence = null;
            _endRepeatCounter = 0;
            _repeatPoint = null;
            SLLint.freeList(_repeatCounter);
            _repeatCounter = null;
            _currentTickCount = 0;
        }
        
        
        
        public function bendingFrom(note:Int, tickLength:Int) : Bool
        {
            if (pointer != _noteEvent || tickLength == 0) return false;
            if (_noteEvent.length != 0) {
                if (tickLength < _noteEvent.length) tickLength = _noteEvent.length - 1;
                _noteEvent.length -= tickLength;
            }
            _bendFrom.length = 0;
            _bendFrom.data = note;
            _bendEvent.length = tickLength;
            pointer = _bendFrom;
            return true;
        }
        
        
        
        public function _publishProessingEvent(e:MMLEvent) : MMLEvent
        {
            if (e.length > 0) {
                
                
                _currentTickCount += e.length;
                _processEvent.length = e.length;
                _processEvent.jump   = e;
                return _processEvent;
            }
            return e.next;
        }
        
        
        
        
        
    
    
        
        public function _onTempoChanged(changingRatio:Float) : Void
        {
            if (_residueSampleCount < 0) changingRatio = 1 / changingRatio;
            _residueSampleCount         *= Std.int(changingRatio);
            _decimalFractionSampleCount *= Std.int(changingRatio);
        }
        
        
        
        public function _onRepeatAll(e:MMLEvent) : MMLEvent
        {
            _repeatPoint = e.next;
            return e.next;
        }
        
        
        
         public function _onRepeatBegin(e:MMLEvent) : MMLEvent
        {
            var counter:SLLint = SLLint.alloc(e.data);
            counter.next = _repeatCounter;
            _repeatCounter = counter;
            return e.next;
        }
        
        
        
        public function _onRepeatBreak(e:MMLEvent) : MMLEvent
        {
            if (_repeatCounter.i == 1) {
                var counter:SLLint = _repeatCounter.next;
                SLLint.free(_repeatCounter);
                _repeatCounter = counter;
                
                return e.jump.jump.next;
            }
            return e.next;
        }
        
        
        
        public function _onRepeatEnd(e:MMLEvent) : MMLEvent
        {
           if (--_repeatCounter.i == 0) {
                var counter:SLLint = _repeatCounter.next;
                SLLint.free(_repeatCounter);
                _repeatCounter = counter;
                return e.next;
            }
            
            return e.jump.next;
         }
        
        
        
		 public function _onSequenceTail(e:MMLEvent) : MMLEvent
        {
            _endRepeatCounter++;
            return _repeatPoint;
         }
    }



