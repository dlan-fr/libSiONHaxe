








package org.si.utils ;
    import flash.events.EventDispatcher;
    import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.errors.Error;
	import flash.events.SecurityErrorEvent;
	
    import flash.utils.ByteArray;
    
    
    
    class AbstructLoader extends EventDispatcher
    {
    
    
        
        var _loader:URLLoader;
        
        var _bytesTotal:Float;
        
        var _bytesLoaded:Float;
        
        var _isLoadCompleted:Bool;
        
        var _childLoaders:Array<Dynamic>;
        
        var _eventPriority:Int;
        
        
        
        
    
    
        
        function new(priority:Int = 0)
        {
            _loader = new URLLoader();
            _bytesTotal = 0;
            _bytesLoaded = 0;
            _isLoadCompleted = false;
            _childLoaders = [];
            _eventPriority = priority;
			super();
        }
        
        
        
        
    
    
        
        public function load(url:URLRequest) : Void
        {
            _loader.close();
            _bytesTotal = 0;
            _bytesLoaded = 0;
            _isLoadCompleted = false;
            _addAllListeners();
            _loader.load(url);
        }
        
        
        
        public function addChild(child:AbstructLoader) : Void
        {
            _childLoaders.push(child);
            child.addEventListener(Event.COMPLETE, _onChildComplete);
        }
        
        
        
        
    
    
        
        function onComplete() : Void { }
        
        
        
        
    
    
        private function _onProgress(e:ProgressEvent) : Void
        {
            _bytesTotal  = e.bytesTotal;
            _bytesLoaded = e.bytesLoaded;
            _isLoadCompleted = false;
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _bytesLoaded, _bytesTotal));
        }
        
        
        private function _onComplete(e:Event) : Void
        {
            _removeAllListeners();
            _bytesLoaded = _bytesTotal;
            _isLoadCompleted = true;
            onComplete();
            if (_childLoaders.length == 0) {
                dispatchEvent(new Event(Event.COMPLETE));
            }
        }

    
        private function _onError(e:ErrorEvent) : Void
        {
            _removeAllListeners();
            dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.toString()));
        }
        
        
        private function _onChildComplete(e:Event) : Void
        {
            var index:Int = _childLoaders.indexOf(e.target);
            if (index == -1) throw new Error("AbstructLoader; unkown error, children mismatched.");
            _childLoaders.splice(index, 1);
            if (_childLoaders.length == 0 && _isLoadCompleted) {
                dispatchEvent(new Event(Event.COMPLETE));
            }
        }
        
        
        private function _addAllListeners() : Void 
        {
            _loader.addEventListener(Event.COMPLETE, _onComplete, false, _eventPriority);
            _loader.addEventListener(ProgressEvent.PROGRESS, _onProgress, false, _eventPriority);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, _onError, false, _eventPriority);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onError, false, _eventPriority);
        }
        
        
        private function _removeAllListeners() : Void 
        {
            _loader.removeEventListener(Event.COMPLETE, _onComplete);
            _loader.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
            _loader.removeEventListener(IOErrorEvent.IO_ERROR, _onError);
            _loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _onError);
        }
    }


