








package org.si.sion.utils.soundloader ;
    import flash.events.*;
    import flash.net.URLRequest;
    import flash.media.Sound;
    import flash.utils.ByteArray;
	import flash.errors.Error;
    
    
    
    
    /*[Event(name="complete", type="flash.events.Event")]
    
    [Event(name="error",    type="flash.events.ErrorEvent")]
    
    [Event(name="progress", type="flash.events.ProgressEvent")]*/
    
    
    
    
    class SoundLoader extends EventDispatcher
    {
    
    
        
        var _loaded:Dynamic;
        
        var _preserveList: Array<SoundLoaderFileData>;
        
        var _bytesTotal:Float;
        
        var _bytesLoaded:Int;
        
        var _errorFileCount:Int;
        
        var _loadingFileCount:Int;
        
        var _loadedFileCount:Int;
        
        var _loadedFileData:Dynamic;
        
        public var _eventPriority:Int;
        
        
        var _loadImgFileAsSoundFont:Bool;
        
        var _loadMP3FileAsBinary:Bool;
        
        var _rememberHistory:Bool;
        
        
        
        
    
    
        
        public function hash() : Dynamic { return _loaded; }

        
        public function bytesTotal() : Float { return _bytesTotal; }
        
        
        public function bytesLoaded() : Float { return _bytesLoaded; }
        
        
        public function loadingFileCount() : Int { return _loadingFileCount + _preserveList.length; }
        
        
        public function loadedFileCount() : Int { return _loadedFileCount; }
        
        
        public function loadImgFileAsSoundFont() : Bool { return _loadImgFileAsSoundFont; }
        public function loadImgFileAsSoundFont2(b:Bool) : Void { _loadImgFileAsSoundFont = b; }
        
        
        public function loadMP3FileAsBinary() : Bool { return _loadMP3FileAsBinary; }
        public function loadMP3FileAsBinary2(b:Bool) : Void { _loadMP3FileAsBinary = b; }
        
        
        public function rememberHistory() : Bool { return _rememberHistory; }
        public function rememberHistory2(b:Bool) : Void { _rememberHistory = b; }
        
        
        
        
    
    
        
        public function new(eventPriority:Int=0, loadImgFileAsSoundFont:Bool=false, loadMP3FileAsBinary:Bool=false, rememberHistory:Bool=false)
        {
            _eventPriority = eventPriority;
            _loaded = {};
            _loadedFileData = {};
            _preserveList = new Array<SoundLoaderFileData>();
            _bytesTotal = 0;
            _bytesLoaded = 0;
            _loadingFileCount = 0;
            _loadedFileCount = 0;
            _errorFileCount = 0;
            _loadImgFileAsSoundFont = loadImgFileAsSoundFont;
            _loadMP3FileAsBinary = loadMP3FileAsBinary;
            _rememberHistory = rememberHistory;
			
			super();
        }
        
        
        
        override public function toString() : String
        {
            var output:String = "[SoundLoader: " + loadedFileCount + " files are loaded.\n";
			
            for (id in Reflect.fields(_loaded)) {
                output += "  '" + id + "' : " + Std.string(Reflect.field(_loaded,id))+ "\n";
            }
            output += "]";
            return output;
        }
        
        
        
        
    
    
        
        public function setURL(urlRequest:URLRequest, id:String=null, type:String=null, checkPolicyFile:Bool=false) : SoundLoaderFileData
        {
            var urlString:String = urlRequest.url;
            var lastDotIndex:Int = urlString.lastIndexOf('.'), lastSlashIndex:Int = urlString.lastIndexOf('/'), fileData:SoundLoaderFileData;
            if (lastSlashIndex == -1) lastSlashIndex = 0;
            if (lastDotIndex < lastSlashIndex) lastDotIndex = urlString.length;
            if (id == null) id = urlString.substr(lastSlashIndex);
            if (_rememberHistory && Reflect.hasField(_loadedFileData, id) && Reflect.field(_loadedFileData,id).urlString == urlString) {
                fileData = Reflect.field(_loadedFileData, id);
            } else {
                if (type == null) type = urlString.substr(lastDotIndex + 1);
                if (_loadImgFileAsSoundFont) {
                    if (type == 'swf') type = 'ssf';
                    else if (type == 'png') type = 'ssfpng';
                }
                if (_loadMP3FileAsBinary && type == 'mp3') type = 'mp3bin';
                if (!(SoundLoaderFileData._ext2typeTable.exists(type))) throw new Error("unknown file type. : " + urlString);
                fileData = new SoundLoaderFileData(this, id, urlRequest, null, type, checkPolicyFile);
            }
            _preserveList.push(fileData);
            return fileData;
        }
        
        
        
        public function setByteArraySound(byteArray:ByteArray, id:String) : SoundLoaderFileData
        {
            var fileData:SoundLoaderFileData = new SoundLoaderFileData(this, id, null, byteArray, "b2snd", false);
            _preserveList.push(fileData);
            return fileData;
        }
        
        
        
        public function setByteArrayImage(byteArray:ByteArray, id:String) : SoundLoaderFileData
        {
            var fileData:SoundLoaderFileData = new SoundLoaderFileData(this, id, null, byteArray, "b2img", false);
            _preserveList.push(fileData);
            return fileData;
        }
        
        
        
        public function loadAll() : Int
        {
            var count:Int = 0;
           var i:Int=0;
 while( i<_preserveList.length){
                if (_preserveList[i].load()) count++;
                else _preserveList[i].dispatchEvent(new Event(Event.COMPLETE, false, false));
             i++;
}
            
            if (_loadingFileCount + count > 0) {
				_preserveList.splice(0, _preserveList.length);
                _loadingFileCount += count;
            } else {
                dispatchEvent(new Event(Event.COMPLETE, false, false));
            }
            return count;
        }
        
        
        
        
    
    
        
        public function _onProgress(fileData:SoundLoaderFileData, bytesLoadedDiff:Int, bytesTotalDiff:Int) : Void
        {
            _bytesTotal += bytesTotalDiff;
            _bytesLoaded += bytesLoadedDiff;
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _bytesLoaded, _bytesTotal));
        }
        
        
        public function _onComplete(fileData:SoundLoaderFileData) : Void
        {
            if (fileData.dataID != null) {
                if (!Reflect.hasField(_loaded, fileData.dataID())) _loadedFileCount++;
				Reflect.setField(_loadedFileData, fileData.dataID(), fileData);
				Reflect.setField(_loaded, fileData.dataID(), fileData.data);
            }
            fileData.dispatchEvent(new Event(Event.COMPLETE, false, false));
            if (--_loadingFileCount == 0) {
                _bytesLoaded = Std.int(_bytesTotal);
                dispatchEvent(new Event(Event.COMPLETE, false, false));
            }
        }
        
        
        public function _onError(fileData:SoundLoaderFileData, message:String) : Void
        {
            var errorMessage:String =  "SoundLoader Error on " + fileData.dataID + " : " + message;
            _errorFileCount++;
            fileData.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, errorMessage));
            dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, errorMessage));
            if (--_loadingFileCount == 0) {
                _bytesLoaded = Std.int(_bytesTotal);
                dispatchEvent(new Event(Event.COMPLETE, false, false));
            }
        }
    }


