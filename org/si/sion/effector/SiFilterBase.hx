





package org.si.sion.effector ;
    
    class SiFilterBase extends SiEffectBase
    {
    
    
        inline static var THRESHOLD:Float = 0.0000152587890625;
        
        
        
        
    
    
        var _a1:Float;
		var _a2:Float;
		var _b0:Float;
		var _b1:Float;
		var _b2:Float;
        private var _in1L:Float;
		private var _in2L:Float;
		private var _out1L:Float;
		private var _out2L:Float;
        private var _in1R:Float;
		private var _in2R:Float;
		private var _out1R:Float;
		private var _out2R:Float;
        
        
        
        
    
    
        
        function sinh(n:Float) : Float {
            return (Math.exp(n) - Math.exp(-n)) * 0.5;
        }
        
        
        
        
    
    
        
        function new() {}
        
        
        
        
    
    
        
        override public function prepareProcess() : Int
        {
            _in1L = _in2L = _out1L = _out2L = _in1R = _in2R = _out1R = _out2R = 0;
            return 2;
        }
        
        
        
        override public function process(channels:Int, buffer: Array<Float>, startIndex:Int, length:Int) : Int
        {
            startIndex <<= 1;
            length <<= 1;
            if (_out1L < THRESHOLD) _out2L = _out1L = 0;
            if (_out1R < THRESHOLD) _out2R = _out1R = 0;
            
            var i:Int, input:Float, output:Float, imax:Int=startIndex+length;
            if (channels == 2) {
               i=startIndex;
 while( i<imax){
                    input = buffer[i];
                    output = _b0*input + _b1*_in1L + _b2*_in2L - _a1*_out1L - _a2*_out2L;
                    if (output > 1) output = 1;
                    else if (output < -1) output = -1;
                    _in2L  = _in1L;  _in1L  = input;
                    _out2L = _out1L; _out1L = output;
                    buffer[i] = output; i++;
                    
                    input = buffer[i];
                    output = _b0*input + _b1*_in1R + _b2*_in2R - _a1*_out1R - _a2*_out2R;
                    if (output > 1) output = 1;
                    else if (output < -1) output = -1;
                    _in2R  = _in1R;  _in1R  = input;
                    _out2R = _out1R; _out1R = output;
                    buffer[i] = output; i++;
                }
            } else {
               i=startIndex;
 while( i<imax){
                    input = buffer[i];
                    output = _b0*input + _b1*_in1L + _b2*_in2L - _a1*_out1L - _a2*_out2L;
                    if (output > 1) output = 1;
                    else if (output < -1) output = -1;
                    _in2L  = _in1L;  _in1L  = input;
                    _out2L = _out1L; _out1L = output;
                    buffer[i] = output; i++;
                    buffer[i] = output; i++;
                }
            }
            return channels;
        }
    }


