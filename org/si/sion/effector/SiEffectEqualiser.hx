





package org.si.sion.effector ;
    
    class SiEffectEqualiser extends SiEffectBase
    {
    
    
        
        private var f1p0L:Float;
		private var f1p1L:Float;
		private var f1p2L:Float;
		private var f1p3L:Float;
        private var f2p0L:Float;
		private var f2p1L:Float;
		private var f2p2L:Float;
		private var f2p3L:Float;
        private var sdm1L:Float;
		private var sdm2L:Float;
		private var sdm3L:Float;
        private var f1p0R:Float;
		private var f1p1R:Float;
		private var f1p2R:Float;
		private var f1p3R:Float;
        private var f2p0R:Float;
		private var f2p1R:Float;
		private var f2p2R:Float;
		private var f2p3R:Float;
        private var sdm1R:Float;
		private var sdm2R:Float;
		private var sdm3R:Float;

        
        private var lf:Float;
		private var hf:Float;
        private var lg:Float;
		private var mg:Float;
		private var hg:Float;
        
        
        
        
    
    
        
        function new(lowGain:Float=1, midGain:Float=1, highGain:Float=1, lowFreq:Float=880, highFreq:Float=5000) 
        {
            setParameters(lowGain, midGain, highGain, lowFreq, highFreq);
        }
        
        
        
        
    
    
        
        public function setParameters(lowGain:Float=1, midGain:Float=1, highGain:Float=1, lowFreq:Float=880, highFreq:Float=5000) : Void
        {
          lg = lowGain;
          mg = midGain;
          hg = highGain;
          lf = 2 * Math.sin(lowFreq  * 0.00007123792865282977);    
          hf = 2 * Math.sin(highFreq * 0.00007123792865282977);
        }
        
        
        
        
    
    
        
        override public function initialize() : Void
        {
            setParameters();
        }
        

        
        override public function mmlCallback(args: Array<Float>) : Void
        {
            setParameters((!Math.isNaN(args[0])) ? args[0]*0.01 : 1,
                          (!Math.isNaN(args[1])) ? args[1]*0.01 : 1,
                          (!Math.isNaN(args[2])) ? args[2]*0.01 : 1,
                          (!Math.isNaN(args[3])) ? args[3] : 880,
                          (!Math.isNaN(args[4])) ? args[4] : 5000);
        }
        
        
        
        override public function prepareProcess() : Int
        {
            sdm1L = sdm2L = sdm3L = f2p0L = f2p1L = f2p2L = f2p3L = f1p0L = f1p1L = f1p2L = f1p3L = 0;
            sdm1R = sdm2R = sdm3R = f2p0R = f2p1R = f2p2R = f2p3R = f1p0R = f1p1R = f1p2R = f1p3R = 0;
            return 2;
        }
        
        
        
        override public function process(channels:Int, buffer: Array<Float>, startIndex:Int, length:Int) : Int
        {
            startIndex <<= 1;
            length <<= 1;
            var i:Int, n:Float, l:Float, m:Float, h:Float, imax:Int=startIndex+length;
            if (channels == 2) {
               i=startIndex;
 while( i<imax){
                    n = buffer[i];
                    f1p0L += (lf * (n - f1p0L)) + 2.3283064370807974e-10;
                    f1p1L += (lf * (f1p0L - f1p1L));
                    f1p2L += (lf * (f1p1L - f1p2L));
                    f1p3L += (lf * (f1p2L - f1p3L));
                    f2p0L += (hf * (n - f2p0L)) + 2.3283064370807974e-10;
                    f2p1L += (hf * (f2p0L - f2p1L));
                    f2p2L += (hf * (f2p1L - f2p2L));
                    f2p3L += (hf * (f2p2L - f2p3L));
                    l = f1p3L;
                    h = sdm3L - f2p3L;
                    m = sdm3L - (h + l);
                    sdm3L = sdm2L;
                    sdm2L = sdm1L;
                    sdm1L = n;
                    buffer[i] = l * lg + m * mg + h * hg;
                    i++;

                    n = buffer[i];
                    f1p0R += (lf * (n - f1p0R)) + 2.3283064370807974e-10;
                    f1p1R += (lf * (f1p0R - f1p1R));
                    f1p2R += (lf * (f1p1R - f1p2R));
                    f1p3R += (lf * (f1p2R - f1p3R));
                    f2p0R += (hf * (n - f2p0R)) + 2.3283064370807974e-10;
                    f2p1R += (hf * (f2p0R - f2p1R));
                    f2p2R += (hf * (f2p1R - f2p2R));
                    f2p3R += (hf * (f2p2R - f2p3R));
                    l = f1p3R;
                    h = (sdm3R - f2p3R);
                    m = (sdm3R - (h + l));
                    sdm3R = sdm2R;
                    sdm2R = sdm1R;
                    sdm1R = n;
                    buffer[i] = l * lg + m * mg + h * hg;
                    i++;
                }
            } else {
               i=startIndex;
 while( i<imax){
                    n = buffer[i];
                    f1p0L += (lf * (n - f1p0L)) + 2.3283064370807974e-10;
                    f1p1L += (lf * (f1p0L - f1p1L));
                    f1p2L += (lf * (f1p1L - f1p2L));
                    f1p3L += (lf * (f1p2L - f1p3L));
                    f2p0L += (hf * (n - f2p0L)) + 2.3283064370807974e-10;
                    f2p1L += (hf * (f2p0L - f2p1L));
                    f2p2L += (hf * (f2p1L - f2p2L));
                    f2p3L += (hf * (f2p2L - f2p3L));
                    l = f1p3L;
                    h = sdm3L - f2p3L;
                    m = sdm3L - (h + l);
                    sdm3L = sdm2L;
                    sdm2L = sdm1L;
                    sdm1L = n;
                    n = l * lg + m * mg + h * hg;
                    buffer[i] = n; i++;
                    buffer[i] = n; i++;
                }
            }
            return channels;
        }
    }


