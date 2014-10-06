





package org.si.sion.events ;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.utils.ByteArray;
    import org.si.sion.SiONDriver;
    import org.si.sion.SiONData;
    
    
    
    class SiONEvent extends Event 
    {
    
    
        
        inline public static var QUEUE_PROGRESS:String = 'queueProgress';
        
        
        
        inline public static var QUEUE_COMPLETE:String = 'queueComplete';
        
        
        
        inline public static var QUEUE_CANCEL:String = 'queueCancel';
        
        
        
        inline public static var STREAM:String = 'stream';
        
        
        
        inline public static var STREAM_START:String = 'streamStart';
        
        
        
        inline public static var STREAM_STOP:String = 'streamStop';
        
        
        
        inline public static var FINISH_SEQUENCE:String = 'finishSequence';
        
        
        
        inline public static var FADE_PROGRESS:String = 'fadeProgress';
        
        
        
        inline public static var FADE_IN_COMPLETE:String = 'fadeInComplete';
        
        
        
        inline public static var FADE_OUT_COMPLETE:String = 'fadeOutComplete';
        
        
        
        
    
    
        
        var _driver:SiONDriver;
        
        
        var _streamBuffer:ByteArray;
        
        
        
        
    
    
        
        public function driver():SiONDriver { return _driver; }
        
        
        public function data():SiONData { return _driver.data(); }
        
        
        public function streamBuffer():ByteArray { return _streamBuffer; }
        
        
        
        
    
    
        
        public function new(type:String, driver:SiONDriver, streamBuffer:ByteArray = null, cancelable:Bool = false)
        {
            super(type, false, cancelable);
            _driver = driver;
            _streamBuffer = streamBuffer;
        }
        
        
        
        override public function clone() : Event
        { 
            return new SiONEvent(type, driver(), streamBuffer(), cancelable);
        }
    }


