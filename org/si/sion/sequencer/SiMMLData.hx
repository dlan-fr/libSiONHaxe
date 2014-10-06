





package org.si.sion.sequencer ;
    import org.si.sion.module.SiOPMChannelParam;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.module.SiOPMWaveTable;
    import org.si.sion.module.SiOPMWavePCMTable;
    import org.si.sion.module.SiOPMWaveSamplerTable;
    import org.si.sion.sequencer.base.MMLData;
    import org.si.utils.SLLint;
	import flash.errors.Error;
    
    
    
    
    class SiMMLData extends MMLData
    {
    
    
        
        public var envelopes: Array<SiMMLEnvelopTable>;
        
        
        public var waveTables: Array<SiOPMWaveTable>;
        
        
        public var fmVoices: Array<SiMMLVoice>;
       
        
        public var pcmVoices: Array<SiMMLVoice>;
        
        
        public var samplerTables: Array<SiOPMWaveSamplerTable>;
        
        
        
        
    
    
        
        public function voices() : Array<SiMMLVoice> { return fmVoices; }
        
        
        
        
    
    
        
        function new()
        {
            envelopes    = new Array<SiMMLEnvelopTable>();
            waveTables   = new Array<SiOPMWaveTable>();
            fmVoices     = new Array<SiMMLVoice>();
            pcmVoices    = new Array<SiMMLVoice>();
            samplerTables = new Array<SiOPMWaveSamplerTable>();
           var i:Int=0;
 while( i<SiOPMTable.SAMPLER_TABLE_MAX){
                samplerTables[i] = new SiOPMWaveSamplerTable();
             i++;
}

		super();
        }
        
        
        
        
    
    
        
        override public function clear() : Void
        {
            super.clear();
            
            var i:Int, pcm:SiOPMWavePCMTable;
           i=0;
 while( i<SiMMLTable.ENV_TABLE_MAX){ envelopes[i] = null; i++;
}
           i=0;
 while( i<SiMMLTable.VOICE_MAX){ fmVoices[i] = null; i++;
}
           i=0;
 while( i<SiOPMTable.WAVE_TABLE_MAX){
                if (waveTables[i] != null) { 
                    waveTables[i].free();
                    waveTables[i] = null;
                }
             i++;
}
           i=0;
 while( i<SiOPMTable.PCM_DATA_MAX){ 
                if (pcmVoices[i] != null) { 
                    pcm = cast(pcmVoices[i].waveData,SiOPMWavePCMTable);
                    if (pcm != null) pcm._free();
                    pcmVoices[i] = null;
                }
             i++;
}
           i=0;
 while( i<SiOPMTable.SAMPLER_TABLE_MAX){
                samplerTables[i]._free();
             i++;
}
        }
        
        
        
        public function setEnvelopTable(index:Int, envelope:SiMMLEnvelopTable) : Void
        {
            if (index >= 0 && index < SiMMLTable.ENV_TABLE_MAX) envelopes[index] = envelope;
        }
        
        
        
        public function setVoice(index:Int, voice:SiMMLVoice) : Void
        {
            if (index >= 0 && index < SiMMLTable.VOICE_MAX) {
                if (!voice._isSuitableForFMVoice()) throw errorNotGoodFMVoice();
                 fmVoices[index] = voice;
            }
        }
        
        
        
        public function setWaveTable(index:Int, data: Array<Float>) : SiOPMWaveTable
        {
            index &= SiOPMTable.WAVE_TABLE_MAX-1;
            var i:Int, imax:Int=data.length;
            var table: Array<Int> = new Array<Int>();
           i=0;
 while( i<imax){ table[i] = SiOPMTable.calcLogTableIndex(data[i]); i++;
}
            waveTables[index] = SiOPMWaveTable.alloc(table);
            return waveTables[index];
        }
        
        
        
        
    
    
        
        public function _getSiOPMChannelParam(index:Int) : SiOPMChannelParam
        {
            var v:SiMMLVoice = new SiMMLVoice();
            v.channelParam = new SiOPMChannelParam();
            fmVoices[index] = v;
            return v.channelParam;
        }
        
        
        
        public function _getPCMVoice(index:Int) : SiMMLVoice
        {
            index &= (SiOPMTable.PCM_DATA_MAX-1);
            if (pcmVoices[index] == null) {
                pcmVoices[index] = new SiMMLVoice();
                return pcmVoices[index]._newBlankPCMVoice(index);
            }
            return pcmVoices[index];
        }
        
        
        
        public function _registerAllTables() : Void
        {
             
            SiOPMTable._instance.samplerTables[0].stencil = samplerTables[0];
            SiOPMTable._instance.samplerTables[1].stencil = samplerTables[1];
            SiOPMTable._instance._stencilCustomWaveTables = waveTables;
            SiOPMTable._instance._stencilPCMVoices        = pcmVoices;
            SiMMLTable._instance._stencilEnvelops = envelopes;
            SiMMLTable._instance._stencilVoices   = fmVoices;
        }
        
        
        
        
    
    
        private function errorNotGoodFMVoice() : Error {
            return new Error("SiONDriver error; Cannot register the voice.");
        }
    }


