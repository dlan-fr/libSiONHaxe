





package org.si.sion.effector ;
    
    class SiFilterPeak extends SiFilterBase
    {
    
    
        
        function new(freq:Float=3000, band:Float=1, gain:Float=6) 
        {
            setParameters(freq, band);
			super();
        }
        
        
        
        
    
    
        
        public function setParameters(freq:Float=3000, band:Float=1, gain:Float=6) : Void {
            var A:Float   = Math.pow(10, gain*0.025),
                omg:Float = freq * 0.00014247585730565955, 
                cos:Float = Math.cos(omg), sin:Float = Math.sin(omg),
                alp:Float = sin * sinh(0.34657359027997264 * band * omg / sin), 
                alpA:Float = alp * A, alpiA:Float = alp / A,
                ia0:Float = 1 / (1+alpiA);
            _b1 = _a1 = -2*cos * ia0;
            _a2 = (1-alpiA) * ia0;
            _b0 = (1+alpA) * ia0;
            _b2 = (1-alpA) * ia0;
        }
        
        
    
    
        
        override public function initialize() : Void
        {
            setParameters();
        }
        

        
        override public function mmlCallback(args: Array<Float>) : Void
        {
            setParameters((!Math.isNaN(args[0])) ? args[0] : 3000,
                          (!Math.isNaN(args[1])) ? args[1] : 1,
                          (!Math.isNaN(args[2])) ? args[2] : 6);
        }
    }


