





package org.si.sion.effector ;
    import org.si.utils.SLLNumber;
    
    
    
    class SiEffectCompressor extends SiEffectBase
    {
    
    
        private var _windowRMSList:SLLNumber = null;
        private var _windowSamples:Int;
        private var _windowRMSTotal:Float;
        private var _windwoRMSAveraging:Float;
        private var _threshold2:Float;  
        private var _attRate:Float;     
        private var _relRate:Float;     
        private var _maxGain:Float;     
        private var _mixingLevel:Float; 
        private var _gain:Float;        
        
        
        
        
    
    
        
        function new(thres:Float=0.7, wndTime:Float=50, attTime:Float=20, relTime:Float=20, maxGain:Float=-6, mixingLevel:Float=0.5)
        {
            setParameters(thres, wndTime, attTime, relTime, maxGain, mixingLevel);
        }
        
        
        
        
    
    
        
        public function setParameters(thres:Float=0.7, wndTime:Float=50, attTime:Float=20, relTime:Float=20, maxGain:Float=-6, mixingLevel:Float=0.5) : Void {
            _threshold2 = thres*thres;
            _windowSamples = Std.int(wndTime * 44.1);
            _windwoRMSAveraging = 1/_windowSamples;
            _attRate = (attTime == 0) ? 0.5 : (Math.pow(2, -1/(attTime * 44.1)));
            _relRate = (relTime == 0) ? 2.0 : (Math.pow(2,  1/(relTime * 44.1)));
            _maxGain = Math.pow(2, -maxGain/6);
            _mixingLevel = mixingLevel;
        }
        
        
        
        
    
    
        
        override public function initialize() : Void
        {
            setParameters();
        }
        

        
        override public function mmlCallback(args: Array<Float>) : Void
        {
            setParameters((!Math.isNaN(args[0])) ? args[0]*0.01 : 0.7,
                          (!Math.isNaN(args[1])) ? args[1] : 50,
                          (!Math.isNaN(args[2])) ? args[2] : 20,
                          (!Math.isNaN(args[3])) ? args[3] : 20,
                          (!Math.isNaN(args[4])) ? -args[4] : -6,
                          (!Math.isNaN(args[5])) ? args[5]*0.01 : 0.5);
        }
        
        
        
        override public function prepareProcess() : Int
        {
            if (_windowRMSList != null) SLLNumber.freeRing(_windowRMSList);
            _windowRMSList = SLLNumber.allocRing(_windowSamples);
            _windowRMSTotal = 0;
            _gain = 2;
            return 2;
        }
        
        
        
        override public function process(channels:Int, buffer: Array<Float>, startIndex:Int, length:Int) : Int
        {
            startIndex <<= 1;
            length <<= 1;
            
            var i:Int, imax:Int = startIndex + length;
            var l:Float, r:Float, rms2:Float;
           i=startIndex;
 while( i<imax){
                l = buffer[i]; i++;
                r = buffer[i]; --i;
                _windowRMSList = _windowRMSList.next;
                _windowRMSTotal  -= _windowRMSList.n;
                _windowRMSList.n = l * l + r * r;
                _windowRMSTotal  += _windowRMSList.n;
                rms2 = _windowRMSTotal * _windwoRMSAveraging;
                _gain *= (rms2 > _threshold2) ? _attRate : _relRate;
                if (_gain > _maxGain) _gain = _maxGain;

                l *= _gain;
                r *= _gain;
                l = (l>1) ? 1 : (l<-1) ? -1 : l;
                r = (r>1) ? 1 : (r<-1) ? -1 : r;
                buffer[i] = l * _mixingLevel; i++;
                buffer[i] = r * _mixingLevel;
             i++;
}
            return channels;
        }
    }


