





package org.si.sion.module ;
    import org.si.utils.SLLNumber;
    import org.si.utils.SLLint;
    import org.si.sion.module.channels.*;
    
    
    
    class SiOPMModule
    {
    
    
        
        inline static public var STREAM_SEND_SIZE:Int = 8;
        
        inline static public var PIPE_SIZE:Int = 5;
        
        
        
        
    
    
        
        public var initOperatorParam:SiOPMOperatorParam;
        
        public var zeroBuffer:SLLint;
        
        public var outputStream:SiOPMStream;
        
        public var streamSlot: Array<SiOPMStream>;
        
        public var pcmVolume:Float;
        
        public var samplerVolume:Float;
        
        private var _bufferLength:Int;  
        private var _bitRate:Int;       
        
        
        private var _pipeBuffer: Array<SLLint>;
        private var _pipeBufferPager: Array<Array<SLLint>>;
        
        
    
    
        
        public function output() : Array<Float> { return outputStream.buffer; }
        
        public function channelCount() : Int { return outputStream.channels; }
        
        public function bitRate() : Int { return _bitRate; }
        
        public function bufferLength() : Int { return _bufferLength; }
        
        
        
        
    
    
        
        public function new()
        {
            
            initOperatorParam = new SiOPMOperatorParam();
            
            
            outputStream = new SiOPMStream();
            streamSlot = new Array<SiOPMStream>();

            
            zeroBuffer = SLLint.allocRing(1);
            
            
            _bufferLength = 0;
            _pipeBuffer = new Array<SLLint>();
            _pipeBufferPager = new Array<Array<SLLint>>();
            
            
            SiOPMChannelManager.initialize(this);
        }
        
        
        
        
    
    
        
        public function initialize(channelCount:Int, bitRate:Int, bufferLength:Int) : Void
        {
            _bitRate = bitRate;
            
            var i:Int, stream:SiOPMStream;

            
           i=0;
 while( i<STREAM_SEND_SIZE){ streamSlot[i] = null; i++;
}
            streamSlot[0] = outputStream;
            
            
            if (_bufferLength != bufferLength) {
                _bufferLength = bufferLength;
				outputStream.buffer[(bufferLength << 1) - 1] = 0;
               i=0;
 while( i<PIPE_SIZE){
                    SLLint.freeRing(_pipeBuffer[i]);
                    _pipeBuffer[i] = SLLint.allocRing(bufferLength);
                    _pipeBufferPager[i] = SLLint.createRingPager(_pipeBuffer[i], true);
                 i++;
}
            }
            
            pcmVolume = 4;
            samplerVolume = 2;
            
            
            SiOPMChannelManager.initializeAllChannels();
        }
        
        
        
        public function reset() : Void
        {
            
            SiOPMChannelManager.resetAllChannels();
        }
        
        
        
        public function _beginProcess() : Void
        {
            outputStream.clear();
        }
        
        
        
        public function _endProcess() : Void
        {
            outputStream.limit();
            if (_bitRate != 0) outputStream.quantize(_bitRate);
        }
        
        
        
        public function getPipe(pipeNum:Int, index:Int=0) : SLLint
        {
            return _pipeBufferPager[pipeNum][index];
        }
    }


