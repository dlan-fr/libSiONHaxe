






package org.si.sion.utils ;
    
    class Chord extends Scale
    {
    
    
        
        static var CT_MAJOR  :Int = 0x1091091;
        
        static var CT_MINOR  :Int = 0x1089089;
        
        static var CT_7TH    :Int = 0x0490491;
        
        static var CT_MIN7   :Int = 0x0488489;
        
        static var CT_MAJ7   :Int = 0x0890891;
        
        static var CT_MM7    :Int = 0x0888889;
        
        static var CT_9TH    :Int = 0x0484491;
        
        static var CT_MIN9   :Int = 0x0484489;
        
        static var CT_MAJ9   :Int = 0x0884891;
        
        static var CT_MM9    :Int = 0x0884889;
        
        static var CT_ADD9   :Int = 0x1084091;
        
        static var CT_MINADD9:Int = 0x1084089;
        
        static var CT_69TH   :Int = 0x1204211;
        
        static var CT_MIN69  :Int = 0x1204209;
        
        static var CT_SUS4   :Int = 0x10a10a1;
        
        static var CT_SUS47  :Int = 0x04a04a1;
        
        static var CT_DIM    :Int = 0x1489489;
        
        static var CT_AUG    :Int = 0x1111111;
        
        
        static var _chordTableDictionary:Dynamic = {
            "m":     CT_MINOR,
            "7":     CT_7TH,
            "m7":    CT_MIN7,
            "M7":    CT_MAJ7,
            "mM7":   CT_MM7,
            "9":     CT_9TH,
            "m9":    CT_MIN9,
            "M9":    CT_MAJ9,
            "mM9":   CT_MM9,
            "add9":  CT_ADD9,
            "madd9": CT_MINADD9,
            "69":    CT_69TH,
            "m69":   CT_MIN69,
            "sus4":  CT_SUS4,
            "sus47": CT_SUS47,
            "dim":   CT_DIM,
            "arg":   CT_AUG
        }
        
        
        
        
    
    
        
        var _bassNoteOffset:Int;
        
        
        
        
    
    
        
        override public function name() : String {
            var rn:Int = _scaleNotes[0] % 12;
            if (_bassNoteOffset == 0) return _noteNames[rn] + _scaleName;
            return _noteNames[rn] + _scaleName + "/" + _noteNames[(rn + _bassNoteOffset)%12];
        }
        override public function name(str:String) : Void {
            if (str == null || str == "") {
                _scaleName = "";
                _scaleTable = CT_MAJOR;
                this.rootNote = 60;
                return;
            }
            
            var rex:RegExp = /(o[0-9])?([A-Ga-g])([+#\-b])?([adgimMsru4679]+)?(,([0-9]+[+#\-]?))?(,([0-9]+[+#\-]?))?/;
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
                else note += 60;
                
                if (mat[4]) {
                    if (!(mat[4] in _chordTableDictionary)) throw _errorInvalidChordName(str);
                    _scaleTable = _chordTableDictionary[mat[4]];
                    _scaleName = mat[4];
                } else {
                    _scaleTable = CT_MAJOR;
                    _scaleName = "";
                }
                this.rootNote = note;
            } else {
                throw _errorInvalidChordName(str);
            }
        }
        
        
        
        override public function bassNote() : Int { return _scaleNotes[0] + _bassNoteOffset; }
        override public function bassNote(note:Int) : Void { _bassNoteOffset = note - _scaleNotes[0]; }
        
        
        
        
    
    
        
        function new(chordName:String = "", defaultCenterOctave:Int = 5)
        {
            super("", defaultCenterOctave);
            this.name = chordName;
            _bassNoteOffset = 0;
        }
        
        
        
        
    
    
        
        override public function copyFrom(src:Scale) : Scale {
            super.copyFrom(src);
            if (Std.is(src,Chord)) {
                _bassNoteOffset = (cast(src,Chord))._bassNoteOffset;
            }
            return this;
        }
        
        
        
        
    
    
        
        function _errorInvalidChordName(name:String) : Error
        {
            return new Error("Chord; Invalid chord name. '" + name +"'");
        }
    }



