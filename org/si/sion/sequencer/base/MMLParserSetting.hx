





package org.si.sion.sequencer.base ;
    
    class MMLParserSetting
    {
    
    
        
        public var resolution       :Int;
        private var _mml2nn         :Int;
        
        public var defaultBPM       :Float;
        
        
        public var defaultLValue    :Int;
        
        public var minQuantRatio     :Int;
        
        public var maxQuantRatio     :Int;
        
        public var defaultQuantRatio :Int;
        
        public var minQuantCount     :Int;
        
        public var maxQuantCount     :Int;
        
        public var defaultQuantCount :Int;
        
        public var maxVolume:Int;
        
        public var defaultVolume:Int;
        
        public var maxFineVolume:Int;
        
        public var defaultFineVolume:Int;
        
        public var minOctave        :Int;
        
        public var maxOctave        :Int;
        private var _defaultOctave  :Int;

        
        public var volumePolarization:Int;
        
        public var octavePolarization:Int;
        
        
        
    
    
                
        public function mml2nn() : Int { return _mml2nn; }
        
        
        public function defaultLength() : Int { return Std.int(resolution / defaultLValue); }
       
        
        public function defaultOctave(o:Int) : Void
        {
            _defaultOctave = o;
            _mml2nn = 60 - _defaultOctave * 12;
            var octaveLimit:Int = Std.int((128 - _mml2nn) / 12) - 1;
            if (maxOctave > octaveLimit) maxOctave = octaveLimit;
        }
		
        public function defaultOctave2() : Int 
		{ 
			return _defaultOctave; 
		}
        
        
        
        
    
    
        
        public function new(initializer:Dynamic=null)
        {
            initialize(initializer);
        }
        
        
        
        public function initialize(initializer:Dynamic=null) : Void
        {
            resolution = 1920;
            defaultBPM = 120;

            defaultLValue     =    4;
            minQuantRatio     =    0;
            maxQuantRatio     =    8;
            defaultQuantRatio =   10;
            minQuantCount     = -192;
            maxQuantCount     =  192;
            defaultQuantCount =    0;

            maxVolume         = 15;
            defaultVolume     = 10;
            maxFineVolume     = 127;
            defaultFineVolume = 127;
            minOctave     = 0;
            maxOctave     = 9;
			defaultOctave(5);

            volumePolarization = 1;
            octavePolarization = 1;
            
            update(initializer);
        }
        
        
        
        public function update(initializer:Dynamic) : Void
        {
            if (initializer == null) return;
            
            if (initializer.resolution       != null) resolution = initializer.resolution;
            if (initializer.defaultBPM       != null) defaultBPM = initializer.defaultBPM;

            if (initializer.defaultLValue     != null) defaultLValue = initializer.defaultLValue;
            if (initializer.minQuantRatio     != null) minQuantRatio = initializer.minQuantRatio;
            if (initializer.maxQuantRatio     != null) maxQuantRatio = initializer.maxQuantRatio;
            if (initializer.defaultQuantRatio != null) defaultQuantRatio = initializer.defaultQuantRatio;
            if (initializer.minQuantCount     != null) minQuantCount = initializer.minQuantCount;
            if (initializer.maxQuantCount     != null) maxQuantCount = initializer.maxQuantCount;
            if (initializer.defaultQuantCount != null) defaultQuantCount = initializer.defaultQuantCount;

            if (initializer.maxVolume         != null) maxVolume = initializer.maxVolume;
            if (initializer.defaultVolume     != null) defaultVolume = initializer.defaultVolume;
            if (initializer.maxFineVolume     != null) maxFineVolume = initializer.maxFineVolume;
            if (initializer.defaultFineVolume != null) defaultFineVolume = initializer.defaultFineVolume;

            if (initializer.minOctave     != null) minOctave = initializer.minOctave;
            if (initializer.maxOctave     != null) maxOctave = initializer.maxOctave;
            if (initializer.defaultOctave != null) defaultOctave(initializer.defaultOctave);

            if (initializer.volumePolarization != null) volumePolarization = initializer.volumePolarization;
            if (initializer.octavePolarization != null) octavePolarization = initializer.volumePolarization;
        }
    }



