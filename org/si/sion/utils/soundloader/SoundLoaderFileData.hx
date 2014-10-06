






package org.si.sion.utils.soundloader ;
    import flash.net.*;
    import flash.media.*;
    import flash.utils.*;
    import flash.system.*;
    import flash.events.*;
    import flash.display.*;
    import org.si.sion.module.ISiOPMWaveInterface;
    import org.si.sion.module.SiOPMWavePCMData;
    import org.si.sion.module.SiOPMWaveSamplerData;
    import org.si.sion.midi.SMFData;
    import org.si.utils.ByteArrayExt;
    import org.si.sion.utils.soundfont.*;
    import org.si.sion.utils.SoundClass;
    import org.si.sion.utils.PCMSample;
    
    
    
    
  /*  [Event(name="complete", type="flash.events.Event")]
    
    [Event(name="error",    type="flash.events.ErrorEvent")]
    
    [Event(name="progress", type="flash.events.ProgressEvent")]*/
    
    
    
    class SoundLoaderFileData extends EventDispatcher
    {
    
    
        
        public static var _ext2typeTable:Map<String,String> = [
            "mp3" => "mp3",
            "wav" => "wav",
            "mp3bin" => "mp3bin",
            "mid" => "mid",
            "smf" => "mid",
            "swf" => "img",
            "png" => "img",
            "gif" => "img",
            "jpg" => "img",
            "img" => "img",
            "bin" => "bin",
            "txt" => "txt",
            "var" => "var",
            "ssf" => "ssf",
            "ssfpng" => "ssfpng",
            "b2snd" => "b2snd",
            "b2img" => "b2img"
		];
        
        
        private var _dataID:String;
        private var _content:Dynamic;
        private var _urlRequest:URLRequest;
        private var _type:String;
        private var _checkPolicyFile:Bool;
        private var _bytesLoaded:Int;
		private var _bytesTotal:Int;
        private var _loader:Loader;
		private var _sound:Sound;
		private var _urlLoader:URLLoader;
		private var _fontLoader:SiONSoundFontLoader;
		private var _byteArray:ByteArray;
        private var _soundLoader:SoundLoader;
        
        
        
        
    
    
        
        public function dataID() : String { return _dataID; }
        
        public function data() : Dynamic { return _content; }
        
        public function urlString() : String { return (_urlRequest != null) ? _urlRequest.url : null; }
        
        public function type() : String { return _type; }
        
        public function bytesLoaded() : Int { return _bytesLoaded; }
        
        public function bytesTotal() : Int { return _bytesTotal; }
        
        
        
        
    
    
        
        function new(soundLoader:SoundLoader, id:String, urlRequest:URLRequest, byteArray:ByteArray, ext:String, checkPolicyFile:Bool)
        {
            this._dataID = id;
            this._soundLoader = soundLoader;
            this._urlRequest = urlRequest;
            this._type = _ext2typeTable.get(ext);
            this._checkPolicyFile = checkPolicyFile;
            this._bytesLoaded = 0;
            this._bytesTotal = 0;
            this._content = null;
            this._sound = null;
            this._loader = null;
            this._urlLoader = null;
            this._byteArray = byteArray;
			
			super();
        }
        
        
        
        
    
    
        
        public function load() : Bool
        {
            
            if (_content) return false;
            
            switch (_type) {
            case "mp3":
                _addAllListeners(_sound = new Sound());
                _sound.load(_urlRequest, new SoundLoaderContext(1000, _checkPolicyFile));
            case "img","ssfpng":
                _loader = new Loader();
                _addAllListeners(_loader.contentLoaderInfo);
                _loader.load(_urlRequest, new LoaderContext(_checkPolicyFile));

            case "txt":
                _addAllListeners(_urlLoader = new URLLoader());
                _urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
                _urlLoader.load(_urlRequest);
           
            case "bin","mp3bin","mid","wav":
                _addAllListeners(_urlLoader = new URLLoader());
                _urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
                _urlLoader.load(_urlRequest);
            case "var":
                _addAllListeners(_urlLoader = new URLLoader());
                _urlLoader.dataFormat = URLLoaderDataFormat.VARIABLES;
                _urlLoader.load(_urlRequest);
            case "ssf":
                _addAllListeners(_fontLoader = new SiONSoundFontLoader());
                _fontLoader.load(_urlRequest);
            case "b2snd":
                SoundClass.loadMP3FromByteArray(_byteArray, __loadMP3FromByteArray_onComplete);
            case "b2img":
                _loader = new Loader();
                _addAllListeners(_loader.contentLoaderInfo);
                _loader.loadBytes(_byteArray);

            default:
            }
            
            return true;
        }
        
        
        
        function listenLoadingStatus(target:Dynamic) : Bool
        {
            _sound = cast(target,Sound);
            _loader = cast(target,Loader);
            _urlLoader = cast(target,URLLoader);
            target = (_sound != null) ? _sound : (_urlLoader != null) ? _urlLoader : _loader; // _sound || _urlLoader || (_loader && _loader.contentLoaderInfo);
            if (target != null) {
                if (target.bytesTotal != 0 && target.bytesTotal == target.bytesLoaded) {
                    _postProcess();
                } else {
                    _addAllListeners(target);
                }
                return true;
            }
            return false;
        }
        
        
        private function _addAllListeners(dispatcher:EventDispatcher) : Void 
        {
            dispatcher.addEventListener(Event.COMPLETE, _onComplete, false, _soundLoader._eventPriority);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, _onProgress, false, _soundLoader._eventPriority);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, _onError, false, _soundLoader._eventPriority);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onError, false, _soundLoader._eventPriority);
        }
        
        
        private function _removeAllListeners() : Void 
        {
            var dispatcher:EventDispatcher = (_sound  != null) ? _sound : (_urlLoader != null) ? _urlLoader :  (_fontLoader != null) ? _fontLoader : ( _loader.contentLoaderInfo != null) ? _loader.contentLoaderInfo : null;
            dispatcher.removeEventListener(Event.COMPLETE, _onComplete);
            dispatcher.removeEventListener(ProgressEvent.PROGRESS, _onProgress);
            dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, _onError);
            dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _onError);
        }
        
        
        private function _onProgress(e:ProgressEvent) : Void
        {
            dispatchEvent(e.clone());
            _soundLoader._onProgress(this, Std.int(e.bytesLoaded - _bytesLoaded), Std.int(e.bytesTotal - _bytesTotal));
            _bytesLoaded = Std.int(e.bytesLoaded);
            _bytesTotal = Std.int(e.bytesTotal);
        }
        
        
        private function _onComplete(e:Event) : Void
        {
            _removeAllListeners();
            _soundLoader._onProgress(this, Std.int(e.target.bytesLoaded - _bytesLoaded), Std.int(e.target.bytesTotal - _bytesTotal));
            _bytesLoaded = e.target.bytesLoaded;
            _bytesTotal = e.target.bytesTotal;
            _postProcess();
        }
        
        
        private function _postProcess() : Void 
        {
            var currentBICID:String, pcmSample:PCMSample, smfData:SMFData;
            
            switch (_type) {
            case "mp3":
                _content = _sound;
                _soundLoader._onComplete(this);
 
            case "wav":
                currentBICID = PCMSample.basicInfoChunkID;
                PCMSample.basicInfoChunkID = "acid";
                pcmSample = new PCMSample().loadWaveFromByteArray(_urlLoader.data); 
                PCMSample.basicInfoChunkID = currentBICID;
                _content = pcmSample;
                _soundLoader._onComplete(this);
         
            case "mid":
                smfData = new SMFData().loadBytes(_urlLoader.data);
                _content = smfData;
                _soundLoader._onComplete(this);
            
            case "mp3bin":
                SoundClass.loadMP3FromByteArray(_urlLoader.data, __loadMP3FromByteArray_onComplete);
        
            case "ssf":
                _content = _fontLoader.soundFont;
                _soundLoader._onComplete(this);
        
            case "ssfpng":
                _convertBitmapDataToSoundFont(cast(cast(_loader.content, Bitmap).bitmapData,BitmapData));
            
                
            case "img","b2img":
                _content = _loader.content;
                _soundLoader._onComplete(this);
     
            case "txt","var","bin":
                _content = _urlLoader.data;
                _soundLoader._onComplete(this);
            }
        }
        
        
        private function _onError(e:ErrorEvent) : Void
        {
            _removeAllListeners();
            __errorCallback(e);
        }
        
        
        private function __loadMP3FromByteArray_onComplete(sound:Sound) : Void
        {
            _content = sound;
            _soundLoader._onComplete(this);
        }
        
        
        private function _convertBitmapDataToSoundFont(bitmap:BitmapData) : Void
        {
            var bitmap2bytes:ByteArrayExt = new ByteArrayExt(); 
            _loader = null;
            _fontLoader = new SiONSoundFontLoader();            
            _fontLoader.addEventListener(Event.COMPLETE, __convertB2SF_onComplete);
            _fontLoader.addEventListener(IOErrorEvent.IO_ERROR, __errorCallback);
            _fontLoader.loadBytes(bitmap2bytes.fromBitmapData(bitmap));
        }
        
        
        private function __convertB2SF_onComplete(e:Event) : Void
        { 
            _content = _fontLoader.soundFont;
            _soundLoader._onComplete(this);
        }
        
        
        private function __errorCallback(e:ErrorEvent) : Void
        {
            _soundLoader._onError(this, e.toString());
        }
    }



