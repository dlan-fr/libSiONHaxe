






package org.si.sion ;
    //import flash.errors.*;
    //import flash.events.*;
	import flash.Lib;
    import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
    //import flash.net.*;
    import flash.display.Sprite;
    import flash.utils.ByteArray;
    import org.si.utils.SLLint;
    import org.si.utils.SLLNumber;
    import org.si.sion.events.*;
    import org.si.sion.sequencer.base.MMLSequence;
    import org.si.sion.sequencer.base.MMLEvent;
    import org.si.sion.sequencer.SiMMLSequencer;
    import org.si.sion.sequencer.SiMMLTrack;
    import org.si.sion.sequencer.SiMMLEnvelopTable;
    import org.si.sion.sequencer.SiMMLTable;
    import org.si.sion.sequencer.SiMMLVoice;
    import org.si.sion.module.ISiOPMWaveInterface;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.module.SiOPMModule;
    import org.si.sion.module.SiOPMChannelParam;
    import org.si.sion.module.SiOPMWaveTable;
    import org.si.sion.module.SiOPMWavePCMTable;
    import org.si.sion.module.SiOPMWavePCMData;
    import org.si.sion.module.SiOPMWaveSamplerTable;
    import org.si.sion.module.SiOPMWaveSamplerData;
    import org.si.sion.effector.SiEffectModule;
    import org.si.sion.effector.SiEffectBase;
    import org.si.sion.midi.SMFData;
    import org.si.sion.midi.MIDIModule;
    import org.si.sion.midi.SiONDataConverterSMF;
    import org.si.sion.utils.soundloader.SoundLoader;
    import org.si.sion.utils.SiONUtil;
    import org.si.sion.utils.Fader;
	import org.si.sion.SiONData;
    
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ErrorEvent;
	
	import flash.errors.Error;
	import flash.net.URLRequest;
    
    
    /*
    [Event(name="queueProgress",   type="org.si.sion.events.SiONEvent")]
    
    [Event(name="queueComplete",   type="org.si.sion.events.SiONEvent")]
    
    [Event(name="queueCancel",     type="org.si.sion.events.SiONEvent")]
    
    [Event(name="stream",          type="org.si.sion.events.SiONEvent")]
    
    [Event(name="streamStart",     type="org.si.sion.events.SiONEvent")]
    
    [Event(name="streamStop",      type="org.si.sion.events.SiONEvent")]
    
    [Event(name="finishSequence",  type="org.si.sion.events.SiONEvent")]
    
    [Event(name="fadeProgress",    type="org.si.sion.events.SiONEvent")]
    
    [Event(name="fadeInComplete",  type="org.si.sion.events.SiONEvent")]
    
    [Event(name="fadeOutComplete", type="org.si.sion.events.SiONEvent")]
    
    [Event(name="noteOnStream",    type="org.si.sion.events.SiONTrackEvent")]
    
    [Event(name="noteOffStream",   type="org.si.sion.events.SiONTrackEvent")]
    
    [Event(name="noteOnFrame",     type="org.si.sion.events.SiONTrackEvent")]
    
    [Event(name="noteOffFrame",    type="org.si.sion.events.SiONTrackEvent")]
    
    [Event(name="beat",            type="org.si.sion.events.SiONTrackEvent")]
    
    [Event(name="changeBPM",       type="org.si.sion.events.SiONTrackEvent")]
    */
    
    
    class SiONDriver extends Sprite implements ISiOPMWaveInterface
    {
    
        
        
        
        
    
    
        
        inline static public var VERSION:String = "0.6.5.2";
        
        
        
        inline static public var NEM_IGNORE:Int = 0;
        
        inline static public var NEM_REJECT:Int = 1;
        
        inline static public var NEM_OVERWRITE:Int = 2;
        
        inline static public var NEM_SHIFT:Int = 3;
        
        inline static private var NEM_MAX:Int = 4;
        
        
        
        private var NO_LISTEN:Int = 0;
        inline static private var listen_queue:Int = 1;
        inline static private var listen_process:Int = 2;
        
        
        private var TIME_AVARAGING_COUNT:Int = 8;
        
        
        
        
    
    
        
        public var module:SiOPMModule;
        
        
        public var effector:SiEffectModule;
        
        
        public var sequencer:SiMMLSequencer;
        
        
        
        
        private var _data:SiONData;         
        private var _tempData:SiONData;     
        private var _mmlString:String;      
        
        private var _sound:Sound;                   
        private var _soundChannel:SoundChannel;     
        private var _soundTransform:SoundTransform; 
        private var _fader:Fader;                   
        
        private var _channelCount:Int;          
        private var _sampleRate:Float;         
        private var _bitRate:Int;               
        private var _bufferLength:Int;          
        private var _debugMode:Bool;         
        private var _dispatchStreamEvent:Bool; 
        private var _dispatchFadingEvent:Bool; 
        private var _inStreaming:Bool;         
        private var _preserveStop:Bool;        
        private var _suspendStreaming:Bool;      
        private var _suspendWhileLoading:Bool;   
        private var _loadingSoundList:Array<Dynamic>;        
        private var _isFinishSeqDispatched:Bool; 
        
        private var _autoStop:Bool;          
        private var _noteOnExceptionMode:Int;   
        private var _isPaused:Bool;          
        private var _position:Float;           
        private var _masterVolume:Float;       
        private var _faderVolume:Float;        
        
        private var _backgroundSound:Sound;                 
        private var _backgroundLoopPoint:Float;            
        private var _backgroundFadeOutFrames:Int;           
        private var _backgroundFadeInFrames:Int;            
        private var _backgroundFadeGapFrames:Int;           
        private var _backgroundTotalFadeFrames:Int;         
        private var _backgroundVoice:SiONVoice;             
        private var _backgroundSample:SiOPMWaveSamplerData; 
        private var _backgroundTrack:SiMMLTrack;            
        private var _backgroundTrackFadeOut:SiMMLTrack;     
        
        private var _queueInterval:Int;         
        private var _queueLength:Int;           
        private var _jobProgress:Float;        
        private var _currentJob:Int;            
        private var _jobQueue: Array<SiONDriverJob> = null;   
        private var _trackEventQueue: Array<SiONTrackEvent>;  
        
        private var _timerSequence:MMLSequence;     
        private var _timerIntervalEvent:MMLEvent;   
        private var _timerCallback:Dynamic;        
        
        private var _renderBuffer: Array<Float>;  
        private var _renderBufferChannelCount:Int;  
        private var _renderBufferIndex:Int;         
        private var _renderBufferSizeMax:Int;       
        
        private var _timeCompile:Int;           
        private var _timeRender:Int;            
        private var _timeProcess:Int;           
        private var _timeProcessTotal:Int;      
        private var _timeProcessData:SLLint;    
        private var _timeProcessAveRatio:Float;
        private var _timePrevStream:Int;        
        private var _latency:Float;            
        private var _prevFrameTime:Int;         
        private var _frameRate:Int;             
        
        private var _eventListenerPrior:Bool;    
        private var _listenEvent:Int;           
        
        private var _midiModule:MIDIModule;                 
        private var _midiConverter:SiONDataConverterSMF;    
        
        
        
        static private var _mutex:SiONDriver = null;     
        
        
        
        
    
    
        
        static public function mutex() : SiONDriver { return _mutex; }
        
        
        
        
        public function mmlString() : String { return _mmlString; }
        
        
        public function data() : SiONData { return _data; }
        
        
        public function sound() : Sound { return _sound; }
        
        
        public function soundChannel() : SoundChannel { return _soundChannel; }

        
        public function fader() : Fader { return _fader; }
        
        
        
        
        public function trackCount() : Int { return sequencer.tracks.length; }
        
        
        public function bufferLength() : Int { return _bufferLength; }
        
        public function sampleRate() : Float { return _sampleRate; }
        
        public function bitRate() : Float { return _bitRate; }
        
        
        public function get_volume() : Float { return _masterVolume; }
        public function volume(v:Float) : Void {
            _masterVolume = v;
            _soundTransform.volume = _masterVolume * _faderVolume;
            if (_soundChannel != null) _soundChannel.soundTransform = _soundTransform;
        }
        
        
        public function get_pan() : Float { return _soundTransform.pan; }
        public function pan(p:Float) : Void {
            _soundTransform.pan = p;
            if (_soundChannel != null) _soundChannel.soundTransform = _soundTransform;
        }
        
        
        
        
        public function compileTime() : Int { return _timeCompile; }
        
        
        public function renderTime() : Int { return _timeRender; }
        
        
        public function processTime() : Int { return _timeProcess; }
        
        
        public function jobProgress() : Float { return _jobProgress; }
        
        
        public function jobQueueProgress() : Float {
            if (_queueLength == 0) return 1;
            return (_queueLength - _jobQueue.length - 1 + _jobProgress) / _queueLength;
        }
        
        
        public function latency() : Float { return _latency; }
        
        
        public function jobQueueLength() : Int { return _jobQueue.length; }
        
        
        
        
        public function isJobExecuting() : Bool { return (_jobProgress>0 && _jobProgress<1); }
        
        
        public function isPlaying() : Bool { return (_soundChannel != null); }
        
        
        public function isPaused() : Bool { return _isPaused; }
        
        
        
        
        public function backgroundSound() : Sound { return _backgroundSound; }
        
        
        public function backgroundSoundTrack() : SiMMLTrack { return _backgroundTrack; }
        
        
        public function backgroundSoundFadeOutTime() : Float { return _backgroundFadeOutFrames * _bufferLength / _sampleRate; }
        
        
        public function backgroundSoundFadeInTime() : Float { return _backgroundFadeInFrames * _bufferLength / _sampleRate; }
        
        
        public function backgroundSoundFadeGapTime() : Float { return _backgroundFadeGapFrames * _bufferLength / _sampleRate; }
        
        
        public function get_backgroundSoundVolume() : Float { return _backgroundVoice.channelParam.volumes[0]; }
        public function backgroundSoundVolume(vol:Float) : Void {
            _backgroundVoice.channelParam.volumes[0] = vol;
            if (_backgroundTrack != null) _backgroundTrack.masterVolume( Std.int(vol * 128));
            if (_backgroundTrackFadeOut != null) _backgroundTrackFadeOut.masterVolume( Std.int(vol * 128 ));
        }
        
        
        public function midiModule() : MIDIModule { return _midiModule; }
        
        
        
        
        public function get_position() : Float {
            return sequencer.processedSampleCount() * 1000 / _sampleRate;
        }
        public function position(pos:Float) : Void {
            _position = pos;
            if (sequencer.isReadyToProcess()) {
                sequencer._resetAllTracks();
                sequencer.dummyProcess(Std.int(_position * _sampleRate * 0.001));
            }
        }
        
        
        
        
        public function get_maxTrackCount() : Int { return sequencer._maxTrackCount; }
        public function maxTrackCount(max:Int) : Void { sequencer._maxTrackCount = max; }
        
        
        public function get_bpm() : Float {
            return (sequencer.isReadyToProcess()) ? sequencer.get_bpm() : sequencer.setting.defaultBPM;
        }
        public function bpm(t:Float) : Void {
            sequencer.setting.defaultBPM = t;
            if (sequencer.isReadyToProcess()) {
                if (!sequencer.isEnableChangeBPM()) throw errorCannotChangeBPM();
                sequencer.bpm( t);
            }
        }
        
        
        public function get_autoStop() : Bool { return _autoStop; }
        public function autoStop(mode:Bool) : Void { _autoStop = mode; }
        
        
        public function get_pauseWhileLoading() : Bool { return _suspendWhileLoading; }
        public function pauseWhileLoading(b:Bool) : Void { _suspendWhileLoading = b; }
        
        
        public function get_debugMode() : Bool { return _debugMode; }
        public function debugMode(mode:Bool) : Void { _debugMode = mode; }
        
        
        public function get_noteOnExceptionMode() : Int { return _noteOnExceptionMode; }
        public function noteOnExceptionMode(mode:Int) : Void { _noteOnExceptionMode = (0<mode && mode<NEM_MAX) ? mode : 0; }
        
        
        
        
    
    
        
        function new(bufferLength:Int=2048, channelCount:Int=2, sampleRate:Int=44100, bitRate:Int=0)
        {
            
            if (_mutex != null) throw errorPluralDrivers();
            
            
            if (bufferLength != 2048 && bufferLength != 4096 && bufferLength != 8192) throw errorParamNotAvailable("stream buffer", bufferLength);
            if (channelCount != 1 && channelCount != 2) throw errorParamNotAvailable("channel count", channelCount);
            if (sampleRate != 44100) throw errorParamNotAvailable("sampling rate", sampleRate);
            
            
            var dummy:Dynamic;
            dummy = SiOPMTable.instance; 
            dummy = SiMMLTable.instance; 
            
            
            _jobQueue = new Array<SiONDriverJob>();
            module = new SiOPMModule();
            effector = new SiEffectModule(module);
            sequencer = new SiMMLSequencer(module, _callbackEventTriggerOn, _callbackEventTriggerOff, _callbackTempoChanged);
            _sound = new Sound();
            _soundTransform = new SoundTransform();
            _fader = new Fader();
            _timerSequence = new MMLSequence();
            _loadingSoundList = [];
            _midiModule = new MIDIModule();
            _midiConverter = new SiONDataConverterSMF(null, _midiModule);
            
            
            _tempData = null;
            _channelCount = channelCount;
            _sampleRate = sampleRate; 
            _bitRate = bitRate;
            _bufferLength = bufferLength;
            _listenEvent = NO_LISTEN;
            _dispatchStreamEvent = false;
            _dispatchFadingEvent = false;
            _preserveStop = false;
            _inStreaming = false;
            _suspendStreaming = false;
            _suspendWhileLoading = true;
            _autoStop = false;
            _noteOnExceptionMode = NEM_IGNORE;
            _debugMode = false;
            _isFinishSeqDispatched = false;
            _timerCallback = null;
            _timerSequence.initialize();
            _timerSequence.appendNewEvent(MMLEvent.REPEAT_ALL, 0);
            _timerSequence.appendNewEvent(MMLEvent.TIMER, 0);
            _timerIntervalEvent = _timerSequence.appendNewEvent(MMLEvent.GLOBAL_WAIT, 0, 0);
            
            _backgroundSound = null;
            _backgroundLoopPoint = -1;
            _backgroundFadeInFrames = 0;
            _backgroundFadeOutFrames = 0;
            _backgroundFadeGapFrames = 0;
            _backgroundTotalFadeFrames = 0;
            _backgroundVoice = new SiONVoice(SiMMLTable.MT_SAMPLE);
            _backgroundVoice.updateVolumes = true;
            _backgroundSample = null;
            _backgroundTrack = null;
            _backgroundTrackFadeOut = null;
            
            _position = 0;
            _masterVolume = 1;
            _faderVolume = 1;
            _soundTransform.pan = 0;
            _soundTransform.volume = _masterVolume * _faderVolume;
            
            _eventListenerPrior = false;
            _trackEventQueue = new Array<SiONTrackEvent>();
            
            _queueInterval = 500;
            _jobProgress = 0;
            _currentJob = 0;
            _queueLength = 0;
            
            _timeCompile = 0;
            _timeProcessTotal = 0;
            _timeProcessData = SLLint.allocRing(TIME_AVARAGING_COUNT);
            _timeProcessAveRatio = _sampleRate / (_bufferLength * TIME_AVARAGING_COUNT);
            _timePrevStream = 0;
            _latency = 0;
            _prevFrameTime = 0;
            _frameRate = 1;
            
            _mmlString    = null;
            _data         = null;
            _soundChannel = null;
            
            
            _sound.addEventListener(SampleDataEvent.SAMPLE_DATA, _streaming);
            
            
            _mutex = this;
			
			super();
        }
        
        
        
        
    
    
        
        public function compile(mml:String, data:SiONData=null) : SiONData
        {
            try {
                
                stop();
                
                
                var t:Int = Lib.getTimer();
                _prepareCompile(mml, data);
                _jobProgress = sequencer.compile(0);
                _timeCompile = Lib.getTimer() - t;
                _mmlString = null;
            } catch(e:Error) {
                
                if (_debugMode) throw e;
                else dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
            }
            
            return _data;
        }
        
        
        
        public function compileQueue(mml:String, data:SiONData) : Int
        {
            if (mml == null || data == null) return _jobQueue.length;
            return _jobQueue.push(new SiONDriverJob(mml, null, data, 2, false));
        }
        
        
        
        
    
    
        
        public function render(data:Dynamic, renderBuffer: Array<Float>=null, renderBufferChannelCount:Int=2, resetEffector:Bool=true) : Array<Float>
        {
            try {
                
                stop();
                
                
                var t:Int = Lib.getTimer();
                _prepareRender(data, renderBuffer, renderBufferChannelCount, resetEffector);
                while(true) { if (_rendering()) break; }
                _timeRender = Lib.getTimer() - t;
            } catch (e:Error) {
                
                _removeAllEventListners();
                if (_debugMode) throw e;
                else dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
            }
            
            return _renderBuffer;
        }
        
        
        
        public function renderQueue(data:Dynamic, renderBuffer: Array<Float>, renderBufferChannelCount:Int=2, resetEffector:Bool=false) : Int
        {
            if (data == null || renderBuffer == null) return _jobQueue.length;
            
            if (Std.is(data,String)) {
                var compiled:SiONData = new SiONData();
                _jobQueue.push(new SiONDriverJob(cast(data,String), null, compiled, 2, false));
                return _jobQueue.push(new SiONDriverJob(null, renderBuffer, compiled, renderBufferChannelCount, resetEffector));
            } else 
            if (Std.is(data,SiONData)) {
                return _jobQueue.push(new SiONDriverJob(null, renderBuffer, cast(data,SiONData), renderBufferChannelCount, resetEffector));
            }
            
            var e:Error = errorDataIncorrect();
            if (_debugMode) throw e;
            else dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
            return _jobQueue.length;
        }
        
        
        
        
    
    
        
        public function startQueue(interval:Int=500) : Int
        {
            try {
                stop();
                _queueLength = _jobQueue.length;
                if (_jobQueue.length > 0) {
                    _queueInterval = interval;
                    _executeNextJob();
                    _queue_addAllEventListners();
                }
            } catch (e:Error) {
                
                _removeAllEventListners();
                _cancelAllJobs();
                if (_debugMode) throw e;
                else dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
            }
            return _queueLength;
        }
                
        
        
        public function listenSoundLoadingStatus(sound:Dynamic, prior:Int=-99999) : Bool 
        {
            if (_loadingSoundList.indexOf(sound) != -1) return true;
            if (Std.is(sound,Sound)) {
                if (sound.bytesTotal == 0 || sound.bytesLoaded != sound.bytesTotal) {
                    _loadingSoundList.push(sound);
                    sound.addEventListener(Event.COMPLETE,        _onSoundEvent, false, prior);
                    sound.addEventListener(IOErrorEvent.IO_ERROR, _onSoundEvent, false, prior);
                    return true;
                }
            } else 
            if (Std.is(sound,SoundLoader)) {
                if (sound.loadingFileCount > 0) {
                    _loadingSoundList.push(sound);
                    sound.addEventListener(Event.COMPLETE,   _onSoundEvent, false, prior);
                    sound.addEventListener(ErrorEvent.ERROR, _onSoundEvent, false, prior);
                    return true;
                }
            } else {
                throw errorCannotListenLoading();
            }
            return false;
        }
        
        
        
        public function clearSoundLoadingList() : Void
        {
			_loadingSoundList.splice(0, _loadingSoundList.length);
        }
        
        
        
        public function setSoudReferenceTable(soundReferenceTable:Dynamic = null) : Void
        {
            SiOPMTable.instance().soundReference = (soundReferenceTable != null) ? soundReferenceTable : {};
        }
        
        
        
    
    
        
        public function play(data:Dynamic=null, resetEffector:Bool=true) : SoundChannel
        {
            try {
                if (_isPaused) {
                    _isPaused = false;
                } else {
                    
                    stop();
                    
                    
                    _prepareProcess(data, resetEffector);

                    
                    _timeProcessTotal = 0;
                   var i:Int=0;
 while( i<TIME_AVARAGING_COUNT){
                        _timeProcessData.i = 0;
                        _timeProcessData = _timeProcessData.next;
                     i++;
}
                    _isPaused = false;
                    _isFinishSeqDispatched = (data == null);
                    
                    
                    _suspendStreaming = true;
                    _soundChannel = _sound.play();
                    _soundChannel.soundTransform = _soundTransform;
                    _process_addAllEventListners();
                }
            } catch(e:Error) {
                
                if (_debugMode) throw e;
                else dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
            }
            
            return _soundChannel;
        }
        
        
        
        public function stop() : Void
        {
            if (_soundChannel != null) {
                if (_inStreaming) {
                    _preserveStop = true;
                } else {
                    stopBackgroundSound();
                    _removeAllEventListners();
                    _preserveStop = false;
                    _soundChannel.stop();
                    _soundChannel = null;
                    _latency = 0;
                    _fader.stop();
                    _faderVolume = 1;
                    _isPaused = false;
                    _soundTransform.volume = _masterVolume;
                    sequencer._stopSequence();
                    
                    
                    dispatchEvent(new SiONEvent(SiONEvent.STREAM_STOP, this));
                }
            }
        }
        
        
        
        public function reset() : Void
        {
            sequencer._resetAllTracks();
        }
        
        
        
        public function pause() : Void
        {
            _isPaused = true;
        }
        
        
        
        public function resume() : Void
        {
            _isPaused = false;
        }
        
        
        
        public function setBackgroundSound(sound:Sound, mixLevel:Float=0.5, loopPoint:Float=-1) : Void
        {
            backgroundSoundVolume( mixLevel );
            _backgroundLoopPoint = loopPoint;
            _setBackgroundSound(sound);
        }
        
        
        
        public function stopBackgroundSound() : Void
        {
            _setBackgroundSound(null);
        }
        
        
        
        public function setBackgroundSoundFadeTime(fadeInTime:Float, fadeOutTime:Float, gapTime:Float) : Void
        {
            var t2f:Float = _sampleRate / _bufferLength;
            _backgroundFadeInFrames  = Std.int(fadeInTime  * t2f);
            _backgroundFadeOutFrames = Std.int(fadeOutTime * t2f);
            _backgroundFadeGapFrames = Std.int(gapTime     * t2f);
            _backgroundTotalFadeFrames = _backgroundFadeOutFrames + _backgroundFadeInFrames + _backgroundFadeGapFrames;
        }
        
        
        
        public function fadeIn(time:Float) : Void
        {
            _fader.setFade(_fadeVolume, 0, 1, Std.int(time * _sampleRate / _bufferLength));
            _dispatchFadingEvent = (Lib.current.hasEventListener(SiONEvent.FADE_PROGRESS));
        }
        
        
        
        public function fadeOut(time:Float) : Void
        {
            _fader.setFade(_fadeVolume, 1, 0, Std.int(time * _sampleRate / _bufferLength));
            _dispatchFadingEvent = (Lib.current.hasEventListener(SiONEvent.FADE_PROGRESS));
        }
        
        
        
        public function setTimerInterruption(length16th:Float=1, callback:Dynamic=null) : Void
        {
            _timerIntervalEvent.length = Std.int(length16th * sequencer.setting.resolution * 0.0625);
            _timerCallback = (length16th > 0) ? callback : null;
        }
        
        
        
        public function setBeatCallbackInterval(length16th:Float=1) : Void
        {
            var filter:Int = 1;
            while (length16th > 1.5) {
                filter <<= 1;
                length16th *= 0.5;
            }
            sequencer._setBeatCallbackFilter(filter - 1);
        }
        
        
        
        public function forceDispatchStreamEvent(dispatch:Bool=true) : Void
        {
            _dispatchStreamEvent = dispatch || (Lib.current.hasEventListener(SiONEvent.STREAM));
        }
        
        
        
    
    
        
	    public function setWaveTable(index:Int, table:Array<Float>) : SiOPMWaveTable
        {
            var len:Int, bits:Int = -1;
			
			len = table.length; 
			
            while (len > 0) 
			{
				len >>= 1;
				bits++;
			}
			
            if (bits < 2) 
				return null;
				
            var waveTable:Array<Int> = SiONUtil.logTransVector(table, 1, null);
            //waveTable.length = 1<<bits;
            return SiOPMTable.instance().registerWaveTable(index, waveTable);
        }
		
        public function setPCMWave(index:Int, data:Dynamic, samplingNote:Float=69, keyRangeFrom:Int=0, keyRangeTo:Int=127, srcChannelCount:Int=2, channelCount:Int=0) : SiOPMWavePCMData
        {
            var pcmVoice:SiMMLVoice = SiOPMTable.instance()._getGlobalPCMVoice(index & (SiOPMTable.PCM_DATA_MAX-1));
            var pcmTable:SiOPMWavePCMTable = cast(pcmVoice.waveData,SiOPMWavePCMTable);
            return pcmTable.setSample(new SiOPMWavePCMData(data, Std.int(samplingNote*64), srcChannelCount, channelCount), keyRangeFrom, keyRangeTo);
        }
        
        
        public function setSamplerWave(index:Int, data:Dynamic, ignoreNoteOff:Bool=false, pan:Int=0, srcChannelCount:Int=2, channelCount:Int=0) : SiOPMWaveSamplerData
        {
            return SiOPMTable.instance().registerSamplerData(index, data, ignoreNoteOff, pan, srcChannelCount, channelCount);
        }
        
        
        
        public function setPCMVoice(index:Int, voice:SiONVoice) : Void
        {
            SiOPMTable._instance._setGlobalPCMVoice(index & (SiOPMTable.PCM_DATA_MAX-1), voice);
        }
        
        
        
        public function setSamplerTable(bank:Int, table:SiOPMWaveSamplerTable) : Void
        {
            SiOPMTable._instance.samplerTables[bank & (SiOPMTable.SAMPLER_TABLE_MAX-1)] = table;
        }
        
        
        
        public function setPCMData(index:Int, data: Array<Float>, samplingOctave:Int=5, keyRangeFrom:Int=0, keyRangeTo:Int=127, isSourceDataStereo:Bool=false) : SiOPMWavePCMData
        {
            return setPCMWave(index, data, samplingOctave*12+9, keyRangeFrom, keyRangeTo, (isSourceDataStereo)?2:1);
        }
        
        
        
        public function setPCMSound(index:Int, sound:Sound, samplingOctave:Int=5, keyRangeFrom:Int=0, keyRangeTo:Int=127) : SiOPMWavePCMData
        {
            return setPCMWave(index, sound, samplingOctave*12+9, keyRangeFrom, keyRangeTo, 1, 0);
        }
        
        
        
        public function setSamplerData(index:Int, data: Array<Float>, ignoreNoteOff:Bool=false, channelCount:Int=1) : SiOPMWaveSamplerData
        {
            return setSamplerWave(index, data, ignoreNoteOff, 0, channelCount);
        }
        
        
        
        public function setSamplerSound(index:Int, sound:Sound, ignoreNoteOff:Bool=false, channelCount:Int=2) : SiOPMWaveSamplerData
        {
            return setSamplerWave(index, sound, ignoreNoteOff, 0, channelCount);
        }
        
        
        
        public function setEnvelopTable(index:Int, table: Array<Int>, loopPoint:Int=-1) : Void
        {
            SiMMLTable.registerMasterEnvelopTable(index, new SiMMLEnvelopTable(table, loopPoint));
        }
        
        
        
        public function setVoice(index:Int, voice:SiONVoice) : Void
        {
            if (!voice._isSuitableForFMVoice()) throw errorNotGoodFMVoice();
            SiMMLTable.registerMasterVoice(index, voice);
        }
        
        
        
        public function clearAllUserTables() : Void
        {
            SiOPMTable.instance().resetAllUserTables();
            SiMMLTable.instance().resetAllUserTables();
        }
        
        
        
        
    
    
        
        public function playSound(sampleNumber:Int, 
                                  length:Float      = 0, 
                                  delay:Float       = 0, 
                                  quant:Float       = 0, 
                                  trackID:Int        = 0, 
                                  isDisposable:Bool = true) : SiMMLTrack
        {
            var internalTrackID:Int = (trackID & SiMMLTrack.TRACK_ID_FILTER) | SiMMLTrack.DRIVER_NOTE,
                mmlTrack:SiMMLTrack = null, 
                delaySamples:Float = sequencer.calcSampleDelay(0, delay, quant);
            
            
            if (_noteOnExceptionMode != NEM_IGNORE) {
                
                mmlTrack = sequencer._findActiveTrack(internalTrackID, Std.int(delaySamples));
                if (_noteOnExceptionMode == NEM_REJECT && mmlTrack != null) return null; 
                else if (_noteOnExceptionMode == NEM_SHIFT) { 
                    var step:Int = Std.int(sequencer.calcSampleLength(quant));
                    while (mmlTrack != null) {
                        delaySamples += step;
                        mmlTrack = sequencer._findActiveTrack(internalTrackID, Std.int(delaySamples));
                    }
                }
            }
            
            mmlTrack = (mmlTrack != null) ? mmlTrack : sequencer._newControlableTrack(internalTrackID, isDisposable);
            if (mmlTrack != null) {
                mmlTrack.setChannelModuleType(10, 0);
                mmlTrack.keyOn(sampleNumber, Std.int(length * sequencer.setting.resolution * 0.0625), Std.int(delaySamples));
            }
            return mmlTrack;
        }
        
        
        
        public function noteOn(note:Int, 
                               voice:SiONVoice    = null, 
                               length:Float      = 0, 
                               delay:Float       = 0, 
                               quant:Float       = 0, 
                               trackID:Int        = 0,
                               isDisposable:Bool = true) : SiMMLTrack
        {
            var internalTrackID:Int = (trackID & SiMMLTrack.TRACK_ID_FILTER) | SiMMLTrack.DRIVER_NOTE,
                mmlTrack:SiMMLTrack = null, 
                delaySamples:Float = sequencer.calcSampleDelay(0, delay, quant);
            
            
            if (_noteOnExceptionMode != NEM_IGNORE) {
                
                mmlTrack = sequencer._findActiveTrack(internalTrackID, Std.int(delaySamples));
                if (_noteOnExceptionMode == NEM_REJECT && mmlTrack != null) return null; 
                else if (_noteOnExceptionMode == NEM_SHIFT) { 
                    var step:Int = Std.int(sequencer.calcSampleLength(quant));
                    while (mmlTrack != null) {
                        delaySamples += step;
                        mmlTrack = sequencer._findActiveTrack(internalTrackID, Std.int(delaySamples));
                    }
                }
            }

            mmlTrack = (mmlTrack != null) ? mmlTrack : sequencer._newControlableTrack(internalTrackID, isDisposable);
            if (mmlTrack != null) {
                if (voice != null) voice.updateTrackVoice(mmlTrack);
                mmlTrack.keyOn(note, Std.int(length * sequencer.setting.resolution * 0.0625), Std.int(delaySamples));
            }
            return mmlTrack;
        }
        
        
        
        public function noteOff(note:Int, trackID:Int=0, delay:Float=0, quant:Float=0, stopImmediately:Bool=false) : Array<SiMMLTrack>
        {
            var internalTrackID:Int = (trackID & SiMMLTrack.TRACK_ID_FILTER) | SiMMLTrack.DRIVER_NOTE,
                delaySamples:Int = Std.int(sequencer.calcSampleDelay(0, delay, quant)), n:Int, 
                tracks: Array<SiMMLTrack> = new Array<SiMMLTrack>();
            for (mmlTrack in sequencer.tracks) {
                if (mmlTrack._internalTrackID == internalTrackID) {
                    if (note == -1 || (note == mmlTrack.note() && mmlTrack.channel.isNoteOn())) {
                        mmlTrack.keyOff(delaySamples, stopImmediately);
                        tracks.push(mmlTrack);
                    } else if (mmlTrack.executor.noteWaitingFor() == note) {
                        
                        mmlTrack.keyOn(note, 1, delaySamples);
                        tracks.push(mmlTrack);
                    }
                }
            }
            return tracks;
        }
        
        
        
        public function sequenceOn(data:SiONData, 
                                   voice:SiONVoice  = null, 
                                   length:Float    = 0, 
                                   delay:Float     = 0, 
                                   quant:Float     = 1, 
                                   trackID:Int      = 0,
                                   isDisposable:Bool = true) : Array<SiMMLTrack>
        {
            var internalTrackID:Int = (trackID & SiMMLTrack.TRACK_ID_FILTER) | SiMMLTrack.DRIVER_SEQUENCE,
                mmlTrack:SiMMLTrack, 
                tracks: Array<SiMMLTrack> = new Array<SiMMLTrack>(), 
                seq:MMLSequence = data.sequenceGroup.headSequence(), 
                delaySamples:Int = Std.int(sequencer.calcSampleDelay(0, delay, quant)),
                lengthSamples:Int = Std.int(sequencer.calcSampleLength(length));
            
            
            while (seq != null) {
                if (seq.isActive) {
                    mmlTrack = sequencer._newControlableTrack(internalTrackID, isDisposable);
                    mmlTrack.sequenceOn(seq, lengthSamples, delaySamples);
                    if (voice != null) voice.updateTrackVoice(mmlTrack);
                    tracks.push(mmlTrack);
                }
                seq = seq.nextSequence();
            }
            return tracks;
        }
        
        
        
        public function sequenceOff(trackID:Int, delay:Float=0, quant:Float=1, stopWithReset:Bool=false) : Array<SiMMLTrack>
        {
            var internalTrackID:Int = (trackID & SiMMLTrack.TRACK_ID_FILTER) | SiMMLTrack.DRIVER_SEQUENCE,
                delaySamples:Int = Std.int(sequencer.calcSampleDelay(0, delay, quant)), stoppedTrack:SiMMLTrack = null,
                tracks: Array<SiMMLTrack> = new Array<SiMMLTrack>();
            for (mmlTrack in sequencer.tracks) {
                if (mmlTrack._internalTrackID == internalTrackID) {
                    mmlTrack.sequenceOff(delaySamples, stopWithReset);
                    tracks.push(mmlTrack);
                }
            }
            return tracks;
        }
        
        
        
        public function newUserControlableTrack(trackID:Int=0) : SiMMLTrack
        {
            var internalTrackID:Int = (trackID & SiMMLTrack.TRACK_ID_FILTER) | SiMMLTrack.USER_CONTROLLED;
            return sequencer._newControlableTrack(internalTrackID, false);
        }
        
        
        
        public function dispatchUserDefinedTrackEvent(eventTriggerID:Int, note:Int) : Void
        {
            var event:SiONTrackEvent = new SiONTrackEvent(SiONTrackEvent.USER_DEFINED, this, null, sequencer.streamWritingPositionResidue(), note, eventTriggerID);
            _trackEventQueue.push(event);
        }
        
        
        
        
    
    
    
    
    
        
        private function _callbackEventTriggerOn(track:SiMMLTrack) : Bool
        {
            return _publishEventTrigger(track, track.eventTriggerTypeOn(), SiONTrackEvent.NOTE_ON_FRAME, SiONTrackEvent.NOTE_ON_STREAM);
        }
        
        
        private function _callbackEventTriggerOff(track:SiMMLTrack) : Bool
        {
            return _publishEventTrigger(track, track.eventTriggerTypeOff(), SiONTrackEvent.NOTE_OFF_FRAME, SiONTrackEvent.NOTE_OFF_STREAM);
        }
        
        
        private function _publishEventTrigger(track:SiMMLTrack, type:Int, frameEvent:String, streamEvent:String) : Bool
        {
            var event:SiONTrackEvent;
            if ((type & 1) != 0) { 
                event = new SiONTrackEvent(frameEvent, this, track);
                _trackEventQueue.push(event);
            }
            if ((type & 2) != 0) { 
                event = new SiONTrackEvent(streamEvent, this, track);
                dispatchEvent(event);
                return !(event.isDefaultPrevented());
            }
            return true;
        }
        
        
        private function _callbackTempoChanged(bufferIndex:Int) : Void
        {
            var event:SiONTrackEvent = new SiONTrackEvent(SiONTrackEvent.CHANGE_BPM, this, null, bufferIndex);
            _trackEventQueue.push(event);
        }
        
        
        private function _callbackBeat(bufferIndex:Int, beatCounter:Int) : Void
        {
            var event:SiONTrackEvent = new SiONTrackEvent(SiONTrackEvent.BEAT, this, null, bufferIndex, 0, beatCounter);
            _trackEventQueue.push(event);
        }
        
        
        
        
    
    
        
        private function _queue_addAllEventListners() : Void
        {
            if (_listenEvent != NO_LISTEN) throw errorDriverBusy(listen_queue);
            Lib.current.addEventListener(Event.ENTER_FRAME, _queue_onEnterFrame,false,_eventListenerPrior);
            _listenEvent = listen_queue;
        }
        
        
        
        private function _process_addAllEventListners() : Void
        {
            if (_listenEvent != NO_LISTEN) throw errorDriverBusy(listen_process);
            Lib.current.addEventListener(Event.ENTER_FRAME, _process_onEnterFrame,false,_eventListenerPrior);
            if (Lib.current.hasEventListener(SiONTrackEvent.BEAT)) sequencer._setBeatCallback(_callbackBeat);
            else sequencer._setBeatCallback(null);
            _dispatchStreamEvent = (Lib.current.hasEventListener(SiONEvent.STREAM));
            _prevFrameTime = Lib.getTimer();
            _listenEvent = listen_process;
        }
        
        
        
        private function _removeAllEventListners() : Void
        {
            switch (_listenEvent) {
            case listen_queue:
                Lib.current.removeEventListener(Event.ENTER_FRAME, _queue_onEnterFrame);

            case listen_process:
                Lib.current.removeEventListener(Event.ENTER_FRAME, _process_onEnterFrame);
                sequencer._setBeatCallback(null);
                _dispatchStreamEvent = false;

            }
            _listenEvent = NO_LISTEN;
        }
        
        
        
        private function _onSoundEvent(e:Event) : Void
        {
            if (Std.is(e.target,Sound)) {
                e.target.removeEventListener(Event.COMPLETE,        _onSoundEvent);
                e.target.removeEventListener(IOErrorEvent.IO_ERROR, _onSoundEvent);
            } else { 
                e.target.removeEventListener(Event.COMPLETE,   _onSoundEvent);
                e.target.removeEventListener(ErrorEvent.ERROR, _onSoundEvent);
            }
            var i:Int = _loadingSoundList.indexOf(e.target);
            if (i != -1) _loadingSoundList.splice(i, 1);
        }
        
        
        
        
    
    
        
        private function _parseSystemCommand(systemCommands:Array<Dynamic>) : Bool
        {
            var id:Int, wcol:Int, effectSet:Bool = false;
            for (cmd in systemCommands) {
                switch(cmd.command){
                case "#EFFECT":
                    effectSet = true;
                    effector.parseMML(cmd.number, cmd.content, cmd.postfix);
                    break;
                case "#WAVCOLOR":
                case "#WAVC":
                    wcol = Std.parseInt(cmd.content);
                    setWaveTable(cmd.number, SiONUtil.waveColor(wcol));
                    break;
                }
            }
            return effectSet;
        }
        
        
        
        
    
    
        
        private function _cancelAllJobs() : Void
        {
            _data = null;
            _mmlString = null;
            _currentJob = 0;
            _jobProgress = 0;
			_jobQueue.splice(0, _jobQueue.length);
            _queueLength = 0;
            _removeAllEventListners();
            dispatchEvent(new SiONEvent(SiONEvent.QUEUE_CANCEL, this, null));
        }
        
        
        
        private function _executeNextJob() : Bool
        {
            _data = null;
            _mmlString = null;
            _currentJob = 0;
            if (_jobQueue.length == 0) {
                _queueLength = 0;
                _removeAllEventListners();
                dispatchEvent(new SiONEvent(SiONEvent.QUEUE_COMPLETE, this, null));
                return true;
            }
            
            var queue:SiONDriverJob = _jobQueue.shift();
            if (queue.mml != null) _prepareCompile(queue.mml, queue.data);
            else _prepareRender(queue.data, queue.buffer, queue.channelCount, queue.resetEffector);
            return false;
        }
        
        
        
        private function _queue_onEnterFrame(e:Event) : Void
        {
            try {
                var event:SiONEvent, t:Int = Lib.getTimer();
                
                switch (_currentJob) {
                case 1: 
                    _jobProgress = sequencer.compile(_queueInterval);
                    _timeCompile += Lib.getTimer() - t;
          
                case 2: 
                    _jobProgress += (1 - _jobProgress) * 0.5;
                    while (Lib.getTimer() - t <= _queueInterval) { 
                        if (_rendering()) {
                            _jobProgress = 1;
                            break;
                        }
                    }
                    _timeRender += Lib.getTimer() - t;
               
                }
                
                
                if (_jobProgress == 1) {
                    
                    if (_executeNextJob()) return;
                }
                
                
                event = new SiONEvent(SiONEvent.QUEUE_PROGRESS, this, null, true);
                dispatchEvent(event);
                if (event.isDefaultPrevented()) _cancelAllJobs();   
            } catch (e:Error) {
                
                _removeAllEventListners();
                _cancelAllJobs();
                if (_debugMode) throw e;
                else dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
            }
        }
        
        
        
        
    
    
        
        private function _prepareCompile(mml:String, data:SiONData) : Void
        {
            if (data != null) data.clear();
            _data = (data != null) ? data : new SiONData();
            _mmlString = mml;
            sequencer.prepareCompile(_data, _mmlString);
            _jobProgress = 0.01;
            _timeCompile = 0; 
            _currentJob = 1;
        }
        
        
        
        
    
    
        
        private function _prepareRender(data:Dynamic, renderBuffer: Array<Float>, renderBufferChannelCount:Int, resetEffector:Bool) : Void
        {
            
            _prepareProcess(data, resetEffector);
            
            
            _renderBuffer = (renderBuffer  != null) ? renderBuffer : new Array<Float>();
            _renderBufferChannelCount = (renderBufferChannelCount==2) ? 2 : 1;
            _renderBufferSizeMax = _renderBuffer.length;
            _renderBufferIndex = 0;

            
            _jobProgress = 0.01;
            _timeRender = 0;
            _currentJob = 2;
        }
        
        
        
        private function _rendering() : Bool
        {
            var i:Int, j:Int, imax:Int, extention:Int, 
                output: Array<Float> = module.output(), 
                finished:Bool = false;
            
            
            module._beginProcess();
            effector._beginProcess();
            sequencer._process();
            effector._endProcess();
            module._endProcess();
            
            
            imax      = _bufferLength<<1;
            extention = _bufferLength<<(_renderBufferChannelCount-1);
            if (_renderBufferSizeMax != 0 && _renderBufferSizeMax < _renderBufferIndex+extention) {
                extention = _renderBufferSizeMax - _renderBufferIndex;
                finished = true;
            }
            
            
            if (_renderBuffer.length < _renderBufferIndex+extention) {
                //_renderBuffer.length = _renderBufferIndex+extention;
            }
            
            
            if (_renderBufferChannelCount==2) {
               i=0; j=_renderBufferIndex;
 while( i<imax){
                    _renderBuffer[j] = output[i];
                 i++; j++;
}
            } else {
               i=0; j=_renderBufferIndex;
 while( i<imax){
                    _renderBuffer[j] = output[i];
                 i+=2; j++;
}
            }
            
            
            _renderBufferIndex += extention;
            
            return (finished || (_renderBufferSizeMax==0 && sequencer.isFinished()));
        }
        
        
        
        
    
    
        
        private function _prepareProcess(data:Dynamic, resetEffector:Bool) : Void
        {
            if (data) {
                if (Std.is(data,String)) { 
                    
                    _tempData = (_tempData != null) ? _tempData : new SiONData();
                    _data = compile(cast(data,String), _tempData);
                } else if (Std.is(data,SiONData)) {
                    
                    _data = data;
                } else if (Std.is(data,Sound)) {
                    setBackgroundSound(data);
                } else if (Std.is(data,URLRequest)) { 
                    var sound:Sound = new Sound(data);
                    setBackgroundSound(sound);
                } else if (Std.is(data,SMFData)) {
                    _midiConverter.smfData( data );
                    _midiConverter.useMIDIModuleEffector = resetEffector;
                    _data = _midiConverter;
                } else throw errorDataIncorrect(); 
            }
            
            
            module.initialize(_channelCount, _bitRate, _bufferLength);      
            module.reset();                                                 
            if (resetEffector) effector.initialize();                       
            else effector._reset();
            sequencer._prepareProcess(_data, Std.int(_sampleRate), _bufferLength);   
            if (_data != null) _parseSystemCommand(_data.systemCommands());           
            effector._prepareProcess();   
			
			_trackEventQueue = new Array<SiONTrackEvent>();
			_trackEventQueue.splice(0, _trackEventQueue.length);                              
            
            
            if (_data != null && _position > 0) {
                sequencer.dummyProcess(Std.int(_position * _sampleRate * 0.001));
            }
            
            
            if (_backgroundSound != null) {
                _startBackgroundSound();
            }
            
            
            if (_timerCallback != null) {
                sequencer.setGlobalSequence(_timerSequence); 
                sequencer._setTimerCallback(_timerCallback);
            }
        }
        
        
        
        private function _process_onEnterFrame(e:Event) : Void
        {
            
            var t:Int = Lib.getTimer();
            _frameRate = t - _prevFrameTime;
            _prevFrameTime = t;
            
            if (_suspendStreaming) {
                _onSuspendStream();
            } else {
                
                if (_preserveStop) stop();

                
                if (_trackEventQueue.length > 0) {
                    _trackEventQueue = _trackEventQueue.filter(_trackEventQueueFilter);
                }
            }
        }
        
        
        
        private function _trackEventQueueFilter(e:SiONTrackEvent) : Bool {
            if (e._decrementTimer(_frameRate)) {
                dispatchEvent(e);
                return false;
            }
            return true;
        }
        
        
        
        private function _onSuspendStream() : Void {
            
            _suspendStreaming = _suspendWhileLoading && (_loadingSoundList.length > 0);

            if (!_suspendStreaming) {
                
                var event:SiONEvent = new SiONEvent(SiONEvent.STREAM_START, this, null, true);
                dispatchEvent(event);
                if (event.isDefaultPrevented()) stop();   
            }
        }
        

        
        private function _streaming(e:SampleDataEvent) : Void
        {
			trace("streaming driver");
            var buffer:ByteArray = e.data, extracted:Int, 
                output: Array<Float> = module.output(), 
                imax:Int, i:Int, event:SiONEvent;

            
            if (_soundChannel != null) {
                _latency = e.position * 0.022675736961451247 - _soundChannel.position;
            }

            try {
                
                _inStreaming = true;
                
				if (e.data == null)
				{
					e.data = new ByteArray();
					e.data.bigEndian = false;
				}
				
                if (_isPaused || _suspendStreaming) {
                    
                    _fillzero(e.data);
                } else {
                    
                    var t:Int = Lib.getTimer();
                    
                    
                    module._beginProcess();
                    effector._beginProcess();
                    sequencer._process();
                    effector._endProcess();
                    module._endProcess();
                    
                    
                    _timePrevStream = t;
                    _timeProcessTotal -= _timeProcessData.i;
                    _timeProcessData.i = Lib.getTimer() - t;
                    _timeProcessTotal += _timeProcessData.i;
                    _timeProcessData   = _timeProcessData.next;
                    _timeProcess = Std.int(_timeProcessTotal * _timeProcessAveRatio);
                    
                    
                    imax = output.length;
                   i=0;
 while( i<imax){
                        event = new SiONEvent(SiONEvent.STREAM, this, buffer, true);
                        dispatchEvent(event);
                        if (event.isDefaultPrevented()) stop();   
                     i++;
}
                    
                    
                    if (!_isFinishSeqDispatched && sequencer.isSequenceFinished()) {
                        dispatchEvent(new SiONEvent(SiONEvent.FINISH_SEQUENCE, this));
                        _isFinishSeqDispatched = true;
                    }
                    
                    
                    if (_fader.execute()) {
                        var eventType:String = (_fader.isIncrement()) ? SiONEvent.FADE_IN_COMPLETE : SiONEvent.FADE_OUT_COMPLETE;
                        dispatchEvent(new SiONEvent(eventType, this, buffer));
                        if (_autoStop && !_fader.isIncrement()) stop();
                    } else {
                        
                        if (_autoStop && sequencer.isFinished()) stop();
                    }
                }
                
                
                _inStreaming = false;
                
            } catch (e:Error) {
                
                _removeAllEventListners();
                if (_debugMode) throw e;
                else dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
            }
        }
        
        
        
        private function _fillzero(buffer:ByteArray) : Void {
            var i:Int, imax:Int = _bufferLength;
           i=0;
 while( i<imax){
                buffer.writeFloat(0);
                buffer.writeFloat(0);
             i++;
}
        }
        
        
        
        
    
    
        
        public function _checkMIDIEventListeners() : Int
        {
            return ((Lib.current.hasEventListener(SiONMIDIEvent.NOTE_ON))?1:0) | 
                   ((Lib.current.hasEventListener(SiONMIDIEvent.NOTE_OFF))?2:0) | 
                   ((Lib.current.hasEventListener(SiONMIDIEvent.CONTROL_CHANGE))?4:0) | 
                   ((Lib.current.hasEventListener(SiONMIDIEvent.PROGRAM_CHANGE))?8:0) | 
                   ((Lib.current.hasEventListener(SiONMIDIEvent.PITCH_BEND))?16:0);
        }
        
        
        
        public function _dispatchMIDIEvent(type:String, track:SiMMLTrack, channelNumber:Int, note:Int, data:Int) : Void
        {
            var event:SiONMIDIEvent = new SiONMIDIEvent(type, this, track, channelNumber, sequencer.streamWritingPositionResidue(), note, data);
            _trackEventQueue.push(event);
        }
        
        
        
        
    
    
        
        private function _fadeVolume(v:Float) : Void {
            _faderVolume = v;
            _soundTransform.volume = _masterVolume * _faderVolume;
            if (_soundChannel != null) _soundChannel.soundTransform = _soundTransform;
            if (_dispatchFadingEvent) {
                var event:SiONEvent = new SiONEvent(SiONEvent.FADE_PROGRESS, this, null, true);
                dispatchEvent(event);
                if (event.isDefaultPrevented()) _fader.stop();   
            }
        }
        
        
        
        
    
    
        
        private function _setBackgroundSound(sound:Sound) : Void {
            if (sound != null) {
                if (sound.bytesTotal == 0 || Std.int(sound.bytesLoaded) != sound.bytesTotal) {
                    sound.addEventListener(Event.COMPLETE,        _onBackgroundSoundLoaded);
                    sound.addEventListener(IOErrorEvent.IO_ERROR, _errorBackgroundSound);
                } else {
                    _backgroundSound = sound;
                    if (isPlaying()) _startBackgroundSound();
                }
            } else {
                
                _backgroundSound = null;
                if (isPlaying()) _startBackgroundSound();
            }
        }
        
        
        
        private function _onBackgroundSoundLoaded(e:Event) : Void {
            _backgroundSound = cast(e.target,Sound);
            if (isPlaying()) _startBackgroundSound();
        }
        
        
        
        private function _startBackgroundSound() : Void {
            
            var startFrame:Int, endFrame:Int;
            
            
            if (_backgroundTrackFadeOut != null) {
                _backgroundTrackFadeOut.setDisposable();
                _backgroundTrackFadeOut.keyOff(0, true);
                _backgroundTrackFadeOut = null;
            }
            
            if (_backgroundTrack != null) {
                _backgroundTrackFadeOut = _backgroundTrack;
                _backgroundTrack = null;
                startFrame = 0;
            } else {
                
                startFrame = _backgroundFadeOutFrames + _backgroundFadeGapFrames;
            }
            
            if (_backgroundSound != null) {
                
                _backgroundSample = new SiOPMWaveSamplerData(_backgroundSound, true, 0, 2, 2);
                _backgroundVoice.waveData = _backgroundSample;
                if (_backgroundLoopPoint != -1) {
                    _backgroundSample.slice(-1, -1, Std.int(_backgroundLoopPoint * 44100));
                }
                _backgroundTrack = sequencer._newControlableTrack(SiMMLTrack.DRIVER_BACKGROUND, false);
                _backgroundTrack.expression(128);
                _backgroundVoice.updateTrackVoice(_backgroundTrack);
                _backgroundTrack.keyOn(60, 0, (_backgroundFadeOutFrames+_backgroundFadeGapFrames)*_bufferLength);
                endFrame = _backgroundTotalFadeFrames;
            } else {
                
                _backgroundSample = null;
                _backgroundVoice.waveData = null;
                _backgroundLoopPoint = -1;
                endFrame = _backgroundFadeOutFrames + _backgroundFadeGapFrames;
            }
            
            
            if (endFrame - startFrame > 0) {
                _fader.setFade(_fadeBackgroundSound, startFrame, endFrame, endFrame - startFrame);
            } else {
                
                if (_backgroundTrackFadeOut != null) {
                    _backgroundTrackFadeOut.setDisposable();
                    _backgroundTrackFadeOut.keyOff(0, true);
                    _backgroundTrackFadeOut = null;
                }
            }
        }
        
        
        
        private function _errorBackgroundSound(e:IOErrorEvent) : Void {
            _backgroundSound = null;
            throw errorSoundLoadingFailure();
        }
        
        
        
        private function _fadeBackgroundSound(v:Float) : Void {
            var fo:Float = 0, fi:Float=0;
            if (_backgroundTrackFadeOut != null) {
                if (_backgroundFadeOutFrames > 0) {
                    fo = 1 - v / _backgroundFadeOutFrames;
                         if (fo<0) fo=0;
                    else if (fo>1) fo=1;
                } else {
                    fo = 0;
                }
                _backgroundTrackFadeOut.expression( Std.int(fo * 128 ));
            }
            if (_backgroundTrack != null) {
                if (_backgroundFadeInFrames > 0) {
                    fi = 1 - (_backgroundTotalFadeFrames - v) / _backgroundFadeInFrames;
                         if (fi<0) fi=0;
                    else if (fi>1) fi=1;
                } else {
                    fi = 1;
                }
                _backgroundTrack.expression( Std.int(fi * 128) );
            }
            if (_backgroundTrackFadeOut != null && (fo==0 || fi==1)) {
                _backgroundTrackFadeOut.setDisposable();
                _backgroundTrackFadeOut.keyOff(0, true);
                _backgroundTrackFadeOut = null;
            }
        }

        
        
        
        
    
    
        private function errorPluralDrivers() : Error {
            return new Error("SiONDriver error; Cannot create pulral SiONDrivers.");
        }
        
        
        private function errorParamNotAvailable(param:String, num:Float) : Error {
            return new Error("SiONDriver error; Parameter not available. " + param + Std.string(num));
        }
        
        
        private function errorDataIncorrect() : Error {
            return new Error("SiONDriver error; data incorrect in play() or render().");
        }
        
        
        private function errorDriverBusy(execID:Int) : Error {
            var states:Array<Dynamic> = ["???", "compiling", "streaming", "rendering"];
            return new Error("SiONDriver error: Driver busy. Call " + states[execID] + " while " + states[_listenEvent] + ".");
        }
        
        
        private function errorCannotChangeBPM() : Error {
            return new Error("SiONDriver error: Cannot change bpm while rendering (SiONTrackEvent.NOTE_*_STREAM).");
        }
        
        
        private function errorNotGoodFMVoice() : Error {
            return new Error("SiONDriver error; Cannot register the voice.");
        }
        
        
        private function errorCannotListenLoading() : Error {
            return new Error("SiONDriver error; the class not available for listenSoundLoadingStatus");
        }
        
        
        private function errorSoundLoadingFailure() : Error {
            return new Error("SiONDriver error; fail to load the sound file");
        }
    }






class SiONDriverJob
{
    public var mml:String;
    public var buffer: Array<Float>;
    public var data:SiONData;
    public var channelCount:Int;
    public var resetEffector:Bool;
    
    public function new(mml_:String, buffer_: Array<Float>, data_:SiONData, channelCount_:Int, resetEffector_:Bool) 
    {
        mml = mml_;
        buffer = buffer_;
        data = (data_  != null) ? data : new SiONData();
        channelCount = channelCount_;
        resetEffector = resetEffector_;
    }
}



