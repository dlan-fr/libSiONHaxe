





package org.si.sion.module ;
    import flash.media.Sound;
    import org.si.utils.SLLint;
    import org.si.sion.sequencer.SiMMLVoice;
	import flash.errors.Error;
    
    
    
    class SiOPMTable
    {
    
        
        inline static public var ENV_BITS            :Int = 10;   
        inline static public var ENV_TIMER_BITS      :Int = 24;   
        inline static public var SAMPLING_TABLE_BITS :Int = 10;   
        inline static public var HALF_TONE_BITS      :Int = 6;    
        inline static public var NOTE_BITS           :Int = 7;    
        inline static public var NOISE_TABLE_BITS    :Int = 15;   
        inline static public var LOG_TABLE_RESOLUTION:Int = 256;  
        inline static public var LOG_VOLUME_BITS     :Int = 13;   
        inline static public var LOG_TABLE_MAX_BITS  :Int = 16;   
        inline static public var FIXED_BITS          :Int = 16;   
        inline static public var PCM_BITS            :Int = 20;   
        inline static public var LFO_FIXED_BITS      :Int = 20;   
        inline static public var CLOCK_RATIO_BITS    :Int = 10;   
        inline static public var NOISE_WAVE_OUTPUT   :Float = 1;     
        inline static public var SQUARE_WAVE_OUTPUT  :Float = 1;     
        inline static public var OUTPUT_MAX          :Float = 0.5;   
        
        inline static public var ENV_LSHIFT          :Int = ENV_BITS - 7;                     
        inline static public var ENV_TIMER_INITIAL   :Int = (2047 * 3) << CLOCK_RATIO_BITS;   
        inline static public var LFO_TIMER_INITIAL   :Int = 1 << SiOPMTable.LFO_FIXED_BITS;   
        inline static public var PHASE_BITS          :Int = SAMPLING_TABLE_BITS + FIXED_BITS; 
        inline static public var PHASE_MAX           :Int = 1 << PHASE_BITS;
        inline static public var PHASE_FILTER        :Int = PHASE_MAX - 1;
        inline static public var PHASE_SIGN_RSHIFT   :Int = PHASE_BITS - 1;
        inline static public var SAMPLING_TABLE_SIZE :Int = 1 << SAMPLING_TABLE_BITS;
        inline static public var NOISE_TABLE_SIZE    :Int = 1 << NOISE_TABLE_BITS;
        inline static public var PITCH_TABLE_SIZE    :Int = 1 << (HALF_TONE_BITS+NOTE_BITS);
        inline static public var NOTE_TABLE_SIZE     :Int = 1 << NOTE_BITS;
        inline static public var HALF_TONE_RESOLUTION:Int = 1 << HALF_TONE_BITS;
        inline static public var LOG_TABLE_SIZE      :Int = LOG_TABLE_MAX_BITS * LOG_TABLE_RESOLUTION * 2;   
        inline static public var LFO_TABLE_SIZE      :Int = 256;                                             
        inline static public var KEY_CODE_TABLE_SIZE :Int = 128;                                             
        inline static public var LOG_TABLE_BOTTOM    :Int = LOG_VOLUME_BITS * LOG_TABLE_RESOLUTION * 2;      
        inline static public var ENV_BOTTOM          :Int = (LOG_VOLUME_BITS * LOG_TABLE_RESOLUTION) >> 2;   
        inline static public var ENV_TOP             :Int = ENV_BOTTOM - (1<<ENV_BITS);                      
        inline static public var ENV_BOTTOM_SSGEC    :Int = 1<<(ENV_BITS-3);                                 
        
        
        inline static public var PT_OPM:Int = 0;
        inline static public var PT_PCM:Int = 1;
        inline static public var PT_PSG:Int = 2;
        inline static public var PT_OPM_NOISE:Int = 3;
        inline static public var PT_PSG_NOISE:Int = 4;
        inline static public var PT_APU_NOISE:Int = 5;

        inline static public var PT_MAX:Int = 6;
                
        
        inline static public var PG_SINE       :Int = 0;     
        inline static public var PG_SAW_UP     :Int = 1;     
        inline static public var PG_SAW_DOWN   :Int = 2;     
        inline static public var PG_TRIANGLE_FC:Int = 3;     
        inline static public var PG_TRIANGLE   :Int = 4;     
        inline static public var PG_SQUARE     :Int = 5;     
        inline static public var PG_NOISE      :Int = 6;     
        inline static public var PG_KNMBSMM    :Int = 7;     
        inline static public var PG_SYNC_LOW   :Int = 8;     
        inline static public var PG_SYNC_HIGH  :Int = 9;     
        inline static public var PG_OFFSET     :Int = 10;    
                                                        
        inline static public var PG_NOISE_WHITE:Int = 16;    
        inline static public var PG_NOISE_PULSE:Int = 17;    
        inline static public var PG_NOISE_SHORT:Int = 18;    
        inline static public var PG_NOISE_HIPAS:Int = 19;    
        inline static public var PG_NOISE_PINK :Int = 20;    
        inline static public var PG_NOISE_GB_SHORT:Int = 21; 
                                                        
        inline static public var PG_PC_NZ_16BIT:Int = 24;    
        inline static public var PG_PC_NZ_SHORT:Int = 25;    
        inline static public var PG_PC_NZ_OPM  :Int = 26;    
                                                        
        inline static public var PG_MA3_WAVE   :Int = 32;    
        inline static public var PG_PULSE      :Int = 64;    
        inline static public var PG_PULSE_SPIKE:Int = 80;    
                                                        
        inline static public var PG_RAMP       :Int = 128;   
        inline static public var PG_CUSTOM     :Int = 256;   
        inline static public var PG_PCM        :Int = 384;   
        inline static public var PG_USER_CUSTOM:Int = -1;    
        inline static public var PG_USER_PCM   :Int = -2;    

        inline static public var DEFAULT_PG_MAX:Int = 256;   
        inline static public var PG_FILTER     :Int = 511;   
        
        inline static public var WAVE_TABLE_MAX   :Int = 128;                
        inline static public var PCM_DATA_MAX     :Int = 128;                
        inline static public var SAMPLER_TABLE_MAX:Int = 4;                  
        inline static public var SAMPLER_DATA_MAX :Int = NOTE_TABLE_SIZE;    

        inline static public var VM_LINEAR:Int = 0;  
        inline static public var VM_DR96DB:Int = 1;  
        inline static public var VM_DR64DB:Int = 2;  
        inline static public var VM_DR48DB:Int = 3;  
        inline static public var VM_DR32DB:Int = 4;  
        inline static public var VM_MAX:Int = 5;
        

        
        inline static public var LFO_WAVE_SAW     :Int = 0;
        inline static public var LFO_WAVE_SQUARE  :Int = 1;
        inline static public var LFO_WAVE_TRIANGLE:Int = 2;
        inline static public var LFO_WAVE_NOISE   :Int = 3;
        inline static public var LFO_WAVE_MAX     :Int = 8;
        
        
        
        
    
    
        
        public var eg_incTables:Array<Dynamic> = [    
            
               [0,1, 0,1, 0,1, 0,1],  
               [0,1, 0,1, 1,1, 0,1],  
               [0,1, 1,1, 0,1, 1,1],  
               [0,1, 1,1, 1,1, 1,1],  
               [1,1, 1,1, 1,1, 1,1],  
               [1,1, 1,2, 1,1, 1,2],  
               [1,2, 1,2, 1,2, 1,2],  
               [1,2, 2,2, 1,2, 2,2],  
               [2,2, 2,2, 2,2, 2,2],  
               [2,2, 2,4, 2,2, 2,4],  
               [2,4, 2,4, 2,4, 2,4],  
               [2,4, 4,4, 2,4, 4,4],  
               [4,4, 4,4, 4,4, 4,4],  
               [4,4, 4,8, 4,4, 4,8],  
               [4,8, 4,8, 4,8, 4,8],  
               [4,8, 8,8, 4,8, 8,8],  
               [8,8, 8,8, 8,8, 8,8],  
               [0,0, 0,0, 0,0, 0,0]   
        ];
        
        public var eg_incTablesAtt:Array<Dynamic> = [
            
              [0,4, 0,4, 0,4, 0,4],  
              [0,4, 0,4, 4,4, 0,4],  
              [0,4, 4,4, 0,4, 4,4],  
              [0,4, 4,4, 4,4, 4,4],  
              [4,4, 4,4, 4,4, 4,4],  
              [4,4, 4,3, 4,4, 4,3],  
              [4,3, 4,3, 4,3, 4,3],  
              [4,3, 3,3, 4,3, 3,3],  
              [3,3, 3,3, 3,3, 3,3],  
              [3,3, 3,2, 3,3, 3,2],  
              [3,2, 3,2, 3,2, 3,2],  
              [3,2, 2,2, 3,2, 2,2],  
              [2,2, 2,2, 2,2, 2,2],  
              [2,2, 2,1, 2,2, 2,1],  
              [2,8, 2,1, 2,1, 2,1],  
              [2,1, 1,1, 2,1, 1,1],  
              [1,1, 1,1, 1,1, 1,1],  
              [0,0, 0,0, 0,0, 0,0]   
        ];
        
        public var eg_tableSelector:Array<Dynamic> = null;
        
        public var eg_levelTables:Array<Dynamic> = null;
        
        public var eg_ssgTableIndex:Array<Dynamic> = null;
        
        public var eg_timerSteps:Array<Dynamic> = null;
        
        public var eg_slTable:Array<Dynamic> = null;
        
        public var eg_tlTables: Array<Array<Int>> = null;
        
        public var eg_tlTableLine: Array<Int> = null;
        
        public var eg_tlTable96dB: Array<Int> = null;
        
        public var eg_tlTable64dB: Array<Int> = null;
        
        public var eg_tlTable48dB: Array<Int> = null;
        
        public var eg_tlTable32dB: Array<Int> = null;
        
        public var eg_lv2tlTable: Array<Int> = null;
        
        
        public var lfo_timerSteps: Array<Int> = null;
        
        public var lfo_waveTables:Array<Dynamic> = null;
        
        public var lfo_chorusTables: Array<Int> = null;
        
        
        public var filter_cutoffTable: Array<Float> = null;
        
        public var filter_feedbackTable: Array<Float> = null;
        
        public var filter_eg_rate: Array<Int> = null;

        
        public var pitchTable: Array<Array<Int>> = null;
        
        public var phaseStepShiftFilter: Array<Int> = null;
        
        public var logTable: Array<Int> = null;
        
        public var nnToKC: Array<Int> = null;
        
        public var pitchSamplingCount: Array<Int> = null;
        
        public var noWaveTable:SiOPMWaveTable;
        public var noWaveTableOPM:SiOPMWaveTable;
        
        
        public var soundReference:Dynamic = null;
        
        public var waveTables: Array<SiOPMWaveTable> = null;
        
        public var samplerTables: Array<SiOPMWaveSamplerTable> = null;
        
        private var _customWaveTables: Array<SiOPMWaveTable> = null;
        
        public var _stencilCustomWaveTables: Array<SiOPMWaveTable> = null;
        
        private var _pcmVoices: Array<SiMMLVoice> = null;
        
        public var _stencilPCMVoices: Array<SiMMLVoice> = null;
        
        
        public var dt1Table:Array<Dynamic> = null;
        
        public var dt2Table: Array<Int> = [0, 384, 500, 608];
        
        
        public var final_oscilator_flags:Array<Dynamic> = [[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                                                  [2,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0], 
                                                  [4,4,5,6,6,7,6,0,0,0,0,0,0,0,0,0], 
                                                  [8,8,8,8,10,14,14,15,9,13,8,9,9,0,0,0]];

        
        public var i2n:Float;
        
        public var panTable: Array<Float> = null;
        
        
        public var rate:Int;
        
        public var clock:Int;
        
        public var psg_clock:Float;
        
        public var clock_ratio:Int;
        
        public var sampleRatePitchShift:Int;
        
        
        
        
    
    
        
        static public var _instance:SiOPMTable = null;
        
        
        
        static public function instance() : SiOPMTable
        {
            return (_instance != null)? _instance : _instance = new SiOPMTable(3580000, 1789772.5, 44100);
        }
        
        
        
        
    
    
        
        function new(clock:Int, psg_clock:Float, rate:Int)
        {
            _setConstants(clock, psg_clock, rate);
            _createEGTables();
            _createPGTables();
            _createWaveSamples();
            _createLFOTables();
            _createFilterTables();
        }
        
        
    
    
        private function _setConstants(clock:Int, psg_clock:Float, rate:Int) : Void
        {
            this.clock = clock;
            this.psg_clock = psg_clock;
            this.rate  = rate;
            sampleRatePitchShift = (rate == 44100) ? 0 : (rate == 22050) ? 1 : -1;
            if (sampleRatePitchShift == -1) throw new Error("SiOPMTable error : Sampling rate "+ rate + " is not supported.");
            clock_ratio = Std.int((Std.int(clock/64)<<CLOCK_RATIO_BITS)/rate);
            
            
            i2n = OUTPUT_MAX/(1<<LOG_VOLUME_BITS);
        }
        
        
    
    
        private function _createEGTables() : Void
        {
            var i:Int, j:Int, imax:Int, imax2:Int, table:Array<Dynamic>;
            
            
            eg_timerSteps    = new Array<Dynamic>();
            eg_tableSelector = new Array<Dynamic>();
            
            i = 0;
           
 while( i< 44){                
                eg_timerSteps   [i] = Std.int((1<<(i>>2)) * clock_ratio);
                eg_tableSelector[i] = (i & 3);
             i++;
}
           
 while( i< 48){                
                eg_timerSteps   [i] = Std.int(2047 * clock_ratio);
                eg_tableSelector[i] = (i & 3);
             i++;
}
           
 while( i< 60){                
                eg_timerSteps   [i] = Std.int(2047 * clock_ratio);
                eg_tableSelector[i] = i - 44;
             i++;
}
           
 while( i< 96){                
                eg_timerSteps   [i] = Std.int(2047 * clock_ratio);
                eg_tableSelector[i] = 16;
             i++;
}
           
 while( i<128){                
                eg_timerSteps   [i] = 0;
                eg_tableSelector[i] = 17;
             i++;
}

            
            
            imax = (1<<ENV_BITS);
            imax2 = imax >> 2;
            eg_levelTables = new Array<Dynamic>();
           i=0;
 while( i<7){
                eg_levelTables[i] = new Array<Int>();
             i++;
}
           i=0;
 while( i<imax2){
                eg_levelTables[0][i] = i;           
                eg_levelTables[1][i] = i<<2;        
                eg_levelTables[2][i] = 512-(i<<2);  
                eg_levelTables[3][i] = 512+(i<<2);  
                eg_levelTables[4][i] = 1024-(i<<2); 
                eg_levelTables[5][i] = 0;           
                eg_levelTables[6][i] = 1024;        
             i++;
}
           
 while( i<imax){
                eg_levelTables[0][i] = i;           
                eg_levelTables[1][i] = 1024;        
                eg_levelTables[2][i] = 0;           
                eg_levelTables[3][i] = 1024;        
                eg_levelTables[4][i] = 512;         
                eg_levelTables[5][i] = 0;           
                eg_levelTables[6][i] = 1024;        
             i++;
}
            
            eg_ssgTableIndex = new Array<Dynamic>();
                                
            eg_ssgTableIndex[0] = [[3,3,3], [1,3,3]];   
            eg_ssgTableIndex[1] = [[1,6,6], [1,6,6]];   
            eg_ssgTableIndex[2] = [[2,1,2], [1,2,1]];   
            eg_ssgTableIndex[3] = [[2,5,5], [1,5,5]];   
            eg_ssgTableIndex[4] = [[4,4,4], [2,4,4]];   
            eg_ssgTableIndex[5] = [[2,5,5], [2,5,5]];   
            eg_ssgTableIndex[6] = [[1,2,1], [2,1,2]];   
            eg_ssgTableIndex[7] = [[1,6,6], [2,6,6]];   
            eg_ssgTableIndex[8] = [[1,1,1], [1,1,1]];   
            eg_ssgTableIndex[9] = [[2,2,2], [2,2,2]];   
            
            
            eg_slTable = new Array<Dynamic>();
           i=0;
 while( i<15){
                eg_slTable[i] = i << 5;
             i++;
}
            eg_slTable[15] = 31<<5;
            
            
            eg_tlTables = new Array<Array<Int>>();
            eg_tlTables[VM_LINEAR] = eg_tlTableLine = new Array<Int>();
            eg_tlTables[VM_DR96DB] = eg_tlTable96dB = new Array<Int>();
            eg_tlTables[VM_DR64DB] = eg_tlTable64dB = new Array<Int>();
            eg_tlTables[VM_DR48DB] = eg_tlTable48dB = new Array<Int>();
            eg_tlTables[VM_DR32DB] = eg_tlTable32dB = new Array<Int>();
            
            
            eg_tlTableLine[0] = eg_tlTable96dB[0] = eg_tlTable48dB[0] = eg_tlTable32dB[0] = ENV_BOTTOM;
           i=1;
 while( i<257){
                
                eg_tlTableLine[i] = calcLogTableIndex(i*0.00390625) >> (LOG_VOLUME_BITS - ENV_BITS);
                eg_tlTable96dB[i] = (256-i) * 4;                       
                eg_tlTable64dB[i] = Std.int((256-i) * 2.6666666666666667); 
                eg_tlTable48dB[i] = (256-i) * 2;                       
                eg_tlTable32dB[i] = Std.int((256-i) * 1.333333333333333);  
             i++;
}
            
           i=1;
 while( i<193){
                j = i + 256;
                eg_tlTableLine[j] = eg_tlTable96dB[j] = eg_tlTable64dB[j] = eg_tlTable48dB[j] = eg_tlTable32dB[j] = -i;
             i++;
}
            
           i=1;
 while( i<65){
                j = i + 448;
                eg_tlTableLine[j] = eg_tlTable96dB[j] = eg_tlTable64dB[j] = eg_tlTable48dB[j] = eg_tlTable32dB[j] = ENV_TOP;
             i++;
}
            
            
            eg_lv2tlTable = new Array<Int>();
           i=0;
 while( i<129){
                eg_lv2tlTable[i] = calcLogTableIndex(i*0.0078125) >> (LOG_VOLUME_BITS - ENV_BITS + ENV_LSHIFT);
             i++;
}
            
            
            panTable = new Array<Float>();
           i=0;
 while( i<129){
                panTable[i] = Math.sin(i*0.01227184630308513);  
             i++;
}
            
        }
        
        
    
    
        private function _createPGTables() : Void
        {
            
            var i:Int, imax:Int, p:Float, dp:Float, n:Float, j:Int, jmax:Int, v:Float, iv:Int = 0, table: Array<Int>;
            
            
        
        
            nnToKC = new Array<Int>();
           i=0; j=0;
 while( j<NOTE_TABLE_SIZE){
                nnToKC[j] = (i<16) ? i : (i>=KEY_CODE_TABLE_SIZE) ? (KEY_CODE_TABLE_SIZE-1) : (i-16);
             i++; j=i-(i>>2);
}
            
            
        
        
            imax = HALF_TONE_RESOLUTION * 12;   
            jmax = PITCH_TABLE_SIZE;
            dp   = 1/imax;
            
            
            pitchSamplingCount = new Array<Int>();
            n = rate / 8.175798915643707;  
           i=0; p=0;
 while( i<imax){ 
                v = Math.pow(2, -p) * n;
               j=i;
 while( j<jmax){
                    pitchSamplingCount[j]  = Std.int(v+0.5);
                    v *= 0.5;
                 j+=imax;
}
             i++; p+=dp;
}
            
            
            
            pitchTable = new Array<Array<Int>>();
            phaseStepShiftFilter = new Array<Int>();
            
            
            table = new Array<Int>();
            n = 8.175798915643707 * PHASE_MAX / rate;    
           i=0; p=0;
 while( i<imax){ 
                v = Math.pow(2, p) * n;
               j=i;
 while( j<jmax){
                    table[j]  = Std.int(v);
                    v *= 2;
                 j+=imax;
}
             i++; p+=dp;
}
            pitchTable[PT_OPM] = table;
            phaseStepShiftFilter[PT_OPM] = 0;
            
            
            
            table = new Array<Int>();
            n = 0.01858136117191752 * PHASE_MAX;     
           i=0; p=0;
 while( i<imax){ 
                v = Math.pow(2, p) * n;
               j=i;
 while( j<jmax){
                    table[j] = Std.int(v);
                    v *= 2;
                 j+=imax;
}
             i++; p+=dp;
}
            pitchTable[PT_PCM] = table;
            phaseStepShiftFilter[PT_PCM] = 0xffffffff;
            
            
            table = new Array<Int>();
            n = psg_clock * (PHASE_MAX>>4) / rate;
           i=0; p=0;
 while( i<imax){
                
                
                v = psg_clock/(Math.pow(2, p) * 130.8127826502993);
               j=i;
 while( j<jmax){
                    
                    iv = Std.int(v + 0.5);
                    if (iv > 4096) iv = 4096;
                    table[j] = Std.int(n/iv);
                    v *= 0.5;
                 j+=imax;
}
             i++; p+=dp;
}
            pitchTable[PT_PSG] = table;
            phaseStepShiftFilter[PT_PSG] = 0;
            

            
            
            
        
        
            
            
            imax  = 32<<HALF_TONE_BITS;
            table = new Array<Int>();
            n = PHASE_MAX * clock_ratio;    
           i=0;
 while( i<31){
                iv = (Std.int (n / ((32-i)*0.5))) >> CLOCK_RATIO_BITS;
               j=0;
 while( j<HALF_TONE_RESOLUTION){
                    table[(i<<HALF_TONE_BITS)+j] = iv;
                 j++;
}
             i++;
}
           i=31<<HALF_TONE_BITS;
 while( i<imax){ table[i] = iv;  i++;
}
            pitchTable[PT_OPM_NOISE] = table;
            phaseStepShiftFilter[PT_OPM_NOISE] = 0xffffffff;
            
            
            table = new Array<Int>();
            
            n = PHASE_MAX * clock / (rate * 16);
           i=0;
 while( i<32){
                iv = Std.int(n / i);
               j=0;
 while( j<HALF_TONE_RESOLUTION){
                    table[(i<<HALF_TONE_BITS)+j] = iv;
                 j++;
}
             i++;
}
            pitchTable[PT_PSG_NOISE] = table;
            phaseStepShiftFilter[PT_PSG_NOISE] = 0xffffffff;
            
            
            var fc_nf:Array<Dynamic> = [4, 8, 16, 32, 64, 96, 128, 160, 202, 254, 380, 508, 762, 1016, 2034, 4068];
            imax  = 16<<HALF_TONE_BITS;
            table = new Array<Int>();
            
            n = PHASE_MAX * psg_clock / rate;
           i=0;
 while( i<16){
                iv = Std.int(n / fc_nf[i]);
               j=0;
 while( j<HALF_TONE_RESOLUTION){
                    table[(i<<HALF_TONE_BITS)+j] = iv;
                 j++;
}
             i++;
}
            pitchTable[PT_APU_NOISE] = table;
            phaseStepShiftFilter[PT_APU_NOISE] = 0xffffffff;
            
            
        
        
            
            var fmgen_dt1:Array<Dynamic> = [  
                [0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0], 
                [0,  0,  0,  0,  1,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  3,  3,  3,  4,  4,  4,  5,  5,  6,  6,  7,  8,  8,  8,  8], 
                [1,  1,  1,  1,  2,  2,  2,  2,  2,  3,  3,  3,  4,  4,  4,  5,  5,  6,  6,  7,  8,  8,  9, 10, 11, 12, 13, 14, 16, 16, 16, 16], 
                [2,  2,  2,  2,  2,  3,  3,  3,  4,  4,  4,  5,  5,  6,  6,  7,  8,  8,  9, 10, 11, 12, 13, 14, 16, 17, 19, 20, 22, 22, 22, 22]
            ];
            dt1Table = new Array<Dynamic>();
           i=0;
 while( i<4){
                dt1Table[i]   = new Array<Int>();
                dt1Table[i+4] = new Array<Int>();
               j=0;
 while( j<KEY_CODE_TABLE_SIZE){
                    iv = (Std.int (fmgen_dt1[i][j>>2]) * 64 * clock_ratio) >> CLOCK_RATIO_BITS;
                    dt1Table[i]  [j] =  iv;
                    dt1Table[i+4][j] = -iv;
                 j++;
}
             i++;
}
            
        
        
            logTable = new Array<Int>();  
            i    = (-ENV_TOP) << 3;                                 
            imax = i + LOG_TABLE_RESOLUTION * 2;                    
            jmax = LOG_TABLE_SIZE;
            dp   = 1 / LOG_TABLE_RESOLUTION;
           p=dp;
 while( i<imax){
                v = Math.pow(2, LOG_VOLUME_BITS-p);  
               j=i;
 while( j<jmax){
                    iv = Std.int(v);
                    logTable[j]   = iv;
                    logTable[j+1] = -iv;
                    v *= 0.5;
                 j+=LOG_TABLE_RESOLUTION * 2;
}
             i+=2; p+=dp;
}
            
            imax = (-ENV_TOP) << 3;
            iv = logTable[imax];
           i=0;
 while( i<imax){
                logTable[i]   = iv;
                logTable[i+1] = -iv;
             i+=2;
}
            
            imax = logTable.length;
           i=jmax;
 while( i<imax){ logTable[i] = Std.int(0);  i++;
}
        }
        
        
    
    
        private function _createWaveSamples() : Void
        {
            
            var i:Int, imax:Int, imax2:Int, imax3:Int, imax4:Int, j:Int, jmax:Int, 
                p:Float, dp:Float, n:Float, v:Float, iv:Int, prev:Int = 0, o:Int, 
                table1: Array<Int>, table2: Array<Int>;

            
            noWaveTable = SiOPMWaveTable.alloc([calcLogTableIndex(1)], PT_PCM);
            noWaveTableOPM = SiOPMWaveTable.alloc([calcLogTableIndex(1)], PT_OPM);
            waveTables = new Array<SiOPMWaveTable>();
            samplerTables = new Array<SiOPMWaveSamplerTable>();
            _customWaveTables = new Array<SiOPMWaveTable>();
            _pcmVoices = new Array<SiMMLVoice>();
            
        
        
           i=0;
 while( i<DEFAULT_PG_MAX){ waveTables[i] = noWaveTable;    i++;
}
           i=0;
 while( i<WAVE_TABLE_MAX){ _customWaveTables[i] = null;    i++;
}
           i=0;
 while( i<PCM_DATA_MAX){ _pcmVoices[i]        = null;      i++;
}
           i=0;
 while( i<SAMPLER_TABLE_MAX){ samplerTables[i] = (new SiOPMWaveSamplerTable()).clear(); i++;
}
            
            _stencilCustomWaveTables = null;
            _stencilPCMVoices = null;
            
        
        
            table1 = new Array<Int>();
            dp    = 6.283185307179586 / SAMPLING_TABLE_SIZE;
            imax  = SAMPLING_TABLE_SIZE >> 1;
            imax2 = SAMPLING_TABLE_SIZE;
           i=0; p=dp*0.5;
 while( i<imax){
                iv = calcLogTableIndex(Math.sin(p));
                table1[i]      = iv;   
                table1[i+imax] = iv+1; 
             i++; p+=dp;
}
            waveTables[PG_SINE] = SiOPMWaveTable.alloc(table1);

        
        
            table1 = new Array<Int>();
            table2 = new Array<Int>();
            dp = 1/imax;
           i=0; p=dp*0.5;
 while( i<imax){
                iv = calcLogTableIndex(p);
                table1[i]         = iv;   
                table1[imax2-i-1] = iv+1; 
                table2[imax-i-1]  = iv;   
                table2[imax+i]    = iv+1; 
             i++; p+=dp;
}
            waveTables[PG_SAW_UP]   = SiOPMWaveTable.alloc(table1);
            waveTables[PG_SAW_DOWN] = SiOPMWaveTable.alloc(table2);
            
        
        
            
            table1  = new Array<Int>();
            imax  = SAMPLING_TABLE_SIZE >> 2;
            imax2 = SAMPLING_TABLE_SIZE >> 1;
            imax4 = SAMPLING_TABLE_SIZE;
            dp   = 1/imax;
           i=0; p=dp*0.5;
 while( i<imax){
                iv = calcLogTableIndex(p);
                table1[i]         = iv;   
                table1[imax2-i-1] = iv;   
                table1[imax2+i]   = iv+1; 
                table1[imax4-i-1] = iv+1; 
             i++; p+=dp;
}
            waveTables[PG_TRIANGLE] = SiOPMWaveTable.alloc(table1);
            
            
            table1 = new Array<Int>();
           i=1; p=0.125;
 while( i<8){
                iv = calcLogTableIndex(p);
                table1[i]    = iv;
                table1[15-i] = iv;
                table1[15+i] = iv+1;
                table1[32-i] = iv+1;
             i++; p+=0.125;
}
            table1[0]  = LOG_TABLE_BOTTOM;
            table1[15] = LOG_TABLE_BOTTOM;
            table1[23] = 3;
            table1[24] = 3;
            waveTables[PG_TRIANGLE_FC] = SiOPMWaveTable.alloc(table1);
            
        
        
            
            iv = calcLogTableIndex(SQUARE_WAVE_OUTPUT);
            waveTables[PG_SQUARE] = SiOPMWaveTable.alloc([iv, iv+1]);
            
            
        
        
            
            
            table2 = waveTables[PG_SQUARE].wavelet;
           j=0;
 while( j<16){
                table1 = new Array<Int>();
               i=0;
 while( i<16){
                    table1[i] = (i<j) ? table2[0] : table2[1];
                 i++;
}
                waveTables[PG_PULSE+j] = SiOPMWaveTable.alloc(table1);
             j++;
}
            
            
            iv = calcLogTableIndex(0);
           j=0;
 while( j<16){
                table1 = new Array<Int>();
                imax = j<<1;
               i=0;
 while( i<imax){
                    table1[i] = (i<j) ? table2[0] : table2[1];
                 i++;
}
               ;
 while( i<32){
                    table1[i] = iv;
                 i++;
}
                waveTables[PG_PULSE_SPIKE+j] = SiOPMWaveTable.alloc(table1);
             j++;
}
            
            
        
        
            var wav:Array<Dynamic> = [-80,-112,-16,96,64,16,64,96,32,-16,64,112,80,0,32,48,-16,-96,0,80,16,-64,-48,-16,-96,-128,-80,0,-48,-112,-80,-32];
            table1 = new Array<Int>();
           i=0;
 while( i<32){
                table1[i] = calcLogTableIndex(wav[i]/128);
             i++;
}
            waveTables[PG_KNMBSMM] = SiOPMWaveTable.alloc(table1);
            
            
        
        
            table1 = new Array<Int>();
            table2 = new Array<Int>();
            imax   = SAMPLING_TABLE_SIZE;
            dp     = 1/imax;
           i=0; p=dp*0.5;
 while( i<imax){
                iv = calcLogTableIndex(p);
                table1[i] = iv+1;   
                table2[i] = iv;     
             i++; p+=dp;
}
            waveTables[PG_SYNC_LOW]  = SiOPMWaveTable.alloc(table1);
            waveTables[PG_SYNC_HIGH] = SiOPMWaveTable.alloc(table2);
            
            
        
        
            
            
            table1 = new Array<Int>();
            table2 = new Array<Int>();
            imax = NOISE_TABLE_SIZE;
            iv = calcLogTableIndex(NOISE_WAVE_OUTPUT);
            n = NOISE_WAVE_OUTPUT / 32768;
            j = 1;                          
           i=0;
 while( i<imax){
                j = (((j<<13)^(j<<14)) & 0x4000) | (j>>1);
                table1[i] = calcLogTableIndex((j&0x7fff)*n*2-1);
                table2[i] = ((j&1) != 0) ? iv : (iv+1);
             i++;
}
            waveTables[PG_NOISE_WHITE] = SiOPMWaveTable.alloc(table1, PT_PCM);
            waveTables[PG_NOISE_PULSE] = SiOPMWaveTable.alloc(table2, PT_PCM);
            waveTables[PG_PC_NZ_OPM]   = SiOPMWaveTable.alloc(table2, PT_OPM_NOISE);
            waveTables[PG_NOISE] = waveTables[PG_NOISE_WHITE];
            
            
            table1 = new Array<Int>();
            imax = SAMPLING_TABLE_SIZE;
            iv = calcLogTableIndex(NOISE_WAVE_OUTPUT);
            j = 1;                          
           i=0;
 while( i<imax){
                j = (((j<<8)^(j<<14)) & 0x4000) | (j>>1);
                table1[i] = ((j&1) != 0) ? iv : (iv+1);
             i++;
}
            waveTables[PG_NOISE_SHORT] = SiOPMWaveTable.alloc(table1, PT_PCM);
            
            
            table1 = new Array<Int>();
            iv = calcLogTableIndex(NOISE_WAVE_OUTPUT);
            j = 0xffff;                      
            o = 0;
           i=0;
 while( i<128){
                j += j + (((j >> 6) ^ (j >> 5)) & 1);
                o ^= j & 1;
                table1[i] = ((o&1) != 0) ? iv : (iv+1);
             i++;
}
            waveTables[PG_NOISE_GB_SHORT] = SiOPMWaveTable.alloc(table1, PT_PCM);
            
            
            table1 = new Array<Int>();
            table1[0] = calcLogTableIndex(SQUARE_WAVE_OUTPUT);
           i=1;
 while( i<16){
                table1[i] = LOG_TABLE_BOTTOM;
             i++;
}
            waveTables[PG_PC_NZ_16BIT] = SiOPMWaveTable.alloc(table1);

            
            table1 = new Array<Int>();
            table2 = waveTables[PG_NOISE_WHITE].wavelet;
            imax = NOISE_TABLE_SIZE;
            j = (-ENV_TOP) << 3;
            n = 16.0/cast(1<<LOG_VOLUME_BITS,Float);
            p = 0.0625;
            v = (logTable[table2[0]+j] - logTable[table2[NOISE_TABLE_SIZE - 1]+j]) * p;
            table1[0] = calcLogTableIndex(v*n);
           i=1;
 while( i<imax){
                imax2 = table2[i]   + j;
                imax3 = table2[i-1] + j;
                v = (v + logTable[imax2] - logTable[imax3]) * p;
                table1[i] = calcLogTableIndex(v*n);
             i++;
}
            waveTables[PG_NOISE_HIPAS] = SiOPMWaveTable.alloc(table1, PT_PCM);
            
            
            var b0:Float=0, b1:Float=0, b2:Float=0;
            table1 = new Array<Int>();
            table2 = waveTables[PG_NOISE_WHITE].wavelet;
            imax = NOISE_TABLE_SIZE;
            j = (-ENV_TOP) << 3;
            n = 0.125/cast(1<<LOG_VOLUME_BITS,Float);
           i=0;
 while( i<imax){
                imax2 = table2[i] + j;
                v = logTable[imax2];
                b0 = 0.99765 * b0 + v * 0.0990460;
                b1 = 0.96300 * b1 + v * 0.2965164;
                b2 = 0.57000 * b2 + v * 1.0526913;
                table1[i] = calcLogTableIndex((b0 + b1 + b2 + v * 0.1848) * n);
             i++;
}
            waveTables[PG_NOISE_PINK] = SiOPMWaveTable.alloc(table1, PT_PCM);

            
            
            table1 = new Array<Int>();
            table1[0] = calcLogTableIndex(SQUARE_WAVE_OUTPUT);
           i=1;
 while( i<16){
                table1[i] = LOG_TABLE_BOTTOM;
             i++;
}
            waveTables[PG_PC_NZ_16BIT] = SiOPMWaveTable.alloc(table1);
            
            
            
            table1 = waveTables[PG_NOISE_SHORT].wavelet;
            table2 = new Array<Int>();
           j=0;
 while( j<SAMPLING_TABLE_SIZE){
                i = j*11;
                imax = ((i+11) < SAMPLING_TABLE_SIZE) ? (i+11) : SAMPLING_TABLE_SIZE;
               
 while( i<imax){ table2[i] = table1[j];  i++;
}
             j++;
}
            waveTables[PG_PC_NZ_SHORT] = SiOPMWaveTable.alloc(table2);
            
            
        
        
            
            imax  = SAMPLING_TABLE_SIZE;
            imax2 = SAMPLING_TABLE_SIZE >> 1;
            imax4 = SAMPLING_TABLE_SIZE >> 2;
           j = 1;
		   
			while( j<60){
                iv = imax4>>(j>>3);
                iv -= (iv * (j&7))>>4;
                if (prev == iv) {
                    waveTables[PG_RAMP+64-j] = waveTables[PG_RAMP+65-j];
                    waveTables[PG_RAMP + 64 + j] = waveTables[PG_RAMP + 63 + j];
					j++;
                    continue;
                }
                prev = iv;
                
                table1 = new Array<Int>();
                table2 = new Array<Int>();
                imax3 = imax2 - iv;
                dp = 1/imax3;
               i=0; p=dp*0.5;
			while( i<imax3){
                    iv = calcLogTableIndex(p);
                    table1[i]         = iv;   
                    table1[imax-i-1]  = iv+1; 
                    table2[imax2+i]   = iv+1; 
                    table2[imax2-i-1] = iv;   
                 i++; p+=dp;
				}
                dp = 1/(imax2-imax3);
               
			while( i<imax2){
                    iv = calcLogTableIndex(p);
                    table1[i]         = iv;   
                    table1[imax-i-1]  = iv+1; 
                    table2[imax2+i]   = iv+1; 
                    table2[imax2-i-1] = iv;   
                 i++; p-=dp;
			}
                waveTables[PG_RAMP+64-j] = SiOPMWaveTable.alloc(table1);
                waveTables[PG_RAMP+64+j] = SiOPMWaveTable.alloc(table2);
             j++;
		}
           j=0;
 while(   j<5){ waveTables[PG_RAMP+j] = waveTables[PG_SAW_UP];   j++;
}
           j=124;
 while( j<128){ waveTables[PG_RAMP+j] = waveTables[PG_SAW_DOWN]; j++;
}
            waveTables[PG_RAMP+64] = waveTables[PG_TRIANGLE];
            
            
        
        
            
            waveTables[PG_MA3_WAVE] = waveTables[PG_SINE];
            __exp_ma3_waves(0);
            
            table2 = waveTables[PG_SINE].wavelet;
            table1 = new Array<Int>();
            j = 0;
           i=0;
 while( i<SAMPLING_TABLE_SIZE){
                table1[i] = table2[i+j];
                j += 1-(((i>>(SAMPLING_TABLE_BITS-3))+1)&2); 
             i++;
}
            waveTables[PG_MA3_WAVE+8] = SiOPMWaveTable.alloc(table1);
            __exp_ma3_waves(8);
            
            waveTables[PG_MA3_WAVE+16] = waveTables[PG_TRIANGLE];
            __exp_ma3_waves(16);
            
            waveTables[PG_MA3_WAVE+24] = waveTables[PG_SAW_UP];
            __exp_ma3_waves(24);
            
            waveTables[PG_MA3_WAVE+6] = waveTables[PG_SQUARE];
            
            iv = calcLogTableIndex(1);
            waveTables[PG_MA3_WAVE+14] = SiOPMWaveTable.alloc([iv, LOG_TABLE_BOTTOM]);
            
            waveTables[PG_MA3_WAVE+22] = SiOPMWaveTable.alloc([iv, LOG_TABLE_BOTTOM, iv, LOG_TABLE_BOTTOM]);
            
            waveTables[PG_MA3_WAVE+30] = SiOPMWaveTable.alloc([iv, LOG_TABLE_BOTTOM, LOG_TABLE_BOTTOM, LOG_TABLE_BOTTOM]);
            
            
            table1 = new Array<Int>();
            dp   = 6.283185307179586 / SAMPLING_TABLE_SIZE;
            imax  = SAMPLING_TABLE_SIZE >> 2;
            imax2 = SAMPLING_TABLE_SIZE >> 1;
            imax4 = SAMPLING_TABLE_SIZE;
           i=0; p=dp*0.5;
 while( i<imax){
                iv = calcLogTableIndex(1-Math.sin(p));
                table1[i]          = iv;   
                table1[i+imax]     = LOG_TABLE_BOTTOM;
                table1[i+imax2]    = LOG_TABLE_BOTTOM;
                table1[imax4-i-1]  = iv+1; 
             i++; p+=dp;
}
            waveTables[PG_MA3_WAVE+7] = SiOPMWaveTable.alloc(table1);
            
            waveTables[PG_MA3_WAVE+15] = noWaveTable;
            waveTables[PG_MA3_WAVE+23] = noWaveTable;
            waveTables[PG_MA3_WAVE+31] = noWaveTable;
        }
        
        
        
        private function __exp_ma3_waves(index:Int) : Void
        {
            
            var i:Int, imax:Int, table1: Array<Int>, table2: Array<Int>;
            
            
            table2 = waveTables[PG_MA3_WAVE+index].wavelet;
            
            
            table1 = new Array<Int>();
            imax = SAMPLING_TABLE_SIZE >> 1;
           i=0;
 while( i<imax){
                table1[i]      = table2[i];
                table1[i+imax] = LOG_TABLE_BOTTOM;
             i++;
}
            waveTables[PG_MA3_WAVE+index+1] = SiOPMWaveTable.alloc(table1);
            
            
            table1 = new Array<Int>();
            imax = SAMPLING_TABLE_SIZE >> 1;
           i=0;
 while( i<imax){
                table1[i]      = table2[i];
                table1[i+imax] = table2[i];
             i++;
}
            waveTables[PG_MA3_WAVE+index+2] = SiOPMWaveTable.alloc(table1);
            
            
            table1 = new Array<Int>();
            imax = SAMPLING_TABLE_SIZE >> 2;
           i=0;
 while( i<imax){
                table1[i]        = table2[i];
                table1[i+imax]   = LOG_TABLE_BOTTOM;
                table1[i+imax*2] = table2[i];
                table1[i+imax*3] = LOG_TABLE_BOTTOM;
             i++;
}
            waveTables[PG_MA3_WAVE+index+3] = SiOPMWaveTable.alloc(table1);
            
            
            table1 = new Array<Int>();
            imax = SAMPLING_TABLE_SIZE >> 1;
           i=0;
 while( i<imax){
                table1[i]      = table2[i<<1];
                table1[i+imax] = LOG_TABLE_BOTTOM;
             i++;
}
            waveTables[PG_MA3_WAVE+index+4] = SiOPMWaveTable.alloc(table1);
            
            
            table1 = new Array<Int>();
            imax = SAMPLING_TABLE_SIZE >> 2;
           i=0;
 while( i<imax){
                table1[i]        = table2[i<<1];
                table1[i+imax]   = table1[i];
                table1[i+imax*2] = LOG_TABLE_BOTTOM;
                table1[i+imax*3] = LOG_TABLE_BOTTOM;
             i++;
}
            waveTables[PG_MA3_WAVE+index+5] = SiOPMWaveTable.alloc(table1);
        }
        
        
    
    
        private function _createLFOTables() : Void
        {
            var i:Int, t:Int, s:Int, table: Array<Int>, table2: Array<Int>;
            
            
            
            lfo_timerSteps = new Array<Int>();
           i=0;
 while( i<256){
                t = 16 + (i & 15);  
                s = 15 - (i >> 4);  
                lfo_timerSteps[i] = Std.int(Std.int((t << (LFO_FIXED_BITS-4)) * clock_ratio / (8 << s)) >> CLOCK_RATIO_BITS); 
             i++;
}
            
            lfo_waveTables = new Array<Dynamic>();    
            
            
            
            table = new Array<Int>();
            table2 = new Array<Int>();
           i=0;
 while( i<256){ 
                table[i] = 255 - i;
                table2[i] = i;
             i++;
}
            lfo_waveTables[LFO_WAVE_SAW] = table;
            lfo_waveTables[LFO_WAVE_SAW+4] = table2;
            
            
            table = new Array<Int>();
            table2 = new Array<Int>();
           i=0;
 while( i<256){
                table[i] = (i<128) ? 255 : 0;
                table2[i] = 255 - table[i];
             i++;
}
            lfo_waveTables[LFO_WAVE_SQUARE] = table;
            lfo_waveTables[LFO_WAVE_SQUARE+4] = table2;
            
            
            table = new Array<Int>();
            table2 = new Array<Int>();
           i=0;
 while( i<64){
                t = i<<1;
                table[i]     = t+128;
                table[127-i] = t+128;
                table[128+i] = 126-t;
                table[255-i] = 126-t;
             i++;
}
           i=0;
 while( i<256){ table2[i] = 255 - table[i];  i++;
}
            lfo_waveTables[LFO_WAVE_TRIANGLE] = table;
            lfo_waveTables[LFO_WAVE_TRIANGLE+4] = table2;

            
            table = new Array<Int>();
            table2 = new Array<Int>();
           i=0;
 while( i<256){ 
                table[i] = Std.int(Math.random()*255);
                table2[i] = 255 - table[i];
             i++;
}
            lfo_waveTables[LFO_WAVE_NOISE] = table;
            lfo_waveTables[LFO_WAVE_NOISE+4] = table2;
            
            
            table = new Array<Int>();
           i=0;
 while( i<256){
                table[i] = (i-128)*(i-128);
             i++;
}
            lfo_chorusTables = table;
        }
        
        
    
    
        private function _createFilterTables() : Void
        {
            var i:Int, shift:Float, liner:Float;
            
            filter_cutoffTable   = new Array<Float>();
            filter_feedbackTable = new Array<Float>();
           i=0;
 while( i<128){
                filter_cutoffTable[i]   = i*i*0.00006103515625; 
                filter_feedbackTable[i] = 1.0 + 1.0 / (1.0 - filter_cutoffTable[i]); 
             i++;
}
            filter_cutoffTable[128]   = 1;
            filter_feedbackTable[128] = filter_feedbackTable[128];
            
            
            filter_eg_rate = new Array<Int>();
            filter_eg_rate[0] = 0;
           i=1;
 while( i<60){
                shift = cast(1 << (14 - (i>>2)),Float);
                liner = cast((i & 3) * 0.125 + 0.5,Float);
                filter_eg_rate[i] = Std.int(2.36514 * shift * liner + 0.5);
             i++;
}
           ;
 while( i<64){
                filter_eg_rate[i] = 1;
             i++;
}
        }
        
        
        
        
    
    
        
        static public function calcLogTableIndex(n:Float) : Int
        {
            
            
            if (n<0) {
                return (n<-0.0001220703125) ? (((Std.int (Math.log(-n) * -369.3299304675746 + 0.5) + 1) << 1) + 1) : LOG_TABLE_BOTTOM;
            } else {
                return (n>0.0001220703125) ? ((Std.int (Math.log(n) * -369.3299304675746 + 0.5) + 1) << 1) : LOG_TABLE_BOTTOM;
            }
        }
        
        
        
        
    
    
        
        public function resetAllUserTables() : Void
        {
            
            var i:Int, pcm:SiOPMWavePCMTable;
            
            
           i=0;
 while( i<WAVE_TABLE_MAX){ 
                if (_customWaveTables[i] != null) { 
                    _customWaveTables[i].free(); 
                    _customWaveTables[i] = null;
                }
             i++;
}
           i=0;
 while( i<PCM_DATA_MAX){ 
                if (_pcmVoices[i] != null) { 
                    pcm = cast(_pcmVoices[i].waveData,SiOPMWavePCMTable);
                    if (pcm != null) pcm._free();
                    _pcmVoices[i] = null;
                }
             i++;
}
            
            _stencilCustomWaveTables = null;
            _stencilPCMVoices = null;
        }
        
        
        
        public function registerWaveTable(index:Int, table: Array<Int>) : SiOPMWaveTable
        {
            
            var newWaveTable:SiOPMWaveTable = SiOPMWaveTable.alloc(table);
            index &= WAVE_TABLE_MAX-1;
            _customWaveTables[index] = newWaveTable;
            
            
            if (index < 3) {
                
                waveTables[15 + index * 8 + PG_MA3_WAVE] = newWaveTable;
            }
            
            return newWaveTable;
        }
        
        
        
        public function registerSamplerData(index:Int, table:Dynamic, ignoreNoteOff:Bool, pan:Int, srcChannelCount:Int, channelCount:Int) : SiOPMWaveSamplerData
        {
            var bank:Int = (index>>NOTE_BITS) & (SAMPLER_TABLE_MAX-1);
            return samplerTables[bank].setSample(new SiOPMWaveSamplerData(table, ignoreNoteOff, pan, srcChannelCount, channelCount), index & (SAMPLER_DATA_MAX-1));
        }
        
        
        
        public function _setGlobalPCMVoice(index:Int, voice:SiMMLVoice) : SiMMLVoice
        {
            
            index &= PCM_DATA_MAX-1;
            if (_pcmVoices[index] == null) _pcmVoices[index] = new SiMMLVoice();
            _pcmVoices[index].copyFrom(voice);
            return _pcmVoices[index];
        }
        
        
        
        public function _getGlobalPCMVoice(index:Int) : SiMMLVoice
        {
            
            index &= PCM_DATA_MAX-1;
            if (_pcmVoices[index] == null) {
                _pcmVoices[index] = new SiMMLVoice()._newBlankPCMVoice(index);
            }
            return _pcmVoices[index];
        }
        
        
        
        public function getWaveTable(index:Int) : SiOPMWaveTable
        {
            if (index < PG_CUSTOM) return waveTables[index];
            if (index < PG_PCM) {
                index -= PG_CUSTOM;
                if (_stencilCustomWaveTables != null && _stencilCustomWaveTables[index] != null) return _stencilCustomWaveTables[index];
                return (_customWaveTables[index] != null) ? _customWaveTables[index] : noWaveTableOPM;
            }
            return noWaveTable;
        }
        
        
        
        public function getPCMData(index:Int) : SiOPMWavePCMTable
        {
            index &= PCM_DATA_MAX-1;
            if (_stencilPCMVoices != null && _stencilPCMVoices[index] != null) return cast(_stencilPCMVoices[index].waveData,SiOPMWavePCMTable);
            return (_pcmVoices[index] == null) ? null : cast(_pcmVoices[index].waveData,SiOPMWavePCMTable);
        }
    }




