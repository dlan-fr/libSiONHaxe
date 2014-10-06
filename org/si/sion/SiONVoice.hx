





package org.si.sion ;
    import flash.media.Sound;
    import org.si.sion.utils.Translator;
    import org.si.sion.sequencer.SiMMLVoice;
    import org.si.sion.module.ISiOPMWaveInterface;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.module.SiOPMChannelParam;
    import org.si.sion.module.SiOPMOperatorParam;
    import org.si.sion.module.SiOPMWaveTable;
    import org.si.sion.module.SiOPMWavePCMData;
    import org.si.sion.module.SiOPMWavePCMTable;
    import org.si.sion.module.SiOPMWaveSamplerData;
    import org.si.sion.module.SiOPMWaveSamplerTable;
	import flash.utils.RegExp;
    
    
    
    class SiONVoice extends SiMMLVoice implements ISiOPMWaveInterface
    {
    
    
        inline static public var CHIPTYPE_SIOPM:String = "";
        inline static public var CHIPTYPE_OPL:String = "OPL";
        inline static public var CHIPTYPE_OPM:String = "OPM";
        inline static public var CHIPTYPE_OPN:String = "OPN";
        inline static public var CHIPTYPE_OPX:String = "OPX";
        inline static public var CHIPTYPE_MA3:String = "MA3";
        inline static public var CHIPTYPE_PMS_GUITAR:String = "PMSGuitar";
        inline static public var CHIPTYPE_ANALOG_LIKE:String = "AnalogLike";
        
        
        
        
    
    
        
        public var name:String;
        
        
        
        
    
    
        
        public function new(moduleType:Int=5, channelNum:Int=0, ar:Int=63, rr:Int=63, dt:Int=0, connectionType:Int=-1, ws2:Int=0, dt2:Int=0)
        {
            super();
            name = "";
            updateTrackParamaters = true;
            
            setModuleType(moduleType, channelNum);
            channelParam.operatorParam[0].ar = ar;
            channelParam.operatorParam[0].rr = rr;
            pitchShift = dt;
            if (connectionType >= 0) {
                channelParam.opeCount = 5;
                channelParam.alg = (connectionType<=2) ? connectionType : 0;
                channelParam.operatorParam[0].setPGType(channelNum);
                channelParam.operatorParam[1].setPGType(ws2);
                channelParam.operatorParam[1].detune = dt2;
            }
        }
        
        
        
        
    
    
        
        public function clone() : SiONVoice
        {
            var newVoice:SiONVoice = new SiONVoice();
            newVoice.copyFrom(this);
            newVoice.name = name;
            return newVoice;
        }
        
        
        
        
    
    
        
        public function param(args:Array<Dynamic>)    : Void { Translator.setParam(channelParam, args);    chipType = ""; }
        
        
        public function paramOPL(args:Array<Dynamic>) : Void { Translator.setOPLParam(channelParam, args); chipType = "OPL"; }
        
        
        public function paramOPM(args:Array<Dynamic>) : Void { Translator.setOPMParam(channelParam, args); chipType = "OPM"; }
        
        
        public function paramOPN(args:Array<Dynamic>) : Void { Translator.setOPNParam(channelParam, args); chipType = "OPN"; }
        
        
        public function paramOPX(args:Array<Dynamic>) : Void { Translator.setOPXParam(channelParam, args); chipType = "OPX"; }
        
        
        public function paramMA3(args:Array<Dynamic>) : Void { Translator.setMA3Param(channelParam, args); chipType = "MA3"; }
        
        
        public function paramAL(args:Array<Dynamic>) : Void { Translator.setALParam(channelParam, args); chipType = "AnalogLike"; }
        
        
        
        public function get_param()    : Array<Dynamic> { return Translator.getParam(channelParam); }
        
        
        public function get_paramOPL() : Array<Dynamic> { return Translator.getOPLParam(channelParam); }
        
        
        public function get_paramOPM() : Array<Dynamic> { return Translator.getOPMParam(channelParam); }
        
        
        public function get_paramOPN() : Array<Dynamic> { return Translator.getOPNParam(channelParam); }
        
        
        public function get_paramOPX() : Array<Dynamic> { return Translator.getOPXParam(channelParam); }
        
        
        public function get_paramMA3() : Array<Dynamic> { return Translator.getMA3Param(channelParam); }
        
        
        public function get_paramAL() : Array<Dynamic> { return Translator.getALParam(channelParam); }
        
        
        
        public function getMML(index:Int, type:String = null, appendPostfixMML:Bool = true) : String {
            if (type == null) type = chipType;
            var mml:String = "";
            switch (type) {
            case "OPL":        mml = "#OPL@" + Std.string(index) + Translator.mmlOPLParam(channelParam, " ", "\n", name); 
            case "OPM":        mml = "#OPM@" + Std.string(index) + Translator.mmlOPMParam(channelParam, " ", "\n", name); 
            case "OPN":        mml = "#OPN@" + Std.string(index) + Translator.mmlOPNParam(channelParam, " ", "\n", name); 
            case "OPX":        mml = "#OPX@" + Std.string(index) + Translator.mmlOPXParam(channelParam, " ", "\n", name); 
            case "MA3":        mml = "#MA@"  + Std.string(index) + Translator.mmlMA3Param(channelParam, " ", "\n", name); 
            case "AnalogLike": mml = "#AL@"  + Std.string(index) + Translator.mmlALParam (channelParam, " ", "\n", name); 
            default:           mml = "#@"    + Std.string(index) + Translator.mmlParam   (channelParam, " ", "\n", name); 
            }
            if (appendPostfixMML) {
                var postfix:String = Translator.mmlVoiceSetting(this);
                if (postfix != "") mml += "\n" + postfix;
            }
            return mml + ";";
        }
        
        
        
        public function setByMML(mml:String) : Int {
            
            initialize();
            var rexNum:RegExp = new RegExp("(#[A-Z]*@)\\s*(\\d+)\\s*{(.*?)}(.*?);", "ms"),
                rexNam:RegExp = new RegExp("^.*?(//\\s*(.+?))?[\\n\\r]"),
                res:Dynamic = rexNum.exec(mml);
            if (res) {
                var cmd:String = Std.string(res[1]),
                    prm:String = Std.string(res[3]),
                    pfx:String = Std.string(res[4]),
                    voiceIndex:Int = Std.int(res[2]);
                switch (cmd) {
                case "#@":   { Translator.parseParam   (channelParam, prm); chipType = ""; }
                case "#OPL@":{ Translator.parseOPLParam(channelParam, prm); chipType = "OPL"; }
                case "#OPM@":{ Translator.parseOPMParam(channelParam, prm); chipType = "OPM"; }
                case "#OPN@":{ Translator.parseOPNParam(channelParam, prm); chipType = "OPN"; }
                case "#OPX@":{ Translator.parseOPXParam(channelParam, prm); chipType = "OPX"; }
                case "#MA@": { Translator.parseMA3Param(channelParam, prm); chipType = "MA3"; }
                case "#AL@": { Translator.parseALParam (channelParam, prm); chipType = "AnalogLike"; }
                default: return -1;
                }
                Translator.parseVoiceSetting(this, pfx);
                res = rexNam.exec(prm);
                name = (res && res[2]) ? Std.string(res[2]) : "";
                return voiceIndex;
            }
            return -1;
        }
        
        
        
    
    
        
        override public function initialize() : Void
        {
            super.initialize();
            name = "";
            updateTrackParamaters = true;
        }
        
        
        
       /** Set wave table voice.
         *  @param index wave table number.
         *  @param table wave shape vector ranges in -1 to 1.
         */
        public function setWaveTable(data:Array<Float>) : SiOPMWaveTable
        {
            var i:Int, imax:Int=data.length;
            var table:Array<Int> = new Array<Int>();
			
			i = 0;
            while ( i < imax) 
			{
				table[i] = SiOPMTable.calcLogTableIndex(data[i]);
				i++;
			}
				
            waveData = SiOPMWaveTable.alloc(table);
            moduleType = 4;
            return cast(waveData,SiOPMWaveTable);
        }
        
        
        /** Set as PCM voice (Sound with pitch shift, LPF envlope).
         *  @param data wave data, Sound, Vector.&lt;Number&gt; or Vector.&lt;int&gt; is available. The Sound instance is extracted internally.
         *  @param samplingNote sampling data's original note
         *  @return PCM data instance as SiOPMWavePCMData
         *  @see org.si.sion.module.SiOPMWavePCMData
         */
        public function setPCMVoice(data:Dynamic, samplingNote:Int=69, srcChannelCount:Int=2, channelCount:Int=0) : SiOPMWavePCMData
        {
            moduleType = 7;
			waveData = new SiOPMWavePCMData(data, samplingNote * 64, srcChannelCount, channelCount);
            return cast (waveData,SiOPMWavePCMData);
        }
        
        
        
       /** Set as Sampler voice (Sound without pitch shift, LPF envlope).
         *  @param data wave data, Sound, Vector.&lt;Number&gt; or Vector.&lt;int&gt; is available. The Sound is extracted when the length is shorter than 4[sec].
         *  @param ignoreNoteOff flag to ignore note off
         *  @param channelCount channel count of streaming, 1 for monoral, 2 for stereo.
         *  @return MP3 data instance as SiOPMWaveSamplerData
         *  @see org.si.sion.module.SiOPMWaveSamplerData
         */
        public function setMP3Voice(wave:Sound, ignoreNoteOff:Bool=false, channelCount:Int=2) : SiOPMWaveSamplerData
        {
            moduleType = 10;
			waveData = new SiOPMWaveSamplerData(wave, ignoreNoteOff, 0, 2, channelCount);
            return cast(waveData,SiOPMWaveSamplerData);
        }
        
        
        
        public function setPCMWave(index:Int, data:Dynamic, samplingNote:Float=69, keyRangeFrom:Int=0, keyRangeTo:Int=127, srcChannelCount:Int=2, channelCount:Int=0) : SiOPMWavePCMData
        {
            if (moduleType != 7 || channelNum != index) waveData = null;
            moduleType = 7;
            channelNum = index;
            var pcmTable:SiOPMWavePCMTable = (waveData != null) ? (cast(waveData,SiOPMWavePCMTable)) : new SiOPMWavePCMTable();
            var pcmData:SiOPMWavePCMData   = new SiOPMWavePCMData(data, Std.int(samplingNote*64), srcChannelCount, channelCount);
            pcmTable.setSample(pcmData, keyRangeFrom, keyRangeTo);
            waveData = pcmTable;
            return pcmData;
        }
        
        
        
        public function setSamplerWave(index:Int, data:Dynamic, ignoreNoteOff:Bool=false, pan:Int=0, srcChannelCount:Int=2, channelCount:Int=0) : SiOPMWaveSamplerData
        {
            moduleType = 10;
            var samplerTable:SiOPMWaveSamplerTable = (waveData != null) ? (cast(waveData,SiOPMWaveSamplerTable)) : new SiOPMWaveSamplerTable();
            var sampleData:SiOPMWaveSamplerData   = new SiOPMWaveSamplerData(data, ignoreNoteOff, pan, srcChannelCount, channelCount);
            samplerTable.setSample(sampleData, index & (SiOPMTable.NOTE_TABLE_SIZE-1));
            waveData = samplerTable;
            return sampleData;
        }
        
        
        
        public function setSamplerTable(table:SiOPMWaveSamplerTable) : SiONVoice
        {
            moduleType = 10;
            waveData = table;
            return this;
        }
        
        
        
        public function setPMSGuitar(ar:Int=48, dr:Int=48, tl:Int=0, fixedPitch:Int=69, ws:Int=20, tension:Int=8) : SiONVoice
        {
            moduleType = 11;
            channelNum = 1;
            param([1, 0, 0, ws, ar, dr, 0, 63, 15, tl, 0, 0, 1, 0, 0, 0, 0, fixedPitch]);
            pmsTension = tension;
            chipType = "PMSGuitar";
            return this;
        }
        
        
        
        public function setAnalogLike(connectionType:Int, ws1:Int=1, ws2:Int=1, balance:Int=0, vco2pitch:Int=0) : SiONVoice
        {
            channelParam.opeCount = 5;
            channelParam.alg = (connectionType>=0 && connectionType<=3) ? connectionType : 0;
            channelParam.operatorParam[0].setPGType(ws1);
            channelParam.operatorParam[1].setPGType(ws2);

            if (balance > 64) balance = 64;
            else if (balance < -64) balance = -64;

            var tltable: Array<Int> = SiOPMTable.instance().eg_lv2tlTable;
            channelParam.operatorParam[0].tl = tltable[64-balance];
            channelParam.operatorParam[1].tl = tltable[balance+64];
            
            channelParam.operatorParam[0].detune = 0;
            channelParam.operatorParam[1].detune = vco2pitch;
            
            chipType = "AnalogLike";
            
            return this;
        }
        
        
        
        
    
    
        
        public function setEnvelop(ar:Int, dr:Int, sr:Int, rr:Int, sl:Int, tl:Int) : SiONVoice
        {
           var i:Int=0;
 while( i<4){
                var opp:SiOPMOperatorParam = channelParam.operatorParam[i];
                opp.ar = ar;
                opp.dr = dr;
                opp.sr = sr;
                opp.rr = rr;
                opp.sl = sl;
                opp.tl = tl;
             i++;
}
            return this;
        }
        
        
        
        public function setFilterEnvelop(filterType:Int=0, cutoff:Int=128, resonance:Int=0, far:Int=0, fdr1:Int=0, fdr2:Int=0, frr:Int=0, fdc1:Int=128, fdc2:Int=64, fsc:Int=32, frc:Int=128) : SiONVoice 
        {
            channelParam.filterType = filterType;
            channelParam.cutoff = cutoff;
            channelParam.resonance = resonance;
            channelParam.far = far;
            channelParam.fdr1 = fdr1;
            channelParam.fdr2 = fdr2;
            channelParam.frr = frr;
            channelParam.fdc1 = fdc1;
            channelParam.fdc2 = fdc2;
            channelParam.fsc = fsc;
            channelParam.frc = frc;
            return this;
        }
        
        
        
        public function setLPFEnvelop(cutoff:Int=128, resonance:Int=0, far:Int=0, fdr1:Int=0, fdr2:Int=0, frr:Int=0, fdc1:Int=128, fdc2:Int=64, fsc:Int=32, frc:Int=128) : SiONVoice 
        {
            return setFilterEnvelop(0, cutoff, resonance, far, fdr1, fdr2, frr, fdc1, fdc2, fsc, frc);
        }
        
        
        
        public function setAmplitudeModulation(depth:Int=0, end_depth:Int=0, delay:Int=0, term:Int=0) : SiONVoice 
        {
            channelParam.amd = amDepth = depth;
            amDepthEnd = end_depth;
            amDelay = delay;
            amTerm = term;
            return this;
        }
        
        
        
        public function setPitchModulation(depth:Int=0, end_depth:Int=0, delay:Int=0, term:Int=0) : SiONVoice 
        {
            channelParam.pmd = pmDepth = depth;
            pmDepthEnd = end_depth;
            pmDelay = delay;
            pmTerm = term;
            return this;
        }
    }



