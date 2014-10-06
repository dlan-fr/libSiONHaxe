












package org.si.sion.midi ;
    import flash.utils.ByteArray;
    
    
    
    class SMFEvent
    {
    
    
        inline static public var NOTE_OFF:Int = 0x80;
        inline static public var NOTE_ON:Int = 0x90;
        inline static public var KEY_PRESSURE:Int = 0xa0;
        inline static public var CONTROL_CHANGE:Int = 0xb0;
        inline static public var PROGRAM_CHANGE:Int = 0xc0;
        inline static public var CHANNEL_PRESSURE:Int = 0xd0;
        inline static public var PITCH_BEND:Int = 0xe0;
        inline static public var SYSTEM_EXCLUSIVE:Int = 0xf0;
        inline static public var SYSTEM_EXCLUSIVE_SHORT:Int = 0xf7;
        inline static public var META:Int = 0xff;
        
        inline static public var META_SEQNUM:Int = 0xff00;
        inline static public var META_TEXT:Int = 0xff01;
        inline static public var META_AUTHOR:Int = 0xff02;
        inline static public var META_TITLE:Int = 0xff03;
        inline static public var META_INSTRUMENT:Int = 0xff04;
        inline static public var META_LYLICS:Int = 0xff05;
        inline static public var META_MARKER:Int = 0xff06;
        inline static public var META_CUE:Int = 0xff07;
        inline static public var META_PROGRAM_NAME:Int = 0xff08;
        inline static public var META_DEVICE_NAME:Int = 0xff09;
        inline static public var META_CHANNEL:Int = 0xff20;
        inline static public var META_PORT:Int = 0xff21;
        inline static public var META_TRACK_END:Int = 0xff2f;
        inline static public var META_TEMPO:Int = 0xff51;
        inline static public var META_SMPTE_OFFSET:Int = 0xff54;
        inline static public var META_TIME_SIGNATURE:Int = 0xff58;
        inline static public var META_KEY_SIGNATURE:Int = 0xff59;
        inline static public var META_SEQUENCER_SPEC:Int = 0xff7f;
        
        inline static public var CC_BANK_SELECT_MSB:Int = 0;
        inline static public var CC_BANK_SELECT_LSB:Int = 32;
        inline static public var CC_MODULATION:Int = 1;
        inline static public var CC_PORTAMENTO_TIME:Int = 5;
        inline static public var CC_DATA_ENTRY_MSB:Int = 6;
        inline static public var CC_DATA_ENTRY_LSB:Int = 38;
        inline static public var CC_VOLUME:Int = 7;
        inline static public var CC_BALANCE:Int = 8;
        inline static public var CC_PANPOD:Int = 10;
        inline static public var CC_EXPRESSION:Int = 11;
        inline static public var CC_SUSTAIN_PEDAL:Int = 64;
        inline static public var CC_PORTAMENTO:Int = 65;
        inline static public var CC_SOSTENUTO_PEDAL:Int = 66;
        inline static public var CC_SOFT_PEDAL:Int = 67;
        inline static public var CC_RESONANCE:Int = 71;
        inline static public var CC_RELEASE_TIME:Int = 72;
        inline static public var CC_ATTACK_TIME:Int = 73;
        inline static public var CC_CUTOFF_FREQ:Int = 74;
        inline static public var CC_DECAY_TIME:Int = 75;
        inline static public var CC_PROTAMENTO_CONTROL:Int = 84;
        inline static public var CC_REVERB_SEND:Int = 91;
        inline static public var CC_CHORUS_SEND:Int = 93;
        inline static public var CC_DELAY_SEND:Int = 94;
        inline static public var CC_NRPN_LSB:Int = 98;
        inline static public var CC_NRPN_MSB:Int = 99;
        inline static public var CC_RPN_LSB:Int = 100;
        inline static public var CC_RPN_MSB:Int = 101;
        
        inline static public var RPN_PITCHBEND_SENCE:Int = 0;
        inline static public var RPN_FINE_TUNE:Int = 1;
        inline static public var RPN_COARSE_TUNE:Int = 2;
        
        static private var _noteText: Array<String> = ["c ","c+","d ","d+","e ","f ","f+","g ","g+","a ","a+","b "];
        
        
        
    
    
        public var type:Int = 0;
        public var value:Int = 0;
        public var byteArray:ByteArray = null;
        
        public var deltaTime:Int = 0;
        public var time:Int = 0;
        
        
        
        
    
    
        
        public function channel() : Int { return (type >= SYSTEM_EXCLUSIVE) ? 0 : (type & 0x0f); }
        
        
        public function note() : Int { return value >> 16; }
        
        
        public function velocity() : Int { return value & 0x7f; }
        
        
        public function get_text() : String { return (byteArray != null) ? byteArray.readUTF() : ""; }
        public function text(str:String) : Void {
            if (byteArray == null) byteArray = new ByteArray();
            byteArray.writeUTF(str);
        }
        
        
        
        public function toString() : String
        {
			var ret:String ;
            if ((type & 0xff00) != 0) {
                switch(type & 0xf0) {
                case meta_tempo:
                    return "bpm(" + Std.string(value) + ")";
                }
            } else {
                ret = "ch" + Std.string((type & 15)) + ":";
				var n:Int, v:Int;
                switch(type & 0xf0) {
                case NOTE_ON:
                    return ret + "ON(" + Std.string(note) + ") " + Std.string(velocity);
                case NOTE_OFF:
                    return ret + "OF(" + Std.string(note) + ") " + Std.string(velocity);
                case CONTROL_CHANGE:
                    return ret + "CC(" + Std.string((value>>16)) + ") " + Std.string((value&0xffff));
                case PROGRAM_CHANGE:
                    return ret + "PC(" + Std.string(value) + ") ";
                case SYSTEM_EXCLUSIVE:
                    var text:String = "SX:";
                    if (byteArray != null) {
                        byteArray.position = 0;
                        while (byteArray.bytesAvailable>0) {
                            text += Std.string(byteArray.readUnsignedByte())+" ";
                        }
                    }
                    return ret + text;
                }
            }

            return ret + "#" + Std.string(type) + "(" + Std.string(value) + ")";
        }
        
        
        
        
    
    
        public function new(type:Int, value:Int, deltaTime:Int, time:Int) 
        {
            this.type = type;
            this.value = value;
            this.deltaTime = deltaTime;
            this.time = time;
        }
    }


