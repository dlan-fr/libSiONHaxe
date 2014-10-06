






package org.si.sion.midi ;
    import org.si.sion.sequencer.SiMMLTrack;
    
    
    
    class MIDIModuleOperator
    {
    
    
        public var next:MIDIModuleOperator;
		public var prev:MIDIModuleOperator;
        public var sionTrack:SiMMLTrack = null;
        public var length:Int = 0;
        public var programNumber:Int;
        public var channel:Int;
        public var note:Int;
        public var isNoteOn:Bool;
        public var drumExcID:Int;
        
        
        
        
    
    
        public function new(sionTrack:SiMMLTrack)
        {
            this.sionTrack = sionTrack;
            next = prev = this;
            programNumber = -1;
            channel = -1;
            note = -1;
            isNoteOn = false;
            drumExcID = -1;
        }
        
        
        
        
    
    
        public function clear() : Void
        {
            prev = next = this;
            length = 0;
        }
        
        
        public function push(ope:MIDIModuleOperator) : Void
        {
            ope.prev = prev;
            ope.next = this;
            prev.next = ope;
            prev = ope;
            length++;
        }
        
        
        public function pop() : MIDIModuleOperator
        {
            if (prev == this) return null;
            var ret:MIDIModuleOperator = prev;
            prev = prev.prev;
            prev.next = this;
            ret.prev = ret.next = ret;
            length--;
            return ret;
        }
        
        
        public function unshift(ope:MIDIModuleOperator) : Void
        {
            ope.prev = this;
            ope.next = next;
            next.prev = ope;
            next = ope;
            length++;
        }
        
        
        public function shift() : MIDIModuleOperator
        {
            if (next == this) return null;
            var ret:MIDIModuleOperator = next;
            next = next.next;
            next.prev = this;
            ret.prev = ret.next = ret;
            length--;
            return ret;
        }
        
        
         public function remove(ope:MIDIModuleOperator) : Void
        {
            ope.prev.next = ope.next;
            ope.next.prev = ope.prev;
            ope.prev = ope.next = this;
            length--;
        }
    }


