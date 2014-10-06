





package org.si.sion.sequencer.base ;
    
    class MMLEvent
    {
    
    
        
        inline static public var NOP          :Int = 0;
        inline static public var PROCESS      :Int = 1;
        inline static public var REST         :Int = 2;
        inline static public var NOTE         :Int = 3;
        
        
        
        
        inline static public var KEY_ON_DELAY :Int = 8;
        inline static public var QUANT_RATIO  :Int = 9;
        inline static public var QUANT_COUNT  :Int = 10;
        inline static public var VOLUME       :Int = 11;
        inline static public var VOLUME_SHIFT :Int = 12;
        inline static public var FINE_VOLUME  :Int = 13;
        inline static public var SLUR         :Int = 14;
        inline static public var SLUR_WEAK    :Int = 15;
        inline static public var PITCHBEND    :Int = 16;
        inline static public var REPEAT_BEGIN :Int = 17;
        inline static public var REPEAT_BREAK :Int = 18;
        inline static public var REPEAT_END   :Int = 19;
        inline static public var MOD_TYPE     :Int = 20;
        inline static public var MOD_PARAM    :Int = 21;
        inline static public var INPUT_PIPE   :Int = 22;
        inline static public var OUTPUT_PIPE  :Int = 23;
        inline static public var REPEAT_ALL   :Int = 24;
        inline static public var PARAMETER    :Int = 25;
        inline static public var SEQUENCE_HEAD:Int = 26;
        inline static public var SEQUENCE_TAIL:Int = 27;
        inline static public var SYSTEM_EVENT :Int = 28;
        inline static public var TABLE_EVENT  :Int = 29;
        inline static public var GLOBAL_WAIT  :Int = 30;
        inline static public var TEMPO        :Int = 31;
        inline static public var TIMER        :Int = 32;
        inline static public var REGISTER     :Int = 33;
        inline static public var DEBUG_INFO   :Int = 34;
        inline static public var INTERNAL_CALL:Int = 35;
        inline static public var INTERNAL_WAIT:Int = 36;
        inline static public var DRIVER_NOTE  :Int = 37;
        
        
        
        inline static public var USER_DEFINE:Int = 64;

        
        inline static public var COMMAND_MAX:Int = 128;
        
        
        
        
    
    
        
        static public var nopEvent:MMLEvent = (new MMLEvent()).initialize(MMLEvent.NOP, 0, 0);
        
        
        public var id:Int = 0;
        
        public var data:Int = 0;
        
        public var length:Int = 0;
        
        public var next:MMLEvent;
        
        public var jump:MMLEvent;
        
        
        

    
    
        
        public function new(id:Int=0, data:Int=0, length:Int=0)
        {
            if (id > 1) initialize(id, data, length);
        }
        
        
        
        public function toString() : String
        {
            return "#" + Std.string(id) + "; " + Std.string(data);
        }
        
        
        
        public function initialize(id:Int, data:Int, length:Int) : MMLEvent
        {
            this.id     = id & 0x7f;
            this.data   = data;
            this.length = length;
            this.next = null;
            this.jump = null;
            return this;
        }
        
        
        
        public function getParameters(param: Array<Int>, length:Int) : MMLEvent
        {
            var i:Int, e:MMLEvent = this;
            
            i = 0;
            while (i<length) {
                param[i++] = e.data;
                if (e.next == null || e.next.id != PARAMETER) break;
                e = e.next;
            }
            while (i<length) {
                param[i++] = -2147483647;
            }
            return e;
        }

        
        
        public function free() : Void
        {
            if (next == null) MMLParser._freeEvent(this);
        }
        
        
        
        public function pack() : Int
        {
            return 0;
        }
        
        
        
        public function unpack(d:Int) : Void
        {
        }
    }



