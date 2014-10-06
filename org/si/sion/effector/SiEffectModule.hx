





package org.si.sion.effector ;
    import org.si.sion.module.SiOPMModule;
    import org.si.sion.module.SiOPMStream;
	import org.si.sion.effector.SiEffectBase;
    
    
    
    class SiEffectModule
    {
    
    
        
        
        
        
    
    
        private var _module:SiOPMModule;
        private var _freeEffectStreams: Array<SiEffectStream>;
        private var _localEffects: Array<SiEffectStream>;
        private var _globalEffects: Array<SiEffectStream>;
        private var _masterEffect:SiEffectStream;
        private var _globalEffectCount:Int;
        static private var _effectorInstances:Dynamic = {};
        
        
        
        
    
    
        
        public function globalEffectCount() : Int { return _globalEffectCount; }
        
        
        
        public function slot0(list:Array<Dynamic>) : Void { setEffectorList(0, list); }
        
        
        public function slot1(list:Array<Dynamic>) : Void { setEffectorList(1, list); }
        
        
        public function slot2(list:Array<Dynamic>) : Void { setEffectorList(2, list); }
        
        
        public function slot3(list:Array<Dynamic>) : Void { setEffectorList(3, list); }
        
        
        public function slot4(list:Array<Dynamic>) : Void { setEffectorList(4, list); }
        
        
        public function slot5(list:Array<Dynamic>) : Void { setEffectorList(5, list); }
        
        
        public function slot6(list:Array<Dynamic>) : Void { setEffectorList(6, list); }
        
        
        public function slot7(list:Array<Dynamic>) : Void { setEffectorList(7, list); }
        
        
        
        
    
    
        
        public function new(module:SiOPMModule) 
        {
            _module = module;
            _freeEffectStreams = new Array<SiEffectStream>();
            _localEffects  = new Array<SiEffectStream>();
            _globalEffects = new Array<SiEffectStream>();
            _masterEffect  = new SiEffectStream(_module, _module.outputStream);
            _globalEffects[0] = _masterEffect;
            _globalEffectCount = 0;

            
            var dummy:SiEffectTable = SiEffectTable.instance();
            
            
            register("ws",      SiEffectWaveShaper);
            register("eq",      SiEffectEqualiser);
            register("delay",   SiEffectStereoDelay);
            register("reverb",  SiEffectStereoReverb);
            register("chorus",  SiEffectStereoChorus);
            register("autopan", SiEffectAutoPan);
            register("ds",      SiEffectDownSampler);
            register("speaker", SiEffectSpeakerSimulator);
            register("comp",    SiEffectCompressor);
            register("dist",    SiEffectDistortion);
            register("stereo",  SiEffectStereoExpander);
            register("vowel",   SiFilterVowel);
            
            register("lf", SiFilterLowPass);
            register("hf", SiFilterHighPass);
            register("bf", SiFilterBandPass);
            register("nf", SiFilterNotch);
            register("pf", SiFilterPeak);
            register("af", SiFilterAllPass);
            register("lb", SiFilterLowBoost);
            register("hb", SiFilterHighBoost);
            
            register("nlf", SiCtrlFilterLowPass);
            register("nhf", SiCtrlFilterHighPass);
        }
        
        
        
        
    
    
        
        public function initialize() : Void
        {
            var es:SiEffectStream, i:Int;
            
            
            for (es in _localEffects) {
                es.free();
                _freeEffectStreams.push(es);
            }
		   _localEffects.splice(0, _localEffects.length);
            
            
           i=1;
 while( i<SiOPMModule.STREAM_SEND_SIZE){
                if (_globalEffects[i] != null) {
                    _globalEffects[i].free();
                    _freeEffectStreams.push(_globalEffects[i]);
                    _globalEffects[i] = null;
                }
             i++;
}
            _globalEffectCount = 0;
            
            
            _masterEffect.initialize(0);
            _globalEffects[0] = _masterEffect;
        }
        
        
        
        public function _reset() : Void
        {
            var es:SiEffectStream, i:Int;
            
            
            for (es in _localEffects) 
				es.reset();
            
            
           i=1;
 while( i<SiOPMModule.STREAM_SEND_SIZE){
                if (_globalEffects[i] != null) _globalEffects[i].reset();
             i++;
}
            
            
            _masterEffect.reset();
            _globalEffects[0] = _masterEffect;
        }
        
        
        
        public function _prepareProcess() : Void
        {
            var slot:Int, channelCount:Int, slotMax:Int = _localEffects.length;
            
            
           
            
            _globalEffectCount = 0;
           slot=1;
 while( slot<SiOPMModule.STREAM_SEND_SIZE){
                _module.streamSlot[slot] = null; 
                if (_globalEffects[slot] != null) {
                    channelCount = _globalEffects[slot].prepareProcess();
                    if (channelCount > 0) {
                        _module.streamSlot[slot] = _globalEffects[slot]._stream;
                        _globalEffectCount++;
                    }
                }
             slot++;
}
            
            
            _masterEffect.prepareProcess();
        }
        
        
        
        public function _beginProcess() : Void
        {
            var slot:Int, leLength:Int=_localEffects.length;
            
            
           slot=0;
 while( slot<leLength){
                _localEffects[slot]._stream.clear();
             slot++;
}
            
            
           slot=1;
 while( slot<SiOPMModule.STREAM_SEND_SIZE){
                if (_globalEffects[slot] != null) _globalEffects[slot]._stream.clear();
             slot++;
}
            
            
        }
        
        
        
        public function _endProcess() : Void
        {
            var i:Int, slot:Int, leLength:Int=_localEffects.length,
                buffer: Array<Float>, effect:SiEffectStream, 
                bufferLength:Int = _module.bufferLength(),
                output: Array<Float> = _module.output(),
                imax:Int = output.length;
            
            
           slot=0;
 while( slot<leLength){
                _localEffects[slot].process(0, bufferLength);
             slot++;
}
            
            
           slot=1;
 while( slot<SiOPMModule.STREAM_SEND_SIZE){
                effect = _globalEffects[slot];
                if (effect != null) {
                    if (effect._outputDirectly()) {
                        effect.process(0, bufferLength, false);
                        buffer = effect._stream.buffer;
                       i=0;
 while( i<imax){ output[i] += buffer[i]; i++;
}
                    } else {
                        effect.process(0, bufferLength, true);
                    }
                }
             slot++;
}
            
            
            _masterEffect.process(0, bufferLength, false);
        }
        
        
        
        
    
    
        
        static public function register(name:String, cls:Class<Dynamic>) : Void
        {
			Reflect.setField(_effectorInstances, name, new EffectorInstances(cls));
        }
        
        
        
        static public function getInstance(name:String) : SiEffectBase
        {
            if (!Reflect.hasField(_effectorInstances,name)) return null;
            
			
            var effect:SiEffectBase, 
                factory:EffectorInstances = Reflect.field(_effectorInstances, name);
            for(effect in factory._instances) {
                if (effect._isFree) {
                    effect._isFree = false;
                    effect.initialize();
                    return effect;
                }
            }
            effect = Type.createInstance(factory._classInstance, []);
            factory._instances.push(effect);
            
            effect._isFree = false;
            effect.initialize();
            return effect;
        }
        
        
        
        
    
    
        
        public function clear(slot:Int) : Void
        {
            if (slot == 0) {
                _masterEffect.initialize(0);
            } else {
                if (_globalEffects[slot] != null) _freeEffectStreams.push(_globalEffects[slot]);
                _globalEffects[slot] = null;
            }
        }
        
        
        
        public function getEffectorList(slot:Int) : Array<SiEffectBase>
        {
            if (_globalEffects[slot] == null) return null;
            return _globalEffects[slot].chain;
        }
        
        
        
        public function setEffectorList(slot:Int, list:Array<Dynamic>) : Void
        {
			
            var es:SiEffectStream = _globalEffector(slot);
            es.chain = cast list ;
            es.prepareProcess();
        }
        

        
        public function connect(slot:Int, effector:SiEffectBase) : Void
        {
            _globalEffector(slot).chain.push(effector);
            effector.prepareProcess();
        }
        
        
        
        public function parseMML(slot:Int, mml:String, postfix:String) : Void
        {
            _globalEffector(slot).parseMML(slot, mml, postfix);
        }
        
        
        
        public function newLocalEffect(depth:Int, list: Array<SiEffectBase>) : SiEffectStream
        {
            var inst:SiEffectStream = _allocStream(depth);
            inst.chain = list;
            inst.prepareProcess();
            if (depth == 0) {
                _localEffects.push(inst);
                return inst;
            } else {
               var slot:Int=_localEffects.length-1;
 while( slot>=0){
                    if (_localEffects[slot]._depth >= depth) {
                        _localEffects.splice(slot, 0);
						_localEffects.insert(slot, inst);
                        return inst;
                    }
                 --slot;
}
            }
            _localEffects.unshift(inst);
            return inst;
        }
        
        
        
        public function deleteLocalEffect(inst:SiEffectStream) : Void
        {
            var i:Int = _localEffects.indexOf(inst);
            if (i != -1) _localEffects.splice(i, 1);
            _freeEffectStreams.push(inst);
        }
        
        
        
        private function _globalEffector(slot:Int) : SiEffectStream {
            if (_globalEffects[slot] == null) {
                var es:SiEffectStream = _allocStream(0);
                _globalEffects[slot] = es;
                _module.streamSlot[slot] = es.stream();
                _globalEffectCount++;
            }
            return _globalEffects[slot];
        }
        
        
        
        
    
    
        private function _allocStream(depth:Int) : SiEffectStream
        {
			var ptmp:SiEffectStream =  _freeEffectStreams.pop();
			
            var es:SiEffectStream = (ptmp != null) ? ptmp :  new SiEffectStream(_module);
            es.initialize(depth);
            return es;
        }
    }


class EffectorInstances
{
    public var _instances:Array<Dynamic> = [];
    public var _classInstance:Class<Dynamic>;
    
    public function new(cls:Class<Dynamic>)
    {
        _classInstance = cls;
    }
}



