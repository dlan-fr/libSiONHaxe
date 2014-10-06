








package org.si.utils ;
    
    class SLLint
    {
    
    
        
        public var i:Int = 0;
        
        public var next:SLLint = null;

        
        static private var _freeList:SLLint = null;

        
        
        
    
    
        
        function new(i:Int=0)
        {
            this.i = i;
        }
        
        
        
        
    
    
        
        static public function alloc(i:Int=0) : SLLint
        {
            var ret:SLLint;
            if (_freeList != null) {
                ret = _freeList;
                _freeList = _freeList.next;
                ret.i = i;
                ret.next = null;
            } else {
                ret = new SLLint(i);
            }
            return ret;
        }
        
        
        static public function allocList(size:Int, defaultData:Int=0) : SLLint
        {
            var ret:SLLint = alloc(defaultData),
                elem:SLLint = ret;
           var i:Int=1;
 while( i<size){
                elem.next = alloc(defaultData);
                elem = elem.next;
             i++;
}
            return ret;
        }
        
        
        static public function allocRing(size:Int, defaultData:Int=0) : SLLint
        {
            var ret:SLLint = alloc(defaultData),
                elem:SLLint = ret;
           var i:Int=1;
 while( i<size){
                elem.next = alloc(defaultData);
                elem = elem.next;
             i++;
}
            elem.next = ret;
            return ret;
        }
        
        
        static public function newRing(args:Array<Dynamic>) : SLLint
        {
            var size:Int = args.length,
                ret:SLLint = alloc(args[0]),
                elem:SLLint = ret;
           var i:Int=1;
 while( i<size){
                elem.next = alloc(args[i]);
                elem = elem.next;
             i++;
}
            elem.next = ret;
            return ret;
        }
        
        
        
        
    
    
        
        static public function free(elem:SLLint) : Void
        {
            elem.next = _freeList;
            _freeList = elem;
        }
        
        
        static public function freeList(firstElem:SLLint) : Void
        {
            if (firstElem == null) return;
            var lastElem:SLLint = firstElem;
            while (lastElem.next != null) { lastElem = lastElem.next; }
            lastElem.next = _freeList;
            _freeList = firstElem;
        }
        
        
        static public function freeRing(firstElem:SLLint) : Void
        {
            if (firstElem == null) return;
            var lastElem:SLLint = firstElem;
            while (lastElem.next == firstElem) { lastElem = lastElem.next; }
            lastElem.next = _freeList;
            _freeList = firstElem;
        }
        
        
        
        
    
    
        
        static public function createListPager(firstElem:SLLint, fixedSize:Bool) : Array<SLLint>
        {
            if (firstElem == null) return null;
            var elem:SLLint, i:Int, size:Int;
           size = 1; elem = firstElem;
 while( elem.next != null){ size++;  elem = elem.next;
}
            var pager: Array<SLLint> = new Array<SLLint>();
            elem = firstElem;
           i=0;
 while( i<size){ pager[i] = elem; elem = elem.next;  i++;
}
            return pager;
        }

        
        static public function createRingPager(firstElem:SLLint, fixedSize:Bool) : Array<SLLint>
        {
            if (firstElem == null) return null;
            var elem:SLLint, i:Int, size:Int;
           size = 1; elem = firstElem;
 while( elem.next != firstElem){ size++;  elem = elem.next;
}
            var pager: Array<SLLint> = new Array<SLLint>();
            elem = firstElem;
           i=0;
 while( i<size){ pager[i] = elem; elem = elem.next;  i++;
}
            return pager;
        }
    }


