





package org.si.sion.effector ;
    
    class SiEffectSpeakerSimulator extends SiEffectBase
    {
    
    
        private var _springCoef:Float = 0.96;
        private var _diaphragmPosL:Float;
		private var _diaphragmPosR:Float;
        private var _prevL:Float;
		private var _prevR:Float;
        
        
        
        
    
    
        
        function new(hardness:Float=0.2) 
        {
            setParameters(hardness);
        }
        
                
        
        public function setParameters(hardness:Float=0.2) : Void 
        {
            _springCoef = 1 - hardness * hardness;
            if (_springCoef < 0.1) _springCoef = 0.1;
        }

        
        
        
    
    
        
        override public function initialize() : Void
        {
            setParameters();
        }
        
        
        
        override public function mmlCallback(args: Array<Float>) : Void
        {
            setParameters((!Math.isNaN(args[0])) ? args[0]*0.01 : 0.2);
        }
        
        
        
        override public function prepareProcess() : Int
        {
            _prevL = _prevR = _diaphragmPosL = _diaphragmPosR = 0;
            return 2;
        }
        
        
        
        override public function process(channels:Int, buffer: Array<Float>, startIndex:Int, length:Int) : Int
        {
            startIndex <<= 1;
            length <<= 1;
            var i:Int, d:Float, imax:Int=startIndex+length;
           i=startIndex;
 while( i<imax){
                d = buffer[i] - _prevL;
                _diaphragmPosL *= _springCoef;
                _diaphragmPosL += d;
                _prevL = buffer[i];
                buffer[i] = _diaphragmPosL; i++;
                
                d = buffer[i] - _prevR;
                _diaphragmPosR *= _springCoef;
                _diaphragmPosR += d;
                _prevR = buffer[i];
                buffer[i] = _diaphragmPosR; i++;
            }
            return channels;
        }
    }


