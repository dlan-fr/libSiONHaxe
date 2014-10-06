





package org.si.sion.module ;
    import flash.utils.ByteArray;
    import org.si.utils.SLLint;
    
    
    
    class SiOPMStream {
        
        
        
        public var channels:Int = 2;
        
        public var buffer: Array<Float> = new Array<Float>();

        
        private var _panTable: Array<Float>;
        private var _i2n:Float;

        
        
        
        
        
        
        public function new()
        {
            var st:SiOPMTable = SiOPMTable.instance();
            _panTable = st.panTable;
            _i2n = st.i2n;
        }
        
        
        
        
        
        
        
        public function clear() : Void
        {
            var i:Int, imax:Int = buffer.length;
           i=0;
 while( i<imax){
                buffer[i] = 0;
             i++;
}
        }
        
        
        
        public function limit() : Void
        {
            var n:Float, i:Int, imax:Int = buffer.length;
           i=0;
 while( i<imax){
                n = buffer[i];
                     if (n < -1) buffer[i] = -1;
                else if (n >  1) buffer[i] =  1;
             i++;
}
        }
        
        
        
        public function quantize(bitRate:Int) : Void
        {
            var i:Int, imax:Int = buffer.length,
                r:Float = 1<<bitRate, ir:Float = 2/r;
           i=0;
 while( i<imax){
                buffer[i] = (Std.int(buffer[i] * r) >> 1) * ir;
             i++;
}
        }
        
        
        
        public function write(pointer:SLLint, start:Int, len:Int, vol:Float, pan:Int) : Void 
        {
            var i:Int, n:Float, imax:Int = (start + len)<<1;
            vol *= _i2n;
            if (channels == 2) {
                
                var volL:Float = _panTable[128-pan] * vol,
                    volR:Float = _panTable[pan] * vol;
               i=start<<1;
 while( i<imax){
                    n = cast(pointer.i,Float);
                    buffer[i] += n * volL;  i++;
                    buffer[i] += n * volR;  i++;
                    pointer = pointer.next;
                }
            } else 
            if (channels == 1) {
                
               i=start<<1;
 while( i<imax){
                    n = cast(pointer.i,Float) * vol;
                    buffer[i] += n; i++;
                    buffer[i] += n; i++;
                    pointer = pointer.next;
                }
            }
        }
        
        
        
        public function writeStereo(pointerL:SLLint, pointerR:SLLint, start:Int, len:Int, vol:Float, pan:Int) : Void 
        {
            var i:Int, n:Float, imax:Int = (start + len)<<1;
            vol *= _i2n;

            if (channels == 2) {
                
                var volL:Float = _panTable[128-pan] * vol,
                    volR:Float = _panTable[pan] * vol;
               i=start<<1;
 while( i<imax){
                    buffer[i] += cast(pointerL.i,Float) * volL;  i++;
                    buffer[i] += cast(pointerR.i,Float) * volR;  i++;
                    pointerL = pointerL.next;
                    pointerR = pointerR.next;
                }
            } else 
            if (channels == 1) {
                
                vol *= 0.5;
               i=start<<1;
 while( i<imax){
                    n = cast(pointerL.i + pointerR.i,Float ) * vol;
                    buffer[i] += n; i++;
                    buffer[i] += n; i++;
                    pointerL = pointerL.next;
                    pointerR = pointerR.next;
                }
            }
        }
        
        
        
        public function writeVectorNumber(pointer: Array<Float>, startPointer:Int, startBuffer:Int, len:Int, vol:Float, pan:Int, sampleChannelCount:Int) : Void
        {
            var i:Int, j:Int, n:Float, jmax:Int, volL:Float, volR:Float;
            
            if (channels == 2) {
                if (sampleChannelCount == 2) {
                    
                    volL = _panTable[128-pan] * vol;
                    volR = _panTable[pan]     * vol;
                    jmax = (startPointer + len)<<1;
                   j=startPointer<<1; i=startBuffer<<1;
 while( j<jmax){
                        buffer[i] += pointer[j] * volL; j++; i++;
                        buffer[i] += pointer[j] * volR; j++; i++;
                    }
                } else {
                    
                    volL = _panTable[128-pan] * vol * 0.707;
                    volR = _panTable[pan]     * vol * 0.707;
                    jmax = startPointer + len;
                   j=startPointer; i=startBuffer<<1;
 while( j<jmax){
                        n = pointer[j];
                        buffer[i] += n * volL;  i++;
                        buffer[i] += n * volR;  i++;
                     j++;
}
                }
            } else 
            if (channels == 1) {
                if (sampleChannelCount == 2) {
                    
                    jmax = (startPointer + len)<<1;
                    vol  *= 0.5;
                   j=startPointer<<1; i=startBuffer<<1;
 while( j<jmax){
                        n  = pointer[j]; j++;
                        n += pointer[j]; j++;
                        n *= vol;
                        buffer[i] += n; i++;
                        buffer[i] += n; i++;
                    }
                } else {
                    
                    jmax = startPointer + len;
                   j=startPointer; i=startBuffer<<1;
 while( j<jmax){
                        n = pointer[j] * vol;
                        buffer[i] += n; i++;
                        buffer[i] += n; i++;
                     j++;
}
                }
            }
        }
        
        
        
        public function writeByteArray(bytes:ByteArray, start:Int, len:Int, vol:Float) : Void
        {
            var i:Int, n:Float, imax:Int = (start + len)<<1;
            var initPosition:Int = bytes.position;

            if (channels == 2) {
               i=start<<1;
 while( i<imax){
                    buffer[i] += bytes.readFloat() * vol;
                 i++;
}
            } else 
            if (channels == 1) {
                
                vol  *= 0.6;
               i=start<<1;
 while( i<imax){
                    n = (bytes.readFloat() + bytes.readFloat()) * vol;
                    buffer[i] += n; i++;
                    buffer[i] += n; i++;
                }
            }
            
            bytes.position = initPosition;
        }
    }


