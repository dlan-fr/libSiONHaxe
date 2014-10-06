





package org.si.sion.utils ;
	import flash.display.DisplayObjectContainer;
    import org.si.sion.SiONVoice;
    //import org.si.sion.module.*;
    //import org.si.sion.sequencer.*;
    import org.si.sion.effector.SiEffectModule;
    import org.si.sion.effector.SiEffectBase;
    import org.si.utils.SLLint;
	import flash.utils.RegExp;
	import flash.errors.Error;
	import org.si.sion.module.SiOPMChannelParam;
	import org.si.sion.module.SiOPMWaveSamplerTable;
	import org.si.sion.module.SiOPMWavePCMTable;
    import org.si.sion.sequencer.SiMMLVoice;
    import org.si.sion.sequencer.SiMMLEnvelopTable;
	import org.si.sion.module.SiOPMOperatorParam;
	import org.si.sion.sequencer.SiMMLTable;
	import org.si.sion.module.SiOPMTable;
	import org.si.sion.module.SiOPMWaveSamplerData;
	import org.si.sion.module.SiOPMWavePCMData;
    
    class Translator
    {
        
        function Translator()
        {
        }
        
        
        
        
    
    
        
        static public function mckc(mckcMML:String) : String
        {
            
            throw new Error("This is not implemented");
            return mckcMML;
        }
        
        
        
        
    
    
        
        static public function flmml(flMML:String) : String
        {
            
            throw new Error("This is not implemented");
            return flMML;
        }
        
        
        
        
    
    
        
        static public function tsscp(tsscpMML:String, volumeByX:Bool=true) : String
        {
            var mml:String, com:String, str1:String, str2:String, i:Int, imax:Int, volUp:String, volDw:String, rex:RegExp, rex_sys:RegExp, rex_com:RegExp, res:Dynamic;
            
        
        
            var noteLetters:String = "cdefgab";
            var noteShift:Array<Dynamic>  = [0,2,4,5,7,9,11];
            var panTable:Array<Dynamic> = ["@v0","p0","p8","p4"];
            var table:SiMMLTable = SiMMLTable.instance();
            var charCodeA:Int = "a".charCodeAt(0);
            var charCodeG:Int = "g".charCodeAt(0);
            var charCodeR:Int = "r".charCodeAt(0);
            var hex:String = "0123456789abcdef";
            var p0:Int, p1:Int, p2:Int, p3:Int, p4:Int, reql8:Bool, octave:Int, revOct:Bool, 
                loopOct:Int, loopMacro:Bool, loopMMLBefore:String, loopMMLContent:String;

            rex  = new RegExp("(;|(/:|:/|ml|mp|na|ns|nt|ph|@kr|@ks|@ml|@ns|@apn|@[fkimopqsv]?|[klopqrstvx$%<>(){}[\\]|_~^/&*]|[a-g][#+\\-]?)\\s*([\\-\\d]*)[,\\s]*([\\-\\d]+)?[,\\s]*([\\-\\d]+)?[,\\s]*([\\-\\d]+)?[,\\s]*([\\-\\d]+)?)|#(FM|[A-Z]+)=?\\s*([^;]*)|([A-Z])(\\(([a-g])([\\-+#]?)\\))?|.", "gms");
            rex_sys = new RegExp("\\s*([0-9]*)[,=<\\s]*([^>]*)","ms");
            rex_com = new RegExp("[{}]","gms");

            volUp = "(";
            volDw = ")";
            mml = "";
            reql8 = true;
            octave = 5;
            revOct = false;
            loopOct = -1;
            loopMacro = false;
            loopMMLBefore = null;
            loopMMLContent = null;
            res = rex.exec(tsscpMML);
            while (res) {
                if (res[1] != null) {
                    if (res[1] == ';') {
                        mml += res[0];
                        reql8 = true;
                    } else {
                        
                        i = res[2].charCodeAt(0);
                        if ((charCodeA <= i && i <= charCodeG) || i == charCodeR) {
                            if (reql8) mml += "l8" + res[0];
                            else       mml += res[0];
                            reql8 = false;
                        } else {
                            switch (res[2]) {
                                case 'l':   { mml += res[0]; reql8 = false; }break;
                                case '/:':  { mml += "[" + res[3]; }break;
                                case ':/':  { mml += "]"; }break;
                                case '/':   { mml += "|"; }break;
                                case '~':   { mml += volUp + res[3]; }break;
                                case '_':   { mml += volDw + res[3]; }break;
                                case 'q':   { mml += "q" + Std.string((Std.int (res[3])+1)>>1); }break;
                                case '@m':  { mml += "@mask" + Std.string(Std.int (res[3])); }break;
                                case 'ml':  { mml += "@ml" + Std.string(Std.int (res[3])); }break;
                                case 'p':   { mml += panTable[Std.int(res[3])&3]; }break;
                                case '@p':  { mml += "@p" + Std.string(Std.int (res[3])-64); }break;
                                case 'ph':  { mml += "@ph" + Std.string(Std.int (res[3])); }break;
                                case 'ns':  { mml += "kt"  + res[3]; }break;
                                case '@ns': { mml += "!@ns" + res[3]; }break;
                                case 'k':   { p0 = Std.int(cast(res[3],Float) * 4);     mml += "k"  + Std.string(p0); }break;
                                case '@k':  { p0 = Std.int(cast(res[3],Float) * 0.768); mml += "k"  + Std.string(p0); }break;
                                case '@kr': { p0 = Std.int(cast(res[3],Float) * 0.768); mml += "!@kr" + Std.string(p0); }break;
                                case '@ks': { mml += "@,,,,,,," + Std.string(Std.int (res[3]) >> 5); }break;
                                case 'na':  { mml += "!" + res[0]; }break;
                                case 'o':   { mml += res[0]; octave = Std.int(res[3]); }break;
                                case '<':   { mml += res[0]; octave += (revOct) ? -1 :  1; }break;
                                case '>':   { mml += res[0]; octave += (revOct) ?  1 : -1; }break;
                                case '%':   { mml += (res[3] == '6') ? '%4' : res[0]; }break;
                                
                                case '@ml': { 
                                    p0 = Std.int(res[3])>>7;
                                    p1 = Std.int(res[3]) - (p0<<7);
                                    mml += "@ml" + Std.string(p0) + "," + Std.string(p1);
                                }break;
                                case 'mp': {
                                    p0 = Std.int(res[3]); p1 = Std.int(res[4]); p2 = Std.int(res[5]); p3 = Std.int(res[6]); p4 = Std.int(res[7]);
                                    if (p3 == 0) p3 = 1;
                                    switch(p0) {
                                    case 0:  mml += "mp0"; break;
                                    case 1:  mml += "@lfo" + Std.string((Std.int (p1/p3)+1)*4*p2) + "mp" + Std.string(p1);   break;
                                    default: mml += "@lfo" + Std.string((Std.int (p1/p3)+1)*4*p2) + "mp0," + Std.string(p1) + "," + Std.string(p0);   break;
                                    }
                                }break;
                                case 'v': {
                                    if (volumeByX) {
                                        p0 = (res[3].length == 0) ? 40 : ((Std.int (res[3])<<2)+(Std.int (res[3])>>2));
                                        if (res[4]) {
                                            p1 = (Std.int (res[4])<<2) + (Std.int (res[4])>>2);
                                            p2 = (p1 > 0) ? (Std.int (Math.atan(p0/p1)*81.48733086305041)) : 128; 
                                            p3 = (p0 > p1) ? p0 : p1;
                                            mml += "@p" + Std.string(p2) + "x" + Std.string(p3);
                                        } else {
                                            mml += "x" + Std.string(p0);
                                        }
                                    } else {
                                        p0 = (res[3].length == 0) ? 10 : (res[3]);
                                        if (res[4]) {
                                            p1 = res[4];
                                            p2 = (p1 > 0) ? (Std.int (Math.atan(p0/p1)*81.48733086305041)) : 128; 
                                            p3 = (p0 > p1) ? p0 : p1;
                                            mml += "@p" + Std.string(p2) + "v" + Std.string(p3);
                                        } else {
                                            mml += "v" + Std.string(p0);
                                        }
                                    }
                                }break;
                                case '@v': {
                                    if (volumeByX) {
                                        p0 = (res[3].length == 0) ? 40 : (Std.int (res[3])>>2);
                                        if (res[4]) {
                                            p1 = Std.int(res[4])>>2;
                                            p2 = (p1 > 0) ? (Std.int (Math.atan(p0/p1)*81.48733086305041)) : 128; 
                                            p3 = (p0 > p1) ? p0 : p1;
                                            mml += "@p" + Std.string(p2) + "x" + Std.string(p3);
                                        } else {
                                            mml += "x" + Std.string(p0);
                                        }
                                    } else {
                                        p0 = (res[3].length == 0) ? 10 : (Std.int (res[3])>>4);
                                        if (res[4]) {
                                            p1 = Std.int(res[4])>>4;
                                            p2 = (p1 > 0) ? (Std.int (Math.atan(p0/p1)*81.48733086305041)) : 128; 
                                            p3 = (p0 > p1) ? p0 : p1;
                                            mml += "@p" + Std.string(p2) + "v" + Std.string(p3);
                                        } else {
                                            mml += "v" + Std.string(p0);
                                        }
                                    }
                                }break;
                                case 's': {
                                    p0 = Std.int(res[3]); p1 = Std.int(res[4]);
                                    mml += "s" + table.tss_s2rr[p0&255];
                                    if (p1!=0) mml += ","  + Std.string(p1*3);
                                }break;
                                case '@s': {
                                    p0 = Std.int(res[3]); p1 = Std.int(res[4]); p3 = Std.int(res[6]);
                                    p2 = (Std.int (res[5]) >= 100) ? 15 : Std.int(Std.parseFloat(res[5])*0.09);
                                    mml += (p0 == 0) ? "@,63,0,0,,0" : (
                                        "@," + table.tss_s2ar[p0&255] + ","  + table.tss_s2dr[p1&255] + "," + table.tss_s2sr[p3&255] + ",," + Std.string(p2)
                                    );
                                }break;
                                case '{': {
                                    i = 1;
                                    p0 = res.index + 1;
                                    rex_com.lastIndex = p0;
                                    do {
                                        res = rex_com.exec(tsscpMML);
                                            if (res == null) throw errorTranslation("{{...} ?");
                                        if (res[0] == '{') i++;
                                        else if (res[0] == '}') --i;
                                    } while (i != 0);
                                    mml += "";
                                    rex.lastIndex = res.index + 1;
                                }break;
                                    
                                case '[': { 
                                    if (loopMMLBefore != null) errorTranslation("[[...] ?");
                                    loopMacro = false;
                                    loopMMLBefore = mml;
                                    loopMMLContent = null;
                                    mml = res[3];
                                    loopOct = octave;
                                }break;
                                case '|': {
                                    if (loopMMLBefore == null) errorTranslation("'|' can be only in '[...]'");
                                    loopMMLContent = mml; 
                                    mml = "";
                                }break;
                                case ']': {
                                    if (loopMMLBefore == null) errorTranslation("[...]] ?");
                                    if (!loopMacro && loopOct==octave) {
                                        if (loopMMLContent != null)  mml = loopMMLBefore + "[" + loopMMLContent + "|" + mml + "]";
                                        else                 mml = loopMMLBefore + "[" + mml + "]";
                                    } else {
                                        if (loopMMLContent != null)  mml = loopMMLBefore + "![" + loopMMLContent + "!|" + mml + "!]";
                                        else                 mml = loopMMLBefore + "![" + mml + "!]";
                                    }
                                    loopMMLBefore = null;
                                    loopMMLContent = null;
                                }break;

                                case '}': 
                                    throw errorTranslation("{...}} ?");
                                case '@apn': case 'x':
                                    break;
                                
                                default: {
                                    mml += res[0];
                                }break;
                            }
                        }
                    }
                } else 
                
                if (res[10] != null) {
                    
                    if (reql8) mml += "l8" + res[10];
                    else       mml += res[10];
                    reql8 = false;
                    loopMacro = true;
                    if (res[11] != null) {
                        
                        i = noteShift[noteLetters.indexOf(res[12])];
                        if (res[13] == '+' || res[13] == '#') i++;
                        else if (res[13] == '-') i--;
                        mml += "(" + Std.string(i) + ")";
                    }
                } else 
                
                if (res[8] != null) {
                    
                    str1 = res[8];
                    switch (str1) {
                        case 'END':    { mml += "#END"; }
                        case 'OCTAVE': { 
                            if (res[9] == 'REVERSE') {
                                mml += "#REV{octave}"; 
                                revOct = true;
                            }
                        }
                        case 'OCTAVEREVERSE': { 
                            mml += "#REV{octave}"; 
                            revOct = true;
                        }
                        case 'VOLUME': {
                            if (res[9] == 'REVERSE') {
                                volUp = ")";
                                volDw = "(";
                                mml += "#REV{volume}";
                            }
                        }
                        case 'VOLUMEREVERSE': {
                            volUp = ")";
                            volDw = "(";
                            mml += "#REV{volume}";
                        }
                        
                        case 'TABLE': {
                            res = rex_sys.exec(res[9]);
                            mml += "#TABLE" + res[1] + "{" + res[2] + "}*0.25";
                        }
                        
                        case 'WAVB': {
                            res = rex_sys.exec(res[9]);
                            str1 = Std.string(res[2]);
                            mml += "#WAVB" + res[1] + "{";
                           i=0;
 while( i<32){
                                p0 = Std.int(Std.parseFloat("0x" + str1.substr(i<<1, 2)));
                                p0 = (p0<128) ? (p0+127) : (p0-128);
                                mml += hex.charAt(p0>>4) + hex.charAt(p0&15);
                             i++;
}
                            mml += "}";
                        }
                        
                        case 'FM': {
							//HAXE PORT: since haxe is not able to have a proper map / replace function, this code is impossible to port as is
							/*var regexx:EReg = ~/([A-Z])([0-9])?(\\()?/g;
							
							var tmpStr:String = "#FM{" + Std.string(res[9]) + "}" ;
							
							
							mml += regexx.map(tmpStr,function(params:EReg) : String {
								
                                    var num:Int = (params[2]) ? (Std.int (params[2])) : 3;
                                    var str:String = (params[3]) ? (Std.string(num) + "(") : "";
                                    return Std.string(params[1]).toLowerCase() + str;
                                });*/
                                
                        }
						
                        
                        case 'MML','FINENESS':
                            
                            res = rex.exec(tsscpMML);
                            
                        default: {
                            if (str1.length == 1) {
                                
                                mml += "#" + str1 + "=";
                                rex.lastIndex -= cast res[9].length;
                                reql8 = false;
                            } else {
                                
                                res = rex_sys.exec(res[9]);
                                if (res[2].length == 0) return "#" + str1 + res[1];
                                mml += "#" + str1 + res[1] + "{" + res[2] + "}";
                            }
                        }
                    }
                } else 
                
                {
                    mml += res[0];
                }
                res = rex.exec(tsscpMML);
            }
            tsscpMML = mml;
            
            return tsscpMML;
        }
        
        
        
        
    
    
    
    
        
        static public function parseEffectorMML(mml:String, postfix:String="") : Array<Dynamic>
        {
            var ret:Array<Dynamic>, res:Dynamic, rex:RegExp = new RegExp("([a-zA-Z_]+|,)\\s*([.\\-\\d]+)?","g") , i:Int,
                cmd:String = "", argc:Int = 0, args: Array<Float> = new Array<Float>();
            
            
            ret = [];
			
			
			var _connectEffect:Dynamic =  function() : Void {
                if (argc == 0) return;
                var e:SiEffectBase = SiEffectModule.getInstance(cmd);
                if (e != null) {
                    e.mmlCallback(args);
                    ret.push(e);
                }
            }
            
            
            var _clearArgs:Dynamic = function () : Void {
               var i:Int=0;
 while( i<16){ args[i]=Math.NaN; i++;
}
            }
			
            _clearArgs();
            
            
            res = rex.exec(mml);
            while (res) {
                if (res[1] == ",") {
                    args[argc++] = Std.parseFloat(res[2]);
                } else {
                    _connectEffect();
                    cmd = res[1];
                    _clearArgs();
                    args[0] = Std.parseFloat(res[2]);
                    argc = 1;
                }
                res = rex.exec(mml);
            }
            _connectEffect();
            
            return ret;
            
            
           
        }
        
        
        
        
    
    
    
    
        
        static public function parseParam(param:SiOPMChannelParam, dataString:String) : SiOPMChannelParam {
            return _setParamByArray(param, _splitDataString(param, dataString, 3, 15, "#@"));
        }
        
        
        
        static public function parseOPLParam(param:SiOPMChannelParam, dataString:String) : SiOPMChannelParam {
            return _setOPLParamByArray(param, _splitDataString(param, dataString, 2, 11, "#OPL@"));
        }
        
        
        
        static public function parseOPMParam(param:SiOPMChannelParam, dataString:String) : SiOPMChannelParam {
            return _setOPMParamByArray(param, _splitDataString(param, dataString, 2, 11, "#OPM@"));
        }
        
        
        
        static public function parseOPNParam(param:SiOPMChannelParam, dataString:String) : SiOPMChannelParam {
            return _setOPNParamByArray(param, _splitDataString(param, dataString, 2, 10, "#OPN@"));
        }
        
        
        
        static public function parseOPXParam(param:SiOPMChannelParam, dataString:String) : SiOPMChannelParam {
            return _setOPXParamByArray(param, _splitDataString(param, dataString, 2, 12, "#OPX@"));
        }
        
        
        
        static public function parseMA3Param(param:SiOPMChannelParam, dataString:String) : SiOPMChannelParam {
            return _setMA3ParamByArray(param, _splitDataString(param, dataString, 2, 12, "#MA@"));
        }
        
        
        static public function parseALParam(param:SiOPMChannelParam, dataString:String) : SiOPMChannelParam {
            return _setALParamByArray(param, _splitDataString(param, dataString, 9, 0, "#AL@"));
        }
        
        
        
        
    
    
        
        static public function setParam(param:SiOPMChannelParam, data:Array<Dynamic>) : SiOPMChannelParam {
            return _setParamByArray(_checkOpeCount(param, data.length, 3, 15, "#@"), data);
        }
        
        
        
        static public function setOPLParam(param:SiOPMChannelParam, data:Array<Dynamic>) : SiOPMChannelParam {
            return _setOPLParamByArray(_checkOpeCount(param, data.length, 2, 11, "#OPL@"), data);
        }
        
        
        
        static public function setOPMParam(param:SiOPMChannelParam, data:Array<Dynamic>) : SiOPMChannelParam {
            return _setOPMParamByArray(_checkOpeCount(param, data.length, 2, 11, "#OPM@"), data);
        }
        
        
        
        static public function setOPNParam(param:SiOPMChannelParam, data:Array<Dynamic>) : SiOPMChannelParam {
            return _setOPNParamByArray(_checkOpeCount(param, data.length, 2, 10, "#OPN@"), data);
        }
        
        
        
        static public function setOPXParam(param:SiOPMChannelParam, data:Array<Dynamic>) : SiOPMChannelParam {
            return _setOPXParamByArray(_checkOpeCount(param, data.length, 2, 12, "#OPX@"), data);
        }
        
        
        
        static public function setMA3Param(param:SiOPMChannelParam, data:Array<Dynamic>) : SiOPMChannelParam {
            return _setMA3ParamByArray(_checkOpeCount(param, data.length, 2, 12, "#MA@"), data);
        }
        
        
        static public function setALParam(param:SiOPMChannelParam, data:Array<Dynamic>) : SiOPMChannelParam {
            if (data.length != 9) throw errorToneParameterNotValid("#AL@", 9, 0);
            return _setALParamByArray(param, data);
        }
        
        
        
        
        
        
    
    
        
        static private function _splitDataString(param:SiOPMChannelParam, dataString:String, chParamCount:Int, opParamCount:Int, cmd:String) : Array<Dynamic>
        {
            var data:Array<Dynamic>, i:Int;
            
            
            if (dataString == "") {
                param.opeCount = 0;
            } else {
				var comrex:EReg = new EReg("/\\*.*?\\*/|//.*?[\\r\\n]+", "gms");
				dataString = comrex.replace(dataString, "");
				var comrex2:EReg = ~/^[^\d\-.]+|[^\d\-.]+$/g;	
				dataString = comrex2.replace(dataString, "");
				var comrex3:EReg = ~/[^\d\-.]+/gm;
			
				data = comrex3.split(dataString);
				
				
               i=1;
 while( i<5){
                    if (data.length == chParamCount + opParamCount*i) {
                        param.opeCount = i;
                        return data;
                    }
                 i++;
}
                throw errorToneParameterNotValid(cmd, chParamCount, opParamCount);
            }
            return null;
        }
        
        
        
        static private function _checkOpeCount(param:SiOPMChannelParam, dataLength:Int, chParamCount:Int, opParamCount:Int, cmd:String) : SiOPMChannelParam
        {
            var opeCount:Int = Std.int((dataLength - chParamCount) / opParamCount);
            if (opeCount > 4 || opeCount*opParamCount+chParamCount != dataLength) throw errorToneParameterNotValid(cmd, chParamCount, opParamCount);
            param.opeCount = opeCount;
            return param;
        }
        
        
        
        
        
        static private function _setParamByArray(param:SiOPMChannelParam, data:Array<Dynamic>) : SiOPMChannelParam
        {
            if (param.opeCount == 0) return param;
            
            param.alg = Std.int(data[0]);
            param.fb  = Std.int(data[1]);
            param.fbc = Std.int(data[2]);
            var dataIndex:Int = 3, n:Float, i:Int;
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                opp.setPGType(Std.int (data[dataIndex++]) & 511); 
                opp.ar     = Std.int(data[dataIndex++]) & 63;   
                opp.dr     = Std.int(data[dataIndex++]) & 63;   
                opp.sr     = Std.int(data[dataIndex++]) & 63;   
                opp.rr     = Std.int(data[dataIndex++]) & 63;   
                opp.sl     = Std.int(data[dataIndex++]) & 15;   
                opp.tl     = Std.int(data[dataIndex++]) & 127;  
                opp.ksr    = Std.int(data[dataIndex++]) & 3;    
                opp.ksl    = Std.int(data[dataIndex++]) & 3;    
                n = Std.parseFloat(data[dataIndex++]);
                opp.fmul   = (n==0) ? 64 : Std.int(n*128);      
                opp.dt1    = Std.int(data[dataIndex++]) & 7;    
                opp.detune = Std.int(data[dataIndex++]);        
                opp.ams    = Std.int(data[dataIndex++]) & 3;    
                i = Std.int(data[dataIndex++]);
                opp.phase  = (i==-1) ? i : (i & 255);           
                opp.fixedPitch = (Std.int (data[dataIndex++]) & 127)<<6;  
             opeIndex++;
}
            return param;
        }
        
        
        
        
        
        static private function _setOPLParamByArray(param:SiOPMChannelParam, data:Array<Dynamic>) : SiOPMChannelParam
        {
            if (param.opeCount == 0) return param;
            
            var alg:Int = SiMMLTable.instance().alg_opl[param.opeCount-1][Std.int(data[0])&15];
            if (alg == -1) throw errorParameterNotValid("#OPL@ algorism", data[0]);
            
            param.fratio = 133;
            param.alg = alg;
            param.fb  = Std.int(data[1]);
            var dataIndex:Int = 2, i:Int;
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                opp.setPGType(SiOPMTable.PG_MA3_WAVE + (Std.int (data[dataIndex++])&31));    
                opp.ar  = (Std.int (data[dataIndex++]) << 2) & 63;   
                opp.dr  = (Std.int (data[dataIndex++]) << 2) & 63;   
                opp.rr  = (Std.int (data[dataIndex++]) << 2) & 63;   
                
                opp.sr  = (Std.int (data[dataIndex++]) != 0) ? 0 : opp.rr;
                opp.sl  = Std.int(data[dataIndex++]) & 15;          
                opp.tl  = Std.int(data[dataIndex++]) & 63;          
                opp.ksr = (Std.int (data[dataIndex++])<<1) & 3;      
                opp.ksl = Std.int(data[dataIndex++]) & 3;           
                i = Std.int(data[dataIndex++]) & 15;                
                opp.mul((i==11 || i==13) ? (i-1) : (i==14) ? (i+1) : i);
                opp.ams = Std.int(data[dataIndex++]) & 3;           
                
             opeIndex++;
}
            return param;
        }
        
        
        
        
        
        static private function _setOPMParamByArray(param:SiOPMChannelParam, data:Array<Dynamic>) : SiOPMChannelParam
        {
            if (param.opeCount == 0) return param;
            
            var alg:Int = SiMMLTable.instance().alg_opm[param.opeCount-1][Std.int(data[0])&15];
            if (alg == -1) throw errorParameterNotValid("#OPN@ algorism", data[0]);

            param.alg = alg;
            param.fb  = Std.int(data[1]);
            var dataIndex:Int = 2;
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                opp.ar  = (Std.int (data[dataIndex++]) << 1) & 63;       
                opp.dr  = (Std.int (data[dataIndex++]) << 1) & 63;       
                opp.sr  = (Std.int (data[dataIndex++]) << 1) & 63;       
                opp.rr  = ((Std.int (data[dataIndex++]) << 2) + 2) & 63; 
                opp.sl  = Std.int(data[dataIndex++]) & 15;              
                opp.tl  = Std.int(data[dataIndex++]) & 127;             
                opp.ksr = Std.int(data[dataIndex++]) & 3;               
                opp.mul(Std.int(data[dataIndex++]) & 15);              
                opp.dt1 = Std.int(data[dataIndex++]) & 7;               
                opp.detune = SiOPMTable.instance().dt2Table[data[dataIndex++] & 3];    
                opp.ams = Std.int(data[dataIndex++]) & 3;               
             opeIndex++;
}
            return param;
        }
        
        
        
        
        
        static private function _setOPNParamByArray(param:SiOPMChannelParam, data:Array<Dynamic>) : SiOPMChannelParam
        {
            if (param.opeCount == 0) return param;
            
            var alg:Int = SiMMLTable.instance().alg_opm[param.opeCount-1][Std.int(data[0])&15];
            if (alg == -1) throw errorParameterNotValid("#OPN@ algorism", data[0]);

            param.alg = alg;
            param.fb  = Std.int(data[1]);
            var dataIndex:Int = 2;
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                opp.ar  = (Std.int (data[dataIndex++]) << 1) & 63;       
                opp.dr  = (Std.int (data[dataIndex++]) << 1) & 63;       
                opp.sr  = (Std.int (data[dataIndex++]) << 1) & 63;       
                opp.rr  = ((Std.int (data[dataIndex++]) << 2) + 2) & 63; 
                opp.sl  = Std.int(data[dataIndex++]) & 15;              
                opp.tl  = Std.int(data[dataIndex++]) & 127;             
                opp.ksr = Std.int(data[dataIndex++]) & 3;               
                opp.mul(Std.int(data[dataIndex++]) & 15);              
                opp.dt1 = Std.int(data[dataIndex++]) & 7;               
                opp.ams = Std.int(data[dataIndex++]) & 3;               
             opeIndex++;
}
            return param;
        }
        
        
        
        
        
        static private function _setOPXParamByArray(param:SiOPMChannelParam, data:Array<Dynamic>) : SiOPMChannelParam
        {
            if (param.opeCount == 0) return param;
            
            var alg:Int = SiMMLTable.instance().alg_opx[param.opeCount-1][Std.int(data[0])&15];
            if (alg == -1) throw errorParameterNotValid("#OPX@ algorism", data[0]);
            
            param.alg = (alg & 15);
            param.fb  = Std.int(data[1]);
            param.fbc = ((alg & 16) != 0) ? 1 : 0;
            var dataIndex:Int = 2, i:Int;
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                i = Std.int(data[dataIndex++]);
                opp.setPGType((i<7) ? (SiOPMTable.PG_MA3_WAVE+(i&7)) : (SiOPMTable.PG_CUSTOM+(i-7)));    
                opp.ar  = (Std.int (data[dataIndex++]) << 1) & 63;       
                opp.dr  = (Std.int (data[dataIndex++]) << 1) & 63;       
                opp.sr  = (Std.int (data[dataIndex++]) << 1) & 63;       
                opp.rr  = ((Std.int (data[dataIndex++]) << 2) + 2) & 63; 
                opp.sl  = Std.int(data[dataIndex++]) & 15;              
                opp.tl  = Std.int(data[dataIndex++]) & 127;             
                opp.ksr = Std.int(data[dataIndex++]) & 3;               
                opp.mul(Std.int(data[dataIndex++]) & 15);              
                opp.dt1 = Std.int(data[dataIndex++]) & 7;               
                opp.detune = Std.int(data[dataIndex++]);                
                opp.ams = Std.int(data[dataIndex++]) & 3;               
             opeIndex++;
}
            return param;
        }
        
        
        
        
        
        static private function _setMA3ParamByArray(param:SiOPMChannelParam, data:Array<Dynamic>) : SiOPMChannelParam
        {
            if (param.opeCount == 0) return param;
            
            var alg:Int = SiMMLTable.instance().alg_ma3[param.opeCount-1][Std.int(data[0])&15];
            if (alg == -1) throw errorParameterNotValid("#MA@ algorism", data[0]);
            
            param.fratio = 133;
            param.alg = alg;
            param.fb  = Std.int(data[1]);
            var dataIndex:Int = 2, i:Int;
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                opp.setPGType(SiOPMTable.PG_MA3_WAVE + (Std.int (data[dataIndex++]) & 31)); 
                opp.ar  = (Std.int (data[dataIndex++]) << 2) & 63;   
                opp.dr  = (Std.int (data[dataIndex++]) << 2) & 63;   
                opp.sr  = (Std.int (data[dataIndex++]) << 2) & 63;   
                opp.rr  = (Std.int (data[dataIndex++]) << 2) & 63;   
                opp.sl  = Std.int(data[dataIndex++]) & 15;          
                opp.tl  = Std.int(data[dataIndex++]) & 63;          
                opp.ksr = (Std.int (data[dataIndex++])<<1) & 3;      
                opp.ksl = Std.int(data[dataIndex++]) & 3;           
                i = Std.int(data[dataIndex++]) & 15;                
                opp.mul((i==11 || i==13) ? (i-1) : (i==14) ? (i+1) : i);
                opp.dt1 = Std.int(data[dataIndex++]) & 7;           
                opp.ams = Std.int(data[dataIndex++]) & 3;           
             opeIndex++;
}
            return param;
        }
        

        
        
        
        static private function _setALParamByArray(param:SiOPMChannelParam, data:Array<Dynamic>) : SiOPMChannelParam
        {
            var opp0:SiOPMOperatorParam = param.operatorParam[0],
                opp1:SiOPMOperatorParam = param.operatorParam[1],
                tltable: Array<Int> = SiOPMTable.instance().eg_lv2tlTable,
                connectionType:Int = Std.int(data[0]), 
                balance:Int = Std.int(data[3]);
            param.opeCount = 5;
            param.alg = (connectionType>=0 && connectionType<=2) ? connectionType : 0;
            opp0.setPGType(Std.int (data[1]));
            opp1.setPGType(Std.int (data[2]));
            if (balance > 64) balance = 64;
            else if (balance < -64) balance = -64;
            opp0.tl = tltable[64-balance];
            opp1.tl = tltable[balance+64];
            opp0.detune = 0;
            opp1.detune = data[4];
            
            opp0.ar = (Std.int (data[5])) & 63;
            opp0.dr = (Std.int (data[6])) & 63;
            opp0.sr = 0;
            opp0.rr = (Std.int (data[8])) & 15;
            opp0.sl = (Std.int (data[7])) & 63;
            
            return param;
        }
        
        
        
        
    
    
        
        static public function getParam(param:SiOPMChannelParam) : Array<Dynamic> {
            if (param.opeCount == 0) return null;
            var res:Array<Dynamic> = [param.alg, param.fb, param.fbc];
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
				
                res = res.concat([opp.pgType, opp.ar, opp.dr, opp.sr, opp.rr, opp.sl, opp.tl, opp.ksr, opp.ksl, opp.get_mul(), opp.dt1, opp.detune, opp.ams, opp.phase, opp.fixedPitch>>6]);
             opeIndex++;
}
            return res;
        }
        
        
        
        static public function getOPLParam(param:SiOPMChannelParam) : Array<Dynamic> {
            if (param.opeCount == 0) return null;
            var alg:Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance().alg_opl);
            if (alg == -1) throw errorParameterNotValid("#OPL@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
            var res:Array<Dynamic> = [alg, param.fb];
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex],
                    ws :Int = _pgTypeMA3(opp.pgType),
                    egt:Int = (opp.sr == 0) ? 1 : 0,
                    tl :Int = (opp.tl < 63) ? opp.tl : 63;
                if (ws == -1) throw errorParameterNotValid("#OPL@", "SiOPM ws" + Std.string(opp.pgType));
                res = res.concat([ws, opp.ar>>2, opp.dr>>2, opp.rr>>2, egt, opp.sl, tl, opp.ksr>>1, opp.ksl, opp.get_mul(), opp.ams]);
             opeIndex++;
}
            return res;
        }
        
        
        
        static public function getOPMParam(param:SiOPMChannelParam) : Array<Dynamic> {
            if (param.opeCount == 0) return null;
            var alg:Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance().alg_opm);
            if (alg == -1) throw errorParameterNotValid("#OPM@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
            var res:Array<Dynamic> = [alg, param.fb];
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex],
                    dt2:Int = _dt2OPM(opp.detune);
                res = res.concat([opp.ar>>1, opp.dr>>1, opp.sr>>1, opp.rr>>2, opp.sl, opp.tl, opp.ksr, opp.get_mul(), opp.dt1, dt2, opp.ams]);
             opeIndex++;
}
            return res;
        }
        
        
        
        static public function getOPNParam(param:SiOPMChannelParam) : Array<Dynamic> {
            if (param.opeCount == 0) return null;
            var alg:Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance().alg_opm);
            if (alg == -1) throw errorParameterNotValid("#OPN@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
            var res:Array<Dynamic> = [alg, param.fb];
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                res = res.concat([opp.ar>>1, opp.dr>>1, opp.sr>>1, opp.rr>>2, opp.sl, opp.tl, opp.ksr, opp.get_mul(), opp.dt1, opp.ams]);
             opeIndex++;
}
            return res;
        }
        
        
        
        static public function getOPXParam(param:SiOPMChannelParam) : Array<Dynamic> {
            if (param.opeCount == 0) return null;
            var alg:Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance().alg_opx);
            if (alg == -1) throw errorParameterNotValid("#OPX@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
            var res:Array<Dynamic> = [alg, param.fb];
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex],
                    ws :Int = _pgTypeMA3(opp.pgType);
                if (ws == -1) throw errorParameterNotValid("#OPX@", "SiOPM ws" + Std.string(opp.pgType));
                res = res.concat([ws, opp.ar>>1, opp.dr>>1, opp.sr>>1, opp.rr>>2, opp.sl, opp.tl, opp.ksr, opp.get_mul(), opp.dt1, opp.detune, opp.ams]);
             opeIndex++;
}
            return res;
        }
        
        
        
        static public function getMA3Param(param:SiOPMChannelParam) : Array<Dynamic> {
            if (param.opeCount == 0) return null;
            var alg:Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance().alg_ma3);
            if (alg == -1) throw errorParameterNotValid("#MA@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
            var res:Array<Dynamic> = [alg, param.fb];
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex],
                    ws :Int = _pgTypeMA3(opp.pgType),
                    tl :Int = (opp.tl < 63) ? opp.tl : 63;
                if (ws == -1) throw errorParameterNotValid("#MA@", "SiOPM ws" + Std.string(opp.pgType));
                res = res.concat([ws, opp.ar>>2, opp.dr>>2, opp.sr>>2, opp.rr>>2, opp.sl, tl, opp.ksr>>1, opp.ksl, opp.get_mul(), opp.dt1, opp.ams]);
             opeIndex++;
}
            return res;
        }
        
        
        
        static public function getALParam(param:SiOPMChannelParam) : Array<Dynamic> {
            if (param.opeCount != 5) return null;
            var opp0:SiOPMOperatorParam = param.operatorParam[0],
                opp1:SiOPMOperatorParam = param.operatorParam[1];
            return [param.alg, opp0.pgType, opp1.pgType, _balanceAL(opp0.tl, opp1.tl), opp1.detune, opp0.ar, opp0.dr, opp0.sl, opp0.rr];
        }
        
        
        
        
    
    
        
        static public function mmlParam(param:SiOPMChannelParam, separator:String=' ', lineEnd:String='\n', comment:String=null) : String
        {
            if (param.opeCount == 0) return "";
            
            var mml:String = "", res:Dynamic = _checkDigit(param);
            mml += "{";
            mml += Std.string(param.alg) + separator;
            mml += Std.string(param.fb)  + separator;
            mml += Std.string(param.fbc);
            if (comment != null) {
                if (lineEnd == '\n') mml += " // " + comment;
                else mml += "/* " + comment + " */";
            }
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                mml += lineEnd;
                mml += _str(opp.pgType, res.ws) + separator;
                mml += _str(opp.ar, 2) + separator;
                mml += _str(opp.dr, 2) + separator;
                mml += _str(opp.sr, 2) + separator;
                mml += _str(opp.rr, 2) + separator;
                mml += _str(opp.sl, 2) + separator;
                mml += _str(opp.tl, res.tl) + separator;
                mml += Std.string(opp.ksr) + separator;
                mml += Std.string(opp.ksl) + separator;
                mml += _str(opp.get_mul(), 2) + separator;
                mml += Std.string(opp.dt1) + separator;
                mml += _str(opp.detune, res.dt) + separator;
                mml += Std.string(opp.ams) + separator;
                mml += _str(opp.phase, res.ph) + separator;
                mml += _str(opp.fixedPitch>>6, res.fn);
             opeIndex++;
}
            mml += "}";
            
            return mml;
        }
        
        
        
        static public function mmlOPLParam(param:SiOPMChannelParam, separator:String=' ', lineEnd:String='\n', comment:String=null) : String
        {
            if (param.opeCount == 0) return "";
            
            var alg:Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance().alg_opl);
            if (alg == -1) throw errorParameterNotValid("#OPL@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
            
            var mml:String = "", res:Dynamic = _checkDigit(param);
            mml += "{" + Std.string(alg) + separator + Std.string(param.fb);
            if (comment != null) {
                if (lineEnd == '\n') mml += " // " + comment;
                else mml += "/* " + comment + " */";
            }
                
            var pgType:Int, tl:Int;
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                mml += lineEnd;
                pgType = _pgTypeMA3(opp.pgType);
                if (pgType == -1) throw errorParameterNotValid("#OPL@", "SiOPM ws" + Std.string(opp.pgType));
                mml += Std.string(pgType) + separator;              
                mml += _str(opp.ar >> 2, 2) + separator;        
                mml += _str(opp.dr >> 2, 2) + separator;        
                mml += _str(opp.rr >> 2, 2) + separator;        
                mml += ((opp.sr == 0) ? "1" : "0") + separator; 
                mml += _str(opp.sl, 2) + separator;                 
                mml += _str((opp.tl<63)?opp.tl:63, 2) + separator;  
                mml += Std.string(opp.ksr>>1) + separator;              
                mml += Std.string(opp.ksl) + separator;                 
                mml += _str(opp.get_mul(), 2) + separator;                
                mml += Std.string(opp.ams);                             
             opeIndex++;
}
            mml += "}";
            
            return mml;
        }
        
        
        
        static public function mmlOPMParam(param:SiOPMChannelParam, separator:String=' ', lineEnd:String='\n', comment:String=null) : String
        {
            if (param.opeCount == 0) return "";
            
            var alg:Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance().alg_opm);
            if (alg == -1) throw errorParameterNotValid("#OPM@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
            
            var mml:String = "", res:Dynamic = _checkDigit(param);
            mml += "{" + Std.string(alg) + separator + Std.string(param.fb);
            if (comment != null) {
                if (lineEnd == '\n') mml += " // " + comment;
                else mml += "/* " + comment + " */";
            }
                
            var pgType:Int, tl:Int;
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                mml += lineEnd;
                
                mml += _str(opp.ar >> 1, 2) + separator;        
                mml += _str(opp.dr >> 1, 2) + separator;        
                mml += _str(opp.sr >> 1, 2) + separator;        
                mml += _str(opp.rr >> 2, 2) + separator;        
                mml += _str(opp.sl, 2) + separator;             
                mml += _str(opp.tl, res.tl) + separator;        
                mml += Std.string(opp.ksl) + separator;             
                mml += _str(opp.get_mul(), 2) + separator;            
                mml += Std.string(opp.dt1) + separator;             
                mml += Std.string(_dt2OPM(opp.detune)) + separator; 
                mml += Std.string(opp.ams);                         
             opeIndex++;
}
            mml += "}";
            
            return mml;
        }
        
        
        
        static public function mmlOPNParam(param:SiOPMChannelParam, separator:String=' ', lineEnd:String='\n', comment:String=null) : String
        {
            if (param.opeCount == 0) return "";
            
            var alg:Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance().alg_opm);
            if (alg == -1) throw errorParameterNotValid("#OPN@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
            
            var mml:String = "", res:Dynamic = _checkDigit(param);
            mml += "{" + Std.string(alg) + separator + Std.string(param.fb);
            if (comment != null) {
                if (lineEnd == '\n') mml += " // " + comment;
                else mml += "/* " + comment + " */";
            }

            var pgType:Int, tl:Int;
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                mml += lineEnd;
                
                mml += _str(opp.ar >> 1, 2) + separator;    
                mml += _str(opp.dr >> 1, 2) + separator;    
                mml += _str(opp.sr >> 1, 2) + separator;    
                mml += _str(opp.rr >> 2, 2) + separator;    
                mml += _str(opp.sl, 2) + separator;         
                mml += _str(opp.tl, res.tl) + separator;    
                mml += Std.string(opp.ksl) + separator;         
                mml += _str(opp.get_mul(), 2) + separator;        
                mml += Std.string(opp.dt1) + separator;         
                mml += Std.string(opp.ams);                     
             opeIndex++;
}
            mml += "}";
            
            return mml;
        }
        
        
        
        static public function mmlOPXParam(param:SiOPMChannelParam, separator:String=' ', lineEnd:String='\n', comment:String=null) : String
        {
            if (param.opeCount == 0) return "";
            
            var alg:Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance().alg_opx);
            if (alg == -1) throw errorParameterNotValid("#OPX@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
            
            var mml:String = "", res:Dynamic = _checkDigit(param);
            mml += "{" + Std.string(alg) + separator + Std.string(param.fb);
             if (comment != null) {
                if (lineEnd == '\n') mml += " // " + comment;
                else mml += "/* " + comment + " */";
            }
            
            var pgType:Int, tl:Int;
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                mml += lineEnd;
                pgType = _pgTypeMA3(opp.pgType);
                if (pgType == -1) throw errorParameterNotValid("#OPX@", "SiOPM ws" + Std.string(opp.pgType));
                mml += Std.string(pgType) + separator;              
                mml += _str(opp.ar >> 1, 2) + separator;        
                mml += _str(opp.dr >> 1, 2) + separator;        
                mml += _str(opp.sr >> 1, 2) + separator;        
                mml += _str(opp.rr >> 2, 2) + separator;        
                mml += _str(opp.sl, 2) + separator;             
                mml += _str(opp.tl, res.tl) + separator;        
                mml += Std.string(opp.ksl) + separator;             
                mml += _str(opp.get_mul(), 2) + separator;            
                mml += Std.string(opp.dt1) + separator;             
                mml += _str(opp.detune, res.dt) + separator;    
                mml += Std.string(opp.ams);                         
             opeIndex++;
}
            mml += "}";
            
            return mml;
        }
        
        
        
        static public function mmlMA3Param(param:SiOPMChannelParam, separator:String=' ', lineEnd:String='\n', comment:String=null) : String
        {
            if (param.opeCount == 0) return "";
            
            var alg:Int = _checkAlgorism(param.opeCount, param.alg, SiMMLTable.instance().alg_ma3);
            if (alg == -1) throw errorParameterNotValid("#MA@ alg", "SiOPM opc" + Std.string(param.opeCount) + "/alg" + Std.string(param.alg));
            
            var mml:String = "", res:Dynamic = _checkDigit(param);
            mml += "{" + Std.string(alg) + separator + Std.string(param.fb);
             if (comment != null) {
                if (lineEnd == '\n') mml += " // " + comment;
                else mml += "/* " + comment + " */";
            }
            
            var pgType:Int, tl:Int;
           var opeIndex:Int=0;
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                mml += lineEnd;
                pgType = _pgTypeMA3(opp.pgType);
                if (pgType == -1) throw errorParameterNotValid("#MA@", "SiOPM ws" + Std.string(opp.pgType));
                mml += _str(pgType, 2) + separator;                 
                mml += _str(opp.ar >> 2, 2) + separator;            
                mml += _str(opp.dr >> 2, 2) + separator;            
                mml += _str(opp.sr >> 2, 2) + separator;            
                mml += _str(opp.rr >> 2, 2) + separator;            
                mml += _str(opp.sl, 2) + separator;                 
                mml += _str((opp.tl<63)?opp.tl:63, 2) + separator;  
                mml += Std.string(opp.ksr>>1) + separator;              
                mml += Std.string(opp.ksl) + separator;                 
                mml += _str(opp.get_mul(), 2) + separator;                
                mml += Std.string(opp.dt1) + separator;                 
                mml += Std.string(opp.ams);                             
             opeIndex++;
}
            mml += "}";
            
            return mml;
        }
        
        
        
        
        static public function mmlALParam(param:SiOPMChannelParam, separator:String=' ', lineEnd:String='\n', comment:String=null) : String
        {
            if (param.opeCount != 5) return null;
            
            var opp0:SiOPMOperatorParam = param.operatorParam[0],
                opp1:SiOPMOperatorParam = param.operatorParam[1],
                mml:String = "";
            mml += "{" + Std.string(param.alg) + separator;
            mml += Std.string(opp0.pgType) + separator;
            mml += Std.string(opp1.pgType) + separator;
            mml += Std.string(_balanceAL(opp0.tl, opp1.tl)) + separator;
            mml += Std.string(opp1.detune) + separator;
            if (comment != null) {
                if (lineEnd == '\n') mml += " // " + comment;
                else mml += "/* " + comment + " */";
            }
            mml += lineEnd + Std.string(opp0.ar) + separator;
            mml += Std.string(opp0.dr) + separator;
            mml += Std.string(opp0.sl) + separator;
            mml += Std.string(opp0.rr);
            mml += "}";
            
            return mml;
        }
        
        
        
        
    
    
        
        static public function extractSystemCommand(mml:String) : Array<Dynamic> 
        {
            var comrex:EReg = new EReg("/\\*.*?\\*/|//.*?[\\r\\n]+", "gms");
			
			
            var seqrex:RegExp = new RegExp("/(#[A-Z@]+)([^;{]*({.*?})?[^;]*);","gms"); //}
            var prmrex:RegExp = new RegExp("/\\s*(\\d*)\\s*(\\{(.*?)\\})?(.*)","ms");
            var res:Dynamic, res2:Dynamic, cmd:String, num:Int, dat:String, pfx:String, cmds:Array<Dynamic>=[];
            
            
            mml += "\n";
            mml = comrex.replace(mml, "") + ";";
            
            
            while (res = seqrex.exec(mml)) {
                cmd = Std.string(res[1]);
                if (res[2] != "") {
                    prmrex.lastIndex = 0;
                    res2 = prmrex.exec(res[2]);
                    num = Std.int(res2[1]);
                    dat = (res2[2] == null) ? "" : Std.string(res2[3]);
                    pfx = Std.string(res2[4]);
                } else {
                    num = 0;
                    dat = "";
                    pfx = "";
                }
                cmds.push({command:cmd, number:num, content:dat, postfix:pfx});
            }
            return cmds;
        }
        
                
        
        
        
    
    
        
        static public function parseVoiceSetting(voice:SiMMLVoice, mml:String, envelopes: Array<SiMMLEnvelopTable>=null) : SiMMLVoice {
            var i:Int, j:Int;
            var cmd:String = "(%[fvx]|@[fpqv]|@er|@lfo|kt?|m[ap]|_?@@|_?n[aptf]|po|p|q|s|x|v)";
            var ags:String = "(-?\\d*)";
           i=0;
 while( i<10){ ags += "(\\s*,\\s*(-?\\d*))?"; i++;
}
            var rex:RegExp = new RegExp(cmd+ags, "g");
            var res:Dynamic = rex.exec(mml);
            var param:SiOPMChannelParam = voice.channelParam;
            while (res) {
                switch(res[1]) {
                case '@f':
                    param.cutoff    = (res[2] != "")  ? Std.int(res[2])  : 128;
                    param.resonance = (res[4] != "")  ? Std.int(res[4])  : 0;
                    param.far       = (res[6] != "")  ? Std.int(res[6])  : 0;
                    param.fdr1      = (res[8] != "")  ? Std.int(res[8])  : 0;
                    param.fdr2      = (res[10] != "") ? Std.int(res[10]) : 0;
                    param.frr       = (res[12] != "") ? Std.int(res[12]) : 0;
                    param.fdc1      = (res[14] != "") ? Std.int(res[14]) : 128;
                    param.fdc2      = (res[16] != "") ? Std.int(res[16]) : 64;
                    param.fsc       = (res[18] != "") ? Std.int(res[18]) : 32;
                    param.frc       = (res[20] != "") ? Std.int(res[20]) : 128;
                    break;
                case '@lfo':
                    param.lfoFrame((res[2] != "") ? Std.int(res[2]) : 30);
                    param.lfoWaveShape = (res[4] != "") ? Std.int(res[4]) : SiOPMTable.LFO_WAVE_TRIANGLE;
                    break;
                case 'ma':
                    voice.amDepth    = (res[2] != "") ? Std.int(res[2]) : 0;
                    voice.amDepthEnd = (res[4] != "") ? Std.int(res[4]) : 0;
                    voice.amDelay    = (res[6] != "") ? Std.int(res[6]) : 0;
                    voice.amTerm     = (res[8] != "") ? Std.int(res[8]) : 0;
                    param.amd = voice.amDepth;
                    break;
                case 'mp':
                    voice.pmDepth    = (res[2] != "") ? Std.int(res[2]) : 0;
                    voice.pmDepthEnd = (res[4] != "") ? Std.int(res[4]) : 0;
                    voice.pmDelay    = (res[6] != "") ? Std.int(res[6]) : 0;
                    voice.pmTerm     = (res[8] != "") ? Std.int(res[8]) : 0;
                    param.pmd = voice.pmDepth;
                    break;
                case 'po':
                    voice.portament = (res[2] != "") ? Std.int(res[2]) : 30;
                    break;
                case 'q':
                    voice.defaultGateTime = (res[2] != "") ? (Std.int (res[2])*0.125) : Math.NaN;
                    break;
                case 's':
                    
                    voice.releaseSweep = (res[4] != "") ? Std.int(res[4]) : 0;
                    break;
                    
                case '%f':
                    voice.channelParam.filterType = (res[2] != "") ? Std.int(res[2]) : 0;
                    break;
                case '@er':
                   i=0;
 while( i<4){ voice.channelParam.operatorParam[i].erst = (res[2] != "1"); i++;
}
                    break;
                case 'k':
                    voice.pitchShift = (res[2] != "") ? Std.int(res[2]) : 0;
                    break;
                case 'kt':
                    voice.noteShift = (res[2] != "") ? Std.int(res[2]) : 0;
                    break;
                    
                case '@v':
                    voice.channelParam.volumes[0] = (res[2]  != "") ? (Std.int (res[2])*0.0078125)  : 0.5;
                    voice.channelParam.volumes[1] = (res[4]  != "") ? (Std.int (res[4])*0.0078125)  : 0;
                    voice.channelParam.volumes[2] = (res[6]  != "") ? (Std.int (res[6])*0.0078125)  : 0;
                    voice.channelParam.volumes[3] = (res[8]  != "") ? (Std.int (res[8])*0.0078125)  : 0;
                    voice.channelParam.volumes[4] = (res[10] != "") ? (Std.int (res[10])*0.0078125) : 0;
                    voice.channelParam.volumes[5] = (res[12] != "") ? (Std.int (res[12])*0.0078125) : 0;
                    voice.channelParam.volumes[6] = (res[14] != "") ? (Std.int (res[14])*0.0078125) : 0;
                    voice.channelParam.volumes[7] = (res[16] != "") ? (Std.int (res[16])*0.0078125) : 0;
                    break;
                case 'p':
                    voice.channelParam.pan = (res[2] != "") ? Std.int(res[2])*16 : 64;
                    break;
                case '@p':
                    voice.channelParam.pan = (res[2] != "") ? Std.int(res[2]) : 64;
                    break;
                case 'v':
                    voice.velocity = (res[2] != "") ? (Std.int (res[2])<<voice.vcommandShift) : 256;
                    break;
                case 'x':
                    voice.expression = (res[2] != "") ? Std.int(res[2]) : 128;
                    break;
                    
                case '%v':
                    voice.velocityMode  = (res[2] != "") ? Std.int(res[2]) : 0;
                    voice.vcommandShift = (res[4] != "") ? Std.int(res[4]) : 4;
                    break;
                case '%x':
                    voice.expressionMode = (res[2] != "") ? Std.int(res[2]) : 0;
                    break;
                case '@q':
                    voice.defaultGateTicks       = (res[2] != "") ? Std.int(res[2]) : 0;
                    voice.defaultKeyOnDelayTicks = (res[4] != "") ? Std.int(res[4]) : 0;
                    break;
                    
                case '@@':
                    i = Std.int(res[2]);
                    if (envelopes != null && i>=0 && i<255) {
                        voice.noteOnToneEnvelop = envelopes[i];
                        voice.noteOnToneEnvelopStep = (Std.int (res[4])>0) ? Std.int(res[4]) : 1;
                    }
                    break;
                case 'na':
                    i = Std.int(res[2]);
                    if (envelopes != null && i>=0 && i<255) {
                        voice.noteOnAmplitudeEnvelop = envelopes[i];
                        voice.noteOnAmplitudeEnvelopStep = (Std.int (res[4])>0) ? Std.int(res[4]) : 1;
                    }
                    break;
                case 'np':
                    i = Std.int(res[2]);
                    if (envelopes != null && i>=0 && i<255) {
                        voice.noteOnPitchEnvelop = envelopes[i];
                        voice.noteOnPitchEnvelopStep = (Std.int (res[4])>0) ? Std.int(res[4]) : 1;
                    }
                    break;
                case 'nt':
                    i = Std.int(res[2]);
                    if (envelopes != null && i>=0 && i<255) {
                        voice.noteOnNoteEnvelop = envelopes[i];
                        voice.noteOnNoteEnvelopStep = (Std.int (res[4])>0) ? Std.int(res[4]) : 1;
                    }
                    break;
                case 'nf':
                    i = Std.int(res[2]);
                    if (envelopes != null && i>=0 && i<255) {
                        voice.noteOnFilterEnvelop = envelopes[i];
                        voice.noteOnFilterEnvelopStep = (Std.int (res[4])>0) ? Std.int(res[4]) : 1;
                    }
                    break;
                case '_@@':
                    i = Std.int(res[2]);
                    if (envelopes != null && i>=0 && i<255) {
                        voice.noteOffToneEnvelop = envelopes[i];
                        voice.noteOffToneEnvelopStep = (Std.int (res[4])>0) ? Std.int(res[4]) : 1;
                    }
                    break;
                case '_na':
                    i = Std.int(res[2]);
                    if (envelopes != null && i>=0 && i<255) {
                        voice.noteOffAmplitudeEnvelop = envelopes[i];
                        voice.noteOffAmplitudeEnvelopStep = (Std.int (res[4])>0) ? Std.int(res[4]) : 1;
                    }
                    break;
                case '_np':
                    i = Std.int(res[2]);
                    if (envelopes != null && i>=0 && i<255) {
                        voice.noteOffPitchEnvelop = envelopes[i];
                        voice.noteOffPitchEnvelopStep = (Std.int (res[4])>0) ? Std.int(res[4]) : 1;
                    }
                    break;
                case '_nt':
                    i = Std.int(res[2]);
                    if (envelopes != null && i>=0 && i<255) {
                        voice.noteOffNoteEnvelop = envelopes[i];
                        voice.noteOffNoteEnvelopStep = (Std.int (res[4])>0) ? Std.int(res[4]) : 1;
                    }
                    break;
                case '_nf':
                    i = Std.int(res[2]);
                    if (envelopes != null && i>=0 && i<255) {
                        voice.noteOffFilterEnvelop = envelopes[i];
                        voice.noteOffFilterEnvelopStep = (Std.int (res[4])>0) ? Std.int(res[4]) : 1;
                    }
                    break;
                }
                res = rex.exec(mml);
            }
            return voice;
        }
        
        
        
        static public function mmlVoiceSetting(voice:SiMMLVoice) : String {
            var mml:String = "", param:SiOPMChannelParam = voice.channelParam, i:Int;
            if (voice.channelParam.filterType > 0) mml += "%f" + Std.string(voice.channelParam.filterType);
            if (param.cutoff<128 || param.resonance>0 || param.far>0 || param.frr>0) {
                mml += "@f" + Std.string(param.cutoff) + "," + Std.string(param.resonance);
                if (param.far>0 || param.frr>0) {
                    mml += "," + Std.string(param.far)  + "," + Std.string(param.fdr1) + "," + Std.string(param.fdr2) + "," + Std.string(param.frr);
                    mml += "," + Std.string(param.fdc1) + "," + Std.string(param.fdc2) + "," + Std.string(param.fsc)  + "," + Std.string(param.frc);
                }
            }
            if (voice.amDepth > 0 || voice.amDepthEnd > 0 || param.amd > 0 || voice.pmDepth > 0 || voice.pmDepthEnd > 0 || param.pmd > 0) {
                var lfo:Int = param.get_lfoFrame(), ws:Int = param.lfoWaveShape;
                if (lfo != 30 || ws != SiOPMTable.LFO_WAVE_TRIANGLE) {
                    mml += "@lfo" + Std.string(lfo);
                    if (ws != SiOPMTable.LFO_WAVE_TRIANGLE) mml += "," + Std.string(ws);
                }
                if (voice.amDepth > 0 || voice.amDepthEnd > 0) {
                    mml += "ma" + Std.string(voice.amDepth);
                    if (voice.amDepthEnd > 0) mml += "," + Std.string(voice.amDepthEnd);
                    if (voice.amDelay > 0 || voice.amTerm > 0) mml += "," + Std.string(voice.amDelay);
                    if (voice.amTerm > 0) mml += "," + Std.string(voice.amTerm);
                } else if (param.amd > 0) {
                    mml += "ma" + Std.string(param.amd);
                }
                if (voice.pmDepth > 0 || voice.pmDepthEnd > 0) {
                    mml += "mp" + Std.string(voice.pmDepth);
                    if (voice.pmDepthEnd > 0) mml += "," + Std.string(voice.pmDepthEnd);
                    if (voice.pmDelay > 0 || voice.pmTerm > 0) mml += "," + Std.string(voice.pmDelay);
                    if (voice.pmTerm > 0) mml += "," + Std.string(voice.pmTerm);
                } else if (param.pmd > 0) {
                    mml += "mp" + Std.string(param.pmd);
                }
            }
            if (voice.velocityMode != 0 || voice.vcommandShift != 4) {
                mml += "%v" + Std.string(voice.velocityMode) + "," + Std.string(voice.vcommandShift);
            }
            if (voice.expressionMode != 0) mml += "%x" + Std.string(voice.expressionMode);
            if (voice.portament > 0) mml += "po" + Std.string(voice.portament);
            if (!Math.isNaN(voice.defaultGateTime)) mml += "q" + Std.string(Std.int (voice.defaultGateTime*8));
            if (voice.defaultGateTicks > 0 || voice.defaultKeyOnDelayTicks > 0) {
                mml += "@q" + Std.string(voice.defaultGateTicks) + "," + Std.string(voice.defaultKeyOnDelayTicks);
            }
            if (voice.releaseSweep > 0) mml += "s," + Std.string(voice.releaseSweep);
            if (voice.channelParam.operatorParam[0].erst) mml += "@er1";
            if (voice.pitchShift != 0) mml += "k"  + Std.string(voice.pitchShift);
            if (voice.noteShift != 0)  mml += "kt" + Std.string(voice.noteShift);
            if (voice.updateVolumes) {
                var ch:Int = (voice.channelParam.volumes[0] == 0.5) ? 0 : 1;
               i=1;
 while( i<8){ if (voice.channelParam.volumes[i] != 0) ch = i+1; i++;
}
                if (i != 0) {
                    mml += "@v";
                    if (voice.channelParam.volumes[0] != 0.5) mml += Std.string(Std.int(voice.channelParam.volumes[0]*128));
                   i=1;
 while( i<ch){
                        if (voice.channelParam.volumes[i] != 0) mml += "," + Std.string(Std.int(voice.channelParam.volumes[i]*128));
                     i++;
}
                }
                if (voice.channelParam.pan != 64) {
                    if ((voice.channelParam.pan & 15) != 0) mml += "@p" + Std.string(voice.channelParam.pan-64);
                    else mml += "p" + Std.string(voice.channelParam.pan >> 4);
                }
                if (voice.velocity   != 256) mml += "v"  + Std.string(voice.velocity >> voice.vcommandShift);
                if (voice.expression != 128) mml += "@v" + Std.string(voice.expression);
            }
            
            return mml;
        }
        
        
        
        
    
    
        
        static public function parseTableNumbers(tableNumbers:String, postfix:String, maxIndex:Int=65536) : Dynamic
        {
            var index:Int = 0, i:Int, imax:Int, j:Int, v:Int, ti0:Int, ti1:Int, tr:Float, 
                t:Float, s:Float, r:Float, o:Float, jmax:Int, last:SLLint, rep:SLLint;
            var regexp:EReg, res:Dynamic, array:Array<Dynamic>, itpl: Array<Int> = new Array<Int>(), loopStac:Array<Dynamic>=[];
            var tempNumberList:SLLint = SLLint.alloc(0), loopHead:SLLint, loopTail:SLLint, l:SLLint;

            
            last = tempNumberList;
            rep = null;

            
            regexp = ~/(\d+)?(\*(-?[\d.]+))?(([+-])([\d.]+))?/;
            res    = regexp.match(postfix);
            jmax = (res[1]) ? Std.int(res[1]) : 1;
            r    = (res[2]) ? Std.parseFloat(res[3]) : 1;
            o    = (res[4]) ? ((res[5] == '+') ? Std.parseFloat(res[6]) : -cast(res[6],Float)) : 0;
            
            
            regexp = ~/(\(\s*([,\-\d\s]+)\)[,\s]*(\d+))|(-?\d+)|(\||\[|\](\d*))/gm;
            res    = regexp.match(tableNumbers);
			
            while (res && index<maxIndex) {
                if (res[1]) {
                    
					var tmpReg:EReg = ~/[,\s]+/;
                    array = tmpReg.split(Std.string(res[2]));
                    imax = Std.int(res[3]);
                    if (imax < 2 || array.length < 1) throw errorParameterNotValid("Table MML", tableNumbers);
                   // itpl.length = array.length;
                   i=0;
 while( i<itpl.length){ itpl[i] = Std.int(array[i]);  i++;
}
                    if (itpl.length > 1) {
                        t = 0;
                        s = cast(itpl.length - 1,Float ) / imax;
                       i=0;
 while( i<imax && index<maxIndex){
                            ti0 = Std.int(t);
                            ti1 = ti0 + 1;
                            tr  = t - cast(ti0,Float);
                            v = Std.int(itpl[ti0] * (1-tr) + itpl[ti1] * tr + 0.5);
                            v = Std.int(v * r + o + 0.5);
                           j=0;
 while( j<jmax){
                                last.next = SLLint.alloc(v);
                                last = last.next;
                             j++; index++;
}
                            t += s;
                         i++;
}
                    } else {
                        
                        v = Std.int(itpl[0] * r + o + 0.5);
                       i=0;
 while( i<imax && index<maxIndex){
                           j=0;
 while( j<jmax){
                                last.next = SLLint.alloc(v);
                                last = last.next;
                             j++; index++;
}
                         i++;
}
                    }
                } else
                if (res[4]) {
                    
                    v = Std.int(Std.int (res[4]) * r + o + 0.5);
                   j=0;
 while( j<jmax){
                        last.next = SLLint.alloc(v);
                        last = last.next;
                     j++;
}
                    index++;
                } else 
                if (res[5]) {
                    switch (res[5]) {
                    case '|': 
                        rep = last;
                        break;
                    case '[': 
                        loopStac.push(last);
                        break;
                    default: 
                        if (loopStac.length == 0) errorParameterNotValid("Table MML's Loop", tableNumbers);
                        loopHead = loopStac.pop().next;
                        if (loopHead == null) errorParameterNotValid("Table MML's Loop", tableNumbers);
                        loopTail = last;
                       j= (Std.int(res[6]) != 0) ? Std.int(res[6]) : 2;
 while( j>0){
                           l=loopHead;
 while( l!=loopTail.next){
                                last.next = SLLint.alloc(l.i);
                                last = last.next;
                             l=l.next;
}
                         --j;
}
                        break;
                    }
                } else {
                    
                    throw errorUnknown("@parseWav()");
                }
                res = regexp.match(tableNumbers);
            }
            
            
            
            if (rep != null) last.next = rep.next;
            return {'head':tempNumberList.next, 'tail':last, 'length':index, 'repeated':(rep!=null)};
        }
        
        
        
        
    
    
        
        static public function parseWAV(tableNumbers:String, postfix:String) : Array<Float>
        {
            var i:Int, imax:Int, v:Float, wav: Array<Float>;
            
            var res:Dynamic = Translator.parseTableNumbers(tableNumbers, postfix, 1024),
                num:SLLint = res.head;
           imax=2;
 while( imax<1024){
                if (imax >= res.length) break;
             imax<<=1;
}

            wav = new Array<Float>();
           i=0;
 while( i<imax && num!=null){
                v = (num.i + 0.5) * 0.0078125;
                wav[i] = (v>1) ? 1 : (v<-1) ? -1 : v;
                num = num.next;
             i++;
}
           ;
 while( i<imax){ wav[i] = 0;  i++;
}
            
            return wav;
        }
        
        
        
        static public function parseWAVB(hex:String) : Array<Float>
        {
            var ub:Int, i:Int, imax:Int, wav: Array<Float>;
			var tmpEre:EReg = ~/\s+/gm;
            hex = tmpEre.replace(hex, '');
			
            imax = hex.length >> 1;
            wav = new Array<Float>();
           i=0;
 while( i<imax){
                ub = Std.parseInt(hex.substr(i<<1,2));
                wav[i] = (ub<128) ? (ub * 0.0078125) : ((ub-256) * 0.0078125);
             i++;
}
            return wav;
        }
        
        
        
        
    
    
        
        static public function parseSamplerWave(table:SiOPMWaveSamplerTable, noteNumber:Int, mml:String, soundReferTable:Dynamic) : Bool
        {
			var tmpere:EReg = ~/\s*,\s*/g;
			
            var args:Array<Dynamic> = tmpere.split(mml),
                waveID:String = Std.string(args[0]), 
                ignoreNoteOff:Bool = (args[1] != null && args[1] != "") ? cast(args[1],Bool) : false, 
                pan:Int               = (args[2] != null && args[2] != "") ? Std.int(args[2]) : 0,
                channelCount:Int      = (args[3] != null && args[3] != "") ? Std.int(args[3]) : 2,
                startPoint:Int        = (args[4] != null && args[4] != "") ? Std.int(args[4]) : -1,
                endPoint:Int          = (args[5] != null && args[5] != "") ? Std.int(args[5]) : -1,
                loopPoint:Int         = (args[6] != null && args[6] != "") ? Std.int(args[6]) : -1;

            if (Reflect.hasField(soundReferTable,waveID)) {
                var sample:SiOPMWaveSamplerData = new SiOPMWaveSamplerData(Reflect.field(soundReferTable,waveID), ignoreNoteOff, pan, 2, channelCount);
                sample.slice(startPoint, endPoint, loopPoint);
                table.setSample(sample, noteNumber);
                return true;
            }
            return false;
        }
        
        
        
        static public function parsePCMWave(table:SiOPMWavePCMTable, mml:String, soundReferTable:Dynamic) : Bool
        {
			var tmpEr:EReg = ~/\s*,\s*/g;
            var args:Array<Dynamic> = tmpEr.split(mml),
                waveID:String = Std.string(args[0]), 
                samplingNote:Int = (args[1] != null && args[1] != "") ? Std.int(args[1]) : 69,
                keyRangeFrom:Int = (args[2] != null && args[2] != "") ? Std.int(args[2]) : 0,
                keyRangeTo:Int   = (args[3] != null && args[3] != "") ? Std.int(args[3]) : 127,
                channelCount:Int = (args[4] != null && args[4] != "") ? Std.int(args[4]) : 2,
                startPoint:Int   = (args[5] != null && args[5] != "") ? Std.int(args[5]) : -1,
                endPoint:Int     = (args[6] != null && args[6] != "") ? Std.int(args[6]) : -1,
                loopPoint:Int    = (args[7] != null && args[7] != "") ? Std.int(args[7]) : -1;
            if (Reflect.hasField(soundReferTable, waveID) ) {
                var sample:SiOPMWavePCMData = new SiOPMWavePCMData(Reflect.field(soundReferTable,waveID), Std.int(samplingNote*64), 2, channelCount);
                sample.slice(startPoint, endPoint, loopPoint);
                table.setSample(sample, keyRangeFrom, keyRangeTo);
                return true;
            }
            return false;
        }
        
        
        
        static public function parsePCMVoice(voice:SiMMLVoice, mml:String, postfix:String, envelopes: Array<SiMMLEnvelopTable>=null) : Bool
        {
            var table:SiOPMWavePCMTable = cast(voice.waveData,SiOPMWavePCMTable);
            if (table == null) return false;
			
			var tmpEreg:EReg = ~/\s*,\s*/g;
			
            var args:Array<Dynamic> = tmpEreg.split(mml),
                volumeNoteNumber:Int  = (args[0]  != null && args[0]  != "") ? args[0] : 64, 
                volumeKeyRange:Float = (args[1]  != null && args[1]  != "") ? args[1] : 0, 
                volumeRange:Float    = (args[2]  != null && args[2]  != "") ? args[2] : 0, 
                panNoteNumber:Int     = (args[3]  != null && args[3]  != "") ? args[3] : 64, 
                panKeyRange:Float    = (args[4]  != null && args[4]  != "") ? args[4] : 0, 
                panWidth:Float       = (args[5]  != null && args[5]  != "") ? args[5] : 0,
                dr:Int                = (args[7]  != null && args[7]  != "") ? args[7] : 0,
                sr:Int                = (args[8]  != null && args[8]  != "") ? args[8] : 0,
                rr:Int                = (args[9]  != null && args[9]  != "") ? args[9] : 63,
                sl:Int                = (args[10] != null && args[10] != "") ? args[10] : 0;
            var opp:SiOPMOperatorParam = voice.channelParam.operatorParam[0];
            opp.ar = (args[6]  != null && args[6]  != "") ? args[6]  : 63;
            opp.dr = (args[7]  != null && args[7]  != "") ? args[7]  : 0;
            opp.sr = (args[8]  != null && args[8]  != "") ? args[8]  : 0;
            opp.rr = (args[9]  != null && args[9]  != "") ? args[9]  : 63;
            opp.sl = (args[10] != null && args[10] != "") ? args[10] : 0;
            table.setKeyScaleVolume(volumeNoteNumber, volumeKeyRange, volumeRange);
            table.setKeyScalePan(panNoteNumber, panKeyRange, panWidth);
            parseVoiceSetting(voice, postfix, envelopes);
            return true;
        }
        
        
        
        
    
    
        
        static public function setOPMVoicesByRegister(regData: Array<Int>, address:Int, enableLFO:Bool=false, voiceSet:Array<Dynamic>=null) : Array<Dynamic>
        {
            var i:Int, imax:Int, value:Int, index:Int, v:Int, ams:Int, pms:Int, 
                chp:SiOPMChannelParam, opp:SiOPMOperatorParam, opi:Int, _pmd:Int=0, _amd:Int=0, 
                opia:Array<Dynamic> = [0,2,1,3], table:SiOPMTable = SiOPMTable.instance();
            
            
            voiceSet = (voiceSet != null) ? voiceSet : [];
           opi=0;
 while( opi<8){ 
                if (voiceSet[opi]) voiceSet[opi].initialize();
                else voiceSet[opi] = new SiONVoice();
                voiceSet[opi].channelParam.opeCount = 4;
                voiceSet[opi].chipType = SiONVoice.CHIPTYPE_OPM;
             opi++;
}
            
            
            imax = regData.length;
           i=0;
 while( i<imax){
                value = regData[i];
                chp = voiceSet[address & 7].channelParam;
                
                
                if (address < 0x20) {
                    switch(address) {
                    case 1:  
                        break;
                    case 8:  
                        break;
                    case 15: 
                        if ((value & 128) != 0) {
                            voiceSet[7].channelParam.operatorParam[3].setPGType(SiOPMTable.PG_NOISE_PULSE);
                            voiceSet[7].channelParam.operatorParam[3].fixedPitch = ((value & 31) << 6) + 2048;
                        }
                        break;
                    case 16: 
                        break;
                    case 17: 
                        break;
                    case 18: 
                        break;
                    case 19: 
                        break;
                    case 24: 
                        if (enableLFO) {
                            v = table.lfo_timerSteps[value];
                           opi=0;
 while( opi<8){ voiceSet[opi].channelParam.lfoFreqStep = v;  opi++;
}
                        }
                        break;
                    case 25: 
                        if (enableLFO) {
                            if ((value & 128) != 0) _pmd = value & 127;
                            else             _amd = value & 127;
                        }
                        break;
                    case 27: 
                        if (enableLFO) {
                            v = value & 3;
                           opi=0;
 while( opi<8){ voiceSet[opi].channelParam.lfoWaveShape = v;  opi++;
}
                        }
                        break;
                    }
                } else 

                
                if (address < 0x40) {
                    switch((address-0x20) >> 3) {
                    case 0: 
                        v = value >> 6;
                        chp.volumes[0] = (v != 0) ? 0.5 : 0;
                        chp.pan = (v==1) ? 128 : (v==2) ? 0 : 64;
                        chp.fb  = (value >> 3) & 7;
                        chp.alg = (value     ) & 7;
                        break;
                    case 1: 
                        
                        break;
                    case 2: 
                        
                        break;
                    case 3: 
                        if (enableLFO) {
                            pms = (value >> 4) & 7;
                            ams = (value     ) & 3;
                            chp.pmd = (pms<6) ? (_pmd >> (6-pms)) : (_pmd << (pms-5));
                            chp.amd = (ams>0) ? (_amd << (ams-1)) : 0;
                        }
                        break;
                    }
                } else 
                
                
                {
                    index = opia[(address >> 3) & 3];
                    opp = chp.operatorParam[index];
                    switch((address-0x40) >> 5) {
                    case 0: 
                        opp.dt1 = (value >> 4) & 7;
                        opp.mul((value     ) & 15);
                        break;
                    case 1: 
                        opp.tl = value & 127;
                        break;
                    case 2: 
                        opp.ksr = (value >> 6) & 3;
                        opp.ar  = (value & 31) << 1;
                        break;
                    case 3: 
                        opp.ams = ((value >> 7) & 1)<<1;
                        opp.dr  = (value & 31) << 1;
                        break;
                    case 4: 
                        opp.detune = table.dt2Table[(value >> 6) & 3];
                        opp.sr     = (value & 31) << 1;
                        break;
                    case 5: 
                        opp.sl = (value >> 4) & 15;
                        opp.rr = (value & 15) << 2;
                        break;
                    }
                }
             i++; address++;
}
            
            return voiceSet;
        }
        
        
        
        
        
    
    
        
        static private function _str(v:Int, length:Int) : String {
            if (v>=0) return ("0000"+Std.string(v)).substr(-length);
            return "-" + ("0000"+Std.string(-v)).substr(-length+1);
        }
        
        
        
        static private function _checkDigit(param:SiOPMChannelParam) : Dynamic {
            var res:Dynamic = {'ws':1, 'tl':2, 'dt':1, 'ph':1, 'fn':1};
           var opeIndex:Int = 0;
		   
		   var max:Dynamic = function (a:Int, b:Int) : Int { return (a>b) ? a:b; }
		   
 while( opeIndex<param.opeCount){
                var opp:SiOPMOperatorParam = param.operatorParam[opeIndex];
                res.ws = max(res.ws, Std.string(opp.pgType).length);
                res.tl = max(res.tl, Std.string(opp.tl).length);
                res.dt = max(res.dt, Std.string(opp.detune).length);
                res.ph = max(res.ph, Std.string(opp.phase).length);
                res.fn = max(res.fn, Std.string(opp.fixedPitch>>6).length);
             opeIndex++;
}
            return res;
            
           
        }
        
        
        
        static private function _checkAlgorism(oc:Int, al:Int, algList:Array<Dynamic>) : Int {
            var list:Array<Dynamic> = algList[oc-1];
           var i:Int=0;
 while( i<list.length){ if (al == list[i]) return i; i++;
}
            return -1;
        }
        
        
        
        static private function _pgTypeMA3(pgType:Int) : Int {
            var ws:Int = pgType - SiOPMTable.PG_MA3_WAVE;
            if (ws>=0 && ws<=31) return ws;
            switch (pgType) {
            case 0:                             return 0;   
            case 1: case 2: case 128: case 255: return 24;  
            case 4: case 192: case 191:         return 16;  
            case 5: case 72:                    return 6;   
            }
            return -1;
        }
        
        
        
        static private function _dt2OPM(detune:Int) : Int {
                 if (detune <= 100) return 0;   
            else if (detune <= 420) return 1;   
            else if (detune <= 550) return 2;   
            return 3;                           
        }
        
        
        
        static private function _balanceAL(tl0:Int, tl1:Int) : Int {
            if (tl0 == tl1) return 0;
            if (tl0 == 0) return -64;
            if (tl1 == 0) return 64;
            var tltable: Array<Int> = SiOPMTable.instance().eg_lv2tlTable, i:Int;
           i=1;
 while( i<128){ if (tl0 >= tltable[i]) return i-64; i++;
}
            return 64;
        }
        
        
        
        
    
    
        static public function errorToneParameterNotValid(cmd:String, chParam:Int, opParam:Int) : Error
        {
            return new Error("Translator error : Parameter count is not valid in '" + cmd + "'. " + Std.string(chParam) + " parameters for channel and " + Std.string(opParam) + " parameters for each operator.");
        }
        
        
        static public function errorParameterNotValid(cmd:String, param:String) : Error
        {
            return new Error("Translator error : Parameter not valid. '" + param + "' in " + cmd);
        }
        
        
        static public function errorTranslation(str:String) : Error
        {
            return new Error("Translator Error : mml error. '" + str + "'");
        }

        
        static public function errorUnknown(str:String) : Error
        {
            return new Error("Translator error : Unknown. "+str);
        }
    }


