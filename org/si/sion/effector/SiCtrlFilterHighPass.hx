





package org.si.sion.effector ;
    
    class SiCtrlFilterHighPass extends SiCtrlFilterBase
    {
        
        public function new(cutoff:Float=1, resonance:Float=0)
        {
            initialize();
            control(cutoff, resonance);
			
			super();
        }
        
        
        
        override function processLFO(buffer: Array<Float>, startIndex:Int, length:Int) : Void
        {
            var i:Int, n:Float, imax:Int = startIndex + length,
                cut:Float = _table.filter_cutoffTable[_cutIndex],
                fb:Float = _res * _table.filter_feedbackTable[_cutIndex];
           i=startIndex;
 while( i<imax){
                n = buffer[i];
                _p0l += cut * (n - _p0l + fb * (_p0l - _p1l));
                _p1l += cut * (_p0l - _p1l);
                buffer[i] = n - _p0l; i++;
                n = buffer[i];
                _p0r += cut * (n - _p0r + fb * (_p0r - _p1r));
                _p1r += cut * (_p0r - _p1r);
                buffer[i] = n - _p0r; i++;
            }
        }
    }


