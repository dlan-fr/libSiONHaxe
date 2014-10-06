





package org.si.sion.effector ;
    import org.si.utils.SLLNumber;
    
    
    
    class SiEffectAutoPan extends SiEffectBase
    {
    
    
        private var _stereo:Bool;
        
        private var _lfoStep:Int;
        private var _lfoResidueStep:Int;
        private var _pL:SLLNumber;
		private var _pR:SLLNumber;
        
        
        
        
    
    
        
        function new(frequency:Float=1, width:Float=1)
        {
            _pL = SLLNumber.allocRing(256);
            _lfoResidueStep = 0;
            setParameters(frequency, width);
        }
        
        
        
        
    
    
        
        public function setParameters(frequency:Float=1, width:Float=1) : Void 
        {
            var i:Int;
            frequency *= 0.5;
            _lfoStep = Std.int(172.265625/frequency);   
            if (_lfoStep <= 4) _lfoStep = 4;
            _stereo = false;
            if (width == 0) {
                width = 1;
                _stereo = true;
            }
            
            
            width *= 0.01227184630308513; 
           i=-128;
 while( i<128){
                _pL.n = Math.sin(1.5707963267948965+i*width); 
                _pL = _pL.next;
             i++;
}
            
            _pR = _pL;
           i=0;
 while( i<128){ _pR = _pR.next; i++;
}
        }
        
        
        
        
        
        override public function initialize() : Void
        {
            _lfoResidueStep = 0;
            setParameters();
        }
        

        
        override public function mmlCallback(args: Array<Float>) : Void
        {
            setParameters((!Math.isNaN(args[0])) ? args[0] : 1, 
                          (!Math.isNaN(args[1])) ? args[1]*0.01 : 1);
        }
        
        
        
        override public function prepareProcess() : Int
        {
            return (_stereo) ? 2 : 1;
        }
        
        
        
        override public function process(channels:Int, buffer: Array<Float>, startIndex:Int, length:Int) : Int
        {
            startIndex <<= 1;
            length <<= 1;
            
            var i:Int, imax:Int, istep:Int, c:Float, s:Float, l:Float, r:Float,
                proc:Dynamic = (_stereo) ? processLFOstereo : processLFOmono;
            istep = _lfoResidueStep;
            imax = startIndex + length;
           i=startIndex;
 while( i<imax-istep){
                proc(buffer, i, istep);
                i += istep;
                istep = _lfoStep<<1;
            
}
            proc(buffer, i, imax-i);
            _lfoResidueStep = istep - (imax - i);
            return 2;
        }
        
        
        
        public function processLFOmono(buffer: Array<Float>, startIndex:Int, length:Int) : Void
        {
            var c:Float = _pL.n, s:Float = _pR.n,
                i:Int, l:Float, imax:Int = startIndex + length;
           i=startIndex;
 while( i<imax){
                l = buffer[i];
                buffer[i] = l * c; i++;
                buffer[i] = l * s; i++;
            
}
            _pL = _pL.next;
            _pR = _pR.next;
        }
        
        
        public function processLFOstereo(buffer: Array<Float>, startIndex:Int, length:Int) : Void
        {
            var c:Float = _pL.n, s:Float = _pR.n,
                i:Int, l:Float, r:Float, imax:Int = startIndex + length;
           i=startIndex;
 while( i<imax){
                l = buffer[i];
                r = buffer[i+1];
                buffer[i]   = l * c - r * s;
                buffer[i+1] = l * s + r * c;
             i+=2;
}
            _pL = _pL.next;
            _pR = _pR.next;
        }
    }


