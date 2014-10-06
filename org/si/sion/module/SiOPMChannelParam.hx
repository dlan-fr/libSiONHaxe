





package org.si.sion.module ;
    import org.si.sion.sequencer.base.MMLSequence;
	import flash.errors.Error;
    
    
    
    class SiOPMChannelParam
    {
    
    
        
        public var operatorParam: Array<SiOPMOperatorParam>;
        
        
        public var opeCount:Int;
        
        public var alg:Int;
        
        public var fb:Int;
        
        public var fbc:Int;
        
        public var fratio:Int;
        
        public var lfoWaveShape:Int;
        
        public var lfoFreqStep:Int;
        
        
        public var amd:Int;
        
        public var pmd:Int;
        
        public var volumes: Array<Float>;
        
        public var pan:Int;

        
        public var filterType:Int;
        
        public var cutoff:Int;
        
        public var resonance:Int;
        
        public var far:Int;
        
        public var fdr1:Int;
        
        public var fdr2:Int;
        
        public var frr:Int;
        
        public var fdc1:Int;
        
        public var fdc2:Int;
        
        public var fsc:Int;
        
        public var frc:Int;
        
        
        public var initSequence:MMLSequence;
        
        
        
        public function lfoFrame(fps:Int) : Void
        {
            lfoFreqStep = Std.int(SiOPMTable.LFO_TIMER_INITIAL/Std.int(fps*2.882352941176471));
        }
        public function get_lfoFrame() : Int
        {
            return Std.int(SiOPMTable.LFO_TIMER_INITIAL * 0.346938775510204 / lfoFreqStep);
        }
        
        
        
        public function new()
        {
            initSequence = new MMLSequence();
            volumes = new Array<Float>();

            operatorParam = new Array<SiOPMOperatorParam>();
           var i:Int = 0;
 while( i<4){
                operatorParam[i] = new SiOPMOperatorParam();
             i++;
}
            
            initialize();
        }
        
        
        
        public function initialize() : SiOPMChannelParam
        {
            var i:Int;
            
            opeCount = 1;
            
            alg = 0;
            fb = 0;
            fbc = 0;
            lfoWaveShape = SiOPMTable.LFO_WAVE_TRIANGLE;
            lfoFreqStep = 12126;    
            amd = 0;
            pmd = 0;
            fratio = 100;
           i=1;
 while( i<SiOPMModule.STREAM_SEND_SIZE){ volumes[i] = 0;  i++;
}
            volumes[0] = 0.5;
            pan = 64;
            
            filterType = 0;
            cutoff = 128;
            resonance = 0;
            far = 0;
            fdr1 = 0;
            fdr2 = 0;
            frr = 0;
            fdc1 = 128;
            fdc2 = 64;
            fsc = 32;
            frc = 128;
            
           i=0;
 while( i<4){ operatorParam[i].initialize();  i++;
}
            
            initSequence.free();
            
            return this;
        }
        
        
        
        public function copyFrom(org:SiOPMChannelParam) : SiOPMChannelParam
        {
            var i:Int;
            
            opeCount = org.opeCount;
            
            alg = org.alg;
            fb = org.fb;
            fbc = org.fbc;
            lfoWaveShape = org.lfoWaveShape;
            lfoFreqStep = org.lfoFreqStep;
            amd = org.amd;
            pmd = org.pmd;
            fratio = org.fratio;
           i=0;
 while( i<SiOPMModule.STREAM_SEND_SIZE){ volumes[i] = org.volumes[i];  i++;
}
            pan = org.pan;
            
            filterType = org.filterType;
            cutoff = org.cutoff;
            resonance = org.resonance;
            far = org.far;
            fdr1 = org.fdr1;
            fdr2 = org.fdr2;
            frr = org.frr;
            fdc1 = org.fdc1;
            fdc2 = org.fdc2;
            fsc = org.fsc;
            frc = org.frc;
            
           i=0;
 while( i<4){ operatorParam[i].copyFrom(org.operatorParam[i]);  i++;
}
            
            initSequence.free();
            
            return this;
        }
        
        
        
        public function toString() : String
        {
            var str:String = "SiOPMChannelParam : opeCount=";
            str += Std.string(opeCount) + "\n";
			
			var s:Dynamic = function (p:String, i:Int) : Void { str += "  " + p + "=" + Std.string(i) + "\n"; }
            var s2:Dynamic = function (p:String, i:Int, q:String, j:Int) : Void { str += "  " + p + "=" + Std.string(i) + " / " + q + "=" + Std.string(j) + "\n"; }
			
			
            s("freq.ratio", fratio);
            s("alg", alg);
            s2("fb ", fb,  "fbc", fbc);
            s2("lws", lfoWaveShape, "lfq", SiOPMTable.LFO_TIMER_INITIAL*0.005782313/lfoFreqStep);
            s2("amd", amd, "pmd", pmd);
            s2("vol", volumes[0],  "pan", pan-64);
            s("filter type", filterType);
            s2("co", cutoff, "res", resonance);
            str += "fenv=" + Std.string(far) + "/" + Std.string(fdr1) + "/"+ Std.string(fdr2) + "/"+ Std.string(frr) + "\n";
            str += "feco=" + Std.string(fdc1) + "/"+ Std.string(fdc2) + "/"+ Std.string(fsc) + "/"+ Std.string(frc) + "\n";
           var i:Int=0;
 while( i<opeCount){
                str += operatorParam[i].toString() + "\n";
             i++;
}
            return str;
            
        }
        
        
        
        public function setByOPMRegister(channel:Int, addr:Int, data:Int) : SiOPMChannelParam
        {
            var v:Int, pms:Int, ams:Int, opp:SiOPMOperatorParam;
            
            if (addr < 0x20) {  
                switch(addr) {
                case 15: 
                    if (channel == 7 && (data & 128) != 0) {
                        operatorParam[3].pgType = SiOPMTable.PG_NOISE_PULSE;
                        operatorParam[3].ptType = SiOPMTable.PT_OPM_NOISE;
                        operatorParam[3].fixedPitch = ((data & 31) << 6) + 2048;
                    }
       
                case 24: 
                    lfoFreqStep = SiOPMTable.instance().lfo_timerSteps[data];
  
                case 25: 
                    if ((data & 128) != 0) pmd = data & 127;
                    else            amd = data & 127;
         
                case 27: 
                    lfoWaveShape = data & 3;
            
                }
            } else {
                if (channel == (addr&7)) {
                    if (addr < 0x40) {
                        
                        switch((addr-0x20) >> 3) {
                        case 0: 
                            v = data >> 6;
                            volumes[0] = (v != 0) ? 0.5 : 0;
                            pan = (v==1) ? 128 : (v==2) ? 0 : 64;
                            fb  = (data >> 3) & 7;
                            alg = (data     ) & 7;
             
                        case 3: 
                            pms = (data >> 4) & 7;
                            ams = (data     ) & 3;
                            
                        }
                    } else {
                        
                        opp = operatorParam[[3,1,2,0][(addr >> 3) & 3]]; 
                        switch((addr-0x40) >> 5) {
                        case 0: 
                            opp.dt1 = (data >> 4) & 7;
                            opp.mul((data     ) & 15);

                        case 1: 
                            opp.tl = data & 127;
        
                        case 2: 
                            opp.ksr = (data >> 6) & 3;
                            opp.ar  = (data & 31) << 1;
                    
                        case 3: 
                            opp.ams = ((data >> 7) & 1)<<1;
                            opp.dr  = (data & 31) << 1;
                  
                        case 4: 
                            opp.detune = [0, 384, 500, 608][(data >> 6) & 3];
                            opp.sr     = (data & 31) << 1;
                 
                        case 5: 
                            opp.sl = (data >> 4) & 15;
                            opp.rr = (data & 15) << 2;
                        
                        }
                    }
                }
            }
            return this;
        }
        
        
        
        public function setByOPNARegister(addr:Int, data:Int) : SiOPMChannelParam {
            throw new Error("SiOPMChannelParam.setByOPNARegister(): Sorry, this function is not available.");
            return this;
        }
    }


