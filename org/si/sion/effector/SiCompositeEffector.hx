





package org.si.sion.effector ;
    
    class SiCompositeEffector extends SiEffectBase
    {
    
    
        private var _effectorSlot: Array<Array<Dynamic>> = null;
        private var _buffer: Array<Array<Float>> = null;
        private var _sendLevel: Array<Float> = null;
        private var _mixLevel: Array<Float> = null;
        
        
        
    
    
        
        public function  slot0(list:Array<Dynamic>) : Void { _effectorSlot[0] = list; }
        
        
        public function  slot1(list:Array<Dynamic>) : Void { _effectorSlot[1] = list; }
        
        
        public function  slot2(list:Array<Dynamic>) : Void { _effectorSlot[2] = list; }
        
        
        public function  slot3(list:Array<Dynamic>) : Void { _effectorSlot[3] = list; }
        
        
        public function  slot4(list:Array<Dynamic>) : Void { _effectorSlot[4] = list; }
        
        
        public function  slot5(list:Array<Dynamic>) : Void { _effectorSlot[5] = list; }
        
        
        public function  slot6(list:Array<Dynamic>) : Void { _effectorSlot[6] = list; }
        
        
        public function  slot7(list:Array<Dynamic>) : Void { _effectorSlot[7] = list; }
        
        
        public function  dry(n:Float) : Void { _sendLevel[0] = n; }
        
        
        public function  masterVolume(n:Float) : Void { _mixLevel[0] = n; }
        
        
        
        
    
    
        
        function new() {
        }
        
        
        
        
    
    
        
        public function setLevel(slotNum:Int, inputLevel:Float, outputLevel:Float) : Void 
        {
            _sendLevel[slotNum] = inputLevel;
            _mixLevel[slotNum] = outputLevel;
        }
        
        
        
        override public function initialize() : Void
        {
            _effectorSlot = new Array<Array<Dynamic>>();
            _buffer = new Array<Array<Float>>();
            _sendLevel = new Array<Float>();
            _mixLevel  = new Array<Float>();
           var i:Int=0;
 while( i<8){
                _effectorSlot[i] = null;
                _buffer[i] = new Array<Float>();
                _mixLevel[i] = _sendLevel[i] = 1;
             i++;
}
        }
        
        
        
        override public function mmlCallback(args: Array<Float>) : Void
        {
        }
        
        
        
        override public function prepareProcess() : Int
        {
            var i:Int, imax:Int, slotNum:Int, list:Array<Dynamic>;
           slotNum=0;
 while( slotNum<8){
                if (_effectorSlot[slotNum] != null) {
                    list = _effectorSlot[slotNum];
                    imax = list.length;
                   i=0;
 while( i<imax){ list[i].prepareProcess(); i++;
}
                }
             slotNum++;
}
            return 2;
        }
        
        
        
        override public function process(channels:Int, buffer: Array<Float>, startIndex:Int, length:Int) : Int
        {
            var i:Int, j:Int, imax:Int, slotNum:Int, list:Array<Dynamic>, str: Array<Float>, ch:Int, lvl:Float;
			str = new Array<Float>();
           slotNum=1;
 while( slotNum<8){
                if (_effectorSlot[slotNum] != null) {
                    str = _buffer[slotNum];
                    lvl = _sendLevel[slotNum];
                   // if (str.length < buffer.length) str.length = buffer.length; HAXE PORT
                   i=0;j=startIndex;
 while( i<length){ str[j] = buffer[j] * lvl; i++;j++;
}
                }
             slotNum++;
}
            lvl = _sendLevel[0];
           i=0;j=startIndex;
 while( i<length){ buffer[j] *= lvl; i++;j++;
}
           slotNum=1;
 while( slotNum<8){
                if (_effectorSlot[slotNum] != null) {
                    ch = channels;
                    list = _effectorSlot[slotNum];
                    imax = list.length;
                   i=0;
 while( i<imax){ ch = list[i].process(ch, str[slotNum], startIndex, length); i++;
}
                    lvl = _mixLevel[slotNum];
                   i=0;j=startIndex;
 while( i<length){ buffer[j] += str[j] * lvl; i++;j++;
}
                }
             slotNum++;
}
            if (_effectorSlot[0] != null) {
                list = _effectorSlot[0];
                imax = list.length;
               i=0;
 while( i<imax){ channels = list[i].process(channels, buffer, startIndex, length); i++;
}
                if (_mixLevel[0] != 1) {
                    lvl = _mixLevel[0];
                   i=0;j=startIndex;
 while( i<length){ buffer[j] *= lvl; i++;j++;
}
                }

            }

            return channels;
        }
    }


