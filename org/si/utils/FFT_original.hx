




















package org.si.utils ;
    
    class FFT_original
    {
    
    
        private var _length:Int = 0;
        private var _waveTable: Array<Float> = new Array<Float>();
        private var _cosTable : Array<Float> = new Array<Float>();
        private var _bitrvTemp: Array<Int> = new Array<Int>();
        
        
        
        
    
    
        
        function FFT_original(length:Int)
        {
            _initialize(length);
        }
        
        
        
        
    
    
                public function cdft(isgn:Int, src: Array<Float>) : Void
        {
            if (isgn >= 0) {
                _bitrv2(src, _length);
                _cftfsub(src);
            } else {
                _bitrv2conj(src, _length);
                _cftbsub(src);
            }
        }
        
        

        
        public function rdft(isgn:Int, src: Array<Float>) : Void
        {
            var xi:Float;
            
            if (isgn >= 0) {
                _bitrv2(src, _length);
                _cftfsub(src);
                _rftfsub(src);
                xi = src[0] - src[1];
                src[0] += src[1];
                src[1] = xi;
            } else {
                src[1] = 0.5 * (src[0] - src[1]);
                src[0] -= src[1];
                _rftbsub(src);
                _bitrv2(src, _length);
                _cftbsub(src);
            }
        }
        
        
        
        public function ddct(isgn:Int, src: Array<Float>) : Void
        {
            var j:Int, xr:Float;
            
            if (isgn < 0) {
                xr = src[_length - 1];
               j = _length - 2;
 while( j >= 2){
                    src[j+1] = src[j] - src[j - 1];
                    src[j] += src[j - 1];
                 j -= 2;
}
                src[1] = src[0] - xr;
                src[0] += xr;
                _rftbsub(src);
                _bitrv2(src, _length);
                _cftbsub(src);
                _dctsub(src);
            } else {
                _dctsub(src);
                _bitrv2(src, _length);
                _cftfsub(src);
                _rftfsub(src);
                xr = src[0] - src[1];
                src[0] += src[1];
               j = 2;
 while( j < _length){
                    src[j - 1] = src[j] - src[j+1];
                    src[j] += src[j+1];
                 j += 2;
}
                src[_length - 1] = xr;
            }
        }


        
        public function ddst(isgn:Int, src: Array<Float>) : Void
        {
            var j:Int, xr:Float;
            
            if (isgn < 0) {
                xr = src[_length - 1];
               j = _length - 2;
 while( j >= 2){
                    src[j+1] = -src[j] - src[j - 1];
                    src[j] -= src[j - 1];
                 j -= 2;
}
                src[1] = src[0] + xr;
                src[0] -= xr;
                _rftbsub(src);
                _bitrv2(src, _length);
                _cftbsub(src);
                _dstsub(src);
            } else {
                _dstsub(src);
                _bitrv2(src, _length);
                _cftfsub(src);
                _rftfsub(src);
                xr = src[0] - src[1];
                src[0] += src[1];
               j = 2;
 while( j < _length){
                    src[j - 1] = -src[j] - src[j+1];
                    src[j] -= src[j+1];
                 j += 2;
}
                src[_length - 1] = -xr;
            }
        }
        
        
        
        
    
    
        
        private function _initialize(len:Int) : Void
        {
           _length=8;
 while( _length<len){	
			_length<<=1;
			
}
         //   _waveTable.length = _length >> 2; HAXE PORT
            //_cosTable.length = _length;
            var i:Int, imax:Int = _length >> 3, tlen:Int = _waveTable.length, 
                dt:Float = 6.283185307179586 / _length;
            
            _waveTable[0] = 1;
            _waveTable[1] = 0;
            _waveTable[imax+1] = _waveTable[imax] = Math.cos(0.7853981633974483);
           i=2;
 while( i<imax){
                _waveTable[tlen-i+1] = _waveTable[i]   = Math.cos(i*dt);
                _waveTable[tlen-i]   = _waveTable[i+1] = Math.sin(i*dt);
             i+=2;
}
            _bitrv2(_waveTable, tlen);
            
            imax = _cosTable.length;
            dt = 1.5707963267948965 / imax;
           i=0;
 while( i<imax){_cosTable[i] = Math.cos(i*dt) * 0.5; i++;
}
        }
        
        
        
        private function _bitrv2(src: Array<Float>, srclen:Int) : Void
        {
            var j:Int, j1:Int, k:Int, k1:Int,
                xr:Float, xi:Float, yr:Float, yi:Float;
            
            _bitrvTemp[0] = 0;
            var l:Int = srclen, m:Int = 1;
            while ((m << 3) < l) {
                l >>= 1;
               j = 0;
 while( j < m){_bitrvTemp[m + j] = _bitrvTemp[j] + l; j++;
}
                m <<= 1;
            }
            var m2:Int = m * 2;
            
            if ((m << 3) == l) {
               k = 0;
 while( k < m){
                   j = 0;
 while( j < k){
                        j1 = j + j + _bitrvTemp[k];
                        k1 = k + k + _bitrvTemp[j];
                        xr = src[j1];
                        xi = src[j1+1];
                        yr = src[k1];
                        yi = src[k1+1];
                        src[j1]   = yr;
                        src[j1+1] = yi;
                        src[k1]   = xr;
                        src[k1+1] = xi;
                        j1 += m2;
                        k1 += m2 + m2;
                        xr = src[j1];
                        xi = src[j1+1];
                        yr = src[k1];
                        yi = src[k1+1];
                        src[j1]   = yr;
                        src[j1+1] = yi;
                        src[k1]   = xr;
                        src[k1+1] = xi;
                        j1 += m2;
                        k1 -= m2;
                        xr = src[j1];
                        xi = src[j1+1];
                        yr = src[k1];
                        yi = src[k1+1];
                        src[j1]   = yr;
                        src[j1+1] = yi;
                        src[k1]   = xr;
                        src[k1+1] = xi;
                        j1 += m2;
                        k1 += m2 + m2;
                        xr = src[j1];
                        xi = src[j1+1];
                        yr = src[k1];
                        yi = src[k1+1];
                        src[j1]   = yr;
                        src[j1+1] = yi;
                        src[k1]   = xr;
                        src[k1+1] = xi;
                     j++;
}
                    j1 = k + k + m2 + _bitrvTemp[k];
                    k1 = j1 + m2;
                    xr = src[j1];
                    xi = src[j1+1];
                    yr = src[k1];
                    yi = src[k1+1];
                    src[j1]   = yr;
                    src[j1+1] = yi;
                    src[k1]   = xr;
                    src[k1+1] = xi;
                 k++;
}
            } else {
               k = 1;
 while( k < m){
                   j = 0;
 while( j < k){
                        j1 = j + j + _bitrvTemp[k];
                        k1 = k + k + _bitrvTemp[j];
                        xr = src[j1];
                        xi = src[j1+1];
                        yr = src[k1];
                        yi = src[k1+1];
                        src[j1]   = yr;
                        src[j1+1] = yi;
                        src[k1]   = xr;
                        src[k1+1] = xi;
                        j1 += m2;
                        k1 += m2;
                        xr = src[j1];
                        xi = src[j1+1];
                        yr = src[k1];
                        yi = src[k1+1];
                        src[j1]   = yr;
                        src[j1+1] = yi;
                        src[k1]   = xr;
                        src[k1+1] = xi;
                     j++;
}
                 k++;
}
            }
        }
        
        
        
        private function _bitrv2conj(src: Array<Float>, srclen:Int) : Void
        {
            var j:Int, j1:Int, k:Int, k1:Int,
                xr:Float, xi:Float, yr:Float, yi:Float;
            
            _bitrvTemp[0] = 0;
            var l:Int = srclen, m:Int = 1;
            while ((m << 3) < l) {
                l >>= 1;
               j = 0;
 while( j < m){ _bitrvTemp[m + j] = _bitrvTemp[j] + l; j++;
}
                m <<= 1;
            }
            var m2:Int = m << 1;

            if ((m << 3) == l) {
               k = 0;
 while( k < m){
                   j = 0;
 while( j < k){
                        j1 = j + j + _bitrvTemp[k];
                        k1 = k + k + _bitrvTemp[j];
                        xr =  src[j1];
                        xi = -src[j1+1];
                        yr =  src[k1];
                        yi = -src[k1+1];
                        src[j1]   = yr;
                        src[j1+1] = yi;
                        src[k1]   = xr;
                        src[k1+1] = xi;
                        j1 += m2;
                        k1 += m2 + m2;
                        xr =  src[j1];
                        xi = -src[j1+1];
                        yr =  src[k1];
                        yi = -src[k1+1];
                        src[j1]   = yr;
                        src[j1+1] = yi;
                        src[k1]   = xr;
                        src[k1+1] = xi;
                        j1 += m2;
                        k1 -= m2;
                        xr =  src[j1];
                        xi = -src[j1+1];
                        yr =  src[k1];
                        yi = -src[k1+1];
                        src[j1]   = yr;
                        src[j1+1] = yi;
                        src[k1]   = xr;
                        src[k1+1] = xi;
                        j1 += m2;
                        k1 += m2 + m2;
                        xr =  src[j1];
                        xi = -src[j1+1];
                        yr =  src[k1];
                        yi = -src[k1+1];
                        src[j1]   = yr;
                        src[j1+1] = yi;
                        src[k1]   = xr;
                        src[k1+1] = xi;
                     j++;
}
                    k1 = k + k + _bitrvTemp[k];
                    src[k1+1] = -src[k1+1];
                    j1 = k1 + m2;
                    k1 = j1 + m2;
                    xr =  src[j1];
                    xi = -src[j1+1];
                    yr =  src[k1];
                    yi = -src[k1+1];
                    src[j1]   = yr;
                    src[j1+1] = yi;
                    src[k1]   = xr;
                    src[k1+1] = xi;
                    k1 += m2;
                    src[k1+1] = -src[k1+1];
                 k++;
}
            } else {
                src[1] = -src[1];
                src[m2+1] = -src[m2+1];
               k = 1;
 while( k < m){
                   j = 0;
 while( j < k){
                        j1 = j + j + _bitrvTemp[k];
                        k1 = k + k + _bitrvTemp[j];
                        xr =  src[j1];
                        xi = -src[j1+1];
                        yr =  src[k1];
                        yi = -src[k1+1];
                        src[j1]   = yr;
                        src[j1+1] = yi;
                        src[k1]   = xr;
                        src[k1+1] = xi;
                        j1 += m2;
                        k1 += m2;
                        xr =  src[j1];
                        xi = -src[j1+1];
                        yr =  src[k1];
                        yi = -src[k1+1];
                        src[j1]   = yr;
                        src[j1+1] = yi;
                        src[k1]   = xr;
                        src[k1+1] = xi;
                     j++;
}
                    k1 = k + k + _bitrvTemp[k];
                    src[k1+1] = -src[k1+1];
                    src[k1 + m2+1] = -src[k1 + m2+1];
                 k++;
}
            }
        }
        
        
        
        
    
    
        private function _cftfsub(src: Array<Float>) : Void
        {
            var j0:Int, j1:Int, j2:Int, j3:Int, l:Int,
                x0r:Float, x1r:Float, x2r:Float, x3r:Float,
                x0i:Float, x1i:Float, x2i:Float, x3i:Float;
            
            _cft1st(src);
            l = 8;
            while ((l << 2) < _length) {
                _cftmdl(src, l);
                l <<= 2;
            }
            
            if ((l << 2) == _length) {
               j0 = 0;
 while( j0 < l){
                    j1 = j0 + l;
                    j2 = j1 + l;
                    j3 = j2 + l;
                    x0r = src[j0]   + src[j1];
                    x0i = src[j0+1] + src[j1+1];
                    x1r = src[j0]   - src[j1];
                    x1i = src[j0+1] - src[j1+1];
                    x2r = src[j2]   + src[j3];
                    x2i = src[j2+1] + src[j3+1];
                    x3r = src[j2]   - src[j3];
                    x3i = src[j2+1] - src[j3+1];
                    src[j0]   = x0r + x2r;
                    src[j0+1] = x0i + x2i;
                    src[j2]   = x0r - x2r;
                    src[j2+1] = x0i - x2i;
                    src[j1]   = x1r - x3i;
                    src[j1+1] = x1i + x3r;
                    src[j3]   = x1r + x3i;
                    src[j3+1] = x1i - x3r;
                 j0 += 2;
}
            } else {
               j0 = 0;
 while( j0 < l){
                    j1 = j0 + l;
                    x0r = src[j0]   - src[j1];
                    x0i = src[j0+1] - src[j1+1];
                    src[j0]   += src[j1];
                    src[j0+1] += src[j1+1];
                    src[j1]   = x0r;
                    src[j1+1] = x0i;
                 j0 += 2;
}
            }
        }


        private function _cftbsub(src: Array<Float>) : Void
        {
            var j0:Int, j1:Int, j2:Int, j3:Int, l:Int,
                x0r:Float, x1r:Float, x2r:Float, x3r:Float,
                x0i:Float, x1i:Float, x2i:Float, x3i:Float;
            
            _cft1st(src);
            l = 8;
            while ((l << 2) < _length) {
                _cftmdl(src, l);
                l <<= 2;
            }

            if ((l << 2) == _length) {
               j0 = 0;
 while( j0 < l){
                    j1 = j0 + l;
                    j2 = j1 + l;
                    j3 = j2 + l;
                    x0r =  src[j0]   + src[j1];
                    x0i = -src[j0+1] - src[j1+1];
                    x1r =  src[j0]   - src[j1];
                    x1i = -src[j0+1] + src[j1+1];
                    x2r =  src[j2]   + src[j3];
                    x2i =  src[j2+1] + src[j3+1];
                    x3r =  src[j2]   - src[j3];
                    x3i =  src[j2+1] - src[j3+1];
                    src[j0]   = x0r + x2r;
                    src[j0+1] = x0i - x2i;
                    src[j2]   = x0r - x2r;
                    src[j2+1] = x0i + x2i;
                    src[j1]   = x1r - x3i;
                    src[j1+1] = x1i - x3r;
                    src[j3]   = x1r + x3i;
                    src[j3+1] = x1i + x3r;
                 j0 += 2;
}
            } else {
               j0 = 0;
 while( j0 < l){
                    j1 = j0 + l;
                    x0r =  src[j0]   - src[j1];
                    x0i = -src[j0+1] + src[j1+1];
                    src[j0]  +=  src[j1];
                    src[j0+1] = -src[j0+1] - src[j1+1];
                    src[j1]   = x0r;
                    src[j1+1] = x0i;
                 j0 += 2;
}
            }
        }
        
        
        private function _cft1st(src: Array<Float>) : Void
        {
            var j:Int, k1:Int, k2:Int,
                wk1r:Float, wk2r:Float, wk3r:Float, x0r:Float, x1r:Float, x2r:Float, x3r:Float,
                wk1i:Float, wk2i:Float, wk3i:Float, x0i:Float, x1i:Float, x2i:Float, x3i:Float;
            
            x0r = src[0] + src[2];
            x0i = src[1] + src[3];
            x1r = src[0] - src[2];
            x1i = src[1] - src[3];
            x2r = src[4] + src[6];
            x2i = src[5] + src[7];
            x3r = src[4] - src[6];
            x3i = src[5] - src[7];
            src[0] = x0r + x2r;
            src[1] = x0i + x2i;
            src[4] = x0r - x2r;
            src[5] = x0i - x2i;
            src[2] = x1r - x3i;
            src[3] = x1i + x3r;
            src[6] = x1r + x3i;
            src[7] = x1i - x3r;
            wk1r = _waveTable[2];
            x0r = src[8] + src[10];
            x0i = src[9] + src[11];
            x1r = src[8] - src[10];
            x1i = src[9] - src[11];
            x2r = src[12] + src[14];
            x2i = src[13] + src[15];
            x3r = src[12] - src[14];
            x3i = src[13] - src[15];
            src[8] = x0r + x2r;
            src[9] = x0i + x2i;
            src[12] = x2i - x0i;
            src[13] = x0r - x2r;
            x0r = x1r - x3i;
            x0i = x1i + x3r;
            src[10] = wk1r * (x0r - x0i);
            src[11] = wk1r * (x0r + x0i);
            x0r = x3i + x1r;
            x0i = x3r - x1i;
            src[14] = wk1r * (x0i - x0r);
            src[15] = wk1r * (x0i + x0r);
            k1 = 0;
           j = 16;
 while( j < _length){
                k1 += 2;
                k2 = 2 * k1;
                wk2r = _waveTable[k1];
                wk2i = _waveTable[k1+1];
                wk1r = _waveTable[k2];
                wk1i = _waveTable[k2+1];
                wk3r = wk1r - 2 * wk2i * wk1i;
                wk3i = 2 * wk2i * wk1r - wk1i;
                x0r = src[j] + src[j + 2];
                x0i = src[j+1] + src[j + 3];
                x1r = src[j] - src[j + 2];
                x1i = src[j+1] - src[j + 3];
                x2r = src[j + 4] + src[j + 6];
                x2i = src[j + 5] + src[j + 7];
                x3r = src[j + 4] - src[j + 6];
                x3i = src[j + 5] - src[j + 7];
                src[j] = x0r + x2r;
                src[j+1] = x0i + x2i;
                x0r -= x2r;
                x0i -= x2i;
                src[j + 4] = wk2r * x0r - wk2i * x0i;
                src[j + 5] = wk2r * x0i + wk2i * x0r;
                x0r = x1r - x3i;
                x0i = x1i + x3r;
                src[j + 2] = wk1r * x0r - wk1i * x0i;
                src[j + 3] = wk1r * x0i + wk1i * x0r;
                x0r = x1r + x3i;
                x0i = x1i - x3r;
                src[j + 6] = wk3r * x0r - wk3i * x0i;
                src[j + 7] = wk3r * x0i + wk3i * x0r;
                wk1r = _waveTable[k2 + 2];
                wk1i = _waveTable[k2 + 3];
                wk3r = wk1r - 2 * wk2r * wk1i;
                wk3i = 2 * wk2r * wk1r - wk1i;
                x0r = src[j + 8] + src[j+10];
                x0i = src[j + 9] + src[j+11];
                x1r = src[j + 8] - src[j+10];
                x1i = src[j + 9] - src[j+11];
                x2r = src[j+12] + src[j+14];
                x2i = src[j+13] + src[j+15];
                x3r = src[j+12] - src[j+14];
                x3i = src[j+13] - src[j+15];
                src[j + 8] = x0r + x2r;
                src[j + 9] = x0i + x2i;
                x0r -= x2r;
                x0i -= x2i;
                src[j+12] = -wk2i * x0r - wk2r * x0i;
                src[j+13] = -wk2i * x0i + wk2r * x0r;
                x0r = x1r - x3i;
                x0i = x1i + x3r;
                src[j+10] = wk1r * x0r - wk1i * x0i;
                src[j+11] = wk1r * x0i + wk1i * x0r;
                x0r = x1r + x3i;
                x0i = x1i - x3r;
                src[j+14] = wk3r * x0r - wk3i * x0i;
                src[j+15] = wk3r * x0i + wk3i * x0r;
             j += 16;
}
        }
        
        
        private function _cftmdl(src: Array<Float>, l:Int) : Void
        {
            var j:Int, j1:Int, j2:Int, j3:Int, k:Int, k1:Int, k2:Int, m:Int, m2:Int,
                wk1r:Float, wk2r:Float, wk3r:Float, x0r:Float, x1r:Float, x2r:Float, x3r:Float,
                wk1i:Float, wk2i:Float, wk3i:Float, x0i:Float, x1i:Float, x2i:Float, x3i:Float;
            
            m = l << 2;
           j = 0;
 while( j < l){
                j1 = j + l;
                j2 = j1 + l;
                j3 = j2 + l;
                x0r = src[j] + src[j1];
                x0i = src[j+1] + src[j1+1];
                x1r = src[j] - src[j1];
                x1i = src[j+1] - src[j1+1];
                x2r = src[j2] + src[j3];
                x2i = src[j2+1] + src[j3+1];
                x3r = src[j2] - src[j3];
                x3i = src[j2+1] - src[j3+1];
                src[j] = x0r + x2r;
                src[j+1] = x0i + x2i;
                src[j2] = x0r - x2r;
                src[j2+1] = x0i - x2i;
                src[j1] = x1r - x3i;
                src[j1+1] = x1i + x3r;
                src[j3] = x1r + x3i;
                src[j3+1] = x1i - x3r;
             j += 2;
}
            wk1r = _waveTable[2];
           j = m;
 while( j < l + m){
                j1 = j + l;
                j2 = j1 + l;
                j3 = j2 + l;
                x0r = src[j] + src[j1];
                x0i = src[j+1] + src[j1+1];
                x1r = src[j] - src[j1];
                x1i = src[j+1] - src[j1+1];
                x2r = src[j2] + src[j3];
                x2i = src[j2+1] + src[j3+1];
                x3r = src[j2] - src[j3];
                x3i = src[j2+1] - src[j3+1];
                src[j] = x0r + x2r;
                src[j+1] = x0i + x2i;
                src[j2] = x2i - x0i;
                src[j2+1] = x0r - x2r;
                x0r = x1r - x3i;
                x0i = x1i + x3r;
                src[j1] = wk1r * (x0r - x0i);
                src[j1+1] = wk1r * (x0r + x0i);
                x0r = x3i + x1r;
                x0i = x3r - x1i;
                src[j3] = wk1r * (x0i - x0r);
                src[j3+1] = wk1r * (x0i + x0r);
             j += 2;
}
            k1 = 0;
            m2 = 2 * m;
           k = m2;
 while( k < _length){
                k1 += 2;
                k2 = 2 * k1;
                wk2r = _waveTable[k1];
                wk2i = _waveTable[k1+1];
                wk1r = _waveTable[k2];
                wk1i = _waveTable[k2+1];
                wk3r = wk1r - 2 * wk2i * wk1i;
                wk3i = 2 * wk2i * wk1r - wk1i;
               j = k;
 while( j < l + k){
                    j1 = j + l;
                    j2 = j1 + l;
                    j3 = j2 + l;
                    x0r = src[j] + src[j1];
                    x0i = src[j+1] + src[j1+1];
                    x1r = src[j] - src[j1];
                    x1i = src[j+1] - src[j1+1];
                    x2r = src[j2] + src[j3];
                    x2i = src[j2+1] + src[j3+1];
                    x3r = src[j2] - src[j3];
                    x3i = src[j2+1] - src[j3+1];
                    src[j] = x0r + x2r;
                    src[j+1] = x0i + x2i;
                    x0r -= x2r;
                    x0i -= x2i;
                    src[j2] = wk2r * x0r - wk2i * x0i;
                    src[j2+1] = wk2r * x0i + wk2i * x0r;
                    x0r = x1r - x3i;
                    x0i = x1i + x3r;
                    src[j1] = wk1r * x0r - wk1i * x0i;
                    src[j1+1] = wk1r * x0i + wk1i * x0r;
                    x0r = x1r + x3i;
                    x0i = x1i - x3r;
                    src[j3] = wk3r * x0r - wk3i * x0i;
                    src[j3+1] = wk3r * x0i + wk3i * x0r;
                 j += 2;
}
                wk1r = _waveTable[k2 + 2];
                wk1i = _waveTable[k2 + 3];
                wk3r = wk1r - 2 * wk2r * wk1i;
                wk3i = 2 * wk2r * wk1r - wk1i;
               j = k + m;
 while( j < l + (k + m)){
                    j1 = j + l;
                    j2 = j1 + l;
                    j3 = j2 + l;
                    x0r = src[j] + src[j1];
                    x0i = src[j+1] + src[j1+1];
                    x1r = src[j] - src[j1];
                    x1i = src[j+1] - src[j1+1];
                    x2r = src[j2] + src[j3];
                    x2i = src[j2+1] + src[j3+1];
                    x3r = src[j2] - src[j3];
                    x3i = src[j2+1] - src[j3+1];
                    src[j] = x0r + x2r;
                    src[j+1] = x0i + x2i;
                    x0r -= x2r;
                    x0i -= x2i;
                    src[j2] = -wk2i * x0r - wk2r * x0i;
                    src[j2+1] = -wk2i * x0i + wk2r * x0r;
                    x0r = x1r - x3i;
                    x0i = x1i + x3r;
                    src[j1] = wk1r * x0r - wk1i * x0i;
                    src[j1+1] = wk1r * x0i + wk1i * x0r;
                    x0r = x1r + x3i;
                    x0i = x1i - x3r;
                    src[j3] = wk3r * x0r - wk3i * x0i;
                    src[j3+1] = wk3r * x0i + wk3i * x0r;
                 j += 2;
}
             k += m2;
}
        }
        
        
        private function _rftfsub(src: Array<Float>) : Void 
        {
            var j:Int, k:Int, kk:Int, m:Int,
                wkr:Float, wki:Float, xr:Float, xi:Float, yr:Float, yi:Float;
            
            m = _length >> 1;
            kk = 0;
           j = 2;
 while( j < m){
                k = _length - j;
                kk += 4;
                wkr = 0.5 - _cosTable[_length - kk];
                wki = _cosTable[kk];
                xr = src[j] - src[k];
                xi = src[j+1] + src[k+1];
                yr = wkr * xr - wki * xi;
                yi = wkr * xi + wki * xr;
                src[j] -= yr;
                src[j+1] -= yi;
                src[k] += yr;
                src[k+1] -= yi;
             j += 2;
}
        }


        private function _rftbsub(src: Array<Float>) : Void 
        {
            var j:Int, k:Int, kk:Int, m:Int,
                wkr:Float, wki:Float, xr:Float, xi:Float, yr:Float, yi:Float;
            
            src[1] = -src[1];
            m = _length >> 1;
            kk = 0;
           j = 2;
 while( j < m){
                k = _length - j;
                kk += 4;
                wkr = 0.5 - _cosTable[_length - kk];
                wki = _cosTable[kk];
                xr = src[j] - src[k];
                xi = src[j+1] + src[k+1];
                yr = wkr * xr + wki * xi;
                yi = wkr * xi - wki * xr;
                src[j] -= yr;
                src[j+1] = yi - src[j+1];
                src[k] += yr;
                src[k+1] = yi - src[k+1];
             j += 2;
}
            src[m+1] = -src[m+1];
        }
        
        
        private function _dctsub(src: Array<Float>) : Void 
        {
            var j:Int, k:Int, kk:Int, m:Int, wkr:Float, wki:Float, xr:Float;
            
            m = _length >> 1;
            kk = 0;
           j = 1;
 while( j < m){
                k = _length - j;
                kk += 1;
                wkr = _cosTable[kk] - _cosTable[_length - kk];
                wki = _cosTable[kk] + _cosTable[_length - kk];
                xr = wki * src[j] - wkr * src[k];
                src[j] = wkr * src[j] + wki * src[k];
                src[k] = xr;
             j++;
}
            src[m] *= 0.7071067811865476; 
        }


        private function _dstsub(src: Array<Float>) : Void 
        {
           var j:Int, k:Int, kk:Int, m:Int, wkr:Float, wki:Float, xr:Float;
            
            m = _length >> 1;
            kk = 0;
           j = 1;
 while( j < m){
                k = _length - j;
                kk += 1;
                wkr = _cosTable[kk] - _cosTable[_length - kk];
                wki = _cosTable[kk] + _cosTable[_length - kk];
                xr = wki * src[k] - wkr * src[j];
                src[k] = wkr * src[k] + wki * src[j];
                src[j] = xr;
             j++;
}
            src[m] *= 0.7071067811865476; 
        }
    }











