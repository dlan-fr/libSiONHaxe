





package org.si.sion.utils.soundfont ;
    import flash.media.Sound;
    import org.si.sion.*;
    import org.si.sion.module.*;
    import org.si.sion.sequencer.*;
    
    
    
    class SiONSoundFont
    {
    
    
        
        public var sounds:Dynamic;
        
        
        public var envelopes: Array<SiMMLEnvelopTable> = new Array<SiMMLEnvelopTable>();
        
        
        public var waveTables: Array<SiOPMWaveTable> = new Array<SiOPMWaveTable>();
        
        
        public var fmVoices: Array<SiONVoice> = new Array<SiONVoice>();
        
        
        public var pcmVoices: Array<SiONVoice> = new Array<SiONVoice>();
        
        
        public var samplerTables: Array<SiOPMWaveSamplerTable> = new Array<SiOPMWaveSamplerTable>();
        
        
        public var defaultFPS:Float = 60;
        
        public var defaultVelocityMode:Int = 0;
        
        public var defaultExpressionMode:Int = 0;
        
        public var defaultVCommandShift:Int = 4;
        
        
        
        
    
    
        
        public function new(sounds:Dynamic = null)
        {
            this.sounds = (sounds != null) ? sounds :  {};
        }
        
        
        
        public function apply(data:SiONData = null) : Void
        {
            var i:Int;
            if (data != null) {
               i=0;
 while( i<pcmVoices.length){ if (pcmVoices[i] != null)     data.pcmVoices[i]     = pcmVoices[i];     i++;
}
               i=0;
 while( i<samplerTables.length){ if (samplerTables[i] != null) data.samplerTables[i] = samplerTables[i]; i++;
}
               i=0;
 while( i<fmVoices.length){ if (fmVoices[i] != null)      data.fmVoices[i]      = fmVoices[i];      i++;
}
               i=0;
 while( i<waveTables.length){ if (waveTables[i] != null)    data.waveTables[i]    = waveTables[i];    i++;
}
               i=0;
 while( i<envelopes.length){ if (envelopes[i] != null)     data.envelopes[i]     = envelopes[i];     i++;
}
                data.defaultFPS = Std.int(defaultFPS);
                data.defaultVelocityMode = defaultVelocityMode;
                data.defaultExpressionMode = defaultExpressionMode;
                data.defaultVCommandShift = defaultVCommandShift;
            } else {
                var driver:SiONDriver = SiONDriver.mutex();
                if (driver != null) {
                   i=0;
 while( i<pcmVoices.length){ if (pcmVoices[i]!= null)     driver.setPCMVoice(i, pcmVoices[i]);     i++;
}
                   i=0;
 while( i<samplerTables.length){ if (samplerTables[i]!= null) driver.setSamplerTable(i, samplerTables[i]); i++;
}
                   i=0;
 while( i<fmVoices.length){ if (fmVoices[i]!= null)      driver.setVoice(i, fmVoices[i]);      i++;
}
                   i=0;
 while( i<waveTables.length){
                        if (waveTables[i] != null) {
							var tmp_table:SiOPMWaveTable =  new SiOPMWaveTable();
                            SiOPMTable._instance.registerWaveTable(i, tmp_table.copyFrom(waveTables[i]).wavelet);
                        }
                        i++;
}
                   i=0;
 while( i<envelopes.length){
                        if (envelopes[i] != null) {
                            SiMMLTable.registerMasterEnvelopTable(i, new SiMMLEnvelopTable().copyFrom(envelopes[i]));
                        }
                     i++;
}
                }
            }
        }
    }


