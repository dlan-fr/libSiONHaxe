






package org.si.sion.utils ;
    import org.si.sion.effector.*;
    import org.si.utils.*;
	import org.si.sion.effector.SiFilterBandPass;

    
    class PeakDetector
    {
    
    
        
        static public var maxPeaksPerMinute:Float = 192;
        
        
        private var _bpf:SiFilterBandPass = new SiFilterBandPass();
        private var _window:SLLNumber = null;
        
        private var _frequency:Float;
        private var _bandWidth:Float;
        private var _windowLength:Float;
        private var _profileDirty:Bool;
        private var _peakListDirty:Bool;
        private var _peakFreqDirty:Bool;
        private var _signalToNoiseRatio:Float;
        private var _samplesChannelCount:Int;
        private var _samples: Array<Float> = null;
        
        private var _stream: Array<Float> = new Array<Float>();
        private var _profile: Array<Float> = new Array<Float>();
        private var _diffLogProfile: Array<Float> = new Array<Float>();
        private var _peakList: Array<Float> = new Array<Float>();
        private var _ppmScore: Array<Float>;
        private var _peaksPerMinute:Float;
        private var _peaksPerMinuteProbability:Float;
        private var _maximum:Float;
        private var _average:Float;
        
        
        
        
    
    
        
        public function get_windowLength() : Int { return Std.int(_windowLength); }
        public function windowLength(l:Int) : Void {
            if (_windowLength != l) {
                _peakFreqDirty = _peakListDirty = _profileDirty = true;
                _windowLength = l;
                _resetWindow();
            }
        }
        
        
        
        public function get_frequency() : Float { return _frequency; }
        public function frequency(f:Float) : Void {
            if (_frequency != f) {
                _peakFreqDirty = _peakListDirty = _profileDirty = true;
                _frequency = f;
                _updateFilter();
            }
        }
        
        
        
        public function get_bandWidth() : Float { return (_frequency>0) ? _bandWidth : 0; }
        public function bandWidth(b:Float) : Void {
            if (_bandWidth != b) {
                _peakFreqDirty = _peakListDirty = _profileDirty = true;
                _bandWidth = b;
                _updateFilter();
            }
        }
        
        
        
        public function get_signalToNoiseRatio() : Float { return _signalToNoiseRatio; }
        public function signalToNoiseRatio(n:Float) : Void { _signalToNoiseRatio = n; }
        
        
        
        public function samples() : Array<Float> { return _samples; }
        
        
        
        public function samplesChannelCount() : Int { return _samplesChannelCount; }
        
        
        
        public function powerProfile() : Array<Float> {
            _updateProfile();
            return _profile;
        }
        
        
        
        public function differencialOfLogPowerProfile() : Array<Float> {
            _updatePeakList();
            return _diffLogProfile;
        }
        
        
        
        public function average() : Float {
            _updateProfile();
            return _average;
        }
        
        
        
        public function maximum() : Float {
            _updateProfile();
            return _maximum;
        }
        
        
        
        public function peakList() : Array<Float> {
            _updatePeakList();
            return _peakList;
        }
        
        
        
        public function peaksPerMinuteEstimationScoreTable() : Array<Float> {
            _updatePeakFreq();
            return _ppmScore;
        }
        
        
        
        public function peaksPerMinute() : Float {
            _updatePeakFreq();
            return _peaksPerMinute;
        }
        
        
        
        public function peaksPerMinuteProbability() : Float {
            _updatePeakFreq();
            return _peaksPerMinuteProbability;
        }
        
        
        
        
    
    
        
        public function new(frequency:Float=0, bandWidth:Float=0.5, windowLength:Float=20, signalToNoiseRatio:Float=20) {
            _frequency = frequency;
            _bandWidth = bandWidth;
            _windowLength = windowLength;
            _signalToNoiseRatio = signalToNoiseRatio;
            _updateFilter();
            _resetWindow();
            _profileDirty = true;
            _peakListDirty = true;
            _peakFreqDirty = true;
            _average = 0;
        }
        
        
        
        
    
    
        
        public function setSamples(samples: Array<Float>, channelCount:Int=2, isStreaming:Bool=false) : PeakDetector
        {
            _peakFreqDirty = _peakListDirty = _profileDirty = true;
            _samples = samples;
            _samplesChannelCount = channelCount;
            if (!isStreaming) _resetWindow();
            return this;
        }
        
        
        
        public function calcPeakIntencity(peakPosition:Float, integrateLength:Float=10) : Float
        {
            var i:Int, n:Float, 
                imin:Int = Std.int(peakPosition * 2.1 + 0.5),
                imax:Int = Std.int((peakPosition + integrateLength) * 2.1 + 0.5);
            _updateProfile();
            if (imin > _profile.length) imin = _profile.length;
            if (imax > _profile.length) imax = _profile.length;
           n=0; i=imin;
 while( i<imax){ n += _profile[i]; i++;
}
            return n;
        }
        
        
         
        static public function mergePeakList(arrayOfPeakList:Array<Dynamic>, singlePeakLength:Float=40) : Array<Float>
        {
            var listIndex:Int, peakListCount:Int, i:Int, 
                currentPosition:Float, nextPeakPosition:Float, nextPeakHolder:Int, 
                merged: Array<Float>, list: Array<Float>, idx: Array<Int>;
            peakListCount = arrayOfPeakList.length;
            idx = new Array<Int>();
            merged = new Array<Float>();
            
           i=0;
 while( i<peakListCount){ idx[i] = 0; i++;
}
            currentPosition = -singlePeakLength;
            while (true) {
                nextPeakPosition = 99999999;
                nextPeakHolder = -1;
               listIndex=0;
 while( listIndex<peakListCount){
                    list = arrayOfPeakList[listIndex];
                    if (idx[listIndex] < list.length && list[idx[listIndex]] < nextPeakPosition) {
                        nextPeakPosition = list[idx[listIndex]];
                        nextPeakHolder = listIndex;
                    }
                 listIndex++;
}
                if (nextPeakHolder != -1) {
                    idx[nextPeakHolder]++;
                    if (nextPeakPosition - currentPosition >= singlePeakLength) {
                        merged.push(nextPeakPosition);
                        currentPosition = nextPeakPosition;
                    }
                } else break; 
            }
            
            return merged;
        }
        
        
        
        
    
    
        
        private function _resetWindow() : Void {
            if (_window != null) SLLNumber.freeRing(_window);
            _window = SLLNumber.allocRing(Std.int (_windowLength * 2.1 + 0.5), 0);
        }
        
        
        
        private function _updateFilter() : Void {
            if (_frequency > 0) {
                _bpf.initialize();
                _bpf.setParameters(_frequency, _bandWidth);
            }
        }
        
        
        
        private function _updateProfile() : Void {
            if (_profileDirty && _samples != null) {
                var imax:Int, i:Int, ix2:Int, ix42:Int, pow:Float, n:Float;

                
                imax = _samples.length;
                if (_samplesChannelCount == 1) { 
                    //_stream.length = imax * 2; HAXE PORT
                   ix2=i=0;
 while( i<imax){
                        _stream[ix2] = _samples[i]; ix2++;
                        _stream[ix2] = _samples[i]; ix2++;
                     i++;
}
                } else { 
                    //_stream.length = imax; HAXE PORT
                   i=0;
 while( i<imax){
                        n  = _samples[i]; i++;
                        n += _samples[i]; i--;
                        n *= 0.5;
                        _stream[i] = n; i++;
                        _stream[i] = n; i++;
                    }
                }
                
                
                if (_frequency > 0) {
                    _bpf.prepareProcess();
                    _bpf.process(1, _stream, 0, _stream.length>>1);
                }
                
                
                imax = Std.int((_stream.length-41) / 42);
               // _profile.length = imax;
                pow = 0;
                _average = 0;
                _maximum = 0;
               i=ix42=0;
 while( i<imax){
                    
                    _window.n  = _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    _window.n += _stream[ix42] * _stream[ix42]; ix42+=2;
                    pow += _window.n;
                    _window = _window.next;
                    pow -= _window.n;
                    _profile[i] = pow;
                    _average += pow;
                    if (_maximum < pow) _maximum = pow;
                 i++;
}
                _average /= imax;
                
                _profileDirty = false;
            }
        }
        
        
        
        private function _updatePeakList() : Void
        {
            _updateProfile();
            if (_peakListDirty && _profile.length>0) {
                var imax:Int = _profile.length,
                    thres:Float = _maximum * 0.001, 
                    snr:Float = Math.pow(10, _signalToNoiseRatio*0.1),
                    wnd:Int = Std.int(_windowLength * 2.1 + 0.5), 
                    decay:Float = Math.pow(2, -1/wnd),
                    i:Int, i1:Int, n:Float, envelope:Float, prevPoint:Int;
                
                //_diffLogProfile.length = imax;
                _diffLogProfile[0] = 0;
               i=1;
 while( i<imax){
                    i1 = i-1;
                    _diffLogProfile[i] = (_profile[i1] > thres) ? (_profile[i]/_profile[i1]-1) : 0;
                 i++;
}
                
				_peakList.splice(0, _peakList.length);
				
                envelope = 0;
                prevPoint = 0;
               i=wnd;
 while( i<imax){
                    if (_diffLogProfile[i] > envelope) {
                        n = _diffLogProfile[i-wnd];
                        if (n <= 0) n = 0.001;
                        n = _diffLogProfile[i] / n;
                        if (n > snr) {
                            if (i-prevPoint < wnd) {
                                _peakList[_peakList.length - 1] = i/2.1;
                            } else {
                                _peakList.push(i/2.1);
                            }
                            prevPoint = i;
                            envelope = _diffLogProfile[i];
                        }
                    }
                    envelope *= decay;
                 i++;
}
                _peakListDirty = false;
            }
        }
        
        
        
        private function _updatePeakFreq() : Void
        {
            _updatePeakList();
            if (_peakFreqDirty && _profile.length>0) {
                var i:Int, j:Int, highScoreFrames:Int, total:Int, frm:Int, score:Int;
                _ppmScore = calcPeaksPerMinuteEstimationScoreTable(_peakList, _ppmScore);
                _estimatePeaksPerMinuteFromScoreTable();
                _peakFreqDirty = false;
            }
        }
        
        
        
        private function _estimatePeaksPerMinuteFromScoreTable() : Void
        {
            var highScoreFrames:Int, i:Int, imax:Int, j:Int, frm:Int, thres:Float, pmin:Float, pmax:Float;
            
           highScoreFrames=100; i=101;
 while( i<2000){
                if (_ppmScore[i] > _ppmScore[highScoreFrames]) highScoreFrames = i;
             i++;
}
            
            while (highScoreFrames < 630) highScoreFrames *= 2;
            
            while (_ppmScore[highScoreFrames]<_ppmScore[highScoreFrames+1]) highScoreFrames++;
            while (_ppmScore[highScoreFrames]<_ppmScore[highScoreFrames-1]) highScoreFrames--;
            
            thres = _ppmScore[highScoreFrames] * 0.7;
            pmin = 0;
            imax = highScoreFrames - 100;
           i=highScoreFrames;
 while( i>imax){
                if (_ppmScore[i] < thres) {
                    pmin = i + (thres-_ppmScore[i])/(_ppmScore[i+1]-_ppmScore[i]);
                    break;
                }
             i--;
}
            pmax = 0;
            imax = highScoreFrames + 100;
           i=highScoreFrames;
 while( i<imax){
                if (_ppmScore[i] < thres) {
                    pmax = i + (_ppmScore[i-1]-thres)/(_ppmScore[i-1]-_ppmScore[i]);
                    break;
                }
             i++;
}
            
            if (pmin != 0 && pmax != 0) _peaksPerMinute = (highScoreFrames>0) ? (2100*60/((pmax+pmin)*0.5)) : 0;
            else _peaksPerMinute = (highScoreFrames>0) ? (2100*60/highScoreFrames) : 0;
            
            var minPeaksPerMinute:Float = maxPeaksPerMinute * 0.5;
            while (_peaksPerMinute >= maxPeaksPerMinute) _peaksPerMinute *= 0.5;
            while (_peaksPerMinute <  minPeaksPerMinute) _peaksPerMinute *= 2;
            
            _peaksPerMinuteProbability = 0;
           i=0;
 while( i<10){
                frm = Std.int(highScoreFrames * _probCheck[i]);
                if (frm>2100) break;
               j=-22;
 while( j<23){ _peaksPerMinuteProbability += _ppmScore[frm+j]; j++;
}
             i++;
}
        }
        static private var _probCheck: Array<Float> = [0.25,0.5,1,2,3,4,5,6,7,8];

        
        
        static public function calcPeaksPerMinuteEstimationScoreTable(peakList: Array<Float>, scoreTable: Array<Float>=null) : Array<Float>
        {
            var i:Int, j:Int, k:Int, s:Int, peakCount:Int, peakDist:Int, dist:Float, dist2:Float, scale:Float, scoreTotal:Int;
            if (scoreTable == null) scoreTable = new Array<Float>();
            
            i=0;
            while (i < 2124) { scoreTable[i] = 0; i++; }
            
            
            peakCount = peakList.length;
           i=0;
 while( i<peakCount){
               j=i+1;
 while( j<peakCount){
                    dist = peakList[j] - peakList[i];
                    if (dist<48) continue;
                    if (dist>1000) break;
                    scale = 1;
                   k=j+1;
 while( k<peakCount){
                        dist2 = (peakList[k] - peakList[j]) / dist + 0.1;
                        dist2 -= Std.int(dist2);
                        if (dist2 < 0.2) {
                            dist2 -= 0.1;
                            if (dist2<0) dist2 = -dist2;
                            scale += _normalDist[Std.int(dist2 * 20)] * 0.01;
                        }
                     k++;
}
                    peakDist = Std.int(dist * 2.1 + 0.5);
                    scoreTable[peakDist] += _normalDist[0] * scale;
                   k=1;
 while( k<20){
                        s = peakDist + k; scoreTable[s] += _normalDist[k] * scale;
                        s = peakDist - k; scoreTable[s] += _normalDist[k] * scale;
                     k++;
}
                 j++;
}
            i++;
}

            
           scoreTotal=0;       i=0;
 while( i<2124){ scoreTotal += Std.int(scoreTable[i]); i++;
}
           scale=1/scoreTotal; i=0;
 while( i<2124){ scoreTable[i] *= scale; i++;
}
            return scoreTable;
        }
        static private var _normalDist: Array<Int> = [100,99,95,89,81,73,63,53,44,35,28,21,16,11,8,6,4,2,2,1];
    }



