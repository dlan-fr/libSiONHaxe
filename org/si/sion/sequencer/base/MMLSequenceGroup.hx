





package org.si.sion.sequencer.base ;
    import flash.utils.ByteArray;
	import flash.errors.Error;
    
    
    
    class MMLSequenceGroup
    {
    
        
        
        
        
    
    
        
        private var _term:MMLSequence;
        
        
        private var _owner:MMLData;
        
        
        
        
    
    
        
        public function sequenceCount() : Int
        {
            return _sequences.length;
        }
        
        
        
        public function headSequence() : MMLSequence
        {
            return _term.nextSequence();
        }
        

        
        public function tickCount() : Int {
            var ml:Int, tc:Int = 0;
            for (seq in _sequences) {
                ml = seq.mmlLength();
                if (ml > tc) tc = ml;
            }
            return tc;
        }
        

        
        public function hasRepeatAll() : Bool {
            for (seq in _sequences) {
                if (seq.hasRepeatAll()) return true;
            }
            return false;
        }
        
        
        
        
    
    
        public function new(owner:MMLData)
        {
            _owner = owner;
            _sequences = new Array<MMLSequence>();
            _term = new MMLSequence(true);
        }
        
        
        
        
    
    
        
        public function alloc(headEvent:MMLEvent) : Void
        {
            
            var seq:MMLSequence;
            while (headEvent!=null && headEvent.jump!=null) {
                if (headEvent.id != MMLEvent.SEQUENCE_HEAD) {
                    throw new Error("MMLSequence: Unknown error on dividing sequences. " + headEvent);
                }
                seq = appendNewSequence();          
                headEvent = seq._cutout(headEvent); 
                seq._updateMMLString();             
                seq.isActive = true;                
            }
        }
        
        
        
        public function free() : Void
        {
            for (seq in _sequences) {
                seq.free();
                _freeList.push(seq);
            }
			_sequences.splice(0, _sequences.length);
            _term.free();
        }
        
        
        
        public function getSequence(index:Int) : MMLSequence
        {
            if (index >= _sequences.length) return null;
            return _sequences[index];
        }
        
        
        
    
    
        
        private var _sequences: Array<MMLSequence>;
        
        static private var _freeList:Array<Dynamic> = [];
        
        
        
        public function appendNewSequence() : MMLSequence
        {
            var seq:MMLSequence = _newSequence();
            seq._insertBefore(_term);
            seq.isActive = false;   
            return seq;
        }
        
        
        
        public function _newSequence() : MMLSequence
        {
			var tmpseq:MMLSequence = _freeList.pop() ;
            var seq:MMLSequence = (tmpseq != null) ? tmpseq :  new MMLSequence();
            seq._owner = _owner;
            _sequences.push(seq);
            return seq;
        }
    }
