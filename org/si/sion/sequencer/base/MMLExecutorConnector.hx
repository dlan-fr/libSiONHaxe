





package org.si.sion.sequencer.base ;
	import flash.display.DisplayObjectContainer;
    import org.si.sion.module.SiOPMModule;
    import org.si.sion.module.channels.SiOPMChannelBase;
	import flash.errors.Error;
	import org.si.sion.sequencer.base.MMLExecutorConnector.MECElement;
    
    
    
    class MMLExecutorConnector
    {
    
        
    
    
        private var _sequenceCount:Int;    
        private var _executorCount:Int;    
        private var _firstElem:MECElement; 
        
        
        
        
    
    
        
        public function executorCount() : Int { return _executorCount; }
        
        public function sequenceCount() : Int { return _sequenceCount; }
        
        
        
        
    
    
        public function new()
        {
            _firstElem = null;
            _executorCount = 0;
            _sequenceCount = 0;
        }
        
        
        
        
		function _free(elem:MECElement) : Void {
                if (elem.firstChild != null) _free(elem.firstChild);
                if (elem.next != null)       _free(elem.next);
                MECElement.free(elem);
		}
    
        public function clear() : Void
        {

			
            if (_firstElem != null) _free(_firstElem);
          
            _firstElem = null;
            _executorCount = 0;
            _sequenceCount = 0;
        }
        
        
        
        public function parse(form:String) : Void
        {
            var i:Int, imax:Int, prev:MECElement=null, elem:MECElement;
            var alp:String = "abcdefghijklmnopqrstuvwxyz";
            var rex:EReg = ~/(\()?([a-zA-Z])([0-7])?(\)+)?/g;
            
            
            clear();
            
            
            var res:Dynamic = rex.match(form);
            while (res) {
                
                i = alp.indexOf(res[2].toLowerCase());
                if (_sequenceCount <= i) _sequenceCount = i+1;
                _executorCount++;
                elem = MECElement.alloc(i);
                if (res[3]) elem.modulation = Std.int(res[3]);
                else        elem.modulation = 5;
                
                
                if (res[1]) {
                    if (prev == null) throw _errorWrongFormula("'(' in " + form);
                    prev.firstChild = elem;
                    elem.parent = prev;
                } else {
                    if (prev != null) {
                        prev.next = elem;
                        elem.parent = prev.parent;
                    } else {
                        _firstElem = elem;
                    }
                }
                
                
                if (res[4]) {
                    imax = Std.string(res[4]).length;
                   i=0;
 while( i<imax){ 
                        if (elem.parent == null) throw _errorWrongFormula("')' in " + form);
                        elem = elem.parent; 
                     i++;
}
                }
                prev = elem;
                
                res = rex.match(form);
            }
            
            if (prev==null || prev.parent!=null) {
                throw _errorWrongFormula(form);
            }
        }
        
		
		function _connect(seqGroup:MMLSequenceGroup,seqList:Array<Dynamic>,prev:MMLSequence,elem:MECElement, firstOsc:Bool, outPipe:Int) : Void {
                var inPipe:Int = 0;
                
                if (elem.firstChild != null) {
                    inPipe = outPipe + ((firstOsc)?0:1);
                    _connect(seqGroup,seqList,prev,elem.firstChild, true, inPipe);
                }

                
                var preprocess:MMLSequence = seqGroup._newSequence();
                preprocess.initialize();

                
                
                if (outPipe != -1) {
                    preprocess.appendNewEvent(MMLEvent.OUTPUT_PIPE, (firstOsc) ? SiOPMChannelBase.OUTPUT_OVERWRITE : SiOPMChannelBase.OUTPUT_ADD);
                    preprocess.appendNewEvent(MMLEvent.PARAMETER,   outPipe);

                } else {
                    preprocess.appendNewEvent(MMLEvent.OUTPUT_PIPE, SiOPMChannelBase.OUTPUT_STANDARD);
                    preprocess.appendNewEvent(MMLEvent.PARAMETER,   0);

                }
                
                
                if (elem.firstChild != null) {
                    preprocess.appendNewEvent(MMLEvent.INPUT_PIPE, elem.modulation);
                    preprocess.appendNewEvent(MMLEvent.PARAMETER,  inPipe);

                } else {
                    preprocess.appendNewEvent(MMLEvent.INPUT_PIPE, 0);
                    preprocess.appendNewEvent(MMLEvent.PARAMETER,  0);

                }
                
                
                preprocess.connectBefore(seqList[elem.number].headEvent.next);
                
                preprocess._insertAfter(prev);
                prev = preprocess;


                
                if (elem.next != null) _connect(seqGroup,seqList,prev,elem.next, false, outPipe);
            }
        
        
        public function connect(seqGroup:MMLSequenceGroup, prev:MMLSequence) : MMLSequence
        {
            
            var seqList:Array<Dynamic> = new Array<Dynamic>();
			
			
           var i:Int=0;
 while( i<_sequenceCount){
                if (prev.nextSequence == null) throw _errorSequenceNotEnough();
                seqList[i] = prev.nextSequence;
                prev.nextSequence()._removeFromChain();
             i++;
}
            
            
            _connect(seqGroup,seqList,prev,_firstElem, false, -1);
            
            return prev;
        }
        
        
        
        
    
    
        private function _errorWrongFormula(form:String) : Error
        {
            return new Error("MMLExecutorConnector error : Wrong connection formula. " + form);
        }
        
        
        private function _errorSequenceNotEnough() : Error
        {
            return new Error("MMLExecutorConnector error: Not enough sequences to connect.");
        }
    }





class MECElement
{
    public var number    :Int;
    public var modulation:Int;
    public var parent    :MECElement = null;
    public var next      :MECElement = null;
    public var firstChild:MECElement = null;
    
    function new()
    {
    }
    
    public function initialize(num:Int) : MECElement
    {
        number = num;
        parent = null;
        next = null;
        firstChild = null;
        modulation = 3;
        return this;
    }
    
    
    
    static private var _freeList:Array<Dynamic> = [];
    static public function free(elem:MECElement) : Void {
        _freeList.push(elem);
    }
    static public function alloc(number:Int) : MECElement {
		var tmp:MECElement = _freeList.pop();
        var elem:MECElement = (tmp != null) ? tmp : new MECElement();
        return elem.initialize(number);
    }
}






