






package org.si.sion.utils ;
    import flash.media.*;
    import flash.utils.ByteArray;
    
    import org.si.utils.SLLNumber;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.module.SiOPMWaveTable;
    
    
    
    class SiONUtil {
    
    
        
        static public function logTrans(data:Sound, dst: Array<Int>=null, dstChannelCount:Int=2, sampleMax:Int=1048576, startPosition:Int=0, maximize:Bool=true) : Array<Int>
        {
            var wave:ByteArray = new ByteArray();
            //var samples:Int = Std.int(data.extract(wave, sampleMax, startPosition)); No Sound.extract
            return logTransByteArray(wave, dst, dstChannelCount, maximize);
        }
        
        
        
        static public function logTransVector(src: Array<Float>, srcChannelCount:Int=2, dst: Array<Int>=null, dstChannelCount:Int=0, maximize:Bool=true) : Array<Int>
        {
            var i:Int, j:Int, n:Float, imax:Int, logmax:Int = SiOPMTable.LOG_TABLE_BOTTOM;
            if (dst == null) dst = new Array<Int>();
            if (srcChannelCount == dstChannelCount || dstChannelCount == 0) {
                imax = src.length;
               // dst.length = imax;
               i=0;
 while( i<imax){
                    dst[i] = SiOPMTable.calcLogTableIndex(src[i]);
                    if (dst[i] < logmax) logmax = dst[i];
                 i++;
}
            } else
            if (srcChannelCount == 2) { 
                imax = src.length>>1;
               // dst.length = imax;
               i=0; j=0;
 while( i<imax){
                    n =  src[j]; j++;
                    n += src[j]; j++;
                    dst[i] = SiOPMTable.calcLogTableIndex(n*0.5);
                    if (dst[i] < logmax) logmax = dst[i];
                 i++;
}
            } else { 
                imax = src.length;
                //dst.length = imax<<1;
               i=0; j=0;
 while( i<imax){
                    dst[j+1] = dst[j] = SiOPMTable.calcLogTableIndex(src[i]);
                    if (dst[j] < logmax) logmax = dst[j];
                 i++; j+=2;
}
            }
            if (maximize && logmax > 1) _amplifyLogData(dst, logmax);
            return dst;
        }
        
        
        
        static public function logTransByteArray(src:ByteArray, dst: Array<Int>=null, dstChannelCount:Int=2, maximize:Bool=true) : Array<Int>
        {
            var i:Int, imax:Int, logmax:Int = SiOPMTable.LOG_TABLE_BOTTOM;
            
            src.position = 0;
            if (dstChannelCount == 2) {
                imax = src.length >> 2;
                if (dst == null) dst = new Array<Int>();
                //dst.length = imax; HAXE PORT
               i=0;
 while( i<imax){
                    dst[i] = SiOPMTable.calcLogTableIndex(src.readFloat());
                    if (dst[i] < logmax) logmax = dst[i];
                 i++;
}
            } else {
                imax = src.length >> 3;
                if (dst == null) dst = new Array<Int>();
                //dst.length = imax;
               i=0;
 while( i<imax){
                    dst[i] = SiOPMTable.calcLogTableIndex((src.readFloat()+src.readFloat())*0.5);
                    if (dst[i] < logmax) logmax = dst[i];
                 i++;
}
            }
            
            if (maximize && logmax > 1) _amplifyLogData(dst, logmax);
            return dst;
        }
        
        
        
        static private function _amplifyLogData(src: Array<Int>, gain:Int) : Void
        {
            var i:Int, imax:Int = src.length;
            gain &= ~1;
           i=0;
 while( i<imax){ src[i] -= gain; i++;
}
        }
        
        
        
        
        
    
    
        
        static public function extract(src:Sound, dst: Array<Float>=null, dstChannelCount:Int=1, length:Int=1048576, startPosition:Int=-1) : Array<Float>
        {
            var wave:ByteArray = new ByteArray(), i:Int, imax:Int;
            //src.extract(wave, length, startPosition); HAXE No Sound.extract
            if (dst == null) dst = new Array<Float>();
            wave.position = 0;
            
            if (dstChannelCount == 2) {
                
                imax = wave.length >> 2;
                //dst.length = imax;
               i=0;
 while( i<imax){
                    dst[i] = wave.readFloat();
                 i++;
}
            } else {
                
                imax = wave.length >> 3;
                //dst.length = imax;
               i=0;
 while( i<imax){
                    dst[i] = (wave.readFloat() + wave.readFloat()) * 0.6;
                 i++;
}
            }
            return dst;
        }
        
        
        
        static public function extractDPCM(src:ByteArray, initValue:Int=0, dst: Array<Float>=null, dstChannelCount:Int=1) : Array<Float>
        {
            var data:Int, i:Int, imax:Int, j:Int, sample:Float, output:Int;
            
            imax = src.length * dstChannelCount * 8;
            if (dst == null) dst = new Array<Float>();
            //dst.length = imax;
            
            output = initValue;
            src.position = 0;
           i=0;
 while( i<imax){
                data = src.readUnsignedByte();
               j=7;
 while( j>=0){
                    if (((data >> j) & 1) != 0) if (output<126) output += 2;
                    else                 if (output>1)   output -= 2;
                    sample = (output - 64) * 0.015625;
                    dst[i] = sample; i++;
                    if (dstChannelCount == 2) { dst[i] = sample; i++; }
                 --j;
}
            }
            
            return dst;
        }
        
        
        
        static public function extractYM2151ADPCM(src:ByteArray, dst: Array<Float>=null, dstChannelCount:Int=1) : Array<Float>
        {
            var data:Int, r:Int, i:Int, imax:Int, pcm:Int=0, sample:Float, 
                InpPcm:Int=0, InpPcm_prev:Int=0, scale:Int=0, output:Int=0;
        
            
            var crTable: Array<Int> = [1,3,5,7,9,11,13,15,-1,-3,-5,-7,-9,-11,-13,-15];
            
            var dltLTBL: Array<Int> = [ 16, 17, 19, 21, 23, 25, 28, 31,  34, 37, 41, 45, 50, 55, 60, 66,
                                                      73, 80, 88, 97,107,118,130,143, 157,173,190,209,230,253,279,307, 
                                                     337,371,408,449,494,544,598,658, 724,796,876,963,1060,1166,1282,1411,1552];
            var DCT: Array<Int> = [-1,-1,-1,-1,2,4,6,8,-1,-1,-1,-1,2,4,6,8];

            imax = src.length * dstChannelCount * 2;
            if (dst == null) dst = new Array<Float>();
           // dst.length = imax;
            
           i=0;
 while( i<imax){
                data = src.readUnsignedByte();

                r = data & 0x0f;
                pcm += (dltLTBL[scale] * crTable[r]) >> 3;
                scale += DCT[r];
                if (pcm < -2048) pcm = -2048;
                else if (pcm > 2047) pcm = 2047;
                if (scale < 0) scale = 0;
                else if (scale  > 48) scale = 48;
                InpPcm = (pcm & 0xfffffffc) << 8;
                output = ((InpPcm<<9) - (InpPcm_prev<<9) + 459*output) >> 9;
                InpPcm_prev = InpPcm;
                sample = output * 0.0000019073486328125;
                dst[i] = sample; i++;
                if (dstChannelCount == 2) { dst[i] = sample; i++; }
                
                r = (data >> 4) & 0x0f;
                pcm += (dltLTBL[scale] * crTable[r]) >> 3;
                scale += DCT[r];
                if (pcm < -2048) pcm = -2048;
                else if (pcm > 2047) pcm = 2047;
                if (scale < 0) scale = 0;
                else if (scale  > 48) scale = 48;
                InpPcm = (pcm & 0xfffffffc) << 8;
                output = ((InpPcm<<9) - (InpPcm_prev<<9) + 459*output) >> 9;
                InpPcm_prev = InpPcm;
                sample = output * 0.0000019073486328125;
                dst[i] = sample; i++;
                if (dstChannelCount == 2) { dst[i] = sample; i++; }
            }
            
            return dst;
        }
        
        
        
        static public function extractYM2608ADPCM(src:ByteArray, dst: Array<Float>=null, dstChannelCount:Int=1) : Array<Float>
        {
            var data:Int, r0:Int, r1:Int, i:Int, imax:Int, sample:Float, 
                predRate:Int = 127, output:Int = 0;
        
            
            var crTable: Array<Int> = [1,3,5,7,9,11,13,15,-1,-3,-5,-7,-9,-11,-13,-15];
            
            var puTable: Array<Int> = [57,57,57,57,77,102,128,153,57,57,57,57,77,102,128,153];
            
            imax = src.length * dstChannelCount * 2;
            if (dst == null) dst = new Array<Float>();
          //  dst.length = imax;
            
           i=0;
 while( i<imax){
                data = src.readUnsignedByte();
                r0 = data & 0x0f;
                r1 = (data >> 4) & 0x0f;
                
                predRate *= crTable[r0];
                predRate >>= 3;
                output += predRate;
                sample = output * 0.000030517578125;
                dst[i] = sample; i++;
                if (dstChannelCount == 2) { dst[i] = sample; i++; }
                predRate *= puTable[r0];
                predRate >>= 6;
                if (predRate>0) {
                         if (predRate < 127)   predRate = 127;
                    else if (predRate > 24576) predRate = 24576;
                } else {
                         if (predRate > -127)   predRate = -127;
                    else if (predRate < -24576) predRate = -24576;
                }
                
                predRate *= crTable[r1];
                predRate >>= 3;
                output += predRate;
                sample = output * 0.000030517578125;
                dst[i] = sample; i++;
                if (dstChannelCount == 2) { dst[i] = sample; i++; }
                predRate *= puTable[r1];
                predRate >>= 6;
                if (predRate>0) {
                         if (predRate < 127)   predRate = 127;
                    else if (predRate > 24576) predRate = 24576;
                } else {
                         if (predRate > -127)   predRate = -127;
                    else if (predRate < -24576) predRate = -24576;
                }
            }
            
           i=0;
 while( i<imax){
                if (dst[i] < -1) dst[i] = -1;
                else if (dst[i] > 1) dst[i] = 1;
             i++;
}
            
            return dst;
        }
        
        
        
        
    
    
        
        static public function calcSampleLength(bpm:Float, beat16:Float=4) : Float
        {
            
            return beat16 * 661500 / bpm;
        }
        
        
        
        
        static public function getHeadSilence(src:Sound, rmsThreshold:Float = 0.01) : Int
        {
            var wave:ByteArray = new ByteArray(), i:Int, imax:Int, extracted:Int, l:Float, r:Float, ms:Float, sp:Int=0;
            var msWindow:SLLNumber = SLLNumber.allocRing(22); 
            
            rmsThreshold *= rmsThreshold;
            rmsThreshold *= 22;
            
            imax = 1152;
            ms = 0;
           extracted=0;
 while ( imax == 1152) {
				wave.clear();
				
               // imax = Std.int(src.extract(wave, 1152, sp)); //no Sound.Extract
                wave.position = 0;
               i=0;
 while( i<imax){
                    l = wave.readFloat();
                    r = wave.readFloat();
                    ms -= msWindow.n;
                    msWindow = msWindow.next;
                    msWindow.n = l * l + r * r;
                    ms += msWindow.n;
                    if (ms >= rmsThreshold) return extracted + i - 22;
                 i++;
}
                sp = -1;
             extracted+=1152;
}
            
            SLLNumber.freeRing(msWindow);
            
            return extracted;
        }
        
        
        
        static public function getEndGap(src:Sound, rmsThreshold:Float=0.01, maxLength:Int=1152) : Int
        {
            var wave:ByteArray = new ByteArray(), ms: Array<Float> = new Array<Float>(),
                i:Int, imax:Int, extracted:Int, l:Float, r:Float, sp:Int;
            
            rmsThreshold *= rmsThreshold;
            sp = Std.int(src.length * 44.1) - 1152;
            
           extracted=0;
 while( extracted<maxLength){
               // imax = Std.int(src.extract(wave, 1152, sp)); No Sound.extract
			   imax = 0;
                wave.position = 0;
               i=0;
 while( i<imax){
                    l = wave.readFloat();
                    r = wave.readFloat();
                    ms[i] = l * l + r * r;
                 i++;
}
               i=imax-1;
 while( i>=0){
                    if (ms[i] >= rmsThreshold) {
                        extracted += i;
                        trace(extracted);
                        return (extracted < maxLength) ? extracted : maxLength;
                    }
                 --i;
}
                sp -= 1152;
                if (sp < 0) break;
             extracted+=imax;
}
            
            return maxLength;
        }
        

        
        static public function getPeakDistance(sample: Array<Float>) : Float
        {
            var i:Int, j:Int, k:Int, idx:Int, n:Float, m:Float, envAccum:Float;
            
            
            if (_envelop == null) _envelop = new Array<Float>();
            if (_xcorr == null)   _xcorr   = new Array<Float>();

            
            m = envAccum = 0;
           i=0; idx=0;
 while( i<462){
               n=0; j=0;
 while( j<128){ n += sample[idx]; j++; idx+=2;
}
                m += n;
                envAccum *= 0.875;
                envAccum += m * m;
                _envelop[i] = envAccum;
                m = n;
             i++;
}
            
            
           i=0; idx=0;
 while( i<113){
               n=0; j=0; k=113+i;
 while( j<226){ n += _envelop[j]*_envelop[k]; j++; k++;
}
                _xcorr[i] = n;
                if (_xcorr[idx] < n) idx = i;
             i++;
}
            
            
            return (113 + idx) * 2.9024943310657596;
        }
        static private var _envelop: Array<Float> = null;
        static private var _xcorr: Array<Float> = null;
        
        
        
        
    
    
        
        static public function waveColor(color:Int, waveType:Int=0, dst: Array<Float>=null) : Array<Float>
        {
            if (dst == null) dst = new Array<Float>();
            var len:Int, bits:Int=0;
           len=dst.length>>1;
 while( len!=0){ bits++; len>>=1;
}
            //dst.length = 1<<bits;
            bits = SiOPMTable.PHASE_BITS - bits;
            
            var i:Int, imax:Int, j:Int, gain:Int, mul:Int, n:Float, nmax:Float, 
                bars: Array<Float> = new Array<Float>(),
                barr: Array<Int> = [1,2,3,4,5,6,8],
                log: Array<Int> = SiOPMTable.instance().logTable,
                waveTable:SiOPMWaveTable = SiOPMTable.instance().getWaveTable(waveType + (color>>>28)),
                wavelet: Array<Int> = waveTable.wavelet, fixedBits:Int = waveTable.fixedBits,
                filter:Int = SiOPMTable.PHASE_FILTER, envtop:Int = (-SiOPMTable.ENV_TOP)<<3,
                index:Int, step:Int = SiOPMTable.PHASE_MAX >> bits;
            
           i=0;
 while( i<7){ bars[i] = (color & 15) * 0.0625; i++; color>>=4;
}

            imax = SiOPMTable.PHASE_MAX;
            nmax = 0;
            
           i=0;
 while( i<imax){
                j = i>>bits;
                dst[j] = 0;
               mul=0;
 while( mul<7){
                    index = (((i * barr[mul]) & filter) >> fixedBits);
                    gain = wavelet[index] + envtop;
                    dst[j] += log[gain] * bars[mul];
                 mul++;
}
                n = (dst[j]<0) ? -dst[j] : dst[j];
                if (nmax < n) nmax = n;
             i+=step;
}

            if (nmax < 8192) nmax = 8192;
            n = 1/nmax;
            imax = dst.length;
           i=0;
 while( i<imax){ dst[i] *= n; i++;
}
            return dst;
        }
    }


