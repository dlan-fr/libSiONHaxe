





package org.si.sion.sequencer.base ;

	import flash.errors.Error;
	
    class MMLSequencer
    {
    
        
        
        
        static public var _tempExecutor:MMLExecutor = new MMLExecutor();//_sion_sequencer_var
    
    
        
        inline static var FIXED_BITS:Int = 8;
        
        inline static var FIXED_FILTER:Int = (1<<FIXED_BITS)-1;
        
        
        
        
    
    
        
        public var setting:MMLParserSetting;
        
        public var sampleRate:Int;
        
        
        var globalExecutor:MMLExecutor;
        
        var currentExecutor:MMLExecutor; 
        
        public var mmlData:MMLData;
        
        var _changableBPM:BeatPerMinutes;
        
        var _bpm:BeatPerMinutes;
        
        
        var _globalBufferIndex:Int;
        
        var _globalBeat16:Float;
        
        var _onBeatCallbackFilter:Int;
        
        
        
		
		
		//static public function tempExecutor():MMLExecutor { return _tempExecutor; }
        
        private var _newUserDefinedEventID:Int = MMLEvent.USER_DEFINE;  
        private var _userDefinedEventID:Dynamic = {};                    
        public var _eventCommandLetter:Array<Dynamic> = [];     //_sion_var         
        private var _eventHandlers: Array<Dynamic>   = new Array<Dynamic>(); 
        private var _eventGlobalFlags: Array<Bool> = new Array<Bool> (); 
        
        private var _processSampleCount:Int;        
        private var _globalBufferSampleCount:Int;   
        private var _globalExecuteSampleCount:Int;  
        
        private var _bufferLength:Int;              
        
        
        
    
    
        
       public function get_bpm() : Float { //_sion_function
            return _changableBPM.bpm();
        }
        
        public function bpm(newValue:Float) : Void { //_sion_function
            var oldValue:Float = _changableBPM.bpm();
            if (_changableBPM.update(newValue, sampleRate)) {
                onTempoChanged(oldValue/newValue);
            }
        }
                
        
        
        
    
    
        
        function new()
        {
            this.setting = new MMLParserSetting();
            
           var i:Int=0;
 while( i<MMLEvent.COMMAND_MAX){ _eventHandlers[i] = _nop;  i++;
}
            setMMLEventListener(MMLEvent.NOP,          _default_onNoOperation,  false);
            setMMLEventListener(MMLEvent.PROCESS,      _default_onProcess,      false);
            setMMLEventListener(MMLEvent.REPEAT_ALL,   _default_onRepeatAll,    false);
            setMMLEventListener(MMLEvent.REPEAT_BEGIN, _default_onRepeatBegin,  false);
            setMMLEventListener(MMLEvent.REPEAT_BREAK, _default_onRepeatBreak,  false);
            setMMLEventListener(MMLEvent.REPEAT_END,   _default_onRepeatEnd,    false);
            setMMLEventListener(MMLEvent.SEQUENCE_TAIL,_default_onSequenceTail, false);
            setMMLEventListener(MMLEvent.GLOBAL_WAIT,  _default_onGlobalWait,   true);
            setMMLEventListener(MMLEvent.TEMPO,        _default_onTempo,        true);
            setMMLEventListener(MMLEvent.TIMER,        _default_onTimer,        true);
            setMMLEventListener(MMLEvent.INTERNAL_WAIT,_default_onInternalWait, false);
            setMMLEventListener(MMLEvent.INTERNAL_CALL,_default_onInternalCall, false);
            setMMLEventListener(MMLEvent.TABLE_EVENT,  _nop,                    true);
            _newUserDefinedEventID = MMLEvent.USER_DEFINE;
            
            _changableBPM = new BeatPerMinutes(120, 44100);
            _bpm = _changableBPM;
            globalExecutor = new MMLExecutor();
            MMLParser._getCommandLetters(_eventCommandLetter);
            
            
            _onBeatCallbackFilter = 3;
        }
        
        
        
        
    
    
        
        function setMMLEventListener(id:Int, func:Dynamic, isGlobal:Bool = false) : Void
        {
            _eventHandlers[id] = func;
            _eventGlobalFlags[id] = isGlobal;
        }
        
        
        
        function newMMLEventListener(letter:String, func:Dynamic, isGlobal:Bool = false) : Int
        {
            var id:Int = _newUserDefinedEventID++;
			Reflect.setField(_userDefinedEventID, letter, id);
            _eventCommandLetter[id] = letter;
            _eventHandlers[id] = func;
            _eventGlobalFlags[id] = isGlobal;
            return id;
        }
        
        
        
        public function getEventID(mmlCommand:String) : Int
        {
            var id:Int = MMLParser.getEventID(mmlCommand);
            if (id != 0) return id;
            if ( Reflect.hasField(_userDefinedEventID, mmlCommand)) return  Reflect.field(_userDefinedEventID, mmlCommand);
            return 0;
        }
        
        
        
        public function getEventLetter(eventID:Int) : String
        {
            return _eventCommandLetter[eventID];
        }
        
        
        
        
    
    
        
        public function prepareCompile(data:MMLData, mml:String) : Bool
        {
            
            mmlData = data;
            if (mmlData == null) return false;
            
            
            mmlData.clear();
            
            
            MMLParser._setUserDefinedEventID(_userDefinedEventID);
            MMLParser._setGlobalEventFlags(_eventGlobalFlags);
            
            
            var mmlString:String = onBeforeCompile(mml);
            if (mmlString== null) {
                mmlData = null;
                return false;
            }
            
            
            MMLParser.prepareParse(setting, mmlString);
            return true;
        }
        
        
        
        public function compile(interval:Int = 1000) : Float
        {
            if (mmlData == null) return 1;
            
            
            var e:MMLEvent = MMLParser.parse(interval);
            
            if (e == null) return MMLParser.parseProgress();

            
            mmlData.sequenceGroup.alloc(e);
            
            _abstructGlobalSequence();
            
            onAfterCompile(mmlData.sequenceGroup);
            
            return 1;
        }
        
        
        
        
    
    
        
        public function _prepareProcess(data:MMLData, sampleRate:Int, bufferLength:Int) : Void
        {
            if (sampleRate!=22050 && sampleRate!=44100) throw new Error ("MMLSequencer error: Only 22050 or 44100 sampling Std.is(rate,available.");
            mmlData = data;
            this.sampleRate = sampleRate;
            _bufferLength = bufferLength;
            if (mmlData != null && mmlData._initialBPM != null) {
                _changableBPM.update(mmlData._initialBPM.bpm(), sampleRate);
                globalExecutor.initialize(mmlData.globalSequence);
            } else {
                _changableBPM.update(setting.defaultBPM, sampleRate);
                globalExecutor.initialize(null);
            }
            _bpm = _changableBPM;
            _globalBufferIndex = 0;
            _globalBeat16 = 0;
        }
        
        
        
        public function _process() : Void
        {
            
            
        }
        

        
        public function setGlobalSequence(seq:MMLSequence) : Void
        {
            globalExecutor.initialize(seq);
        }
        
        
        function startGlobalSequence() : Void
        {
            _globalBufferSampleCount = _bufferLength;
            _globalExecuteSampleCount = 0;
            _globalBufferIndex = 0;
        }
        
        function executeGlobalSequence() : Int
        {
            currentExecutor = globalExecutor;
            
            var event:MMLEvent = currentExecutor.pointer;
            _globalExecuteSampleCount = 0;
            do {
                if (event == null) {
                    _globalExecuteSampleCount = _globalBufferSampleCount;
                    _globalBufferSampleCount = 0;
                } else {
                    
                    event = _eventHandlers[event.id](event);
                    currentExecutor.pointer = event;
                }
            } while (_globalExecuteSampleCount == 0);
            return _globalExecuteSampleCount;
        }
        
        function isEndGlobalSequence() : Bool
        {
            var prevBeat:Float = _globalBeat16,
                floorPrevBeat:Int = Std.int(prevBeat);
            _globalBufferIndex += _globalExecuteSampleCount;
            _globalBeat16 += _globalExecuteSampleCount * _bpm.beat16PerSample;
            var floorCurrBeat:Int = Std.int(_globalBeat16); 
            if (prevBeat == 0) {
                onBeat(0, 0);
            } else {
                while (floorPrevBeat < floorCurrBeat) {
                    floorPrevBeat++;
                    if ((floorPrevBeat & _onBeatCallbackFilter) == 0) {
                        onBeat(Std.int((floorPrevBeat - prevBeat) * _bpm.samplePerBeat16), floorPrevBeat);
                    }
                }
            }
            if (_globalBufferSampleCount == 0) {
                _globalBufferIndex = 0;
                return true;
            }
            return false;
        }
        

        
        function processMMLExecutor(exe:MMLExecutor, bufferSampleCount:Int) : Bool
        {
            currentExecutor = exe;
            
            
            var event:MMLEvent = currentExecutor.pointer;
            _processSampleCount = bufferSampleCount;
            while (_processSampleCount > 0) {
                if (event == null) {
                    _eventHandlers[MMLEvent.NOP](MMLEvent.nopEvent);
                    return true;
                } else {
                    
                    event = _eventHandlers[event.id](event);
                    currentExecutor.pointer = event;
                }
            }
            return false;
        }
        
        
        
        
    
    
        
        function calcSampleCount(len:Int) : Int
        {
            return Std.int(len * _bpm._samplePerTick) >> FIXED_BITS;
        }
        
        
        
        function currentTickCount() : Int
        {
            return currentExecutor._currentTickCount - Std.int(currentExecutor._residueSampleCount * _bpm.tickPerSample);
        }
        
        
        
        function callOnTableParse(prev:MMLEvent) : Void
        {
            var tableEvent:MMLEvent = prev.next;
            onTableParse(prev, MMLParser._getSystemEventString(tableEvent));
            prev.next = tableEvent.next;
            MMLParser._freeEvent(tableEvent);
        }
        
        
        
        
    
    
        
        function onBeforeCompile(mml:String) : String
        {
            return null;
        }
        
        
        
        function onAfterCompile(seqGroup:MMLSequenceGroup) : Void
        {
        }
        
        
        
        function onTableParse(prev:MMLEvent, table:String) : Void
        {
        }
        
        
        
        function onProcess(length:Int, e:MMLEvent) : Void
        {
        }
        
        
        
        function onTempoChanged(tempoRatio:Float) : Void
        {
        }
        

        
        function onTimerInterruption() : Void
        {
        }
        
        
        
        function onBeat(delaySamples:Int, beatCounter:Int) : Void
        {
        }
        
        
        
        
    
    
        private function _abstructGlobalSequence() : Void
        {
            var seqGroup:MMLSequenceGroup = mmlData.sequenceGroup;
            
            var list:Array<Dynamic> = [];
            var seq:MMLSequence, prev:MMLEvent, e:MMLEvent, pos:Int, count:Int, hasNoEvent:Bool, i:Int, initialBPM:Int;
            
           seq = seqGroup.headSequence();
 while( seq != null){
                count = seq.headEvent.data;
                if (count == 0) continue;
                
                
                _tempExecutor.initialize(seq);
                prev = seq.headEvent;
                e = prev.next;
                pos = 0;
                hasNoEvent = true;
                
                
                while (e != null && (count > 0 || hasNoEvent)) {
                    if (_eventGlobalFlags[e.id]) {
                        if (e.id == MMLEvent.TABLE_EVENT) {
                            
                            callOnTableParse(prev);
                        } else {
                            
                            if (seq.headEvent.jump == e) seq.headEvent.jump = prev;
                            prev.next = e.next;
                            e.next = null;
                            e.length = pos;
                            list.push(e);
                        }
                        e = prev.next;
                        count--;
                    } else
                    if (e.length != 0) {
                        
                        pos += e.length;
                        if (e.id != MMLEvent.REST) hasNoEvent = false;
                        prev = e;
                        e = e.next;
                    } else {
                        
                        prev = e;
                        switch (e.id) {
                        case MMLEvent.REPEAT_BEGIN:  e = _tempExecutor._onRepeatBegin(e);  break;
                        case MMLEvent.REPEAT_BREAK:
                            e = _tempExecutor._onRepeatBreak(e);
                            if (prev.next != e) prev = prev.jump.jump;
                            break;
                        case MMLEvent.REPEAT_END:
                            e = _tempExecutor._onRepeatEnd(e);
                            if (prev.next != e) prev = prev.jump;
                            break;
                        case MMLEvent.REPEAT_ALL:    e = _tempExecutor._onRepeatAll(e);    break;
                        case MMLEvent.SEQUENCE_TAIL: e = null;                             break;
                        default:
                            e = e.next;
                            hasNoEvent = true;
                            break;
                        }
                    }
                }
                
                
                if (hasNoEvent) {

                    seq = seq._removeFromChain();
                }
             seq = seq.nextSequence();
}
            
            
            
            seq = mmlData.globalSequence;
			
            list.sort(function(a:Dynamic, b:Dynamic):Int
			{
				if (a.length < b.length) return -1;
				if (a.length > b.length) return 1;
				return 0;
			} );
			
			
			
			
            pos = 0;
            initialBPM = 0;
            for (e in list) {
                if (e.length == 0 && e.id == MMLEvent.TEMPO) {
                    
                    initialBPM = Std.int(mmlData._calcBPMfromTcommand(e.data));
                } else {
                    count = Std.int(e.length - pos);
                    pos = e.length;
                    e.length = 0;
                    if (count > 0) seq.appendNewEvent(MMLEvent.GLOBAL_WAIT, 0, count);
                    seq.push(e);
                }
            }

            
            
            if (initialBPM > 0) {
                mmlData._initialBPM = new BeatPerMinutes(initialBPM, 44100, setting.resolution);
            }
        }
        
        
        
    
    
        
        function _nop(e:MMLEvent) : MMLEvent
        {
            return e.next;
        }
        
        
        
        function _default_onNoOperation(e:MMLEvent) : MMLEvent
        {
            onProcess(_processSampleCount, e);
            currentExecutor._residueSampleCount -= _processSampleCount;
            return e;
        }
        
        
        
        function _default_onGlobalWait(e:MMLEvent) : MMLEvent
        {
            var exec:MMLExecutor = currentExecutor;
            
            
            if (exec._residueSampleCount == 0) {
                var sampleCountFixed:Int = Std.int(e.length * _bpm._samplePerTick + exec._decimalFractionSampleCount);
                exec._residueSampleCount = sampleCountFixed >> FIXED_BITS;
                exec._decimalFractionSampleCount = sampleCountFixed & FIXED_FILTER;
            }
            
            
            if (exec._residueSampleCount <= _globalBufferSampleCount) {
                _globalExecuteSampleCount = exec._residueSampleCount;
                _globalBufferSampleCount  -= _globalExecuteSampleCount;
                exec._residueSampleCount  = 0;
                
                return e.next;
            } else {
                _globalExecuteSampleCount =  _globalBufferSampleCount;
                exec._residueSampleCount  -= _globalExecuteSampleCount;
                _globalBufferSampleCount  = 0;
                
                return e;
            }
        }
        
        
        
        function _default_onProcess(e:MMLEvent) : MMLEvent
        {
            var exec:MMLExecutor = currentExecutor;
            
            
            if (exec._residueSampleCount == 0) {
                var sampleCountFixed:Int = Std.int(e.length * _bpm._samplePerTick + exec._decimalFractionSampleCount);
                exec._residueSampleCount = sampleCountFixed >> FIXED_BITS;
                exec._decimalFractionSampleCount = sampleCountFixed & FIXED_FILTER;
            }
            
            
            if (exec._residueSampleCount <= _processSampleCount) {
                onProcess(exec._residueSampleCount, e.jump);
                _processSampleCount -= exec._residueSampleCount;
                exec._residueSampleCount = 0;
                
                return e.jump.next;
            } else {
                onProcess(_processSampleCount, e.jump);
                exec._residueSampleCount -= _processSampleCount;
                _processSampleCount = 0;
                
                return e;
            }
        }
        
        
        
        function _dummy_onProcess(e:MMLEvent) : MMLEvent
        {
            var exec:MMLExecutor = currentExecutor;
            
            
            if (exec._residueSampleCount == 0) {
                var sampleCountFixed:Int = Std.int(e.length * _bpm._samplePerTick) + exec._decimalFractionSampleCount;
                exec._residueSampleCount = sampleCountFixed >> FIXED_BITS;
                exec._decimalFractionSampleCount = sampleCountFixed & FIXED_FILTER;
            }
            
            
            if (exec._residueSampleCount <= _processSampleCount) {
                _processSampleCount -= exec._residueSampleCount;
                exec._residueSampleCount = 0;
                
                return e.jump.next;
            } else {
                exec._residueSampleCount -= _processSampleCount;
                _processSampleCount = 0;
                
                return e;
            }
        }
        
        
        
        function _default_onRepeatAll(e:MMLEvent) : MMLEvent
        {
            return currentExecutor._onRepeatAll(e);
        }
        
        
        
        function _default_onRepeatBegin(e:MMLEvent) : MMLEvent
        {
            return currentExecutor._onRepeatBegin(e);
        }
        
        
        
        function _default_onRepeatBreak(e:MMLEvent) : MMLEvent
        {
            return currentExecutor._onRepeatBreak(e);
        }
        
        
        
        function _default_onRepeatEnd(e:MMLEvent) : MMLEvent
        {
            return currentExecutor._onRepeatEnd(e);
        }
        
        
        
        function _default_onSequenceTail(e:MMLEvent) : MMLEvent
        {
            return currentExecutor._onSequenceTail(e);
        }
        
        
        
        function _default_onTempo(e:MMLEvent) : MMLEvent
        {
            bpm((mmlData != null) ? (mmlData._calcBPMfromTcommand(e.data)) : e.data);
            return e.next;
        }
        
        
        
        function _default_onTimer(e:MMLEvent) : MMLEvent
        {
            onTimerInterruption();
            return e.next;
        }
        
        
        
        function _default_onInternalWait(e:MMLEvent) : MMLEvent
        {
            return currentExecutor._publishProessingEvent(e);
        }
        
        
        
        function _default_onInternalCall(e:MMLEvent) : MMLEvent
        {
            var callbacks:Array<Dynamic> = currentExecutor.sequence()._callbackInternalCall,
                next:MMLEvent = null;
            if (callbacks[e.data]) next = callbacks[e.data](e.length);
            return (next != null)? next : e.next;
        }
    }


