





package org.si.sion.effector ;
    
    class SiEffectDistortion extends SiEffectBase
    {
    
    
       inline static var THRESHOLD:Float = 0.0000152587890625;
        
        
        
        
    
    
        private var _preScale:Float;
		private var _limit:Float;
		private var _filterEnable:Bool;
        private var _a1:Float;
		private var _a2:Float;
		private var _b0:Float;
		private var _b1:Float;
		private var _b2:Float;
        private var _in1:Float;
		private var _in2:Float;
		private var _out1:Float;
		private var _out2:Float;
        
        
        
        
    
    
        
        function new(preGain:Float=-60, postGain:Float=18, lpfFreq:Float=2400, lpfSlope:Float=1) 
        {
            setParameters(preGain, postGain);
        }        
        
        
        
        
    
    
        
        public function setParameters(preGain:Float=-60, postGain:Float=18, lpfFreq:Float=2400, lpfSlope:Float=1) : Void
        {
            var postScale:Float = Math.pow(2, -postGain/6);
            _preScale = Math.pow(2, -preGain/6) * postScale;
            _limit = postScale;
            _filterEnable = (lpfFreq > 0);
            if (_filterEnable) {
                var omg:Float = lpfFreq * 0.00014247585730565955, 
                    cos:Float = Math.cos(omg), sin:Float = Math.sin(omg),
                    ang:Float = 0.34657359027997264 * lpfSlope * omg / sin,
                    alp:Float = sin * (Math.exp(ang) - Math.exp(-ang)) * 0.5, 
                    ia0:Float = 1 / (1+alp);
                _a1 = -2*cos * ia0;
                _a2 = (1-alp) * ia0;
                _b1 = (1-cos) * ia0;
                _b2 = _b0 = _b1 * 0.5;
            }
        }
        
        
        
        
    
    
        
        override public function initialize() : Void
        {
            setParameters();
        }
        

        
        override public function mmlCallback(args: Array<Float>) : Void
        {
            setParameters((!Math.isNaN(args[0])) ? args[0] : -60,
                          (!Math.isNaN(args[1])) ? args[1] : 18,
                          (!Math.isNaN(args[2])) ? args[2] : 2400,
                          (!Math.isNaN(args[3])) ? args[3] : 1);
        }
        
        
        
        override public function prepareProcess() : Int
        {
            _in1 = _in2 = _out1 = _out2 = 0;
            return 1;
        }
        
        
        
        override public function process(channels:Int, buffer: Array<Float>, startIndex:Int, length:Int) : Int
        {
            startIndex <<= 1;
            length <<= 1;
            if (_out1 < THRESHOLD) _out2 = _out1 = 0;
            var i:Int, n:Float, out:Float, imax:Int=startIndex+length;
            if (_filterEnable) {
               i=startIndex;
 while( i<imax){
                    n = buffer[i];
                    n *= _preScale;
                    if (n < -_limit) n = -_limit;
                    else if (n > _limit) n = _limit;
                    out = _b0*n + _b1*_in1 + _b2*_in2 - _a1*_out1 - _a2*_out2;
                    _in2  = _in1;  _in1  = n;
                    _out2 = _out1; _out1 = out;
                    buffer[i] = out; i++;
                    buffer[i] = out;
                 i++;
}
            } else {
               i=startIndex;
 while( i<imax){
                    n = buffer[i];
                    n *= _preScale;
                    if (n < -_limit) n = -_limit;
                    else if (n > _limit) n = _limit;
                    buffer[i] = n; i++;
                    buffer[i] = n;
                 i++;
}
            }
            return 1;
        }
    }


