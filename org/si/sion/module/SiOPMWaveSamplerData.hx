





package org.si.sion.module ;
    import flash.media.Sound;
    import org.si.sion.sequencer.SiMMLTable;
    import org.si.sion.utils.SiONUtil;
    import org.si.sion.utils.PeakDetector;
    import org.si.utils.SLLNumber;
	import flash.errors.Error;
    
    
    class SiOPMWaveSamplerData extends SiOPMWaveBase
    {
    
    
        
        static public var extractThreshold:Int = 4000;
        
        
        
    
    
        
        private var _soundData:Sound;
        
        private var _waveData: Array<Float>;
        
        private var _channelCount:Int;
        
        private var _pan:Int;
        
        private var _isExtracted:Bool;
        
        private var _startPoint:Int;
        
        private var _endPoint:Int;
        
        private var _loopPoint:Int;
        
        private var _sliceAfterLoading:Bool;
        
        private var _ignoreNoteOff:Bool;
        
        private var _peakList: Array<Float>;
        
        
        
    
    
        
        public function soundData() : Sound { return _soundData; }
        
        
        public function waveData() : Array<Float> { return _waveData; }
        
        
        public function channelCount() : Int { return _channelCount; }

        
        public function pan():Int { return _pan; }
        
        
        public function length() : Int {
            if (_isExtracted) return (_waveData.length >> (_channelCount-1));
            if (_soundData != null) return Std.int(_soundData.length * 44.1);
            return 0;
        }
        
        
        
        public function isExtracted() : Bool { return _isExtracted; }
        
        
        
        public function get_ignoreNoteOff() : Bool { return _ignoreNoteOff; }
        public function ignoreNoteOff(b:Bool) : Void {
            _ignoreNoteOff = (_loopPoint == -1) && b;
        }
        
        
        
        public function startPoint() : Int { return _startPoint; }
        
        
        public function endPoint()   : Int { return _endPoint; }
        
        
        public function loopPoint()  : Int { return _loopPoint; }
        
        
        public function peakList() : Array<Float> { return  _peakList; }
        
        
        
        
    
    
        
        public function new(data:Dynamic=null, ignoreNoteOff:Bool=false, pan:Int=0, srcChannelCount:Int=2, channelCount:Int=0, peakList: Array<Float>=null) 
        {
            super(SiMMLTable.MT_SAMPLE);
            if (data) initialize(data, ignoreNoteOff, pan, srcChannelCount, channelCount, peakList);
        }
        
        
        
        
    
    
        
        public function initialize(data:Dynamic, ignoreNoteOff:Bool=false, pan:Int=0, srcChannelCount:Int=2, channelCount:Int=0, peakList: Array<Float>=null) : SiOPMWaveSamplerData
        {
            _sliceAfterLoading = false;
            srcChannelCount = (srcChannelCount == 1) ? 1 : 2;
            if (channelCount == 0) channelCount = srcChannelCount;
            this._channelCount = (channelCount == 1) ? 1 : 2;
			
			var isFloat:Bool = data != null && !Std.is(data, Sound) && data.length > 0 && Std.is(data[0], Float);
			
            if (isFloat) {
                this._soundData = null;
                this._waveData = _transChannel(data, srcChannelCount, _channelCount);
                _isExtracted = true;
            } else if (Std.is(data,Sound)) {
                _listenSoundLoadingEvents(cast(data,Sound));
            } else if (data == null) {
                this._soundData = null;
                this._waveData = null;
                _isExtracted = false;
            } else {
                throw new Error("SiOPMWaveSamplerData; not suitable data type");
            }
            
            this._startPoint = 0;
            this._endPoint   = length();
            this._loopPoint  = -1;
            this._peakList = peakList;
            this.ignoreNoteOff(ignoreNoteOff);
            this._pan = pan;
            return this;
        }
        
        
        
        public function slice(startPoint:Int=-1, endPoint:Int=-1, loopPoint:Int=-1) : SiOPMWaveSamplerData
        {
            _startPoint = startPoint;
            _endPoint = endPoint;
            _loopPoint = loopPoint;
            if (!_isSoundLoading()) _slice();
            else _sliceAfterLoading = true;
            return this;
        }
        
        
        
        public function extract() : Void
        {
            if (_isExtracted) return;
            this._waveData = SiONUtil.extract(this._soundData, null, _channelCount, length(), 0);
            _isExtracted = true;
        }
        
        
        
        public function getInitialSampleIndex(phase:Float=0) : Int
        {
            return Std.int(_startPoint*(1-phase) + _endPoint*phase);
        }
        
        
        
        public function constructPeakList() : PeakDetector
        {
            if (!_isExtracted) throw new Error("constructPeakList is only available for extracted data");
            var pd:PeakDetector = new PeakDetector();
            pd.setSamples(_waveData, _channelCount);
            _peakList = pd.peakList();
            return pd;
        }
        
        
        
        private function _seekHeadSilence() : Int
        {
            if (_waveData != null) {
                var i:Int=0, imax:Int=_waveData.length, ms:Float;
                var msWindow:SLLNumber = SLLNumber.allocRing(22); 
                if (_channelCount == 1) {
                    ms = 0;
                   i=0;
 while( i<imax){
                        ms -= msWindow.n;
                        msWindow = msWindow.next;
                        msWindow.n = _waveData[i] * _waveData[i];
                        ms += msWindow.n;
                        if (ms > 0.0011) break;
                     i++;
}
                } else {
                    ms = 0;
                   i=0;
 while( i<imax){
                        ms -= msWindow.n;
                        msWindow = msWindow.next;
                        msWindow.n  = _waveData[i] * _waveData[i]; i++;
                        msWindow.n += _waveData[i] * _waveData[i]; i++;
                        ms += msWindow.n;
                        if (ms > 0.0022) break;
                    }
                    i >>= 1;
                }
                SLLNumber.freeRing(msWindow);
                return i - 22;
            }
            return (_soundData != null) ? SiONUtil.getHeadSilence(_soundData) : 0;
        }
        
        
        
        private function _seekEndGap() : Int
        {
            if (_waveData != null) {
                var i:Int, ms:Float;
                if (_channelCount == 1) {
                   i=_waveData.length-1;
 while( i>=0){
                        if (_waveData[i]*_waveData[i] > 0.0001) break;
                     i--;
}
                } else {
                   i=_waveData.length-1;
 while( i>=0){
                        ms  = _waveData[i] * _waveData[i]; i--;
                        ms += _waveData[i] * _waveData[i]; i--;
                        if (ms > 0.0002) break;
                    }
                    i >>= 1;
                }
                return (i>length()-1152) ? i : (length()-1152);
            }
            return (_soundData != null) ? (length() - SiONUtil.getEndGap(_soundData)) : 0;
        }
        
        
        
        private function _transChannel(src: Array<Float>, srcChannelCount:Int, channelCount:Int) : Array<Float>
        {
            var i:Int, j:Int, imax:Int, dst: Array<Float>;
            if (srcChannelCount == channelCount) return src;
            if (srcChannelCount == 1) { 
                imax = src.length;
                dst = new Array<Float>();
               i=0; j=0;
 while( i<imax){ dst[j+1] = dst[j] = src[i]; i++; j+=2;
}
            } else { 
                imax = src.length>>1;
                dst = new Array<Float>();
               i=0; j=0;
 while( i<imax){ dst[i] = (src[j] + src[j+1]) * 0.5; i++; j+=2;
}
            }
            return dst;
        }
        
        
        
        override function _onSoundLoadingComplete(sound:Sound) : Void 
        {
            this._soundData = sound;
            if (this._soundData.length <= extractThreshold) {
                this._waveData = SiONUtil.extract(this._soundData, null, _channelCount, extractThreshold*45, 0);
                _isExtracted = true;
            } else {
                this._waveData = null;
                _isExtracted = false;
            }
            if (_sliceAfterLoading) _slice();
            _sliceAfterLoading = false;
        }
        
        
        private function _slice() : Void
        {
            if (_startPoint < 0) _startPoint = _seekHeadSilence();
            if (_loopPoint < 0) _loopPoint = -1;
            if (_endPoint < 0) _endPoint = _seekEndGap();
            if (_endPoint < _loopPoint) _loopPoint = -1;
            if (_endPoint < _startPoint) _endPoint = length() - 1;
        }
    }


