





package org.si.sion.effector ;
    
    class SiEffectStereoDelay extends SiEffectBase
    {
    
    
        inline static private var DELAY_BUFFER_BITS:Int = 16;
        inline static private var DELAY_BUFFER_FILTER:Int = (1<<DELAY_BUFFER_BITS)-1;
        
        private var _delayBuffer: Array<Array<Float>>;
        private var _pointerRead:Int;
        private var _pointerWrite:Int;
        private var _feedback:Float;
        private var _readBufferL: Array<Float>;
        private var _readBufferR: Array<Float>;
        private var _wet:Float;
        
        
        
        
    
    
        
        public function new(delayTime:Float=250, feedback:Float=0.25, isCross:Bool=false, wet:Float=0.25)
        {
            _delayBuffer = new Array<Array<Float>>();//2, true
            _delayBuffer[0] = new Array<Float>();//1<<DELAY_BUFFER_BITS
            _delayBuffer[1] = new Array<Float>();//1<<DELAY_BUFFER_BITS
            setParameters(delayTime, feedback, isCross, wet);
        }
        
        
        
        
    
    
        
        public function setParameters(delayTime:Float=250, feedback:Float=0.25, isCross:Bool=false, wet:Float=0.25) : Void
        {
            var offset:Int = Std.int(delayTime * 44.1),
                cross:Int  = (isCross) ? 1 : 0;
            if (offset > DELAY_BUFFER_FILTER) offset = DELAY_BUFFER_FILTER;
            _pointerWrite = (_pointerRead + offset) & DELAY_BUFFER_FILTER;
            _feedback = (feedback>=1) ? 0.9990234375 : (feedback<=-1) ? -0.9990234375 : feedback;
            _readBufferL = _delayBuffer[cross];
            _readBufferR = _delayBuffer[1-cross];
            _wet = wet;
        }
        
        
        
        
    
    
        
        override public function initialize() : Void
        {
            setParameters();
        }
        

        
        override public function mmlCallback(args: Array<Float>) : Void
        {
            setParameters((!Math.isNaN(args[0])) ? args[0] : 250,
                          (!Math.isNaN(args[1])) ? (args[1]*0.01) : 0.25,
                          (args[2] == 1),
                          (!Math.isNaN(args[3])) ? (args[3]*0.01) : 1);
        }
        
        
        
        override public function prepareProcess() : Int
        {
            var i:Int, imax:Int = 1<<DELAY_BUFFER_BITS, 
                buf0: Array<Float> = _delayBuffer[0],
                buf1: Array<Float> = _delayBuffer[1];
           i=0;
 while( i<imax){ buf0[i] = buf1[i] = 0; i++;
}
            return 2;
        }
        
        
        
        override public function process(channels:Int, buffer: Array<Float>, startIndex:Int, length:Int) : Int
        {
            startIndex <<= 1;
            length <<= 1;
            var i:Int, n:Float, imax:Int = startIndex + length,
                writeBufferL: Array<Float> = _delayBuffer[0],
                writeBufferR: Array<Float> = _delayBuffer[1],
                dry:Float = 1-_wet;
           i=startIndex;
 while( i<imax){
                n = _readBufferL[_pointerRead];
                writeBufferL[_pointerWrite] = buffer[i] - n * _feedback;
                buffer[i] *= dry;
                buffer[i] += n * _wet; i++;
                n = _readBufferR[_pointerRead];
                writeBufferR[_pointerWrite] = buffer[i] - n * _feedback;
                buffer[i] *= dry;
                buffer[i] += n * _wet; i++;
                _pointerWrite = (_pointerWrite+1) & DELAY_BUFFER_FILTER;
                _pointerRead  = (_pointerRead +1) & DELAY_BUFFER_FILTER;
            }
            return channels;
        }
    }


