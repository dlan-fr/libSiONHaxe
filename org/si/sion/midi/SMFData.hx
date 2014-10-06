












package org.si.sion.midi ;
    import flash.utils.ByteArray;
    import flash.net.*;
    import flash.events.*;
    
    
    
    class SMFData extends EventDispatcher
    {
    
    
        
        public var format:Int;
        
        public var numTracks:Int;
        
        public var resolution:Int;
        
        public var bpm:Int = 0;
        
        public var text:String = "";
        
        public var title:String = null;
        
        public var author:String = null;
        
        public var signature_n:Int = 0;
        
        public var signature_d:Int = 0;
        
        public var measures:Float = 0;
        
        public var tracks: Array<SMFTrack> = new Array<SMFTrack>();
        
        private var _urlLoader:URLLoader;
        
        
        
        
    
    
        
        public function isAvailable() : Bool { return (numTracks > 0); }
        
        
        
        override public function toString():String
        {
            var text:String = "";
            text += "format : SMF" + format + "\n";
            text += "numTracks : " + numTracks + "\n";
            text += "resolution : " + (resolution>>2) + "\n";
            text += "title : " + title + "\n";
            text += "author : " + author + "\n";
            text += "signature : " + signature_n + "/" + signature_d + "\n";
            text += "BPM : " + bpm + "\n";
            return text;
        }
        
        
        
        
    
    
        
        function new()
        {
            clear();
			super();
        }
        
        
        
        
    
    
        
        public function clear() : SMFData
        {
            format = 0;
            numTracks = 0;
            resolution = 0;
            bpm = 0;
            text = null;
            title = null;
            author = null;
            signature_n = 0;
            signature_d = 0;
            measures = 0;
			tracks.splice(0, tracks.length);
            
            return this;
        }
        
        
        
        public function load(url:URLRequest) : Void
        {
            var byteArray:ByteArray = new ByteArray();
            _urlLoader = new URLLoader();
            _urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
            _urlLoader.addEventListener(Event.COMPLETE, _onComplete);
            _urlLoader.addEventListener(ProgressEvent.PROGRESS, _onProgress);
            _urlLoader.addEventListener(IOErrorEvent.IO_ERROR, _onError);
            _urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onError);
            _urlLoader.load(url);
        }
        
        
        
        public function loadBytes(bytes:ByteArray) : SMFData
        {
            bytes.position = 0;
            clear();
            
            var tr:Int, len:Int, temp:ByteArray = new ByteArray();
            while (bytes.bytesAvailable > 0) {
                var type:String = bytes.readMultiByte(4, "us-ascii");
                switch(type) {
                case "MThd":
                    bytes.position += 4;
                    format = bytes.readUnsignedShort();
                    numTracks = bytes.readUnsignedShort();
                    resolution = bytes.readUnsignedShort() << 2;
                    break;
                case "MTrk":
                    len = bytes.readUnsignedInt();
                    bytes.readBytes(temp, 0, len);
                    tracks.push(new SMFTrack(this, tracks.length, temp));
                    break;
                default:
                    len = bytes.readUnsignedInt();
                    bytes.position += len;
                    break;
                }
            }

            if (text == null) text = "";
            if (title == null) title = "";
            if (author == null) author = "";
            
            if (resolution > 0) {
                len = 0;
               tr=0;
 while( tr<tracks.length){
                    if (len < tracks[tr].totalTime) len = tracks[tr].totalTime;
                 tr++;
}
                measures = len / resolution;
            }
            
            dispatchEvent(new Event(Event.COMPLETE));
            
            return this;
        }
        
        
        
        
    
    
        private function _onProgress(e:ProgressEvent) : Void
        {
            dispatchEvent(e.clone());
        }
        
        
        private function _onComplete(e:Event) : Void
        {
            _removeAllListeners();
            loadBytes(_urlLoader.data);
        }
        
        
        private function _onError(e:ErrorEvent) : Void
        {
            _removeAllListeners();
            dispatchEvent(e.clone());
        }
        
        
        private function _removeAllListeners() : Void
        {
            _urlLoader.removeEventListener(Event.COMPLETE, _onComplete);
            _urlLoader.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
            _urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, _onError);
            _urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _onError);
        }
    }



