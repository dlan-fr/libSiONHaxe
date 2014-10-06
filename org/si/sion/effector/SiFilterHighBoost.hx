





package org.si.sion.effector ;
    
    class SiFilterHighBoost extends SiFilterBase
    {
    
    
        
        function new(freq:Float=5500, slope:Float=1, gain:Float=6) 
        {
            setParameters(freq, slope, gain);
			super();
        }
        
        
        
        
    
    
        
        public function setParameters(freq:Float=5500, slope:Float=1, gain:Float=6) : Void {
            if (slope<1) slope = 1;
            var A:Float   = Math.pow(10, gain*0.025),
                omg:Float = freq * 0.00014247585730565955, 
                cos:Float = Math.cos(omg), sin:Float = Math.sin(omg),
                alp:Float = sin * 0.5 * Math.sqrt((A + 1/A)*(1/slope-1)+2),
                alpsA2:Float = alp * Math.sqrt(A) * 2,
                ia0:Float = 1 / ((A+1) - (A-1)*cos + alpsA2);
            _a1 = 2 * ((A-1) - (A+1)*cos)          * ia0;
            _a2 =     ((A+1) - (A-1)*cos - alpsA2) * ia0;
            _b0 =     ((A+1) + (A-1)*cos + alpsA2) * A * ia0;
            _b1 =-2 * ((A-1) + (A+1)*cos)          * A * ia0;
            _b2 =     ((A+1) + (A-1)*cos - alpsA2) * A * ia0;
        }

        
        
        
    
    
        
        override public function initialize() : Void
        {
            setParameters();
        }
        

        
        override public function mmlCallback(args: Array<Float>) : Void
        {
            setParameters((!Math.isNaN(args[0])) ? args[0] : 5500,
                          (!Math.isNaN(args[1])) ? args[1] : 1,
                          (!Math.isNaN(args[2])) ? args[2] : 6);
        }
    }


