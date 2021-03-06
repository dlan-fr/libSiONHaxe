





package org.si.sion.effector ;
    
    class SiFilterAllPass extends SiFilterBase
    {
    
    
        
        public function new(freq:Float=3000, band:Float=1)
        {
            setParameters(freq, band);
			super();
        }
        
        
        
        
    
    
        
        public function setParameters(freq:Float=3000, band:Float=1) : Void {
            var omg:Float = freq * 0.00014247585730565955, 
                cos:Float = Math.cos(omg), sin:Float = Math.sin(omg),
                alp:Float = sin * sinh(0.34657359027997264 * band * omg / sin), 
                ia0:Float = 1 / (1+alp);
            _b1 = _a1 = -2*cos * ia0;
            _b0 = _a2 = (1-alp) * ia0;
            _b2 = 1;
        }
        
        
    
    
        
        override public function initialize() : Void
        {
            setParameters();
        }
        

        
        override public function mmlCallback(args: Array<Float>) : Void
        {
            setParameters((!Math.isNaN(args[0])) ? args[0] : 3000,
                          (!Math.isNaN(args[1])) ? args[1] : 1);
        }
    }


