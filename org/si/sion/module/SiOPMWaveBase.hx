





package org.si.sion.module ;
    import flash.media.Sound;
    import flash.events.*;
    
    
    class SiOPMWaveBase {
        
        public var moduleType:Int;
        
        private var _loadingTarget:Sound;
        
        
        
        function new(moduleType:Int)
        {
            this.moduleType = moduleType;
        }
        
        
        
        function _listenSoundLoadingEvents(sound:Sound) : Void 
        {
            if (sound.bytesTotal == 0 || sound.bytesTotal > Std.int(sound.bytesLoaded)) {
                _loadingTarget = sound;
                sound.addEventListener(Event.COMPLETE, _cmp);
                sound.addEventListener(IOErrorEvent.IO_ERROR, _err);
                sound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _err);
            } else {
                _onSoundLoadingComplete(sound);
            }
        }
        
        
        
        function _isSoundLoading() : Bool { return (_loadingTarget != null); }
        
        
        
        function _onSoundLoadingComplete(sound:Sound) : Void
        {
        }
        
        
        
        private function _cmp(e:Event) : Void {
            _onSoundLoadingComplete(_loadingTarget);
            _removeAllListeners();
        }
        private function _err(e:Event) : Void {
            _removeAllListeners();
        }
        private function _removeAllListeners() : Void 
        {
            _loadingTarget.removeEventListener(Event.COMPLETE, _cmp);
            _loadingTarget.removeEventListener(IOErrorEvent.IO_ERROR, _err);
            _loadingTarget.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _err);
            _loadingTarget = null;
        }
    }


