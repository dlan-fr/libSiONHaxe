








package org.si.sion.utils ;
    import flash.events.EventDispatcher;
    import flash.utils.ByteArray;
    import org.si.utils.ByteArrayExt;
	import flash.errors.Error;
	import flash.utils.Endian;
	import flash.events.ErrorEvent;
	import flash.events.Event;
    
    
    
    
    class PCMSample extends EventDispatcher {
    
    
        
        static public var basicInfoChunkID:String = "sinf";
        
        static public var extendedInfoChunkID:String = "SiON";
        
        
        
        public var sampleType:Int;    
        
        public var baseNote:Int; 
        
        public var beatCount:Int;    
        
        public var timeSignatureDenominator:Int;   
        
        public var timeSignatureNumber:Int;   
        
        public var bpm:Float;       


        
        
        var _waveDataChunks:Dynamic = null;
        
        var _waveData:ByteArrayExt = null;
        
        var _waveDataFormatID:Int;
        
        var _waveDataSampleRate:Float;
        
        var _waveDataBitRate:Int;
        
        var _waveDataChannels:Int;
        
        
        
        var _cache: Array<Float>;
        
        var _cacheSampleRate:Float;
        
        var _cacheChannels:Int;
        
        var _outputSampleRate:Float;
        
        var _outputChannels:Int;
        
        var _outputBitRate:Int;
        
        
        
        var _samples: Array<Float>;
        
        var _channels:Int;
        
        var _sampleRate:Int;
        
        
        
        var _appendPosition:Int;
        
        var _extractPosition:Float;
        
        
        
        
    
    
        
        public function samples() : Array<Float> { 
            if (_outputSampleRate == _sampleRate && _outputChannels == _channels) {

                return _samples;
            }
            if (_outputSampleRate == _cacheSampleRate && _outputChannels == _cacheChannels) {

                return _cache;
            }
            _cacheChannels = _outputChannels;
            _cacheSampleRate = _outputSampleRate;
            _convertSampleRate(_samples, _channels, _sampleRate, _cache, _cacheChannels, _cacheSampleRate, true);

            return _cache;
        }
        
        
        public function sampleLength() : Int {
            var sampleLength:Int = _samples.length >> (_channels - 1);
            return Std.int(sampleLength * _outputSampleRate / _sampleRate);
        }
        
         
        public function get_sampleRate() : Float { return _outputSampleRate; }
        public function sampleRate(rate:Float) : Void {
            _outputSampleRate = (rate == 0) ? _sampleRate : rate;
        }

         
        public function get_channels() : Int { return _outputChannels; }
        public function channels(count:Int) : Void {
            if (count != 1 && count != 2) throw new Error("channel count of 1 or 2 is only avairable.");
            _outputChannels = count;
        }
        
         
        public function get_bitRate() : Int { return _outputBitRate; }
        public function bitRate(rate:Int) : Void {
            if (rate != 8 && rate != 16 && rate != 24 && rate != 32) throw new Error("bitRate of " + Std.string(rate) +" is not avairable.");
            _outputBitRate = rate;
        }
        
        
        
        public function waveDataChunks() : Dynamic { return _waveDataChunks; }
        
        
        public function waveData() : ByteArray { return _waveData; }
        
        
        public function waveDataSampleRate() : Float { return _waveDataSampleRate; }
        
        
        public function waveDataBitRate() : Int { return _waveDataBitRate; }
        
        
        public function waveDataChannels() : Int { return _waveDataChannels; }
        
        
        
        public function internalSampleRate() : Float { return _sampleRate; }
        
        
        public function internalChannels() : Int { return _channels; }
        
        
        
        private var _lvfunctions:Array<Dynamic>;
		private var _v2wfunctions:Array<Dynamic>;
		private var _w2vfunctions:Array<Dynamic>;
    
        
        function new(channels:Int=2, sampleRate:Int=44100, samples: Array<Float>=null) 
        {
            this._channels = channels;
            this._sampleRate = sampleRate;
            this._samples = (samples != null) ? samples : new Array<Float>();
            this._cache = new Array<Float>();
            this._cacheSampleRate = 0;
            this._cacheChannels = 0;
            this._outputSampleRate = _sampleRate;
            this._outputChannels = _channels;
            this._outputBitRate = 16;
            this._waveDataChunks = null;
            this._waveData = null;
            this._waveDataFormatID = 1;
            this._waveDataSampleRate = 0;
            this._waveDataBitRate = 0;
            this._waveDataChannels = 0;
            this._extractPosition = 0;
            this._appendPosition = this._samples.length;
            this.sampleType = 0;
            this.baseNote = 69;
            this.beatCount = 0;
            this.timeSignatureDenominator = 4;
            this.timeSignatureNumber = 4;
            this.bpm = 0;
			
			_lvfunctions  = [_lvmmn, _lvsmn, _lvmsn, _lvssn, _lvmml, _lvsml, _lvmsl, _lvssl];
			_v2wfunctions = [_v2w8, _v2w16, _v2w24, _v2w32];
			_w2vfunctions = [_w2v8, _w2v16, _w2v24, _w2v32];
			
			super();

        }
        
        
        
        override public function toString() : String 
        {
            var str:String = "[object PCMSample : ";
            str += "channels=" + Std.string(_channels);
            str += " / sampleRate=" + Std.string(_sampleRate);
            str += " / sampleLength=" + Std.string(sampleLength);
            str += " / baseNote=" + Std.string(baseNote);
            str += " / beatCount=" + Std.string(beatCount);
            str += " / bpm=" + Std.string(bpm);
            str += " / timeSignature=" + Std.string(timeSignatureNumber)+"/"+Std.string(timeSignatureDenominator);
            str += "]";
            return str;
        }
        
        
        
        
    
    
        
        public function loadFromVector(src: Array<Float>, srcChannels:Int=2, srcSampleRate:Float=44100, linear:Bool=true) : PCMSample
        {
            _convertSampleRate(src, srcChannels, srcSampleRate, _samples, _channels, _sampleRate, linear);
            return this;
        }
        
        
        
        public function appendSamples(src: Array<Float>, sampleCount:Int=0, srcOffset:Int=0) : PCMSample
        {
            clearCache();
            var i:Int=srcOffset * _channels, len:Int = sampleCount * _channels, ptr:Int, ptrMax:Int;
            if ((len == 0) || ((i + len) > src.length)) len = src.length - i;
            ptrMax = _appendPosition + len;
			
            //if (_samples.length < ptrMax) _samples.length = ptrMax;
			
           ptr=_appendPosition;
 while( ptr<ptrMax){ _samples[ptr] = src[i]; ptr++; i++;
}
            _appendPosition = ptrMax;
            return this;
        }
        
        
        
        public function appendSamplesFromByteArrayFloat(bytes:ByteArray, sampleCount:Int=0) : PCMSample
        {
            if (_channels != 2 || _sampleRate != 44100) throw new Error("The format should be 2ch/44.1kHz.");
            clearCache();
            var len:Int = (bytes.length - bytes.position)>>3, ptr:Int, ptrMax:Int;
            if (sampleCount != 0 && len > sampleCount) len = sampleCount;
            ptrMax = _appendPosition + len*2;
           // if (_samples.length < ptrMax) _samples.length = ptrMax;
           ptr=_appendPosition;
 while( ptr<ptrMax){ _samples[ptr] = bytes.readFloat(); ptr++;
}
            _appendPosition = ptrMax;
            return this;
        }
        
        
        
        public function extract(dst: Array<Float>=null, length:Int=0, offset:Int=-1) : Array<Float>
        {
            if (offset == -1) offset = Std.int(_extractPosition);
            if (dst == null) dst = new Array<Float>();
            if (length == 0) length = 999999;
            
            var output: Array<Float> = this.samples();
            var i:Int, imax:Int=length*_outputChannels, j:Int=offset*_outputChannels;
            if (imax + j > output.length) imax = output.length - j;
           i=0;
 while( i<imax){ dst[i] = output[j]; i++; j++;
}
            
            _extractPosition = j >> (_outputChannels - 1);
            return dst;
        }
        
        
        
        public function clearCache() : PCMSample
        {
            _cache.splice(0, _cache.length);
            _cacheSampleRate = 0;
            _cacheChannels = 0;
            return this;
        }
        
        
        
        public function clearWaveDataCache() : PCMSample 
        {
            _waveDataChunks = null;
            _waveData = null;
            _waveDataFormatID = 1;
            _waveDataSampleRate = 0;
            _waveDataBitRate = 0;
            _waveDataChannels = 0;
            return this;
        }
        
        
        
        
    
    
        
        public function loadWaveFromByteArray(waveFile:ByteArray) : PCMSample
        {
            var bae:ByteArrayExt = cast(waveFile,ByteArrayExt), 
                content:ByteArrayExt = new ByteArrayExt(),
                fileSize:Int, header:Dynamic, 
                chunkBAE:ByteArrayExt, sliceCount:Int, i:Int, pos:Int;
            if (bae == null) bae = new ByteArrayExt(waveFile);
            bae.endian = Endian.LITTLE_ENDIAN;
            bae.position = 0;
            header = bae.readChunk(content);
            if (header.chunkID != "RIFF" || header.listType != "WAVE") dispatchEvent(new ErrorEvent("Not good wave file"));
            else {
                fileSize = header.length;
                _waveDataChunks = content.readAllChunks();
				
                if (!Reflect.hasField(_waveDataChunks,"fmt ") && Reflect.hasField(_waveDataChunks,"data ")) dispatchEvent(new ErrorEvent("Not good wave file"));
                else {
                    chunkBAE = Reflect.field(_waveDataChunks,"fmt ");
                    _waveDataFormatID = chunkBAE.readShort();
                    _waveDataChannels = chunkBAE.readShort();
                    _waveDataSampleRate = chunkBAE.readInt();
                    chunkBAE.readInt();     
                    chunkBAE.readShort();   
                    _waveDataBitRate = chunkBAE.readShort();
                    _waveData = Reflect.field(_waveDataChunks, "data");
                   
                    if ( Reflect.hasField(_waveDataChunks,basicInfoChunkID) ) {
                        chunkBAE = Reflect.field(_waveDataChunks,basicInfoChunkID);
                        sampleType = chunkBAE.readInt();
                        baseNote = chunkBAE.readShort();
                        chunkBAE.readShort();   
                        chunkBAE.readInt();     
                        beatCount = chunkBAE.readInt();
                        timeSignatureDenominator = chunkBAE.readShort();
                        timeSignatureNumber = chunkBAE.readShort();
                        bpm = chunkBAE.readFloat();
                    }
                    
                    _updateSampleFromWaveData();
                    dispatchEvent(new Event(Event.COMPLETE));
                }
            }
            return this;
        }
        
        
        
        public function saveWaveAsByteArray() : ByteArray
        {
            var bytesPerSample:Int = (_outputBitRate * _outputChannels) >> 3, 
                waveFile:ByteArrayExt = new ByteArrayExt(),
                content:ByteArrayExt = new ByteArrayExt(), 
                fmt:ByteArray = new ByteArray();

            
            if (_waveDataChannels != _outputChannels || _waveDataSampleRate != _outputSampleRate || _waveDataBitRate != _outputBitRate) {
                _updateWaveDataFromSamples();
            }
            
            
            fmt.endian = Endian.LITTLE_ENDIAN;
            fmt.writeShort(1);
            fmt.writeShort(_outputChannels);
            fmt.writeInt(Std.int(_outputSampleRate));
            fmt.writeInt(Std.int(_outputSampleRate * bytesPerSample));
            fmt.writeShort(bytesPerSample);
            fmt.writeShort(_outputBitRate);
            content.endian = Endian.LITTLE_ENDIAN;
            content.writeChunk("fmt ", fmt);
            content.writeChunk("data", _waveData);
            waveFile.endian = Endian.LITTLE_ENDIAN;
            waveFile.writeChunk("RIFF", content, "WAVE");
            return waveFile;
        }
        
        
        
        
    
    
        
        static public function readSTRCChunk(strcChunk:ByteArray) : Array<Dynamic>
        {
            if (strcChunk == null) return null;
            var i:Int, imax:Int, positions:Array<Dynamic> = [];
            strcChunk.readInt(); 
            imax = strcChunk.readInt();
            strcChunk.readInt(); 
            strcChunk.readInt(); 
            strcChunk.readInt(); 
            strcChunk.readInt(); 
            strcChunk.readInt(); 
           i=0;
 while( i<imax){
                strcChunk.readInt(); 
                strcChunk.readInt(); 
                positions.push(strcChunk.readInt());
                strcChunk.readInt(); 
                strcChunk.readInt();
                strcChunk.readInt(); 
                strcChunk.readInt(); 
                strcChunk.readInt(); 
             i++;
}
            return positions;
        }
        
        
        
        
    
    
        
        private function _convertSampleRate(src: Array<Float>, srcch:Int, srcsr:Float, dst: Array<Float>, dstch:Int, dstsr:Float, linear:Bool) : Void
        {
            var flag:Int, dstStep:Float = srcsr / dstsr;
            if (dstStep == 1) linear = false;
            
            //dst.length = Std.int(src.length * dstch * dstsr / (srcch * srcsr));

            
            flag  = (srcch == 2) ? 1 : 0;
            flag |= (dstch == 2) ? 2 : 0;
            flag |= (linear)     ? 4 : 0;
            _lvfunctions[flag](src, dst, dstStep, 0);
        }
        

        private function _lvmmn(src: Array<Float>, dst: Array<Float>, step:Float, ptr:Float) : Void {
            var i:Int = 0, imax:Int = dst.length, iptr:Int;
           i=0;
 while( i<imax){
                iptr = Std.int(ptr);
                dst[i] = src[iptr];
             i++; ptr+=step;
}
        }
        private function _lvmsn(src: Array<Float>, dst: Array<Float>, step:Float, ptr:Float) : Void {
            var i:Int = 0, imax:Int = dst.length, iptr:Int;
           i=0;
 while( i<imax){
                iptr = Std.int(ptr);
                dst[i] = src[iptr]; i++;
                dst[i] = src[iptr];
             i++; ptr+=step;
}
        }
        private function _lvsmn(src: Array<Float>, dst: Array<Float>, step:Float, ptr:Float) : Void {
            var i:Int = 0, imax:Int = dst.length, iptr:Int, n:Float;
           i=0;
 while( i<imax){
                iptr = (Std.int (ptr)) * 2;
                n = src[iptr];
                iptr++;
                n += src[iptr];
                dst[i] = n * 0.5;
             i++; ptr+=step;
}
        }
        private function _lvssn(src: Array<Float>, dst: Array<Float>, step:Float, ptr:Float) : Void {
            var i:Int = 0, imax:Int = dst.length, iptr:Int;
           i=0;
 while( i<imax){
                iptr = (Std.int (ptr)) * 2;
                dst[i] = src[iptr];
                iptr++;
                i++;
                dst[i] = src[iptr];
             i++; ptr+=step;
}
        }
        private function _lvmml(src: Array<Float>, dst: Array<Float>, step:Float, ptr:Float) : Void {
            var i:Int = 0, imax:Int = dst.length - 1, istep:Float = 1/step, 
                iptr0:Int, iptr1:Int = Std.int(ptr), t:Float;
           i=0;
 while( i<imax){
                iptr0 = iptr1;
                t = (ptr - iptr0) * istep;
                iptr1 = Std.int(ptr += step);
                dst[i] = src[iptr0] * (1 - t) + src[iptr1] * t;
             i++;
}
            dst[imax] = src[iptr1];
        }
        private function _lvmsl(src: Array<Float>, dst: Array<Float>, step:Float, ptr:Float) : Void {
            var i:Int = 0, imax:Int = dst.length - 2, istep:Float = 1/step, 
                iptr0:Int, iptr1:Int = Std.int(ptr), t:Float, n:Float;
           i=0;
 while( i<imax){
                iptr0 = iptr1;
                t = (ptr - iptr0) * istep;
                iptr1 = Std.int(ptr += step);
                n = src[iptr0] * (1 - t) + src[iptr1] * t;
                dst[i] = n; i++;
                dst[i] = n;
             i++;
}
            dst[imax] = src[iptr1];
            dst[imax+1] = src[iptr1];
        }
        private function _lvsml(src: Array<Float>, dst: Array<Float>, step:Float, ptr:Float) : Void {
            var i:Int = 0, imax:Int = dst.length - 1, istep:Float = 0.5/step, 
                iptr0:Int, iptr1:Int = Std.int(ptr), t:Float, n:Float, pl0:Int, pl1:Int = 0;
           i=0;
 while( i<imax){
                iptr0 = iptr1;
                t = (ptr - iptr0) * istep;
                iptr1 = Std.int(ptr += step);
                pl0 = iptr0 * 2;
                pl1 = iptr1 * 2;
                n = src[pl0] * (0.5 - t) + src[pl1] * t;
                pl0++;
                pl1++;
                n += src[pl0] * (0.5 - t) + src[pl1] * t;
                dst[i] = n;
             i++;
}
            dst[imax] = (src[pl1] + src[pl1-1]) * 0.5;
        }
        private function _lvssl(src: Array<Float>, dst: Array<Float>, step:Float, ptr:Float) : Void {
            var i:Int = 0, imax:Int = dst.length - 2, istep:Float = 1/step, 
                iptr0:Int, iptr1:Int = Std.int(ptr), t:Float, n:Float, pl0:Int, pl1:Int = 0;
           i=0;
 while( i<imax){
                iptr0 = iptr1;
                t = (ptr - iptr0) * istep;
                iptr1 = Std.int(ptr += step);
                pl0 = iptr0 * 2;
                pl1 = iptr1 * 2;
                dst[i] = src[pl0] * (1 - t) + src[pl1] * t;
                pl0++;
                pl1++;
                i++;
                dst[i] = src[pl0] * (1 - t) + src[pl1] * t;
             i++;
}
            dst[imax] = src[pl1-1];
            dst[imax+1] = src[pl1];
        }
        
        
        
        private function _updateSampleFromWaveData() : Void {

            var byteRate:Int = _waveDataBitRate>>3;
            if (_waveDataChannels == _channels && _waveDataSampleRate == _sampleRate) {
                //_samples.length = _waveData.length / byteRate;
                _w2vfunctions[byteRate-1](_waveData, _samples);
            } else {
                //_cache.length = _waveData.length / byteRate;
                _cacheChannels = _waveDataChannels;
                _cacheSampleRate = _waveDataSampleRate;
                _w2vfunctions[byteRate-1](_waveData, _cache);
                _convertSampleRate(_cache, _cacheChannels, _cacheSampleRate, _samples, _channels, _sampleRate, true);
                clearCache();
            }
        }
        
        
        private function _w2v8(wav:ByteArray, dst: Array<Float>) : Void {
            var unq:Float = 1 / (1<<(_waveDataBitRate-1)), imax:Int = dst.length;
           var i:Int=0;
 while( i<imax){ dst[i] = (wav.readUnsignedByte() - 128) * unq; i++;
}
        }
        private function _w2v16(wav:ByteArray, dst: Array<Float>) : Void {
            var unq:Float = 1 / (1<<(_waveDataBitRate-1)), imax:Int = dst.length;
           var i:Int=0;
 while( i<imax){ dst[i] = wav.readShort() * unq; i++;
}
        }
        private function _w2v24(wav:ByteArray, dst: Array<Float>) : Void {
            var unq:Float = 1 / (1<<(_waveDataBitRate-1)), imax:Int = dst.length;
           var i:Int=0;
 while( i<imax){ dst[i] = (_waveData.readByte() + (_waveData.readShort() << 8)) * unq; i++;
}
        }
        private function _w2v32(wav:ByteArray, dst: Array<Float>) : Void {
            var unq:Float = 1 / (1<<(_waveDataBitRate-1)), imax:Int = dst.length;
           var i:Int=0;
 while( i<imax){ dst[i] = _waveData.readInt() * unq; i++;
}
        }
        
        
        
        private function _updateWaveDataFromSamples() : Void 
        {

            var byteRate:Int = _outputBitRate >> 3,
                output: Array<Float> = this.samples();
            _waveData = (_waveData != null) ?  _waveData : new ByteArrayExt();
            _waveDataSampleRate = _outputSampleRate;
            _waveDataBitRate = _outputBitRate;
            _waveDataChannels = _outputChannels;
            
            
            _waveData.clear();
            _waveData.length = output.length * byteRate;
            _waveData.position = 0;
            
            
            _v2wfunctions[byteRate-1](output, _waveData);
        }
        
        
        private function _v2w8(src: Array<Float>, wav:ByteArray) : Void {
            var qn:Float = (1<<(_waveDataBitRate-1)) - 1, imax:Int = src.length;
           var i:Int=0;
 while( i<imax){ wav.writeByte(Std.int(src[i] * qn)+ 128); i++;
}
        }
        private function _v2w16(src: Array<Float>, wav:ByteArray) : Void {
            var qn:Float = (1<<(_waveDataBitRate-1)) - 1, imax:Int = src.length;
           var i:Int=0;
 while( i<imax){ wav.writeShort(Std.int(src[i] * qn)); i++;
}
        }
        private function _v2w24(src: Array<Float>, wav:ByteArray) : Void {
            var n:Float, qn:Float = (1<<(_waveDataBitRate-1)) - 1, imax:Int = src.length;
           var i:Int=0;
 while( i<imax){
                n = src[i] * qn;
                wav.writeByte(Std.int(n));
                wav.writeShort(Std.int(n)>>8);
             i++;
}
        }
        private function _v2w32(src: Array<Float>, wav:ByteArray) : Void {
            var qn:Float = (1<<(_waveDataBitRate-1)) - 1, imax:Int = src.length;
           var i:Int=0;
 while( i<imax){ wav.writeInt(Std.int(src[i] * qn)); i++;
}
        }
    } 


