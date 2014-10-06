





package org.si.sion.effector ;
    
    class SiEffectStereoExpander extends SiEffectBase
    {
    
    
        private var _l2l:Float;
		private var _r2l:Float;
		private var _l2r:Float;
		private var _r2r:Float;
        private var _monoralize:Bool;
        
        
        
        
    
    
        
        function new(width:Float=1, rotation:Float=0, phaseInvert:Bool=false) : Void
        {
            setParameters(width, rotation, phaseInvert);
        }        
        
        
        
        
    
    
        
        public function setParameters(width:Float=1.4, rotation:Float=0, phaseInvert:Bool=false) : Void
        {
            _monoralize = (width == 0 && rotation == 0 && !phaseInvert);
            var halfWidth:Float   = width * 0.7853981633974483,  
                centerAngle:Float = (rotation + 0.5) * 1.5707963267948965,
                langle:Float = centerAngle - halfWidth,
                rangle:Float = centerAngle + halfWidth,
                invert:Float = (phaseInvert) ? -1 : 1,
                x:Float, y:Float, l:Float;
            _l2l = Math.cos(langle);
            _r2l = Math.sin(langle);
            _l2r = Math.cos(rangle) * invert;
            _r2r = Math.sin(rangle) * invert;
            x = _l2l + _l2r;
            y = _r2l + _r2r;
            l = Math.sqrt(x * x + y * y);
            if (l > 0.01) {
                l = 1 / l;
                _l2l *= l;
                _r2l *= l;
                _l2r *= l;
                _r2r *= l;
            }
        }
        
        
        
        
    
    
        
        override public function initialize() : Void
        {
            setParameters();
        }
        

        
        override public function mmlCallback(args: Array<Float>) : Void
        {
            setParameters((!Math.isNaN(args[1])) ? (args[1]*0.01) : 1.4,
                          (!Math.isNaN(args[2])) ? (args[2]*0.01) : 0,
                          (!Math.isNaN(args[0])) ? (args[0]!=0) : false);
        }
        
        
        
        override public function prepareProcess() : Int
        {
            return 2;
        }
        
        
        
        override public function process(channels:Int, buffer: Array<Float>, startIndex:Int, length:Int) : Int
        {
            startIndex <<= 1;
            length <<= 1;
            var i:Int, l:Float, r:Float, imax:Int=startIndex+length;
            if (_monoralize) {
               i=startIndex;
 while( i<imax){
                    l = buffer[i]; i++;
                    l += buffer[i]; --i;
                    l *= 0.7071067811865476;
                    buffer[i] = l; i++;
                    buffer[i] = l; i++;
                }
                return 1;
            }
           i=startIndex;
 while( i<imax){
                l = buffer[i]; i++;
                r = buffer[i]; --i;
                buffer[i] = l * _l2l + r * _r2l; i++;
                buffer[i] = l * _l2r + r * _r2r; i++;
            }
            return 2;
        }
    }


