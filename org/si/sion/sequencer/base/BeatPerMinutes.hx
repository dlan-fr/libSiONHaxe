





package org.si.sion.sequencer.base ;
    
    class BeatPerMinutes
    {
        
        public var beat16PerSample:Float;
        
        public var samplePerBeat16:Float;
        
        public var tickPerSample:Float;
        
        public var _samplePerTick:Float;
        
        private var _bpm:Float = 0;
        
        private var _sampleRate:Int = 0;
        
        private var _resolution:Int;
        
        inline static var FIXED_BITS:Int = 8;
        
        public function bpm() : Float { return _bpm; }
        
        
        public function sampleRate() : Int { return _sampleRate; }
        

        
        public function new(bpm:Float, sampleRate:Int, resolution:Int=1920) {
            _resolution = resolution;
            update(bpm, sampleRate);
        }
        

        
        public function update(beatPerMinutes:Float, sampleRate:Int) : Bool {
            if (beatPerMinutes<1) beatPerMinutes=1;
            else if (beatPerMinutes>511) beatPerMinutes=511;
            if (beatPerMinutes != _bpm || sampleRate != _sampleRate) {
                _bpm = beatPerMinutes;
                _sampleRate = sampleRate;
                tickPerSample = _resolution * _bpm / (_sampleRate * 240);
                beat16PerSample = _bpm / (_sampleRate * 15); 
                samplePerBeat16 = 1 / beat16PerSample;
                _samplePerTick = Std.int((1/tickPerSample) * (1<<FIXED_BITS));
                return true;
            }
            return false;
        }
    }



