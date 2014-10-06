





package org.si.sion.module ;
    
    class SiOPMOperatorParam
    {
    
    
        
        public var pgType:Int;
        
        public var ptType:Int;
        
        
        public var ar:Int;
        
        public var dr:Int;
        
        public var sr:Int;
        
        public var rr:Int;
        
        public var sl:Int;
        
        public var tl:Int;
        
        
        public var ksr:Int;
        
        public var ksl:Int;
        
        
        public var fmul:Int;
        
        public var dt1:Int;
        
        public var detune:Int;
        
        
        public var ams:Int;
        
        public var phase:Int;
        
        public var fixedPitch:Int;
        
        
        public var mute:Bool;
        
        public var ssgec:Int;
        
        public var modLevel:Int;
        
        public var erst:Bool;
        
        
        
        public function mul(m:Int) : Void { fmul = (m != 0) ? (m<<7) : 64; }
        public function get_mul() : Int { return (fmul>>7)&15; }
        
        
        public function setPGType(type:Int) : Void
        {
            pgType = type & 511;
            ptType = SiOPMTable.instance().getWaveTable(pgType).defaultPTType;
        }
        
        
        
        public function new()
        {
            initialize();
        }
        
        
        
        public function initialize() : Void
        {
            pgType = SiOPMTable.PG_SINE;
            ptType = SiOPMTable.PT_OPM;
            ar = 63;
            dr = 0;
            sr = 0;
            rr = 63;
            sl = 0;
            tl = 0;
            ksr = 1;
            ksl = 0;
            fmul = 128;
            dt1 = 0;
            detune = 0;
            ams = 0;
            phase = 0;
            fixedPitch = 0;
            mute = false;
            ssgec = 0;
            modLevel = 5;
            erst = false;
        }
        
        
        
        public function copyFrom(org:SiOPMOperatorParam) : Void
        {
            pgType = org.pgType;
            ptType = org.ptType;
            ar = org.ar;
            dr = org.dr;
            sr = org.sr;
            rr = org.rr;
            sl = org.sl;
            tl = org.tl;
            ksr = org.ksr;
            ksl = org.ksl;
            fmul = org.fmul;
            dt1 = org.dt1;
            detune = org.detune;
            ams = org.ams;
            phase = org.phase;
            fixedPitch = org.fixedPitch;
            mute = org.mute;
            ssgec = org.ssgec;
            modLevel = org.modLevel;
            erst = org.erst;
        }
        
        
        
        public function toString() : String
        {
            var str:String = "SiOPMOperatorParam : ";
            str += Std.string(pgType) + "(";
            str += Std.string(ptType) + ") : ";
            str += Std.string(ar) + "/";
            str += Std.string(dr) + "/";
            str += Std.string(sr) + "/";
            str += Std.string(rr) + "/";
            str += Std.string(sl) + "/";
            str += Std.string(tl) + " : ";
            str += Std.string(ksr) + "/";
            str += Std.string(ksl) + " : ";
            str += Std.string(fmul) + "/";
            str += Std.string(dt1) + "/";
            str += Std.string(detune) + " : ";
            str += Std.string(ams) + "/";
            str += Std.string(phase)  + "/";
            str += Std.string(fixedPitch) + " : ";
            str += Std.string(ssgec) + "/";
            str += Std.string(mute) + "/";
            str += Std.string(erst);
            return str;
        }
    }


