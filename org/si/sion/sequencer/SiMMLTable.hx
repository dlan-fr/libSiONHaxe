





package org.si.sion.sequencer ;
    import org.si.utils.SLLint;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.module.SiOPMChannelParam;
    import org.si.sion.module.channels.SiOPMChannelManager;
    
    
    
    class SiMMLTable
    {
    
    
        
        static public var MT_PSG   :Int = 0;  
        static public var MT_APU   :Int = 1;  
        static public var MT_NOISE :Int = 2;  
        static public var MT_MA3   :Int = 3;  
        static public var MT_CUSTOM:Int = 4;  
        static public var MT_ALL   :Int = 5;  
        static public var MT_FM    :Int = 6;  
        static public var MT_PCM   :Int = 7;  
        static public var MT_PULSE :Int = 8;  
        static public var MT_RAMP  :Int = 9;  
        static public var MT_SAMPLE:Int = 10; 
        static public var MT_KS    :Int = 11; 
        static public var MT_MAX   :Int = 13;
        
        static private var MT_ARRAY_SIZE:Int = 11;
        
        static public var ENV_TABLE_MAX:Int = 512;
        static public var VOICE_MAX:Int = 256;
        
        
        
    
    
        
        public var channelModuleSetting:Array<Dynamic> = null;
        
        public var effectModuleSetting:Array<Dynamic> = null;
       
        
        
        public var tss_s2ar: Array<String> = null;
        
        public var tss_s2dr: Array<String> = null;
        
        public var tss_s2sr: Array<String> = null;
        
        public var tss_s2rr: Array<String> = null;
        
        
        
        public var alg_opm:Array<Dynamic> = [[ 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1],
                                    [ 0, 1, 1, 1, 1, 0, 1, 1,-1,-1,-1,-1,-1,-1,-1,-1],
                                    [ 0, 1, 2, 3, 3, 4, 3, 5,-1,-1,-1,-1,-1,-1,-1,-1],
                                    [ 0, 1, 2, 3, 4, 5, 6, 7,-1,-1,-1,-1,-1,-1,-1,-1]];
        
        public var alg_opl:Array<Dynamic> = [[ 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
                                    [ 0, 1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
                                    [ 0, 3, 2, 2,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
                                    [ 0, 4, 8, 9,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1]];
        
        public var alg_ma3:Array<Dynamic> = [[ 0, 0, 0, 0, 0, 0, 0, 0,-1,-1,-1,-1,-1,-1,-1,-1],
                                    [ 0, 1, 1, 1, 0, 1, 1, 1,-1,-1,-1,-1,-1,-1,-1,-1],
                                    [-1,-1, 5, 2, 0, 3, 2, 2,-1,-1,-1,-1,-1,-1,-1,-1],
                                    [-1,-1, 7, 2, 0, 4, 8, 9,-1,-1,-1,-1,-1,-1,-1,-1]];
        
        public var alg_opx:Array<Dynamic> = [[ 0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
                                    [ 0,16, 1, 2,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
                                    [ 0,16, 1, 2, 3,19, 5, 6,-1,-1,-1,-1,-1,-1,-1,-1],
                                    [ 0,16, 1, 2, 3,19, 4,20, 8,11, 6,22, 5, 9,12, 7]];
        
        public var alg_init:Array<Dynamic> = [0,1,5,7];

        
        private var _masterEnvelops: Array<SiMMLEnvelopTable> = null;
        
        private var _masterVoices: Array<SiMMLVoice> = null;
        
        public var _stencilEnvelops: Array<SiMMLEnvelopTable> = null;
        
        public var _stencilVoices: Array<SiMMLVoice> = null;
        
        
        
        
    
    
        
        static public var _instance:SiMMLTable = null;
        
        
        
        static public function instance() : SiMMLTable
        {
            return (_instance != null) ? _instance : (_instance = new SiMMLTable());
        }
        
        
        
        
    
    
        
        function new()
        {
			var i:Int;
			
			var _logTable:Dynamic = function (start:Int, step:Int, v0:Int, v255:Int) : Array<String> {
                var vector: Array<String> = new Array<String>();
                var imax:Int, j:Int, t:Int, dt:Int;

                t  = start<<16;
                dt = step<<16;
               i=1; j=1;
 while( j<=8){
                   imax=1<<j;
 while( i<imax){
                        vector[i] = Std.string(t>>16);
                        t += dt;
                     i++;
}
                    dt >>= 1;
                 j++;
}
                vector[0]   = Std.string(v0);
                vector[255] = Std.string(v255);
                
                return vector;
            }
			
            
            
            
            var ms:SiMMLChannelSetting;
            channelModuleSetting = new Array<Dynamic>();
            channelModuleSetting[MT_PSG]    = new SiMMLChannelSetting(MT_PSG,    SiOPMTable.PG_SQUARE,      3,   1, 4);   
            channelModuleSetting[MT_APU]    = new SiMMLChannelSetting(MT_APU,    SiOPMTable.PG_PULSE,       12,  2, 5);   
            channelModuleSetting[MT_NOISE]  = new SiMMLChannelSetting(MT_NOISE,  SiOPMTable.PG_NOISE_WHITE, 16,  1, 16);  
            channelModuleSetting[MT_MA3]    = new SiMMLChannelSetting(MT_MA3,    SiOPMTable.PG_MA3_WAVE,    32,  1, 32);  
            channelModuleSetting[MT_CUSTOM] = new SiMMLChannelSetting(MT_CUSTOM, SiOPMTable.PG_CUSTOM,      256, 1, 256); 
            channelModuleSetting[MT_ALL]    = new SiMMLChannelSetting(MT_ALL,    SiOPMTable.PG_SINE,        512, 1, 512); 
            channelModuleSetting[MT_FM]     = new SiMMLChannelSetting(MT_FM,     SiOPMTable.PG_SINE,        1,   1, 1);   
            channelModuleSetting[MT_PCM]    = new SiMMLChannelSetting(MT_PCM,    SiOPMTable.PG_PCM,         128, 1, 128); 
            channelModuleSetting[MT_PULSE]  = new SiMMLChannelSetting(MT_PULSE,  SiOPMTable.PG_PULSE,       32,  1, 32);  
            channelModuleSetting[MT_RAMP]   = new SiMMLChannelSetting(MT_RAMP,   SiOPMTable.PG_RAMP,        128, 1, 128); 
            channelModuleSetting[MT_SAMPLE] = new SiMMLChannelSetting(MT_SAMPLE, 0,                         4,   1, 4);   
            channelModuleSetting[MT_KS]     = new SiMMLChannelSetting(MT_KS,     0,                         3,   1, 3);   
            
            
            ms = channelModuleSetting[MT_PSG];
            ms._pgTypeList[0] = SiOPMTable.PG_SQUARE;
            ms._pgTypeList[1] = SiOPMTable.PG_NOISE_PULSE;
            ms._pgTypeList[2] = SiOPMTable.PG_PC_NZ_16BIT;
            ms._ptTypeList[0] = SiOPMTable.PT_PSG;
            ms._ptTypeList[1] = SiOPMTable.PT_PSG_NOISE;
            ms._ptTypeList[2] = SiOPMTable.PT_PSG;
            ms._voiceIndexTable[0] = 0;
            ms._voiceIndexTable[1] = 0;
            ms._voiceIndexTable[2] = 0;
            ms._voiceIndexTable[3] = 1;
            
            ms = channelModuleSetting[MT_APU];
            ms._pgTypeList[8]  = SiOPMTable.PG_TRIANGLE_FC;
            ms._pgTypeList[9]  = SiOPMTable.PG_NOISE_PULSE;
            ms._pgTypeList[10] = SiOPMTable.PG_NOISE_SHORT;
            ms._pgTypeList[11] = SiOPMTable.PG_CUSTOM;
           i=0;
 while( i<9){ ms._ptTypeList[i] = SiOPMTable.PT_PSG;   i++;
}
           i=9;
 while( i<12){ ms._ptTypeList[i] = SiOPMTable.PT_APU_NOISE;  i++;
}
            ms._initIndex      = 1;
            ms._voiceIndexTable[0] = 4;
            ms._voiceIndexTable[1] = 4;
            ms._voiceIndexTable[2] = 8;
            ms._voiceIndexTable[3] = 9;
            ms._voiceIndexTable[4] = 11;
            
            channelModuleSetting[MT_FM]._selectToneType = SiMMLChannelSetting.select_tone_fm;
            channelModuleSetting[MT_FM]._isSuitableForFMVoice = false;
            
            channelModuleSetting[MT_PCM]._channelType = SiOPMChannelManager.CT_CHANNEL_PCM;
            channelModuleSetting[MT_PCM]._isSuitableForFMVoice = false;
            
            
            channelModuleSetting[MT_SAMPLE]._channelType = SiOPMChannelManager.CT_CHANNEL_SAMPLER;
            channelModuleSetting[MT_SAMPLE]._isSuitableForFMVoice = false;
            
            channelModuleSetting[MT_KS]._channelType = SiOPMChannelManager.CT_CHANNEL_KS;
            channelModuleSetting[MT_KS]._isSuitableForFMVoice = false;

            
            _masterEnvelops = new Array<SiMMLEnvelopTable>();
           i=0;
 while( i<ENV_TABLE_MAX){ _masterEnvelops[i] = null; i++;
}
            _masterVoices = new Array<SiMMLVoice>();
           i=0;
 while( i<VOICE_MAX){ _masterVoices[i] = null; i++;
}
            
            
            tss_s2ar = _logTable(41, -4, 63, 9);
            tss_s2dr = _logTable(52, -4,  0, 20);
            tss_s2sr = _logTable( 9,  5,  0, 63);
            tss_s2rr = _logTable(12,  4, 63, 63);
        }
        
        
        
        
    
    
        
        public function resetAllUserTables() : Void
        {
            var i:Int;
           i=0;
 while( i<ENV_TABLE_MAX){
                if (_masterEnvelops[i] != null) {
                    _masterEnvelops[i].free();
                    _masterEnvelops[i] = null;
                }
             i++;
}
           i=0;
 while( i<VOICE_MAX){
                _masterVoices[i] = null;
             i++;
}
        }
        
        
        
        static public function registerMasterEnvelopTable(index:Int, table:SiMMLEnvelopTable) : Void
        {
            if (index>=0 && index<ENV_TABLE_MAX) instance()._masterEnvelops[index] = table;
        }
        
        
        
        static public function registerMasterVoice(index:Int, voice:SiMMLVoice) : Void
        {
            if (index>=0 && index<VOICE_MAX) instance()._masterVoices[index] = voice;
        }
        
        
        
        public function getEnvelopTable(index:Int) : SiMMLEnvelopTable
        {
            if (index<0 || index>=ENV_TABLE_MAX) return null;
            if (_stencilEnvelops != null && _stencilEnvelops[index] != null) return _stencilEnvelops[index];
            return _masterEnvelops[index];
        }
        
        
        
        public function getSiMMLVoice(index:Int) : SiMMLVoice
        {
            if (index<0 || index>=VOICE_MAX) return null;
            if (_stencilVoices != null && _stencilVoices[index] != null) return _stencilVoices[index];
            return _masterVoices[index];
        }
        
        
        
        static public function getPGType(moduleType:Int, channelNum:Int, toneNum:Int=-1) : Int
        {
            var ms:SiMMLChannelSetting = instance().channelModuleSetting[moduleType];
            
            if (ms._selectToneType == SiMMLChannelSetting.select_tone_normal) {
                if (toneNum == -1) {
                    if (channelNum>=0 && channelNum<ms._voiceIndexTable.length) toneNum = ms._voiceIndexTable[channelNum];
                    else channelNum = ms._initIndex;
                }
                if (toneNum <0 || toneNum >=ms._pgTypeList.length) toneNum = ms._initIndex;
                return ms._pgTypeList[toneNum];
            }
            
            return -1;
        }
        
        
        
        static public function isSuitableForFMVoice(moduleType:Int) : Bool
        {
            return instance().channelModuleSetting[moduleType]._isSuitableForFMVoice;
        }
    }


