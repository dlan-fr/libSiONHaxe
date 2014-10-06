





package org.si.sion.module ;
    import org.si.sion.sequencer.SiMMLTable;
    import org.si.sion.module.SiOPMTable;
	import flash.errors.Error;
    
    
    
    class SiOPMWavePCMTable extends SiOPMWaveBase
    {
    
    
        
        public var _table: Array<SiOPMWavePCMData>;
        
        public var _volumeTable: Array<Float>;
        
        public var _panTable: Array<Int>;
        
        
        
        
    
    
        
        public function new()
        {
            super(SiMMLTable.MT_PCM);
            _table = new Array<SiOPMWavePCMData>();
            _volumeTable = new Array<Float>();
            _panTable = new Array<Int>();
            clear();
        }
        
        
        
        
    
    
        
        public function clear(pcmData:SiOPMWavePCMData = null) : SiOPMWavePCMTable
        {
            var i:Int;
           i=0;
 while( i<SiOPMTable.NOTE_TABLE_SIZE){
                _table[i] = pcmData;
                _volumeTable[i] = 1;
                _panTable[i] = 0;
             i++;
}
            return this;
        }
        
        
        
        public function setSample(pcmData:SiOPMWavePCMData, keyRangeFrom:Int=0, keyRangeTo:Int=127) : SiOPMWavePCMData
        {
            if (keyRangeFrom < 0) keyRangeFrom = 0;
            if (keyRangeTo > 127) keyRangeTo = 127;
            if (keyRangeTo == -1) keyRangeTo = keyRangeFrom;
            if (keyRangeFrom > 127 || keyRangeTo < 0 || keyRangeTo < keyRangeFrom) throw new Error("SiOPMWavePCMTable error; Invalid key range");
           var i:Int=keyRangeFrom;
 while( i<=keyRangeTo){ _table[i] = pcmData; i++;
}
            return pcmData;
        }
        
        
        
        public function setKeyScaleVolume(centerNoteNumber:Int=64, keyRange:Float=0, volumeRange:Float=0) : SiOPMWavePCMTable
        {
            volumeRange *= 0.0078125;
            var imin:Int = centerNoteNumber - Std.int(keyRange * 0.5), imax:Int = centerNoteNumber + Std.int(keyRange * 0.5),
                v:Float, dv:Float = (keyRange == 0) ? volumeRange : (volumeRange / keyRange), i:Int;
            if (volumeRange > 0) {
                v = 1 - volumeRange;
               i=0;
 while( i<imin){ _volumeTable[i] = v; i++;
}
               
 while( i<imax){ _volumeTable[i] = v; i++; v+=dv;
}
               
 while( i<SiOPMTable.NOTE_TABLE_SIZE){ _volumeTable[i] = 1; i++;
}
            } else {
                v = 1;
               i=0;
 while( i<imin){ _volumeTable[i] = 1; i++;
}
               
 while(i<imax){ _volumeTable[i] = v; i++; v+=dv;
}
                v = 1 + volumeRange;
               
 while( i<SiOPMTable.NOTE_TABLE_SIZE){ _volumeTable[i] = v; i++;
}
            }
            return this;
        }
        
        
        
        public function setKeyScalePan(centerNoteNumber:Int=64, keyRange:Float=0, panWidth:Float=0) : SiOPMWavePCMTable
        {
            var imin:Int = centerNoteNumber - Std.int(keyRange * 0.5), imax:Int = centerNoteNumber + Std.int(keyRange * 0.5), 
                p:Float = -panWidth * 0.5, dp:Float = (keyRange == 0) ? panWidth : (panWidth / keyRange), i:Int;
           i=0;
 while( i<imin){    _panTable[i] = Std.int(p); i++;
}
           ;
 while( i<imax){ _panTable[i] = Std.int(p); i++; p+=dp;
}
           p=panWidth*0.5;
 while( i<SiOPMTable.NOTE_TABLE_SIZE){ _panTable[i] = Std.int(p); i++;
}
            return this;
        }
        
        
        
        public function _free() : Void
        {
           var i:Int=0;
 while( i<SiOPMTable.NOTE_TABLE_SIZE){
                
                _table[i] = null;
             i++;
}
        }
    }


