





package org.si.sion.effector ;
    
    class SiCtrlFilterLowPass extends SiCtrlFilterBase
    {
        
        function new(cutoff:Float=1, resonance:Float=0)
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
                _p0l += cut * (buffer[i] - _p0l + fb * (_p0l - _p1l));
                _p1l += cut * (_p0l - _p1l);
                buffer[i] = _p1l; i++;
                _p0r += cut * (buffer[i] - _p0r + fb * (_p0r - _p1r));
                _p1r += cut * (_p0r - _p1r);
                buffer[i] = _p1r; i++;
            }
        }
    }


