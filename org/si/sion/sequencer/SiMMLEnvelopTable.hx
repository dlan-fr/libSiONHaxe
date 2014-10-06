





package org.si.sion.sequencer ;
    import org.si.utils.SLLint;
    import org.si.sion.utils.Translator;
    
    
    
    class SiMMLEnvelopTable
    {
    
    
        
        public var head:SLLint;
        
        public var tail:SLLint;
        
        
        
        
        
    
    
        
        public function new(table: Array<Int>=null, loopPoint:Int=-1)
        {
            if (table != null) {
                var loop:SLLint, i:Int, imax:Int = table.length;
                head = tail = SLLint.allocList(imax);
                loop = null;
               i=0;
 while( i<imax-1){
                    if (loopPoint == i) loop = tail;
                    tail.i = table[i];
                    tail = tail.next;
                 i++;
}
                tail.i = table[i];
                tail.next = loop;
            } else {
                head = null;
                tail = null;
            }
        }
        
        
        
        
    
    
        
        public function toVector(length:Int, min:Int=-65536, max:Int=65536, dst: Array<Int>=null) : Array<Int>
        {
            if (dst == null) dst = new Array<Int>();
            //dst.length = length; HAXE PORT
            var i:Int, n:Int, ptr:SLLint=head;
           i=0;
 while( i<length){
                if (ptr != null) {
                    n = ptr.i;
                    ptr = ptr.next;
                } else {
                    n = 0;
                }
                if (n < min) n = min;
                else if (n > max) n = max;
                dst[i] = n;
             i++;
}
            return dst;
        }
        
        
        
        
        public function free() : Void
        {
            if (head != null) {
                tail.next = null;
                SLLint.freeList(head);
                head = null;
                tail = null;
            }
        }
        
        
        
        public function copyFrom(src:SiMMLEnvelopTable) : SiMMLEnvelopTable
        {
            free();
            if (src.head != null) {
               var pSrc:SLLint = src.head; 
			   var pDst:SLLint = null;
 while( pSrc != src.tail){
                    var p:SLLint = SLLint.alloc(pSrc.i);
                    if (pDst != null) {
                        pDst.next = p;
                        pDst = p;
                    } else {
                        head = p;
                        pDst = head;
                    }
                 pSrc = pSrc.next;
}
            }
            return this;
        }
        
        
	    function _initialize(head_:SLLint, tail_:SLLint) : Void
        {
            head = head_;
            tail = tail_;
            
            if (tail.next == null) tail.next = tail;
        }
        
        public function parseMML(tableNumbers:String, postfix:String, maxIndex:Int=65536) : SiMMLEnvelopTable
        {
            var res:Dynamic = Translator.parseTableNumbers(tableNumbers, postfix, maxIndex);
            if (res.head) _initialize(res.head, res.tail);
            return this;
        }
        
        
        
        
    
    
        
      
    }


