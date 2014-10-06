





package org.si.sion.sequencer.base ;
	import flash.errors.Error;
	import flash.Lib;
	import flash.utils.RegExp;
    
    
    class MMLParser
    {
    
    
        static private var _keySignitureTable:Array<Dynamic> = [
            [ 0, 0, 0, 0, 0, 0, 0],
            [ 0, 0, 0, 1, 0, 0, 0],
            [ 1, 0, 0, 1, 0, 0, 0],
            [ 1, 0, 0, 1, 1, 0, 0],
            [ 1, 1, 0, 1, 1, 0, 0],
            [ 1, 1, 0, 1, 1, 1, 0],
            [ 1, 1, 1, 1, 1, 1, 0],
            [ 1, 1, 1, 1, 1, 1, 1],
            [ 0, 0, 0, 0, 0, 0,-1],
            [ 0, 0,-1, 0, 0, 0,-1],
            [ 0, 0,-1, 0, 0,-1,-1],
            [ 0,-1,-1, 0, 0,-1,-1],
            [ 0,-1,-1, 0,-1,-1,-1],
            [-1,-1,-1, 0,-1,-1,-1],
            [-1,-1,-1,-1,-1,-1,-1]
        ];
        
        
        
        
    
    
        
        static private var _setting:MMLParserSetting = null;
        
        
        static private var _mmlString:String = null;
        
        
        static private var _userDefinedEventID:Dynamic = null;
        
        
        static private var _systemEventStrings: Array<String> = new Array<String>();
        static private var _sequenceMMLStrings: Array<String> = new Array<String>();
        
        
        static private var _globalEventFlags: Array<Bool> = null;
        
        
        static private var _freeEventChain:MMLEvent = null;

        static private var _interruptInterval:Int     = 0;
        static private var _startTime:Int             = 0;
        static private var _parsingTime:Int           = 0;
        
        static private var _staticLength:Int          = 0;
        static private var _staticOctave:Int          = 0;
        static private var _staticNoteShift:Int       = 0;
        static private var _isLastEventLength:Bool = false;
        static private var _systemEventIndex:Int      = 0;
        static private var _sequenceMMLIndex:Int      = 0;
        static private var _headMMLIndex:Int          = 0;
        static private var _cacheMMLString:Bool    = false;
        
        static private var _keyScale    : Array<Int> = [0,2,4,5,7,9,11];
        static private var _keySigniture: Array<Int> = _keySignitureTable[0];
        static private var _keySignitureCustom: Array<Int> = new Array<Int>();
        static private var _terminator      :MMLEvent = new MMLEvent();
        static private var _lastEvent       :MMLEvent = null;
        static private var _lastSequenceHead:MMLEvent = null;
        static private var _repeatStac:Array<Dynamic>          = [];
        
        
        
        
    
    
        
        static public function keySign(sign:String) : Void
        {
            var note:Int, i:Int, list:Array<String>, shift:String, noteLetters:String = "cdefgab";
            switch(sign) {
            case '':
            case 'C':   case 'Am':                          _keySigniture = _keySignitureTable[0]; 
            case 'G':   case 'Em':                          _keySigniture = _keySignitureTable[1];  
            case 'D':   case 'Bm':                          _keySigniture = _keySignitureTable[2];  
            case 'A':   case 'F+m': case 'F#m':             _keySigniture = _keySignitureTable[3]; 
            case 'E':   case 'C+m': case 'C#m':             _keySigniture = _keySignitureTable[4]; 
            case 'B':   case 'G+m': case 'G#m':             _keySigniture = _keySignitureTable[5];  
            case 'F+':  case 'F#':  case 'D+m': case 'D#m': _keySigniture = _keySignitureTable[6];  
            case 'C+':  case 'C#':  case 'A+m': case 'A#m': _keySigniture = _keySignitureTable[7];  
            case 'F':   case 'Dm':                          _keySigniture = _keySignitureTable[8];  
            case 'B-':  case 'Bb':  case 'Gm':              _keySigniture = _keySignitureTable[9];  
            case 'E-':  case 'Eb':  case 'Cm':              _keySigniture = _keySignitureTable[10];
            case 'A-':  case 'Ab':  case 'Fm':              _keySigniture = _keySignitureTable[11]; 
            case 'D-':  case 'Db':  case 'B-m': case 'Bbm': _keySigniture = _keySignitureTable[12]; 
            case 'G-':  case 'Gb':  case 'E-m': case 'Ebm': _keySigniture = _keySignitureTable[13]; 
            case 'C-':  case 'Cb':  case 'A-m': case 'Abm': _keySigniture = _keySignitureTable[14];
            default:
               i=0;
 while( i<7){ _keySignitureCustom[i] = 0;  i++;
}
                list = sign.split("/[\\s,]/");
               i=0;
 while( i<list.length){
                    note = noteLetters.indexOf(list[0].toLowerCase());
                    if (note == -1) throw errorKeySign(sign);
                    if (list.length > 1) {
                        shift = list[1];
                        _keySignitureCustom[note] = (shift=='+' || shift=='#') ? 1 : (shift=='-' || shift=='b') ? -1 : 0;
                    } else {
                        _keySignitureCustom[note] = 0;
                    }
                 i++;
}
                _keySigniture = _keySignitureCustom;
            }
        }
        
        
        
        static public function parseProgress() : Float
        {
            if (_mmlString != null) {
                return _mmlRegExp.lastIndex / (_mmlString.length+1);
            }
            return 0;
        }
        
        
        
        
    
    
        
        function new()
        {
        }
        
        
        
        
    
    
        
        static public function _freeAllEvents(seq:MMLSequence) : Void
        {
            if (seq.headEvent == null) return;
            
            
            seq.tailEvent.next = _freeEventChain;
            
            
            _freeEventChain = seq.headEvent;

            
            seq.headEvent = null;
            seq.tailEvent = null;
        }
        
        
        
        static public function _freeEvent(e:MMLEvent) : MMLEvent
        {
            var next:MMLEvent = e.next;
            e.next = _freeEventChain;
            _freeEventChain = e;
            return next;
        }
        
        
        
		static public function _allocEvent(id:Int, data:Int, length:Int=0) : MMLEvent
        {
            if (_freeEventChain != null) {
                var e:MMLEvent = _freeEventChain;
                _freeEventChain = _freeEventChain.next;
                return e.initialize(id, data, length);
            }
            return (new MMLEvent()).initialize(id, data, length);
        }
        
        
        
        
    
    
        
        static public function _setUserDefinedEventID(map:Dynamic) : Void
        {
            if (_userDefinedEventID != map) {
                _userDefinedEventID = map;
                _mmlRegExp = null;
            }
        }
        
        
        
        static public function _setGlobalEventFlags(flags: Array<Bool>) : Void
        {
            _globalEventFlags = flags;
        }
        
        
        
        
    
    
        
        static public function addMMLEvent(id:Int, data:Int=0, length:Int=0, noteOption:Bool=false) : MMLEvent
        {
            if (!noteOption) {
                
                if (id == MMLEvent.SEQUENCE_HEAD) {
                    _lastSequenceHead.jump = _lastEvent;
                    _lastSequenceHead = _pushMMLEvent(id, data, length);
                    _initialize_track();
                } else
                
                if (id == MMLEvent.REST && _lastEvent.id == MMLEvent.REST) {
                    _lastEvent.length += length;
                } else {
                    _pushMMLEvent(id, data, length);
                    
                    if (_globalEventFlags[id]) _lastSequenceHead.data++;
                }
            } else {
                
                if (_lastEvent.id == MMLEvent.NOTE) {
                    length = _lastEvent.length;
                    _lastEvent.length = 0;
                    _pushMMLEvent(id, data, length);
                } else {
                    
                    throw errorSyntax("* or &");
                }
            }
            
            _isLastEventLength = false;
            return _lastEvent;
        }
        
        
        
        static public function getEventID(mmlCommand:String) : Int
        {
            switch (mmlCommand) {
            case 'c': case 'd': case 'e': case 'f': case 'g': case 'a': case 'b':   return MMLEvent.NOTE;
            case 'r':   return MMLEvent.REST;
            case 'q':   return MMLEvent.QUANT_RATIO;
            case '@q':  return MMLEvent.QUANT_COUNT;
            case 'v':   return MMLEvent.VOLUME;
            case '@v':  return MMLEvent.FINE_VOLUME;
            case '%':   return MMLEvent.MOD_TYPE;
            case '@':   return MMLEvent.MOD_PARAM;
            case '@i':  return MMLEvent.INPUT_PIPE;
            case '@o':  return MMLEvent.OUTPUT_PIPE;
            case '(':   case ')':   return MMLEvent.VOLUME_SHIFT;
            case '&':   return MMLEvent.SLUR;
            case '&&':  return MMLEvent.SLUR_WEAK;
            case '*':   return MMLEvent.PITCHBEND;
            case ',':   return MMLEvent.PARAMETER;
            case '$':   return MMLEvent.REPEAT_ALL;
            case '[':   return MMLEvent.REPEAT_BEGIN;
            case ']':   return MMLEvent.REPEAT_END;
            case '|':   return MMLEvent.REPEAT_BREAK;
            case 't':   return MMLEvent.TEMPO;
            }
            return 0;
        }
        
        
        
        static public function _getCommandLetters(list:Array<Dynamic>) : Void
        {
            list[MMLEvent.NOTE] = 'c';
            list[MMLEvent.REST] = 'r';
            list[MMLEvent.QUANT_RATIO] = 'q';
            list[MMLEvent.QUANT_COUNT] = '@q';
            list[MMLEvent.VOLUME] = 'v';
            list[MMLEvent.FINE_VOLUME] = '@v';
            list[MMLEvent.MOD_TYPE] = '%';
            list[MMLEvent.MOD_PARAM] = '@';
            list[MMLEvent.INPUT_PIPE] = '@i';
            list[MMLEvent.OUTPUT_PIPE] = '@o';
            list[MMLEvent.VOLUME_SHIFT] = '(';
            list[MMLEvent.SLUR] = '&';
            list[MMLEvent.SLUR_WEAK] = '&&';
            list[MMLEvent.PITCHBEND] = '*';
            list[MMLEvent.PARAMETER] = ',';
            list[MMLEvent.REPEAT_ALL] = '$';
            list[MMLEvent.REPEAT_BEGIN] = '[';
            list[MMLEvent.REPEAT_END] = ']';
            list[MMLEvent.REPEAT_BREAK] = '|';
            list[MMLEvent.TEMPO] = 't';
        }
        
        
        
        static public function _getSystemEventString(e:MMLEvent) : String
        {
            return _systemEventStrings[e.data];
        }
        
        
        
        static public function _getSequenceMML(e:MMLEvent) : String
        {
            return (e.length == -1) ? "" : _sequenceMMLStrings[e.length];
        }
        

        
        static private function _pushMMLEvent(id:Int, data:Int, length:Int) : MMLEvent
        {
            _lastEvent.next = _allocEvent(id, data, length);
            _lastEvent = _lastEvent.next;
            return _lastEvent;
        }
        

        
        static private function _regSystemEventString(str:String) : Int
        {
            //if (_systemEventStrings.length <= _systemEventIndex) _systemEventStrings.length = _systemEventStrings.length * 2; HAXE PORT
            _systemEventStrings[_systemEventIndex++] = str;
            return _systemEventIndex - 1;
        }
        
        
        
        static private function _regSequenceMMLStrings(str:String) : Int
        {
            //if (_sequenceMMLStrings.length <= _sequenceMMLIndex) _sequenceMMLStrings.length = _sequenceMMLStrings.length * 2; HAXE PORT
            _sequenceMMLStrings[_sequenceMMLIndex++] = str;
            return _sequenceMMLIndex - 1;
        }
        
        
        
    
    
        inline static private var REX_WHITESPACE:Int = 1;
        inline static private var REX_SYSTEM    :Int = 2;
        inline static private var REX_COMMAND   :Int = 3;
        inline static private var REX_NOTE      :Int = 4;
        inline static private var REX_SHIFT_NOTE:Int = 5;
        inline static private var REX_USER_EVENT:Int = 6;
        inline static private var REX_EVENT     :Int = 7;
        inline static private var REX_TABLE     :Int = 8;
        inline static private var REX_PARAM     :Int = 9;
        inline static private var REX_PERIOD    :Int = 10;
        static private var _mmlRegExp:RegExp = null;
        static private function createRegExp(reset:Bool) : RegExp
        {
            if (_mmlRegExp == null) {
                
                var ude:Array<Dynamic> = [];
				
				var tmpArray:Array<String> = cast _userDefinedEventID ;
				
                for (letter in tmpArray) { ude.push(letter); }
				
				var uderex:String = 'a';
				
				if (ude.length > 0)
				{
					ude.sort(function(a,b)
  return Reflect.compare(a.toLowerCase(), b.toLowerCase()) );
					uderex = ude.join('|');
  
				}
                
                var rex:String;
                rex  = "(\\s+)";                                            
                rex += "|(#[^;]*)";                                         
                rex += "|(";                                                
                    rex += "([a-g])([\\-+#]?)";                                 
                    rex += "|(" + uderex + ")";                                 
                    rex += "|(@[qvio]?|&&|!@ns|[rlqovt^<>()\\[\\]/|$%&*,;])";   
                    rex += "|(\\{.*?\\}[0-9]*\\*?[\\-0-9.]*\\+?[\\-0-9.]*)";    
                rex += ")\\s*(-?[0-9]*)";                                    
                rex += "\\s*(\\.*)";                                         
                _mmlRegExp = new RegExp(rex, 'gms');
            }
            
            
            if (reset) _mmlRegExp.lastIndex = 0;
            return _mmlRegExp;
        }
        
        
        
        
    
    
        
        static public function prepareParse(setting:MMLParserSetting, mml:String) : Void
        {
            
            _setting   = setting;
            _mmlString = mml;
            _parsingTime = Lib.getTimer();
            
            createRegExp(true);
            
            _initialize();
        }
        
        
        
        static public function parse(interrupt:Int=0) : MMLEvent
        {
            var shift:Int;
			var note:Int;
			var halt:Bool;
			var rex:RegExp;
			var res:Dynamic = null;
            var mml2nn:Int = _setting.mml2nn();
			var codeC:Int = "c".charCodeAt(0);
			
			var __calcLength:Dynamic = function() : Int {
                if (Std.string(res[REX_PARAM]).length == 0) return -2147483648 ;
                var len:Int = Std.int(res[REX_PARAM]);
                if (len == 0) return 0;
                var iLength:Int = Std.int(_setting.resolution/len);
                if (iLength<1 || iLength>_setting.resolution) throw errorRangeOver("length", 1, _setting.resolution);
                return iLength;
            }
            
            
            var __param:Dynamic = function(defaultValue:Int = -2147483648) : Int {
                return (Std.string(res[REX_PARAM]).length > 0) ? Std.int(res[REX_PARAM]) : defaultValue;
            }
            
            
            var __period:Dynamic = function() : Int {
                return Std.string(res[REX_PERIOD]).length;
            }

            
            
            _interruptInterval = interrupt;
            _startTime         = Lib.getTimer();
            
            
            rex = createRegExp(false);
            
            
            halt = false;
            res = rex.exec(_mmlString);
            while (res && Std.string(res[0]).length>0) {
                
                if (res[REX_WHITESPACE] == null) {
                    if (res[REX_NOTE]) {
                        
                        note  = Std.string(res[REX_NOTE]).charCodeAt(0) - codeC;
                        if (note < 0) note += 7;
                        shift = _keySigniture[note];
                        switch(Std.string(res[REX_SHIFT_NOTE])) {
                        case '+':   case '#':   shift++;    break;
                        case '-':               shift--;    break;
                        }
                        _note(_keyScale[note] + shift + mml2nn, __calcLength(), __period());
                    } else 
                    if (res[REX_USER_EVENT]) {
                        
						
                        if (!Reflect.hasField(_userDefinedEventID,res[REX_USER_EVENT]) ) throw errorUnknown("REX_USER_EVENT");
                        addMMLEvent(_userDefinedEventID[res[REX_USER_EVENT]], __param());
                    } else
                    if (res[REX_EVENT]) {
                        
                        switch(Std.string(res[REX_EVENT])) {
                        case 'r':   _rest     (__calcLength(), __period());          break;
                        case 'l':   _length   (__calcLength(), __period());          break;
                        case '^':   _tie      (__calcLength(), __period());          break;
                        case 'o':   _octave   (__param(_setting.defaultOctave));     break;
                        case 'q':   _quant    (__param(_setting.defaultQuantRatio)); break;
                        case '@q':  _at_quant (__param(_setting.defaultQuantCount)); break;
                        case 'v':   _volume   (__param(_setting.defaultVolume));     break;
                        case '@v':  _at_volume(__param(_setting.defaultFineVolume)); break;
                        case '%':   _mod_type (__param());                           break;
                        case '@':   _mod_param(__param());                           break;
                        case '@i':  _input (__param(0));        break;
                        case '@o':  _output(__param(0));        break;
                        case '(':   _volumeShift( __param(1));  break;
                        case ')':   _volumeShift(Std.int(-__param(1)));  break;
                        case '<':   _octaveShift( __param(1));  break;
                        case '>':   _octaveShift(Std.int(-__param(1)));  break;
                        case '&':   _slur();                    break;
                        case '&&':  _slurweak();                break;
                        case '*':   _portament();               break;
                        case ',':   _parameter(__param());      break;
                        case ';':   halt = _end_sequence();     break;
                        case '$':   _repeatPoint();             break;
                        case '[':   _repeatBegin(__param(2));   break;
                        case ']':   _repeatEnd(__param());      break;
                        case '|':   _repeatBreak();             break;
                        case '!@ns': _noteShift( __param(0));               break;
                        case 't':   _tempo(__param(_setting.defaultBPM));   break;
                        default:
                            throw errorUnknown("REX_EVENT;"+res[REX_EVENT]);
                            break;
                        }
                    } else 
                    if (res[REX_SYSTEM]) {
                        
                        if (_lastEvent.id != MMLEvent.SEQUENCE_HEAD) throw errorSyntax(res[0]);
                        
                        addMMLEvent(MMLEvent.SYSTEM_EVENT, _regSystemEventString(res[REX_SYSTEM]));
                    } else
                    if (res[REX_TABLE]) {
                        
                        addMMLEvent(MMLEvent.TABLE_EVENT, _regSystemEventString(res[REX_TABLE]));
                    } else {
                        
                        throw errorSyntax(res[0]);
                    }
                }
                
                
                if (halt) return null;
                
                
                res = rex.exec(_mmlString);
            }
            
            
            
            if (_repeatStac.length != 0) throw errorStacOverflow("[");
            
            if (_lastEvent.id != MMLEvent.SEQUENCE_HEAD) _lastSequenceHead.jump = _lastEvent;

            
            _parsingTime = Lib.getTimer() - _parsingTime;

            
            var headEvent:MMLEvent = _terminator.next;
            _terminator.next = null;
            return headEvent;


        
        }
        
        
        
        static private function _initialize() : Void
        {
            
            var e:MMLEvent = _terminator.next;
            while (e != null) { e = _freeEvent(e); }
            
            
            _systemEventIndex = 0;                                            
            _sequenceMMLIndex = 0;                                            
            _lastEvent        = _terminator;                                  
            _lastSequenceHead = _pushMMLEvent(MMLEvent.SEQUENCE_HEAD, 0, 0);  
            if (_cacheMMLString) addMMLEvent(MMLEvent.DEBUG_INFO, -1);
            _initialize_track();
        }
        
        
        
        static private function _initialize_track() : Void
        {
            _staticLength      = _setting.defaultLength();    
            _staticOctave      = _setting.defaultOctave2();    
            _staticNoteShift   = 0;                         
            _isLastEventLength = false;                      
			 _repeatStac = new Array<Dynamic>();
            _headMMLIndex      = _mmlRegExp.lastIndex;      
        }
        
        
        
        
    
    
        
        static private function _note(note:Int, iLength:Int, period:Int) : Void
        {
            note += _staticOctave*12 + _staticNoteShift;
            if (note < 0) {
                
                note = 0;
            } else 
            if (note > 127) {
                
                note = 127;
            }
            addMMLEvent(MMLEvent.NOTE, note, __calcLength(iLength, period));
        }
        
        
        
        static private function _rest(iLength:Int, period:Int) : Void
        {
            addMMLEvent(MMLEvent.REST, 0, __calcLength(iLength, period));
        }
        
        
    
    
        
        static private function _length(iLength:Int, period:Int) : Void
        {
            _staticLength = __calcLength(iLength, period);
            _isLastEventLength = true;
        }
        
        
        
        static private function _tie(iLength:Int, period:Int) : Void
        {
            if (_isLastEventLength) {
                _staticLength += __calcLength(iLength, period);
            } else 
            if (_lastEvent.id == MMLEvent.REST || _lastEvent.id == MMLEvent.NOTE) {
                _lastEvent.length += __calcLength(iLength, period);
            } else {
                throw errorSyntax("tie command");
            }
        }
        
        
        
        static private function _slur() : Void
        {
            addMMLEvent(MMLEvent.SLUR, 0, 0, true);
        }
        
        
        
        static private function _slurweak() : Void
        {
            addMMLEvent(MMLEvent.SLUR_WEAK, 0, 0, true);
        }
        
        
        
        static private function _portament() : Void
        {
            addMMLEvent(MMLEvent.PITCHBEND, 0, 0, true);
        }
        
        
        
        static private function _quant(param:Int) : Void
        {
            if (param<_setting.minQuantRatio || param>_setting.maxQuantRatio) {
                throw errorRangeOver("q", _setting.minQuantRatio, _setting.maxQuantRatio);
            }
            addMMLEvent(MMLEvent.QUANT_RATIO, param);
        }
        
        
        
        static private function _at_quant(param:Int) : Void
        {
            if (param<_setting.minQuantCount || param>_setting.maxQuantCount) {
                throw errorRangeOver("@q", _setting.minQuantCount, _setting.maxQuantCount);
            }
            addMMLEvent(MMLEvent.QUANT_COUNT, param);
        }
        
        
        
        static private function __calcLength(iLength:Int, period:Int) : Int
        {
            
            if (iLength == -2147483648) iLength = _staticLength;
            
            var len:Int = iLength;
            while (period>0) { iLength += len>>(period--); }
            return iLength;
        }
        
        
    
    
        
        static private function _octave(param:Int) : Void
        {
            if (param<_setting.minOctave || param>_setting.maxOctave) {
                throw errorRangeOver("o", _setting.minOctave, _setting.maxOctave);
            }
            _staticOctave = param;
        }
        
        
        
        static private function _octaveShift(param:Int) : Void
        {
            param *= _setting.octavePolarization;
            _staticOctave += param;
        }
        

        
        static private function _noteShift(param:Int) : Void
        {
            _staticNoteShift += param;
        }
        
        
        
        static private function _volume(param:Int) : Void
        {
            if (param<0 || param>_setting.maxVolume) {
                throw errorRangeOver("v", 0, _setting.maxVolume);
            }
            addMMLEvent(MMLEvent.VOLUME, param);
        }
        
        
        
        static private function _at_volume(param:Int) : Void
        {
            if (param<0 || param>_setting.maxFineVolume) {
                throw errorRangeOver("@v", 0, _setting.maxFineVolume);
            }
            addMMLEvent(MMLEvent.FINE_VOLUME, param);
        }
        
        
        
        static private function _volumeShift(param:Int) : Void
        {
            param *= _setting.volumePolarization;
            if (_lastEvent.id == MMLEvent.VOLUME_SHIFT || _lastEvent.id == MMLEvent.VOLUME) {
                _lastEvent.data += param;
            } else {
                addMMLEvent(MMLEvent.VOLUME_SHIFT, param);
            }
        }
        
        
    
    
        
        static private function _repeatPoint() : Void
        {
            addMMLEvent(MMLEvent.REPEAT_ALL, 0);
        }
        
        
        
        static private function _repeatBegin(rep:Int) : Void
        {
            if (rep < 1 || rep > 65535) throw errorRangeOver("[", 1, 65535);
            addMMLEvent(MMLEvent.REPEAT_BEGIN, rep, 0);
            _repeatStac.unshift(_lastEvent);
        }
        
        
        
        static private function _repeatBreak() : Void
        {
            if (_repeatStac.length == 0) throw errorStacUnderflow("|");
            addMMLEvent(MMLEvent.REPEAT_BREAK);
            _lastEvent.jump = new MMLEvent(_repeatStac[0]);
        }
        
        
        
        static private function _repeatEnd(rep:Int) : Void
        {
            if (_repeatStac.length == 0) throw errorStacUnderflow("]");
            addMMLEvent(MMLEvent.REPEAT_END);
            var beginEvent:MMLEvent = new MMLEvent(_repeatStac.shift());
            _lastEvent.jump = beginEvent;   
            beginEvent.jump = _lastEvent;   
            
            
            if (rep != -2147483648) {
                if (rep < 1 || rep > 65535) throw errorRangeOver("]", 1, 65535);
                beginEvent.data = rep;
            }
        }
        
        
    
    
        
        static private function _mod_type(param:Int) : Void
        {
            addMMLEvent(MMLEvent.MOD_TYPE, param);
        }
        
        
        
        static private function _mod_param(param:Int) : Void
        {
            addMMLEvent(MMLEvent.MOD_PARAM, param);
        }
        
        
        
        static private function _input(param:Int) : Void
        {
            addMMLEvent(MMLEvent.INPUT_PIPE, param);
        }
        
        
        
        static private function _output(param:Int) : Void
        {
            addMMLEvent(MMLEvent.OUTPUT_PIPE, param);
        }
        
        
        
        static private function _parameter(param:Int) : Void
        {
            addMMLEvent(MMLEvent.PARAMETER, param);
        }
        
        
        
        static private function _end_sequence() : Bool
        {
            if (_lastEvent.id != MMLEvent.SEQUENCE_HEAD) {
                if (_lastSequenceHead.next != null && _lastSequenceHead.next.id == MMLEvent.DEBUG_INFO) {
                    
                    _lastSequenceHead.next.data = _regSequenceMMLStrings(_mmlString.substring(_headMMLIndex, _mmlRegExp.lastIndex));
                }
                addMMLEvent(MMLEvent.SEQUENCE_HEAD, 0);
                if (_cacheMMLString) addMMLEvent(MMLEvent.DEBUG_INFO, -1);
                
                if (_interruptInterval == 0) return false;
                return (_interruptInterval < (Lib.getTimer() - _startTime));
            }
            return false;
        }
        
        
        
        static private function _tempo(t:Int) : Void
        {
            addMMLEvent(MMLEvent.TEMPO, t);
        }
        
        
        
        
    
    
        static public function errorUnknown(n:String) : Error
        {
            return new Error("MMLParser Error : Unknown error #" + n + ".");
        }
        

        static public function errorNoteOutofRange(note:Int) : Error
        {
            return new Error("MMLParser Error : Note #" + note + " is out of range.");
        }
        
        
        static public function errorSyntax(syn:String) : Error
        {
            return new Error("MMLParser Error : Syntax error '" + syn + "'.");
        }
        
        
        static public function errorRangeOver(cmd:String, min:Int, max:Int) : Error
        {
            return new Error("MMLParser Error : The parameter of '" + cmd + "' command must ragne from " + min + " to " + max + ".");
        }


        static public function errorStacUnderflow(cmd:String) : Error
        {
            return new Error("MMLParser Error : The stac of '" + cmd + "' command is underflow.");
        }
        
        
        static public function errorStacOverflow(cmd:String) : Error
        {
            return new Error("MMLParser Error : The stac of '" + cmd + "' command is overflow.");
        }
        
        
        static public function errorKeySign(ksign:String) : Error
        {
            return new Error("MMLParser Error : Cannot recognize '" + ksign + "'as a key signiture.");
        }
    }


