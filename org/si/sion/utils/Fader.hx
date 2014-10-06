






package org.si.sion.utils ;
    
    class Fader
    {
    
    
        
        private var _end:Float = 0;
        
        private var _step:Float = 0;
        
        private var _counter:Int = 0;
        
        private var _value:Float = 0;
        
        private var _callback:Dynamic = null;
        
        
        
        
    
    
        
        public function isActive() : Bool { return (_counter>0); }
        
        public function isIncrement() : Bool { return (_step > 0); }
        
        public function value() : Float { return _value; }
        
        
        
        
    
    
        
        public function new(callback:Dynamic=null, valueFrom:Float=0, valueTo:Float=1, frames:Int=60)
        {
            setFade(callback, valueFrom, valueTo, frames);
        }
        
        
        
        
    
    
        
        public function setFade(callback:Dynamic, valueFrom:Float=0, valueTo:Float=1, frames:Int=60) : Fader
        {
            _value = valueFrom;
            if (frames == 0 || callback == null) {
                _counter = 0;
                return this;
            }
            _callback = callback;
            _end = valueTo;
            _step = (valueTo - valueFrom) / frames;
            _counter = frames;
            _callback(_value);
            return this;
        }
        
        
        
        public function execute() : Bool
        {
            if (_counter > 0) {
                _value += _step;
                if (--_counter == 0) {
                    _value = _end;
                    _callback(_end);
                    return true;
                } else {
                    _callback(_value);
                }
            }
            return false;
        }
        
        
        
        public function stop() : Void
        {
            _counter = 0;
        }
    }



