








package org.si.utils ;
    
    class SLLNumber
    {
    
    
        
        public var n:Float = 0;
        
        public var next:SLLNumber = null;

        
        static private var _freeList:SLLNumber = null;

        
        
        
    
    
        
        function new(n:Float=0)
        {
            this.n = n;
        }
        
        
        
        
    
    
        
        static public function alloc(n:Float=0) : SLLNumber
        {
            var ret:SLLNumber;
            if (_freeList != null) {
                ret = _freeList;
                _freeList = _freeList.next;
                ret.n = n;
                ret.next = null;
            } else {
                ret = new SLLNumber(n);
            }
            return ret;
        }
        
        
        static public function allocList(size:Int, defaultData:Float=0) : SLLNumber
        {
            var ret:SLLNumber = alloc(defaultData),
                elem:SLLNumber = ret;
           var i:Int=1;
 while( i<size){
                elem.next = alloc(defaultData);
                elem = elem.next;
             i++;
}
            return ret;
        }
        
        
        static public function allocRing(size:Int, defaultData:Float=0) : SLLNumber
        {
            var ret:SLLNumber = alloc(defaultData),
                elem:SLLNumber = ret;
           var i:Int=1;
 while( i<size){
                elem.next = alloc(defaultData);
                elem = elem.next;
             i++;
}
            elem.next = ret;
            return ret;
        }
        
        
        static public function newRing(args:Array<Dynamic>) : SLLNumber
        {
            var size:Int = args.length,
                ret:SLLNumber = alloc(args[0]),
                elem:SLLNumber = ret;
           var i:Int=1;
 while( i<size){
                elem.next = alloc(args[i]);
                elem = elem.next;
             i++;
}
            elem.next = ret;
            return ret;
        }
        
        
        
        
    
    
        
        static public function free(elem:SLLNumber) : Void
        {
            elem.next = _freeList;
            _freeList = elem;
        }
        
        
        static public function freeList(firstElem:SLLNumber) : Void
        {
            if (firstElem == null) return;
            var lastElem:SLLNumber = firstElem;
            while (lastElem.next != null) { lastElem = lastElem.next; }
            lastElem.next = _freeList;
            _freeList = firstElem;
        }
        
        
        static public function freeRing(firstElem:SLLNumber) : Void
        {
            if (firstElem == null) return;
            var lastElem:SLLNumber = firstElem;
            while (lastElem.next == firstElem) { lastElem = lastElem.next; }
            lastElem.next = _freeList;
            _freeList = firstElem;
        }
        
        
        
        
    
    
        
        static public function createListPager(firstElem:SLLNumber, fixedSize:Bool) : Array<SLLNumber>
        {
            if (firstElem == null) return null;
            var elem:SLLNumber, i:Int, size:Int;
           size = 1; elem = firstElem;
 while( elem.next != null){ size++;  elem = elem.next;
}
            var pager: Array<SLLNumber> = new Array<SLLNumber>();
            elem = firstElem;
           i=0;
 while( i<size){ pager[i] = elem; elem = elem.next;  i++;
}
            return pager;
        }

        
        static public function createRingPager(firstElem:SLLNumber, fixedSize:Bool) : Array<SLLNumber>
        {
            if (firstElem == null) return null;
            var elem:SLLNumber, i:Int, size:Int;
           size = 1; elem = firstElem;
 while( elem.next != firstElem){ size++;  elem = elem.next;
}
            var pager: Array<SLLNumber> = new Array<SLLNumber>();
            elem = firstElem;
           i=0;
 while( i<size){ pager[i] = elem; elem = elem.next;  i++;
}
            return pager;
        }
    }


