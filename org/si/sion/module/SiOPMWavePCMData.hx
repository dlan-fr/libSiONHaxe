





package org.si.sion.module ;
    import flash.media.Sound;
    import org.si.sion.utils.SiONUtil;
    import org.si.sion.sequencer.SiMMLTable;
    import org.si.sion.module.SiOPMTable;
	import flash.errors.Error;
    
    
    
    class SiOPMWavePCMData extends SiOPMWaveBase
    {
    
    
        
        static public var maxSampleLengthFromSound:Int = 1048576;
        
        
        public var wavelet: Array<Int>;
        
        public var channelCount:Int;
        
        
        public var samplingPitch:Int;
        
        
        private var _startPoint:Int;
        
        private var _endPoint:Int;
        
        private var _loopPoint:Int;
        
        private var _sliceAfterLoading:Bool;
        
        
        static private var _sin: Array<Float> = new Array<Float>();
        
        
    
    
        
        public function sampleCount() : Int { return (wavelet != null) ? (wavelet.length >> (channelCount-1)) : 0; }
        
        
        public function samplingOctave() : Int { return Std.int(samplingPitch*0.001272264631043257); }
        
        
        public function startPoint() : Int { return _startPoint; }
        
        
        public function endPoint()   : Int { return _endPoint; }
        
        
        public function loopPoint()  : Int { return _loopPoint; }
        
        
        
        
    
    
        
        public function new(data:Dynamic=null, samplingPitch:Int=4416, srcChannelCount:Int=2, channelCount:Int=0)
        {
            super(SiMMLTable.MT_PCM);
            if (data) initialize(data, samplingPitch, srcChannelCount, channelCount);
        }
        
        
        
        
    
    
        
        public function initialize(data:Dynamic, samplingPitch:Int=4416, srcChannelCount:Int=2, channelCount:Int=0) : SiOPMWavePCMData
        {
			
			var isFloat:Bool = data != null && !Std.is(data,Sound) && data.length > 0 && Std.is(data[0], Float);
			var isInt:Bool = data != null && !Std.is(data,Sound) && data.length > 0 && Std.is(data[0], Int);

            _sliceAfterLoading = false;
            srcChannelCount = (srcChannelCount == 1) ? 1 : 2;
            if (channelCount == 0) channelCount = srcChannelCount;
            this.channelCount = (channelCount == 1) ? 1 : 2;
            if (Std.is(data,Sound)) {
                _listenSoundLoadingEvents(cast(data,Sound));
            } else if (isFloat) {
				var newdata:Array<Float> = cast data;
                wavelet = SiONUtil.logTransVector(newdata, srcChannelCount, null, this.channelCount);
            } else if (isInt) {
                wavelet = cast data;
            } else if (data == null) {
                wavelet = null;
            } else {
                throw new Error("SiOPMWavePCMData; not suitable data type");
            }
            this.samplingPitch = samplingPitch;

            _startPoint = 0;
            _endPoint   = this.sampleCount() - 1;
            _loopPoint  = -1;
            return this;
        }
        
        
        
        public function slice(startPoint:Int=-1, endPoint:Int=-1, loopPoint:Int=-1) : SiOPMWavePCMData 
        {
            _startPoint = startPoint;
            _endPoint = endPoint;
            _loopPoint = loopPoint;
            if (!_isSoundLoading()) _slice();
            else _sliceAfterLoading = true;
            return this;
        }
        
        
        
        public function getInitialSampleIndex(phase:Float=0) : Int
        {
            return Std.int(_startPoint*(1-phase) + _endPoint*phase);
        }
        
        
        
        public function loopTailSamples(sampleCount:Int=2205, tailMargin:Int=0, crossFade:Bool=true) : SiOPMWavePCMData
        {
            _endPoint = _seekEndGap() - tailMargin;
            if (_endPoint < _startPoint+sampleCount) {
                if (_endPoint < _startPoint) _endPoint = _startPoint;
                _loopPoint = _startPoint;
                return this;
            }
            _loopPoint = _endPoint - sampleCount;
            
            if (crossFade && _loopPoint > _startPoint+sampleCount) {
                var i:Int, j:Int, t:Float, idx0:Int, idx1:Int, li0:Int ,li1:Int, 
                    log: Array<Int> = SiOPMTable.instance().logTable,
                    envtop:Int = (-SiOPMTable.ENV_TOP)<<3,
                    i2n:Float = 1/cast(1<<SiOPMTable.LOG_VOLUME_BITS,Float),
                    offset:Int = _loopPoint << (channelCount - 1),
                    imax:Int = sampleCount << (channelCount - 1),
                    dt:Float = 1.5707963267948965/imax;
                if (_sin.length != imax) {
                    //_sin.length = imax;
                   i=0; t=0;
 while( i<imax){ _sin[i] =  Math.sin(t); i++; t+=dt;
}
                }
               i=0;
 while( i<imax){
                    idx0 = offset + i;
                    idx1 = idx0 - imax;
                    li0 = wavelet[idx0] + envtop;
                    li1 = wavelet[idx1] + envtop;
                    j = imax - 1 - i;
                    wavelet[idx0] = SiOPMTable.calcLogTableIndex((log[li0] * _sin[j] + log[li1] * _sin[i]) * i2n);
                 i++;
}
            }
            
            return this;
        }
        
        
        
        private function _seekHeadSilence() : Int
        {
            var i:Int, imax:Int = wavelet.length, threshold:Int = SiOPMTable.LOG_TABLE_BOTTOM - SiOPMTable.LOG_TABLE_RESOLUTION*14; 
           i=0;
 while( i<imax){ if (wavelet[i] < threshold) break; i++;
}
            return i >> (channelCount - 1);
        }
        
        
        
        private function _seekEndGap() : Int
        {
            var i:Int, threshold:Int = SiOPMTable.LOG_TABLE_BOTTOM - SiOPMTable.LOG_TABLE_RESOLUTION*2; 
           i=wavelet.length-1;
 while( i>0){ if (wavelet[i] < threshold) break; --i;
}
            return (i >> (channelCount - 1)) - 100; 
        }
        
        
        
        override function _onSoundLoadingComplete(sound:Sound) : Void 
        {
            wavelet = SiONUtil.logTrans(sound, null, channelCount, maxSampleLengthFromSound);
            if (_sliceAfterLoading) _slice();
            _sliceAfterLoading = false;
        }
        
        
        private function _slice() : Void
        {
            
            if (_startPoint < 0) _startPoint = _seekHeadSilence();
            if (_loopPoint < -1) {
                
                if (_endPoint >= 0) {
                    loopTailSamples(-_loopPoint);
                    if (_startPoint >= _endPoint) _endPoint = _startPoint;
                } else {
                    loopTailSamples(-_loopPoint, -_endPoint);
                }
            } else {
                
                var waveletLengh:Int = sampleCount();
                if (_endPoint < 0) _endPoint = _seekEndGap() + _endPoint;
                else if (_endPoint < _startPoint) _endPoint = _startPoint;
                else if (waveletLengh < _endPoint) _endPoint = waveletLengh - 1;
                
                if (_loopPoint != -1 && _loopPoint < _startPoint) _loopPoint = _startPoint;
                else if (_endPoint < _loopPoint) _loopPoint = -1;
            }
        }
    }


