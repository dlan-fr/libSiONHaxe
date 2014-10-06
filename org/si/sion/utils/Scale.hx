






package org.si.sion.utils ;
    
    class Scale
    {
    
    
        
        static var ST_MAJOR:Int            = 0x1ab5ab5;
        
        static var ST_MINOR:Int            = 0x15ad5ad;
        
        static var ST_HARMONIC_MINOR:Int   = 0x19ad9ad;
        
        static var ST_MELODIC_MINOR:Int    = 0x1aadaad;
        
        static var ST_PENTATONIC:Int       = 0x1295295;
        
        static var ST_MINOR_PENTATONIC:Int = 0x14a94a9;
        
        static var ST_BLUE_NOTE:Int        = 0x14e94e9;
        
        static var ST_DIMINISH:Int         = 0x1249249;
        
        static var ST_COMB_DIMINISH:Int    = 0x16db6db;
        
        static var ST_WHOLE_TONE:Int       = 0x1555555;
        
        static var ST_CHROMATIC:Int        = 0x1ffffff;
        
        static var ST_PERFECT:Int          = 0x10a10a1;
        
        static var ST_DPERFECT:Int         = 0x14a14a1;
        
        static var ST_POWER:Int            = 0x1081081;
        
        static var ST_UNISON:Int           = 0x1001001;
        
        static var ST_DORIAN:Int           = 0x16ad6ad;
        
        static var ST_PHRIGIAN:Int         = 0x15ab5ab;
        
        static var ST_LYDIAN:Int           = 0x1ad5ad5;
        
        static var ST_MIXOLYDIAN:Int       = 0x16b56b5;
        
        static var ST_LOCRIAN:Int          = 0x156b56b;
        
        static var ST_GYPSY:Int            = 0x19b39b3;
        
        static var ST_SPANISH:Int          = 0x15ab5ab;
        
        static var ST_HANGARIAN:Int        = 0x1acdacd;
        
        static var ST_JAPANESE:Int         = 0x14a54a5;
        
        static var ST_RYUKYU:Int           = 0x18b18b1;
        
        
        static var _scaleTableDictionary:Dynamic = {
            "m"    : ST_MINOR,
            "nm"   : ST_MINOR,
            "aeo"  : ST_MINOR,
            "hm"   : ST_HARMONIC_MINOR,
            "mm"   : ST_MELODIC_MINOR,
            "p"    : ST_PENTATONIC,
            "mp"   : ST_MINOR_PENTATONIC,
            "b"    : ST_BLUE_NOTE,
            "d"    : ST_DIMINISH,
            "cd"   : ST_COMB_DIMINISH,
            "w"    : ST_WHOLE_TONE,
            "c"    : ST_CHROMATIC,
            "sus4" : ST_PERFECT,
            "sus47": ST_DPERFECT,
            "5"    : ST_POWER,
            "u"    : ST_UNISON,
            "dor"  : ST_DORIAN,
            "phr"  : ST_PHRIGIAN,
            "lyd"  : ST_LYDIAN,
            "mix"  : ST_MIXOLYDIAN,
            "loc"  : ST_LOCRIAN,
            "gyp"  : ST_GYPSY,
            "spa"  : ST_SPANISH,
            "han"  : ST_HANGARIAN,
            "jap"  : ST_JAPANESE,
            "ryu"  : ST_RYUKYU
        };
        
        
        static var _noteNames:Array<Dynamic> = ["C", "C+", "D", "D+", "E", "F", "F+", "G", "G+", "A", "A+", "B"];
        
        
        
        
    
    
        
        var _scaleTable:Int;
        
        var _scaleNotes: Array<Int>;
        
        var _tensionNotes: Array<Int>;
        
        var _scaleName:String;
        
        var _defaultCenterOctave:Int;
        
        
        
        
    
    
        
        public function name() : String { return _noteNames[_scaleNotes[0]%12] + _scaleName; }
        public function name(str:String) : Void {
            if (str == null || str == "") {
                _scaleName = "";
                _scaleTable = ST_MAJOR;
                this.rootNote = _defaultCenterOctave*12;
                return;
            }
            
            var rex:RegExp = /(o[0-9])?([A-Ga-g])([+#\-b])?([a-z0-9]+)?/;
            var mat:Dynamic = rex.exec(str);
            var i:Int;
            if (mat) {
                _scaleName = str;
                var note:Int = [9,11,0,2,4,5,7][String(mat[2]).toLowerCase().charCodeAt() - 'a'.charCodeAt()];
                if (mat[3]) {
                    if (mat[3]=='+' || mat[3]=='#') note++;
                    else if (mat[3]=='-') note--;
                }
                if (note < 0) note += 12;
                else if (note > 11) note -= 12;
                if (mat[1]) note += Std.int(mat[1].charAt(1)) * 12;
                else note += _defaultCenterOctave*12;
                
                if (mat[4]) {
                    if (!(mat[4] in _scaleTableDictionary)) throw _errorInvalidScaleName(str);
                    _scaleTable = _scaleTableDictionary[mat[4]];
                    _scaleName = mat[4];
                } else {
                    _scaleTable = ST_MAJOR;
                    _scaleName = "";
                }
                this.rootNote = note;
            } else {
                throw _errorInvalidScaleName(str);
            }
        }
        
        
        
        public function centerOctave() : Int { return Std.int(_scaleNotes[0]/12); }
        public function centerOctave(oct:Int) : Void {
            _defaultCenterOctave = oct;
            var prevoct:Int = Std.int(_scaleNotes[0]/12);
            if (prevoct == oct) return;
            var i:Int, offset:Int = (oct - prevoct) * 12;
           i=0;
 while( i<_scaleNotes.length){ _scaleNotes[i] += offset; i++;
}
           i=0;
 while( i<_tensionNotes.length){ _tensionNotes[i] += offset; i++;
}
        }
        
        
        
        public function rootNote() : Int { return _scaleNotes[0]; }
        public function rootNote(note:Int) : Void {
            _scaleNotes.splice(0, _scaleNotes.length);
            _tensionNotes.splice(0, _tensionNotes.length);
           var i:Int=0;
 while( i<12){ if (_scaleTable & (1<<i)) _scaleNotes.push(i + note); i++;
}
           ;
 while( i<24){ if (_scaleTable & (1<<i)) _tensionNotes.push(i + note); i++;
}
        }
        
        
        
        public function bassNote() : Int { return _scaleNotes[0]; }
        public function bassNote(note:Int) : Void { rootNote = note; }
        
        
        
        
        
    
    
        
        function Scale(scaleName:String = "", defaultCenterOctave:Int = 5)
        {
            _scaleNotes = new Array<Int>();
            _tensionNotes = new Array<Int>();
            _defaultCenterOctave = defaultCenterOctave;
            this.name = scaleName;
        }
        
        
        
        public function setScaleTable(name:String, rootNote:Int, table:Array<Dynamic>) : Void
        {
            _scaleName = name;
            var i:Int, imax:Int = (table.length<25) ? table.length : 25;
            _scaleTable = 0;
           i=0;
 while( i<imax){ if (table[i]) _scaleTable |= (1<<i); i++;
}
            this.rootNote = rootNote;
        }
        
        
        
        
    
    
        
        public function check(note:Int) : Bool
        {
            note -= _scaleNotes[0];
                 if (note < 0)  note = (note + 144) % 12;
            else if (note > 24) note = ((note - 12) % 12) + 12;
            return ((_scaleTable & (1<<note)) != 0);
        }
        
        
        
        public function shift(note:Int) : Int
        {
            var n:Int = note - _scaleNotes[0];
                 if (n < 0)  n = (n + 144) % 12;
            else if (n > 23) n = ((n - 12) % 12) + 12;
            if ((_scaleTable & (1<<n)) != 0) return note;
            var up:Int, dw:Int;
           up=n+1;
 while( up<24 && (_scaleTable & (1<<up)) == 0){ up++;} 
           dw=n-1;
 while( dw>=0 && (_scaleTable & (1<<dw)) == 0){ dw--;} 
            return note - n + (((n-dw)<=(up-n)) ? dw : up);
        }
        
        
        
        public function getScaleIndex(note:Int) : Int
        {
            return 0;
        }
        
        
        
        public function getNote(index:Int) : Int
        {
            var imax:Int = _scaleNotes.length, octaveShift:Int = 0;
            if (index < 0) {
                octaveShift = Std.int((index-imax+1)/ imax);
                index -= octaveShift * imax;
                return _scaleNotes[index] + octaveShift*12;
            }
            if (index < imax) {
                return _scaleNotes[index];
            }
            
            index -= imax;
            imax = _tensionNotes.length;
            if (index < imax) {
                return _tensionNotes[index];
            }
            
            octaveShift = Std.int(index / imax);
            index -= octaveShift * imax;
            return _tensionNotes[index] + octaveShift*12;
        }
        
        
        
        public function copyFrom(src:Scale) : Scale
        {
            _scaleName = src._scaleName;
            _scaleTable = src._scaleTable;
            var i:Int, imax:Int = src._scaleNotes.length;
            _scaleNotes.length = imax;
           i=0;
 while( i<imax){
                _scaleNotes[i] = src._scaleNotes[i];
             i++;
}
            imax = src._tensionNotes.length;
            _tensionNotes.length = imax;
           i=0;
 while( i<imax){
                _tensionNotes[i] = src._tensionNotes[i];
             i++;
}
            return this;
        }
        
        
        
        
    
    
        
        function _errorInvalidScaleName(name:String) : Error
        {
            return new Error("Scale; Invalid scale name. '" + name +"'");
        }
    }



