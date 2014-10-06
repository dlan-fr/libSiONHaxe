





package org.si.sion.module ;
    import org.si.sion.sequencer.SiMMLTable;
	import flash.errors.Error;
    
    
    
    class SiOPMWaveSamplerTable extends SiOPMWaveBase
    {
    
    
        
        public var stencil:SiOPMWaveSamplerTable;

        
        private var _table: Array<SiOPMWaveSamplerData>;
        
        
        
        
    
    
        
        public function new() 
        {
            super(SiMMLTable.MT_SAMPLE);
            _table = new Array<SiOPMWaveSamplerData>();
            stencil = null;
            clear();
        }
        
        
        
        
    
    
        
        public function clear(sampleData:SiOPMWaveSamplerData = null) : SiOPMWaveSamplerTable
        {
           var i:Int=0;
 while( i<SiOPMTable.SAMPLER_DATA_MAX){ _table[i] = sampleData; i++;
}
            return this;
        }
        
        
        
        public function setSample(sample:SiOPMWaveSamplerData, keyRangeFrom:Int=0, keyRangeTo:Int=-1) : SiOPMWaveSamplerData
        {
            if (keyRangeFrom < 0) keyRangeFrom = 0;
            if (keyRangeTo > 127) keyRangeTo = 127;
            if (keyRangeTo == -1) keyRangeTo = keyRangeFrom;
            if (keyRangeFrom > 127 || keyRangeTo < 0 || keyRangeTo < keyRangeFrom) throw new Error("SiOPMWaveSamplerTable error; Invalid key range");
           var i:Int=keyRangeFrom;
 while( i<=keyRangeTo){ _table[i] = sample; i++;
}
            return sample;
        }
        
        
        
        public function getSample(sampleNumber:Int) : SiOPMWaveSamplerData
        {
            if (stencil != null) return (stencil._table[sampleNumber] != null) ? stencil._table[sampleNumber] :  _table[sampleNumber];
            return _table[sampleNumber];
        }
        

        
        public function _free() : Void
        {
           var i:Int=0;
 while( i<SiOPMTable.SAMPLER_DATA_MAX){
                
                _table[i] = null;
             i++;
}
        }
    }


