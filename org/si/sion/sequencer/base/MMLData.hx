





package org.si.sion.sequencer.base ;
    import org.si.sion.module.SiOPMTable;
    
    
    
    class MMLData
    {
        
        
        
        
    
    
        
        inline static public var TCOMMAND_BPM:Int = 0;
        
        inline static public var TCOMMAND_TIMERB:Int = 1;
        
        inline static public var TCOMMAND_FRAME:Int = 2;
        
        
        
    
    
        
        public var sequenceGroup:MMLSequenceGroup;
        
        public var globalSequence:MMLSequence;
        
        
        public var defaultFPS:Int;
        
        public var title:String;
        
        public var author:String;
        
        public var tcommandMode:Int;
        
        public var tcommandResolution:Float;
        
        public var defaultVCommandShift:Int;
        
        public var defaultVelocityMode:Int;
        
        public var defaultExpressionMode:Int;
        
        
        public var _initialBPM:BeatPerMinutes;
        
        var _systemCommands:Array<Dynamic>;
        
        
        
        
    
    
        
        public function sequenceCount() : Int { return sequenceGroup.sequenceCount(); }
        
        
        
        public function bpm(t:Float) : Void {
            _initialBPM = (t>0) ? (new BeatPerMinutes(t, 44100)) : null;
        }
        public function get_bpm() : Float {
            return (_initialBPM != null) ? _initialBPM.bpm() : 0;
        }
                
        
        public function systemCommands() : Array<Dynamic> { return _systemCommands; }
        
        
        
        public function tickCount() : Int { return sequenceGroup.tickCount(); }
        
        
        
        public function  hasRepeatAll() : Bool { return sequenceGroup.hasRepeatAll(); }
        
        
        
        
    
    
        public function new()
        {
            sequenceGroup = new MMLSequenceGroup(this);
            globalSequence = new MMLSequence();
            
            _initialBPM = null;
            tcommandMode = TCOMMAND_BPM;
            tcommandResolution = 1;
            defaultVCommandShift = 4;
            defaultVelocityMode = 0;
            defaultExpressionMode = 0;
            defaultFPS = 60;
            title = "";
            author = "";
            _systemCommands = [];
        }
        
        
        
        
    
    
        
        public function clear() : Void
        {
            var i:Int, imax:Int;
            
            sequenceGroup.free();
            globalSequence.free();
            
            _initialBPM = null;
            tcommandMode = TCOMMAND_BPM;
            tcommandResolution = 1;
            defaultVelocityMode = 0;
            defaultExpressionMode = 0;
            defaultFPS = 60;
            title = "";
            author = "";

		   _systemCommands.splice(0, _systemCommands.length);
            
            globalSequence.initialize();
        }
        
        
        
        public function appendNewSequence(sequence: Array<MMLEvent> = null) : MMLSequence
        {
            var seq:MMLSequence = sequenceGroup.appendNewSequence();
            if (sequence != null) seq.fromVector(sequence);
            return seq;
        }
        
        
        
        public function getSequence(index:Int) : MMLSequence
        {
            return sequenceGroup.getSequence(index);
        }
        
        
        
        public function _calcBPMfromTcommand(param:Int) : Float
        {
            switch(tcommandMode) {
            case TCOMMAND_BPM:
                return param * tcommandResolution;
            case TCOMMAND_FRAME:
                return (param != 0) ? (tcommandResolution / param) : 120;
            case TCOMMAND_TIMERB:
                return (param>=0 && param<256) ? (tcommandResolution / (256-param)) : 120;
            }
            return 0;
         }
    }



