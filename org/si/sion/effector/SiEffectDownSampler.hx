





package org.si.sion.effector ;
    
    class SiEffectDownSampler extends SiEffectBase
    {
    
    
        private var _freqShift:Int = 0;
        private var _bitConv0:Float = 1;
        private var _bitConv1:Float = 1;
        private var _channelCount:Int = 2;
        
        
        
        
    
    
        
        function new(freqShift:Int=0, bitRate:Int=16, channelCount:Int=2) 
        {
            setParameters(freqShift, bitRate, channelCount);
        }
        
        
        
        public function setParameters(freqShift:Int=0, bitRate:Int=16, channelCount:Int=2) : Void 
        {
            _freqShift = freqShift;
            _bitConv0 = 1<<bitRate;
            _bitConv1 = 1/_bitConv0;
            _channelCount = channelCount;
        }
        
        
        
        
    
    
        
        override public function initialize() : Void
        {
            setParameters();
        }
        
        
        
        override public function mmlCallback(args: Array<Float>) : Void
        {
            setParameters((!Math.isNaN(args[0])) ? Std.int(args[0]) : 0,
                          (!Math.isNaN(args[1])) ? Std.int(args[1]) : 16,
                          (!Math.isNaN(args[2])) ? Std.int(args[2]) : 2);
        }
        
        
        
        override public function prepareProcess() : Int
        {
            return 2;
        }
        
        
        
        override public function process(channels:Int, buffer: Array<Float>, startIndex:Int, length:Int) : Int
        {
            startIndex <<= 1;
            length <<= 1;
            var i:Int, j:Int, jmax:Int, bc0:Float, l:Float, r:Float, imax:Int=startIndex+length;
            if (_channelCount == 1) {
                switch (_freqShift) {
                case 0:
                    bc0 = 0.5 * _bitConv0;
                   i=startIndex;
 while( i<imax){
                        l =  buffer[i]; i++;
                        l += buffer[i]; i--;
                        l = (Std.int (l * bc0)) * _bitConv1;
                        buffer[i] = l; i++;
                        buffer[i] = l; i++;
                    }
              
                case 1:
                    bc0 = 0.25 * _bitConv0;
                   i=startIndex;
 while( i<imax){
                        l =  buffer[i]; i++;
                        l += buffer[i]; i++;
                        l += buffer[i]; i++;
                        l += buffer[i]; i-=3;
                        l = (Std.int (l * bc0)) * _bitConv1;
                        buffer[i] = l; i++;
                        buffer[i] = l; i++;
                        buffer[i] = l; i++;
                        buffer[i] = l; i++;
                    }
           
                case 2:
                    bc0 = 0.125 * _bitConv0;
                   i=startIndex;
 while( i<imax){
                        l =  buffer[i]; i++;
                        l += buffer[i]; i++;
                        l += buffer[i]; i++;
                        l += buffer[i]; i++;
                        l += buffer[i]; i++;
                        l += buffer[i]; i++;
                        l += buffer[i]; i++;
                        l += buffer[i]; i-=7;
                        l = (Std.int (l * bc0)) * _bitConv1;
                        buffer[i] = l; i++;
                        buffer[i] = l; i++;
                        buffer[i] = l; i++;
                        buffer[i] = l; i++;
                        buffer[i] = l; i++;
                        buffer[i] = l; i++;
                        buffer[i] = l; i++;
                        buffer[i] = l; i++;
                    }
                 
                default:
                    jmax = 2<<_freqShift;
                    bc0 = (1/jmax) * _bitConv0;
                   i=startIndex;
 while( i<imax){
                       j=0; l=0;
 while( j<jmax){
                            l += buffer[i];
                         j++; i++;
}
                        i -= jmax;
                        l = (Std.int (l * bc0)) * _bitConv1;
                       j=0;
 while( j<jmax){
                            buffer[i] = l;
                         j++; i++;
}
                    }
          
                }
            } else {
                switch (_freqShift) {
                case 0:
                   i=startIndex;
 while( i<imax){
                        buffer[i] = (Std.int (buffer[i] * _bitConv0)) * _bitConv1;
                     i++;
}
                 
                case 1:
                    bc0 = 0.5 * _bitConv0;
                   i=startIndex;
 while( i<imax){
                        l =  buffer[i]; i++;
                        r =  buffer[i]; i++;
                        l += buffer[i]; i++;
                        r += buffer[i]; i-=3;
                        l = (Std.int (l * bc0)) * _bitConv1;
                        r = (Std.int (r * bc0)) * _bitConv1;
                        buffer[i] = l; i++;
                        buffer[i] = r; i++;
                        buffer[i] = l; i++;
                        buffer[i] = r; i++;
                    }
           
                case 2:
                    bc0 = 0.25 * _bitConv0;
                   i=startIndex;
 while( i<imax){
                        l =  buffer[i]; i++;
                        r =  buffer[i]; i++;
                        l += buffer[i]; i++;
                        r += buffer[i]; i++;
                        l += buffer[i]; i++;
                        r += buffer[i]; i++;
                        l += buffer[i]; i++;
                        r += buffer[i]; i-=7;
                        l = (Std.int (l * bc0)) * _bitConv1;
                        r = (Std.int (r * bc0)) * _bitConv1;
                        buffer[i] = l; i++;
                        buffer[i] = r; i++;
                        buffer[i] = l; i++;
                        buffer[i] = r; i++;
                        buffer[i] = l; i++;
                        buffer[i] = r; i++;
                        buffer[i] = l; i++;
                        buffer[i] = r; i++;
                    }
              
                default:
                    jmax = 1<<_freqShift;
                    bc0 = (1/jmax) * _bitConv0;
                   i=startIndex;
 while( i<imax){
                       j=0; l=0; r=0;
 while( j<jmax){
                            l += buffer[i];
                            r += buffer[i];
                         j++; i++;
}
                        i -= jmax;
                        l = (Std.int (l * bc0)) * _bitConv1;
                        r = (Std.int (r * bc0)) * _bitConv1;
                       j=0;
 while( j<jmax){
                            buffer[i] = l; i++;
                            buffer[i] = r; i++;
                         j++;
}
                    }

                }
            }
            return _channelCount;
        }
    }


