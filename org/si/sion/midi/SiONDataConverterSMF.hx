






package org.si.sion.midi ;
    import flash.utils.ByteArray;
    import org.si.sion.SiONData;
    import org.si.sion.sequencer.base.MMLEvent;
    
    
    
    class SiONDataConverterSMF extends SiONData
    {
    
    
        
        public var useMIDIModuleEffector:Bool = true;
        
        private var _smfData:SMFData = null;
        private var _module:MIDIModule = null;
        private var _waitEvent:MMLEvent;
        private var _executors: Array<SMFExecutor> = new Array<SMFExecutor>();
        private var _resolutionRatio:Float = 1;
        
        
        
    
    
        
        public function get_smfData() : SMFData { return _smfData; }
        public function smfData(data:SMFData) : Void {
            _smfData = data;
            if (_smfData != null) {
                bpm(_smfData.bpm);
                _resolutionRatio = 1920 / _smfData.resolution;
            } else {
                bpm( 120);
                _resolutionRatio = 1;
            }
        }
        
        
        
        public function get_midiModule() : MIDIModule { return _module; }
        public function midiModule(module:MIDIModule) : Void { _module = module; }
        
        
        
        
        
    
    
        
        public function new(smfData:SMFData=null, midiModule:MIDIModule=null)
        {
            super();
            _smfData = smfData;
            _module = midiModule;
            
            if (_smfData != null) {
                bpm(_smfData.bpm);
                _resolutionRatio = 1920 / _smfData.resolution;
            } else {
                bpm (120);
                _resolutionRatio = 1;
            }
            
            globalSequence.initialize();
            globalSequence.appendNewCallback(_onMIDIInitialize, 0);
            globalSequence.appendNewEvent(MMLEvent.REPEAT_ALL, 0);
            globalSequence.appendNewCallback(_onMIDIEventCallback, 0);
            _waitEvent = globalSequence.appendNewEvent(MMLEvent.GLOBAL_WAIT, 0, 0);
        }
        
        
        
        
    
    
        private function _onMIDIInitialize(data:Int) : MMLEvent
        {
            var i:Int, imax:Int;
            
            
            _module._initialize(useMIDIModuleEffector);
            
            
             imax = _smfData.tracks.length;
           i=0;
 while( i<imax){
                if (_executors[i] == null) _executors[i] = new SMFExecutor();
                _executors[i]._initialize(_smfData.tracks[i], _module);
             i++;
}
            
            
            _waitEvent.length = 0;
            
            return null;
        }
        
        
        private function _onMIDIEventCallback(data:Int) : MMLEvent
        {
            var i:Int, imax:Int = _executors.length, exec:SMFExecutor, seq: Array<SMFEvent>, 
                ticks:Int, deltaTime:Int, minDeltaTime:Int;
            ticks = Std.int(_waitEvent.length / _resolutionRatio);
            minDeltaTime = _executors[0]._execute(ticks);
           i=1;
 while( i<imax){
                deltaTime = _executors[i]._execute(ticks);
                if (minDeltaTime > deltaTime) minDeltaTime = deltaTime;
             i++;
}
            if (minDeltaTime == 65536) _module._onFinishSequence();
            _waitEvent.length = Std.int(minDeltaTime * _resolutionRatio);
            return null;
        }
    }



