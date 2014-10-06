





package org.si.sion.effector ;
    
    class SiEffectWaveShaper extends SiEffectBase
    {
    
    
        private var _coefficient:Int;
        private var _outputLevel:Float;
        
        
        
        
    
    
        
        function new(distortion:Float=0.5, outputLevel:Float=1.0) 
        {
            setParameters(distortion, outputLevel);
        }        
        
        
        
        
    
    
        
        public function setParameters(distortion:Float=0.5, outputLevel:Float=1.0) : Void
        {
            if (distortion >= 1) distortion = 0.9999847412109375; 
            _coefficient = Std.int(2*distortion/(1-distortion));
            _outputLevel = outputLevel;
        }
        
        
        
        
    
    
        
        override public function initialize() : Void
        {
            setParameters();
        }
        

        
        override public function mmlCallback(args: Array<Float>) : Void
        {
            setParameters((!Math.isNaN(args[0])) ? args[0]*0.01 : 0.5,
                          (!Math.isNaN(args[1])) ? args[1]*0.01 : 1.0);
        }
        
        
        
        override public function prepareProcess() : Int
        {
            return 2;
        }
        
        
        
        
        override public function process(channels:Int, buffer: Array<Float>, startIndex:Int, length:Int) : Int
        {
            startIndex <<= 1;
            length <<= 1;
            var i:Int, n:Float, c1:Float=(1 + _coefficient)*_outputLevel, imax:Int=startIndex+length;
            if (channels == 2) {
               i=startIndex;
 while( i<imax){
                    n = buffer[i];
                    buffer[i] = c1 * n / (1 + _coefficient * ((n<0) ? -n : n));
                 i++;
}
            } else {
               i=startIndex;
 while( i<imax){
                    n = buffer[i];
                    n = c1 * n / (1 + _coefficient * ((n<0) ? -n : n));
                    buffer[i] = n; i++;
                    buffer[i] = n; i++;
                }
            }
            return channels;
        }
    }


