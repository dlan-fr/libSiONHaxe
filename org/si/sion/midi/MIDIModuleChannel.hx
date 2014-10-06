






package org.si.sion.midi ;
    
    class MIDIModuleChannel
    {
    
    
        
        public var activeOperatorCount:Int;
        
        public var maxOperatorCount:Int;
        
        public var drumMode:Int;
        public var mute:Bool;
        public var programNumber:Int;
        public var pan:Int;
        public var modulation:Int;
        public var pitchBend:Int;
        public var channelAfterTouch:Int;
        public var sustainPedal:Bool;
        public var portamento:Bool;
        public var portamentoTime:Int;
        public var masterFineTune:Int;
        public var masterCoarseTune:Int;
        public var pitchBendSensitivity:Int;
        public var modulationCycleTime:Int;
        
        public var eventTriggerID:Int;
        public var eventTriggerTypeOn:Int;
        public var eventTriggerTypeOff:Int;
        
        public var bankNumber:Int;
        
        
        
        public var _sionVolumes: Array<Int> = new Array<Int>();
        
        public var _effectSendLevels: Array<Int> = new Array<Int>();

        private var _expression:Int;
        private var _masterVolume:Int;
        
        
        
        
    
    
        
        public function get_masterVolume() : Int { return _masterVolume; }
        public function masterVolume(v:Int) : Void { _masterVolume = v; _updateVolumes(); }
        
        
        
        public function get_expression() : Int { return _expression; }
        public function expression(e:Int) : Void { _expression = e; _updateVolumes(); }
        
        
        
        private function _updateVolumes() : Void {
            var v:Int = (_masterVolume * _expression + 64) >> 7;
            _sionVolumes[0] = _effectSendLevels[0] = v;
           var i:Int =1;
 while( i<8){
                _sionVolumes[i] = (v * _effectSendLevels[i] + 64) >> 7;
             i++;
}
        }
        
        
        
    
    
        
        public function new()
        {
            mute = false;
            eventTriggerID = 0;
            eventTriggerTypeOn = 0;
            eventTriggerTypeOff = 0;
            reset();
        }
        
        
        
        
    
    
        
        public function reset() : Void
        {
            activeOperatorCount = 0;
            maxOperatorCount = 1024;
            
            
            drumMode = 0;
            programNumber = 0;
            _expression = 127;
            _masterVolume = 64;
            pan = 0;
            modulation = 0;
            pitchBend = 0;
            channelAfterTouch = 0;
            sustainPedal = false;
            portamento = false;
            portamentoTime = 0;
            masterFineTune = 0;
            masterCoarseTune = 0;
            pitchBendSensitivity = 2;
            modulationCycleTime = 180;
            
            bankNumber = 0;
            
            _sionVolumes[0] = _masterVolume;
            _effectSendLevels[0] = _masterVolume;
           var i:Int = 1;
 while( i<8){
                _sionVolumes[i] = 0;
                _effectSendLevels[i] = 0;
             i++;
}
        }
        
        
        
        public function getEffectSendLevel(slotNumber:Int) : Int { 
            return _effectSendLevels[slotNumber];
        }
        
        
        
        public function setEffectSendLevel(slotNumber:Int, level:Int) : Void {
            _effectSendLevels[slotNumber] = level;
            _sionVolumes[slotNumber] = (_effectSendLevels[0] * _effectSendLevels[slotNumber] + 64) >> 7;
        }
        
        
        
        public function setEventTrigger(id:Int, noteOnType:Int=1, noteOffType:Int=0) : Void
        {
            eventTriggerID = id;
            eventTriggerTypeOn = noteOnType;
            eventTriggerTypeOff = noteOffType;
        }
    }


