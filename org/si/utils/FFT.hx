























package org.si.utils ;
    
    class FFT
    {
    
    
        
        public var re: Array<Float>;
        
        public var im: Array<Float>;
        
        private var _length:Int = 0;
        private var _cosTable : Array<Float> = new Array<Float>();
        private var _bitrvTemp: Array<Int> = new Array<Int>();
        private var _waveTabler: Array<Float> = new Array<Float>();
        private var _waveTablei: Array<Float> = new Array<Float>();
        
        
        
        
    
    
        
        public function length() : Int { return _length; }
        
        
        
        
    
    
        
        function FFT(len:Int)
        {
            _initialize(len>>1);
        }
        
        
        
        
    
    
        
        public function cdft(isgn:Int, src: Array<Float>) : Void
        {
            setData(src);
            if (isgn >= 0) calcFFT();
            else           calcIFFT();
            getData(src);
        }
        
        

        
        public function rdft(isgn:Int, src: Array<Float>) : Void
        {
            setData(src);
            if (isgn >= 0) calcRealFFT();
            else           calcRealIFFT();
            getData(src);
        }
        
        
        
        public function ddct(isgn:Int, src: Array<Float>) : Void
        {
            setData(src);
            if (isgn >= 0) calcIDCT();
            else           calcDCT();
            getData(src);
        }


        
        public function ddst(isgn:Int, src: Array<Float>) : Void
        {
            var j:Int, xr:Float;
            
            setData(src);
            if (isgn >= 0) {
                xr = im[_length - 1];
               j=_length-1;
 while( j>=1){
                    im[j] = -re[j] - im[j-1];
                    re[j] -= im[j-1];
                 j--;
}
                im[0] = re[0] + xr;
                re[0] -= xr;
                _rftbsub();
                _bitrv2();
                _cftbsub();
                _dstsub();
            } else {
                _dstsub();
                _bitrv2();
                _cftfsub();
                _rftfsub();
                xr = re[0] - im[0];
                re[0] += im[0];
               j=1;
 while( j<_length){
                    im[j - 1] = - re[j] - im[j];
                    re[j] -= im[j];
                 j++;
}
                im[_length - 1] = xr;
            }
            getData(src);
        }
        
        
        
        
    
    
        
        public function setData(src: Array<Float>) : FFT
        {
            var i:Int, i2:Int;
           i=0; i2=0;
 while( i<_length){
                re[i] = src[i2]; i2++;
                im[i] = src[i2]; i2++;
             i++;
}
            return this;
        }
        
        
        
        
    
    
        
        public function getData(dst: Array<Float>=null) : Array<Float>
        {
            if (dst == null) dst = new Array<Float>();//_length<<1
            var i:Int, i2:Int;
           i=0; i2=0;
 while( i<_length){
                dst[i2] = re[i]; i2++;
                dst[i2] = im[i]; i2++;
             i++;
}
            return dst;
        }
        
        
        
        public function getIntensity(dst: Array<Float>=null) : Array<Float>
        {
            var i:Int, x:Float, y:Float;
            if (dst == null) dst = new Array<Float>();//_length
           i=0;
 while( i<_length){
                x = re[i];
                y = im[i];
                dst[i] = x*x + y*y;
             i++;
}
            return dst;
        }
        
        
        
        public function getMagnitude(dst: Array<Float>=null) : Array<Float>
        {
            var i:Int, x:Float, y:Float;
            if (dst == null) dst = new Array<Float>();//_length
           i=0;
 while( i<_length){
                x = re[i];
                y = im[i];
                dst[i] = Math.sqrt(x*x + y*y);
             i++;
}
            return dst;
        }
        
        
        
        public function getPhase(dst: Array<Float>=null) : Array<Float>
        {
            if (dst == null) dst = new Array<Float>();//_length
           var i:Int=0;
 while( i<_length){ 
                dst[i] = Math.atan2(im[i], re[i]);
             i++;
}
            return dst;
        }
        
        
        
        
    
    
        
        public function scale(n:Float) : FFT
        {
           var i:Int=0;
 while( i<_length){
                re[i] *= n;
                im[i] *= n;
             i++;
}
            return this;
        }
        
        
        
        public function calcFFT() : FFT
        {
            _bitrv2();
            _cftfsub();
            return this;
        }
        
        
        
        public function calcIFFT() : FFT
        {
            _bitrv2conj();
            _cftbsub();
            return this;
        }
        
        
        
        public function calcRealFFT() : FFT
        {
            _bitrv2();
            _cftfsub();
            _rftfsub();
            var xi:Float = re[0] - im[0];
            re[0] += im[0];
            im[0] = xi;
            return this;
        }
        
        
        
        public function calcRealIFFT() : FFT
        {
            im[0] = 0.5 * (re[0] - im[0]);
            re[0] -= im[0];
            _rftbsub();
            _bitrv2();
            _cftbsub();
            return this;
        }
        
        
        
        public function calcDCT() : FFT
        {
            var j:Int, dj:Int = _length - 1, xr:Float;
            xr = im[dj];
           j = _length - 1;
 while( j>=1){
                dj = j - 1;
                im[j] = re[j] - im[dj];
                re[j] += im[dj];
             j--;
}
            im[0] = re[0] - xr;
            re[0] += xr;
            _rftbsub();
            _bitrv2();
            _cftbsub();
            _dctsub();
            return this;
        }
        
        
        
        public function calcIDCT() : FFT
        {
            var j:Int, dj:Int, xr:Float;
            _dctsub();
            _bitrv2();
            _cftfsub();
            _rftfsub();
            xr = re[0] - im[0];
            re[0] += im[0];
            dj = 0;
           j=1;
 while( j<_length){
                im[dj] = re[j] - im[j];
                re[j] += im[j];
                dj = j;
             j++;
}
            im[dj] = xr;
            return this;
        }
        
        
        
        
    
    
        
        private function _initialize(len:Int) : Void
        {
            
           var l:Int=8;
 while( l<len){
				l<<=1;
		
}
            len = l;
            var tableLength:Int = len >> 2;

           // _waveTabler.length = tableLength; HAXE PORT / check if any error
           // _waveTablei.length = tableLength;
            var i:Int, imax:Int = len >> 3, dt:Float = 6.283185307179586 / len;
            _waveTabler[0] = 1;
            _waveTablei[0] = 0;
            _waveTabler[imax] = _waveTablei[imax] = Math.cos(0.7853981633974483);
           i=1;
 while( i<imax){
                _waveTablei[tableLength-i] = _waveTabler[i] = Math.cos(i*dt);
                _waveTabler[tableLength-i] = _waveTablei[i] = Math.sin(i*dt);
             i++;
}
            
            re = _waveTabler;
            im = _waveTablei;
            _length = tableLength;
            _bitrv2();
            
            
            imax = len << 1;
            //_cosTable.length = imax;HAXE PORT / check if any error
            dt = 1.5707963267948965 / imax;
           i=0;
 while( i<imax){
				_cosTable[i] = Math.cos(i*dt) * 0.5;
			 i++;
}
            
            
            re = new Array<Float>();
            im = new Array<Float>();
            _length = len;
        }
        
        
        
        private function _bitrv2() : Void
        {
            var j:Int, j1:Int, k:Int, k1:Int,
                xr:Float, xi:Float, yr:Float, yi:Float;
            
            _bitrvTemp[0] = 0;
            var l:Int = _length, m:Int = 1;
            while ((m << 2) < l) {
                l >>= 1;
               j = 0;
 while( j < m){_bitrvTemp[m + j] = _bitrvTemp[j] + l; j++;
}
                m <<= 1;
            }
            
            if ((m << 2) == l) {
               k = 0;
 while( k < m){
                   j = 0;
 while( j < k){
                        j1 = j + _bitrvTemp[k];
                        k1 = k + _bitrvTemp[j];
                        xr = re[j1];
                        xi = im[j1];
                        yr = re[k1];
                        yi = im[k1];
                        re[j1] = yr;
                        im[j1] = yi;
                        re[k1] = xr;
                        im[k1] = xi;
                        j1 += m;
                        k1 += m + m;
                        xr = re[j1];
                        xi = im[j1];
                        yr = re[k1];
                        yi = im[k1];
                        re[j1] = yr;
                        im[j1] = yi;
                        re[k1] = xr;
                        im[k1] = xi;
                        j1 += m;
                        k1 -= m;
                        xr = re[j1];
                        xi = im[j1];
                        yr = re[k1];
                        yi = im[k1];
                        re[j1] = yr;
                        im[j1] = yi;
                        re[k1] = xr;
                        im[k1] = xi;
                        j1 += m;
                        k1 += m + m;
                        xr = re[j1];
                        xi = im[j1];
                        yr = re[k1];
                        yi = im[k1];
                        re[j1] = yr;
                        im[j1] = yi;
                        re[k1] = xr;
                        im[k1] = xi;
                     j++;
}
                    j1 = k + m + _bitrvTemp[k];
                    k1 = j1 + m;
                    xr = re[j1];
                    xi = im[j1];
                    yr = re[k1];
                    yi = im[k1];
                    re[j1] = yr;
                    im[j1] = yi;
                    re[k1] = xr;
                    im[k1] = xi;
                 k++;
}
            } else {
               k = 1;
 while( k < m){
                   j = 0;
 while( j < k){
                        j1 = j + _bitrvTemp[k];
                        k1 = k + _bitrvTemp[j];
                        xr = re[j1];
                        xi = im[j1];
                        yr = re[k1];
                        yi = im[k1];
                        re[j1] = yr;
                        im[j1] = yi;
                        re[k1] = xr;
                        im[k1] = xi;
                        j1 += m;
                        k1 += m;
                        xr = re[j1];
                        xi = im[j1];
                        yr = re[k1];
                        yi = im[k1];
                        re[j1] = yr;
                        im[j1] = yi;
                        re[k1] = xr;
                        im[k1] = xi;
                     j++;
}
                 k++;
}
            }
        }
        
        
        
        private function _bitrv2conj() : Void
        {
            var j:Int, j1:Int, k:Int, k1:Int,
                xr:Float, xi:Float, yr:Float, yi:Float;
            
            _bitrvTemp[0] = 0;
            var l:Int = _length, m:Int = 1;
            while ((m << 2) < l) {
                l >>= 1;
               j = 0;
 while( j < m){_bitrvTemp[m + j] = _bitrvTemp[j] + l; j++;
}
                m <<= 1;
            }

            if ((m << 2) == l) {
               k = 0;
 while( k < m){
                   j = 0;
 while( j < k){
                        j1 = j + _bitrvTemp[k];
                        k1 = k + _bitrvTemp[j];
                        xr =  re[j1];
                        xi = -im[j1];
                        yr =  re[k1];
                        yi = -im[k1];
                        re[j1] = yr;
                        im[j1] = yi;
                        re[k1] = xr;
                        im[k1] = xi;
                        j1 += m;
                        k1 += m + m;
                        xr =  re[j1];
                        xi = -im[j1];
                        yr =  re[k1];
                        yi = -im[k1];
                        re[j1] = yr;
                        im[j1] = yi;
                        re[k1] = xr;
                        im[k1] = xi;
                        j1 += m;
                        k1 -= m;
                        xr =  re[j1];
                        xi = -im[j1];
                        yr =  re[k1];
                        yi = -im[k1];
                        re[j1] = yr;
                        im[j1] = yi;
                        re[k1] = xr;
                        im[k1] = xi;
                        j1 += m;
                        k1 += m + m;
                        xr =  re[j1];
                        xi = -im[j1];
                        yr =  re[k1];
                        yi = -im[k1];
                        re[j1] = yr;
                        im[j1] = yi;
                        re[k1] = xr;
                        im[k1] = xi;
                     j++;
}
                    k1 = k + _bitrvTemp[k];
                    im[k1] = -im[k1];
                    j1 = k1 + m;
                    k1 = j1 + m;
                    xr =  re[j1];
                    xi = -im[j1];
                    yr =  re[k1];
                    yi = -im[k1];
                    re[j1] = yr;
                    im[j1] = yi;
                    re[k1] = xr;
                    im[k1] = xi;
                    k1 += m;
                    im[k1] = -im[k1];
                 k++;
}
            } else {
                im[0] = -im[0];
                im[m] = -im[m];
               k = 1;
 while( k < m){
                   j = 0;
 while( j < k){
                        j1 = j + _bitrvTemp[k];
                        k1 = k + _bitrvTemp[j];
                        xr =  re[j1];
                        xi = -im[j1];
                        yr =  re[k1];
                        yi = -im[k1];
                        re[j1] = yr;
                        im[j1] = yi;
                        re[k1] = xr;
                        im[k1] = xi;
                        j1 += m;
                        k1 += m;
                        xr =  re[j1];
                        xi = -im[j1];
                        yr =  re[k1];
                        yi = -im[k1];
                        re[j1] = yr;
                        im[j1] = yi;
                        re[k1] = xr;
                        im[k1] = xi;
                     j++;
}
                    k1 = k + _bitrvTemp[k];
                    im[k1] = -im[k1];
                    im[k1 + m] = -im[k1 + m];
                 k++;
}
            }
        }
        
        
        
        
    
    
        private function _cftfsub() : Void
        {
            var j0:Int, j1:Int, j2:Int, j3:Int, l:Int,
                x0r:Float, x1r:Float, x2r:Float, x3r:Float,
                x0i:Float, x1i:Float, x2i:Float, x3i:Float;
            
            _cft1st();
            l = 4;
            while ((l << 2) < _length) {
                _cftmdl(l);
                l <<= 2;
            }
            
            if ((l << 2) == _length) {
               j0 = 0;
 while( j0 < l){
                    j1 = j0 + l;
                    j2 = j1 + l;
                    j3 = j2 + l;
                    x0r = re[j0] + re[j1];
                    x0i = im[j0] + im[j1];
                    x1r = re[j0] - re[j1];
                    x1i = im[j0] - im[j1];
                    x2r = re[j2] + re[j3];
                    x2i = im[j2] + im[j3];
                    x3r = re[j2] - re[j3];
                    x3i = im[j2] - im[j3];
                    re[j0] = x0r + x2r;
                    im[j0] = x0i + x2i;
                    re[j2] = x0r - x2r;
                    im[j2] = x0i - x2i;
                    re[j1] = x1r - x3i;
                    im[j1] = x1i + x3r;
                    re[j3] = x1r + x3i;
                    im[j3] = x1i - x3r;
                 j0++;
}
            } else {
               j0 = 0;
 while( j0 < l){
                    j1 = j0 + l;
                    x0r = re[j0] - re[j1];
                    x0i = im[j0] - im[j1];
                    re[j0] += re[j1];
                    im[j0] += im[j1];
                    re[j1] = x0r;
                    im[j1] = x0i;
                 j0++;
}
            }
        }


        private function _cftbsub() : Void
        {
            var j0:Int, j1:Int, j2:Int, j3:Int, l:Int,
                x0r:Float, x1r:Float, x2r:Float, x3r:Float,
                x0i:Float, x1i:Float, x2i:Float, x3i:Float;
            
            _cft1st();
            l = 4;
            while ((l << 2) < _length) {
                _cftmdl(l);
                l <<= 2;
            }

            if ((l << 2) == _length) {
               j0 = 0;
 while( j0 < l){
                    j1 = j0 + l;
                    j2 = j1 + l;
                    j3 = j2 + l;
                    x0r =  re[j0] + re[j1];
                    x0i = -im[j0] - im[j1];
                    x1r =  re[j0] - re[j1];
                    x1i = -im[j0] + im[j1];
                    x2r =  re[j2] + re[j3];
                    x2i =  im[j2] + im[j3];
                    x3r =  re[j2] - re[j3];
                    x3i =  im[j2] - im[j3];
                    re[j0] = x0r + x2r;
                    im[j0] = x0i - x2i;
                    re[j2] = x0r - x2r;
                    im[j2] = x0i + x2i;
                    re[j1] = x1r - x3i;
                    im[j1] = x1i - x3r;
                    re[j3] = x1r + x3i;
                    im[j3] = x1i + x3r;
                 j0++;
}
            } else {
               j0 = 0;
 while( j0 < l){
                    j1 = j0 + l;
                    x0r =  re[j0] - re[j1];
                    x0i = -im[j0] + im[j1];
                    re[j0] +=  re[j1];
                    im[j0] = -im[j0] - im[j1];
                    re[j1] = x0r;
                    im[j1] = x0i;
                 j0++;
}
            }
        }
        
        
        private function _cft1st() : Void
        {
            var j0:Int, j1:Int, j2:Int, j3:Int, k1:Int, k2:Int,
                wk1r:Float, wk2r:Float, wk3r:Float, x0r:Float, x1r:Float, x2r:Float, x3r:Float,
                wk1i:Float, wk2i:Float, wk3i:Float, x0i:Float, x1i:Float, x2i:Float, x3i:Float;
            
            x0r = re[0] + re[1];
            x0i = im[0] + im[1];
            x1r = re[0] - re[1];
            x1i = im[0] - im[1];
            x2r = re[2] + re[3];
            x2i = im[2] + im[3];
            x3r = re[2] - re[3];
            x3i = im[2] - im[3];
            re[0] = x0r + x2r;
            im[0] = x0i + x2i;
            re[2] = x0r - x2r;
            im[2] = x0i - x2i;
            re[1] = x1r - x3i;
            im[1] = x1i + x3r;
            re[3] = x1r + x3i;
            im[3] = x1i - x3r;
            wk1r = _waveTabler[1];
            x0r = re[4] + re[5];
            x0i = im[4] + im[5];
            x1r = re[4] - re[5];
            x1i = im[4] - im[5];
            x2r = re[6] + re[7];
            x2i = im[6] + im[7];
            x3r = re[6] - re[7];
            x3i = im[6] - im[7];
            re[4] = x0r + x2r;
            im[4] = x0i + x2i;
            re[6] = x2i - x0i;
            im[6] = x0r - x2r;
            x0r = x1r - x3i;
            x0i = x1i + x3r;
            re[5] = wk1r * (x0r - x0i);
            im[5] = wk1r * (x0r + x0i);
            x0r = x3i + x1r;
            x0i = x3r - x1i;
            re[7] = wk1r * (x0i - x0r);
            im[7] = wk1r * (x0i + x0r);
            k1 = 0;
           j0 = 8;
 while( j0 < _length){
                j1 = j0 + 1;
                j2 = j1 + 1;
                j3 = j2 + 1;
                k1++;
                k2 = 2 * k1;
                wk2r = _waveTabler[k1];
                wk2i = _waveTablei[k1];
                wk1r = _waveTabler[k2];
                wk1i = _waveTablei[k2];
                wk3r = wk1r - 2 * wk2i * wk1i;
                wk3i = 2 * wk2i * wk1r - wk1i;
                x0r = re[j0] + re[j1];
                x0i = im[j0] + im[j1];
                x1r = re[j0] - re[j1];
                x1i = im[j0] - im[j1];
                x2r = re[j2] + re[j3];
                x2i = im[j2] + im[j3];
                x3r = re[j2] - re[j3];
                x3i = im[j2] - im[j3];
                re[j0] = x0r + x2r;
                im[j0] = x0i + x2i;
                x0r -= x2r;
                x0i -= x2i;
                re[j2] = wk2r * x0r - wk2i * x0i;
                im[j2] = wk2r * x0i + wk2i * x0r;
                x0r = x1r - x3i;
                x0i = x1i + x3r;
                re[j1] = wk1r * x0r - wk1i * x0i;
                im[j1] = wk1r * x0i + wk1i * x0r;
                x0r = x1r + x3i;
                x0i = x1i - x3r;
                re[j3] = wk3r * x0r - wk3i * x0i;
                im[j3] = wk3r * x0i + wk3i * x0r;
                
                k2++;
                wk1r = _waveTabler[k2];
                wk1i = _waveTablei[k2];
                wk3r = wk1r - 2 * wk2r * wk1i;
                wk3i = 2 * wk2r * wk1r - wk1i;
                j0 += 4;
                j1 = j0 + 1;
                j2 = j1 + 1;
                j3 = j2 + 1;
                x0r = re[j0] + re[j1];
                x0i = im[j0] + im[j1];
                x1r = re[j0] - re[j1];
                x1i = im[j0] - im[j1];
                x2r = re[j2] + re[j3];
                x2i = im[j2] + im[j3];
                x3r = re[j2] - re[j3];
                x3i = im[j2] - im[j3];
                re[j0] = x0r + x2r;
                im[j0] = x0i + x2i;
                x0r -= x2r;
                x0i -= x2i;
                re[j2] = -wk2i * x0r - wk2r * x0i;
                im[j2] = -wk2i * x0i + wk2r * x0r;
                x0r = x1r - x3i;
                x0i = x1i + x3r;
                re[j1] = wk1r * x0r - wk1i * x0i;
                im[j1] = wk1r * x0i + wk1i * x0r;
                x0r = x1r + x3i;
                x0i = x1i - x3r;
                re[j3] = wk3r * x0r - wk3i * x0i;
                im[j3] = wk3r * x0i + wk3i * x0r;
             j0 += 4;
}
        }
        
        
        private function _cftmdl(l:Int) : Void
        {
            var j0:Int, j1:Int, j2:Int, j3:Int, k:Int, k1:Int, k2:Int, m:Int, m2:Int,
                wk1r:Float, wk2r:Float, wk3r:Float, x0r:Float, x1r:Float, x2r:Float, x3r:Float,
                wk1i:Float, wk2i:Float, wk3i:Float, x0i:Float, x1i:Float, x2i:Float, x3i:Float;
            
            m = l << 2;
           j0 = 0;
 while( j0 < l){
                j1 = j0 + l;
                j2 = j1 + l;
                j3 = j2 + l;
                x0r = re[j0] + re[j1];
                x0i = im[j0] + im[j1];
                x1r = re[j0] - re[j1];
                x1i = im[j0] - im[j1];
                x2r = re[j2] + re[j3];
                x2i = im[j2] + im[j3];
                x3r = re[j2] - re[j3];
                x3i = im[j2] - im[j3];
                re[j0] = x0r + x2r;
                im[j0] = x0i + x2i;
                re[j2] = x0r - x2r;
                im[j2] = x0i - x2i;
                re[j1] = x1r - x3i;
                im[j1] = x1i + x3r;
                re[j3] = x1r + x3i;
                im[j3] = x1i - x3r;
             j0++;
}
            wk1r = _waveTabler[1];
           j0 = m;
 while( j0 < l + m){
                j1 = j0 + l;
                j2 = j1 + l;
                j3 = j2 + l;
                x0r = re[j0] + re[j1];
                x0i = im[j0] + im[j1];
                x1r = re[j0] - re[j1];
                x1i = im[j0] - im[j1];
                x2r = re[j2] + re[j3];
                x2i = im[j2] + im[j3];
                x3r = re[j2] - re[j3];
                x3i = im[j2] - im[j3];
                re[j0] = x0r + x2r;
                im[j0] = x0i + x2i;
                re[j2] = x2i - x0i;
                im[j2] = x0r - x2r;
                x0r = x1r - x3i;
                x0i = x1i + x3r;
                re[j1] = wk1r * (x0r - x0i);
                im[j1] = wk1r * (x0r + x0i);
                x0r = x3i + x1r;
                x0i = x3r - x1i;
                re[j3] = wk1r * (x0i - x0r);
                im[j3] = wk1r * (x0i + x0r);
             j0++;
}
            k1 = 0;
            m2 = 2 * m;
           k = m2;
 while( k < _length){
                k1 += 1;
                k2 = 2 * k1;
                wk2r = _waveTabler[k1];
                wk2i = _waveTablei[k1];
                wk1r = _waveTabler[k2];
                wk1i = _waveTablei[k2];
                wk3r = wk1r - 2 * wk2i * wk1i;
                wk3i = 2 * wk2i * wk1r - wk1i;
               j0 = k;
 while( j0 < l + k){
                    j1 = j0 + l;
                    j2 = j1 + l;
                    j3 = j2 + l;
                    x0r = re[j0] + re[j1];
                    x0i = im[j0] + im[j1];
                    x1r = re[j0] - re[j1];
                    x1i = im[j0] - im[j1];
                    x2r = re[j2] + re[j3];
                    x2i = im[j2] + im[j3];
                    x3r = re[j2] - re[j3];
                    x3i = im[j2] - im[j3];
                    re[j0] = x0r + x2r;
                    im[j0] = x0i + x2i;
                    x0r -= x2r;
                    x0i -= x2i;
                    re[j2] = wk2r * x0r - wk2i * x0i;
                    im[j2] = wk2r * x0i + wk2i * x0r;
                    x0r = x1r - x3i;
                    x0i = x1i + x3r;
                    re[j1] = wk1r * x0r - wk1i * x0i;
                    im[j1] = wk1r * x0i + wk1i * x0r;
                    x0r = x1r + x3i;
                    x0i = x1i - x3r;
                    re[j3] = wk3r * x0r - wk3i * x0i;
                    im[j3] = wk3r * x0i + wk3i * x0r;
                 j0++;
}
                k2++;
                wk1r = _waveTabler[k2];
                wk1i = _waveTablei[k2];
                wk3r = wk1r - 2 * wk2r * wk1i;
                wk3i = 2 * wk2r * wk1r - wk1i;
               j0 = k + m;
 while( j0 < l + (k + m)){
                    j1 = j0 + l;
                    j2 = j1 + l;
                    j3 = j2 + l;
                    x0r = re[j0] + re[j1];
                    x0i = im[j0] + im[j1];
                    x1r = re[j0] - re[j1];
                    x1i = im[j0] - im[j1];
                    x2r = re[j2] + re[j3];
                    x2i = im[j2] + im[j3];
                    x3r = re[j2] - re[j3];
                    x3i = im[j2] - im[j3];
                    re[j0] = x0r + x2r;
                    im[j0] = x0i + x2i;
                    x0r -= x2r;
                    x0i -= x2i;
                    re[j2] = -wk2i * x0r - wk2r * x0i;
                    im[j2] = -wk2i * x0i + wk2r * x0r;
                    x0r = x1r - x3i;
                    x0i = x1i + x3r;
                    re[j1] = wk1r * x0r - wk1i * x0i;
                    im[j1] = wk1r * x0i + wk1i * x0r;
                    x0r = x1r + x3i;
                    x0i = x1i - x3r;
                    re[j3] = wk3r * x0r - wk3i * x0i;
                    im[j3] = wk3r * x0i + wk3i * x0r;
                 j0++;
}
             k += m2;
}
        }
        
        
        private function _rftfsub() : Void 
        {
            var j:Int, k:Int, kk:Int, m:Int, ctLength:Int = _cosTable.length, 
                wkr:Float, wki:Float, xr:Float, xi:Float, yr:Float, yi:Float;
            
            m = _length >> 1;
            kk = 0;
           j = 1;
 while( j < m){
                k = _length - j;
                kk += 4;
                wkr = 0.5 - _cosTable[ctLength - kk];
                wki = _cosTable[kk];
                xr = re[j] - re[k];
                xi = im[j] + im[k];
                yr = wkr * xr - wki * xi;
                yi = wkr * xi + wki * xr;
                re[j] -= yr;
                im[j] -= yi;
                re[k] += yr;
                im[k] -= yi;
             j++;
}
        }


        private function _rftbsub() : Void 
        {
            var j:Int, k:Int, kk:Int, m:Int, ctLength:Int = _cosTable.length, 
                wkr:Float, wki:Float, xr:Float, xi:Float, yr:Float, yi:Float;
            
            im[0] = -im[0];
            m = _length >> 1;
            kk = 0;
           j = 1;
 while( j < m){
                k = _length - j;
                kk += 4;
                wkr = 0.5 - _cosTable[ctLength - kk];
                wki = _cosTable[kk];
                xr = re[j] - re[k];
                xi = im[j] + im[k];
                yr = wkr * xr + wki * xi;
                yi = wkr * xi - wki * xr;
                re[j] -= yr;
                im[j]  = yi - im[j];
                re[k] += yr;
                im[k]  = yi - im[k];
             j++;
}
            im[m] = -im[m];
        }
        
        
        private function _dctsub() : Void 
        {
            var j:Int, k:Int, kk:Int, ikk:Int, 
                m:Int, wkr:Float, wki:Float, xr:Float,
                ctLength:Int = _cosTable.length;
            
            m = _length >> 1;
            k = _length-1;
            kk = 1;
            ikk = ctLength - 1;
            wkr = _cosTable[kk] - _cosTable[ikk];
            wki = _cosTable[kk] + _cosTable[ikk];
            xr       = wki * im[0] - wkr * im[k];
            im[0] = wkr * im[0] + wki * im[k];
            im[k] = xr;
           j = 1;
 while( j < m){
                k = _length - j;
                kk++;
                ikk--;
                wkr = _cosTable[kk] - _cosTable[ikk];
                wki = _cosTable[kk] + _cosTable[ikk];
                xr    = wki * re[j] - wkr * re[k];
                re[j] = wkr * re[j] + wki * re[k];
                re[k] = xr;
                k--;
                kk++;
                ikk--;
                wkr = _cosTable[kk] - _cosTable[ikk];
                wki = _cosTable[kk] + _cosTable[ikk];
                xr    = wki * im[j] - wkr * im[k];
                im[j] = wkr * im[j] + wki * im[k];
                im[k] = xr;
             j++;
}
            re[m] *= 0.7071067811865476; 
        }


        private function _dstsub() : Void 
        {
            var j:Int, k:Int, kk:Int, ikk:Int, 
                m:Int, wkr:Float, wki:Float, xr:Float,
                ctLength:Int = _cosTable.length;
            
            m = _length >> 1;
            k = _length-1;
            kk = 1;
            ikk = ctLength - 1;
            wkr = _cosTable[kk] - _cosTable[ikk];
            wki = _cosTable[kk] + _cosTable[ikk];
            xr    = wki * im[k] - wkr * im[0];
            im[k] = wkr * im[k] + wki * im[0];
            im[0] = xr;
           j = 1;
 while( j < m){
                k = _length - j;
                kk++;
                ikk--;
                wkr = _cosTable[kk] - _cosTable[ikk];
                wki = _cosTable[kk] + _cosTable[ikk];
                xr    = wki * re[k] - wkr * re[j];
                re[k] = wkr * re[k] + wki * re[j];
                re[j] = xr;
                k--;
                kk++;
                ikk--;
                wkr = _cosTable[kk] - _cosTable[ikk];
                wki = _cosTable[kk] + _cosTable[ikk];
                xr    = wki * im[k] - wkr * im[j];
                im[k] = wkr * im[k] + wki * im[j];
                im[j] = xr;
             j++;
}
            re[m] *= 0.7071067811865476; 
        }
    }



