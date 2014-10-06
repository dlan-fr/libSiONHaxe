





package org.si.sion.module ;
    import org.si.sion.sequencer.SiMMLTable;

    
    class SiOPMWaveTable extends SiOPMWaveBase
    {
        public var wavelet: Array<Int>;
        public var fixedBits:Int;
        public var defaultPTType:Int;
        
        
        
        public function new()
        {
            super(SiMMLTable.MT_CUSTOM);
            this.wavelet = null;
            this.fixedBits = 0;
            this.defaultPTType = 0;
        }
        
        
        
        public function initialize(wavelet: Array<Int>, defaultPTType:Int=0) : SiOPMWaveTable
        {
            var len:Int, bits:Int=0;
           len=wavelet.length>>1;
 while( len!=0){ bits++; len>>=1;
}
            
            this.wavelet = wavelet;
            this.fixedBits = SiOPMTable.PHASE_BITS - bits;
            this.defaultPTType = defaultPTType;
            
            return this;
        }
        
        
        
        public function copyFrom(src:SiOPMWaveTable) : SiOPMWaveTable
        {
            var i:Int, imax:Int = src.wavelet.length;
            this.wavelet = new Array<Int>();
           i=0;
 while( i<imax){ this.wavelet[i] = src.wavelet[i]; i++;
}
            this.fixedBits = src.fixedBits;
            this.defaultPTType = src.defaultPTType;
            
            return this;
        }
        
        
        
        public function free() : Void
        {
            _freeList.push(this);
        }
        
        
        static private var _freeList: Array<SiOPMWaveTable> = new Array<SiOPMWaveTable>();
        
        
        
        static public function alloc(wavelet: Array<Int>, defaultPTType:Int=0) : SiOPMWaveTable
        {
			var tmp = _freeList.pop();
            var newInstance:SiOPMWaveTable = (tmp != null) ? tmp : new SiOPMWaveTable();
            return newInstance.initialize(wavelet, defaultPTType);
        }
    }


