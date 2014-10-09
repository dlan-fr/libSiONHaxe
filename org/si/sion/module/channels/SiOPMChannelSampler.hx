





package org.si.sion.module.channels ;
    import flash.utils.ByteArray;
    import org.si.utils.SLLNumber;
    import org.si.utils.SLLint;
    import org.si.sion.module.SiOPMWaveSamplerData;
    import org.si.sion.module.SiOPMWaveSamplerTable;
	import org.si.sion.module.SiOPMModule;
    
    
    class SiOPMChannelSampler extends SiOPMChannelBase
    {
    
    
           var _bankNumber:Int;
           var _waveNumber:Int;
        
            var _expression:Float;
        
          var _samplerTable:SiOPMWaveSamplerTable;
          var _sampleData :SiOPMWaveSamplerData;
          var _sampleIndex:Int;
           var _sampleStartPhase:Int;

         var _extractedByteArray:ByteArray;
                  var _extractedSample: Array<Float>;
        
        
        private var _samplePan:Int;
        
        
        
        
    
    
        
        public function toString() : String
        {
            var str:String = "SiOPMChannelSampler : ";
			var s2:Dynamic = function (p:String, i:Dynamic, q:String, j:Dynamic) : Void { str += "  " + p + "=" + Std.string(i) + " / " + q + "=" + Std.string(j) + "\n"; }
            s2("vol", _volumes[0]*_expression,  "pan", _pan-64);
            return str;
            
        }
        
        
        
        
    
    
        
        function new(chip:SiOPMModule)
        {
            _extractedByteArray = new ByteArray();
            _extractedSample = new Array<Float>();
            super(chip);
        }




    
    
        
        override public function setSiOPMChannelParam(param:SiOPMChannelParam, withVolume:Bool, withModulation:Bool=true) : Void
        {
            var i:Int;
            if (param.opeCount == 0) return;
            
            if (withVolume) {
                var imax:Int = SiOPMModule.STREAM_SEND_SIZE;
               i=0;
 while( i<imax){ _volumes[i] = param.volumes[i]; i++;
}
               _hasEffectSend=false; i=1;
 while( i<imax){ if (_volumes[i] > 0) _hasEffectSend = true; i++;
}
                _pan = param.pan;
            }
        }
        
        
        
        override public function getSiOPMChannelParam(param:SiOPMChannelParam) : Void
        {
            var i:Int, imax:Int = SiOPMModule.STREAM_SEND_SIZE;
           i=0;
 while( i<imax){ param.volumes[i] = _volumes[i]; i++;
}
            param.pan = _pan;
        }
        
        
        
        
    
    
        
        override public function setAlgorism(cnt:Int, alg:Int) : Void
        {
        }
        
        
        
        override public function setType(pgType:Int, ptType:Int) : Void 
        {
            _bankNumber = pgType & 3;
        }
        
        
        
        
    
    
        
        override public function get_pitch() : Int { return _waveNumber<<6; }
        override public function pitch(p:Int) : Void {
            _waveNumber = p >> 6;
        }
        
        
        override public function setWaveData(waveData:SiOPMWaveBase) : Void {
            _samplerTable = cast(waveData,SiOPMWaveSamplerTable);
            _sampleData  = cast(waveData,SiOPMWaveSamplerData);
        }
        
        
        
        
    
    
        
        override public function offsetVolume(expression:Int, velocity:Int) : Void {
            _expression = expression * velocity * 0.00006103515625; 
        }
        
        
        override public function phase(i:Int) : Void {
            _sampleStartPhase = i;
        }
        
        
        
        
    
    
        
        override public function initialize(prev:SiOPMChannelBase, bufferIndex:Int) : Void
        {
            super.initialize(prev, bufferIndex);
            reset();
        }
        
        
        
        override public function reset() : Void
        {
            _isNoteOn = false;
            _isIdling = true;
            _bankNumber = 0;
            _waveNumber = -1;
            _samplePan = 0;
            
            _samplerTable = _table.samplerTables[0];
            _sampleData = null;
            
            _sampleIndex = 0;
            _sampleStartPhase = 0;
            _expression = 1;
        }
        
        
        
        override public function noteOn() : Void
        {
            if (_waveNumber >= 0) {
                if (_samplerTable != null) _sampleData = _samplerTable.getSample(_waveNumber & 127);
                if (_sampleData != null && _sampleStartPhase!=255) {
                    _sampleIndex = _sampleData.getInitialSampleIndex(_sampleStartPhase * 0.00390625); 
                    _samplePan = _pan + _sampleData.pan();
                    if (_samplePan < 0) _samplePan = 0;
                    else if (_samplePan > 128) _samplePan = 128;
                }
                _isIdling = (_sampleData == null);
                _isNoteOn = !_isIdling;
            }
        }
        
        
        
        override public function noteOff() : Void
        {
            if (_sampleData != null) {
                if (!_sampleData.get_ignoreNoteOff()) {
                    _isNoteOn = false;
                    _isIdling = true;
                    if (_samplerTable != null) _sampleData = null;
                }
            }
        }
        
        
        
        override public function buffer(len:Int) : Void
        {
            var i:Int, imax:Int, vol:Float, residue:Int, processed:Int, stream:SiOPMStream;
            if (_isIdling || _sampleData == null || _mute) {
                
            } else {
                if (_sampleData.isExtracted()) {
                    
                   residue=len; i=0;
 while( residue>0){
                        
                        processed = (_sampleIndex + residue < _sampleData.endPoint()) ? residue : (_sampleData.endPoint() - _sampleIndex);
                        if (_hasEffectSend) {
                           i=0;
 while( i<SiOPMModule.STREAM_SEND_SIZE){
                                if (_volumes[i]>0) {
                                    stream = (_streams[i] != null) ? _streams[i] : _chip.streamSlot[i];
                                    if (stream != null) {
                                        vol = _volumes[i] * _expression * _chip.samplerVolume;
                                        stream.writeVectorNumber(_sampleData.waveData(), _sampleIndex, _bufferIndex, processed, vol, _samplePan, _sampleData.channelCount());
                                    }
                                }
                             i++;
}
                        } else {
                            stream = (_streams[0] != null) ? _streams[0] :  _chip.outputStream;
                            vol = _volumes[0] * _expression * _chip.samplerVolume;
                            stream.writeVectorNumber(_sampleData.waveData(), _sampleIndex, _bufferIndex, processed, vol, _samplePan, _sampleData.channelCount());
                        }
                        _sampleIndex += processed;
                        
                        
                        residue -= processed;
                        if (residue > 0) {
                            if (_sampleData.loopPoint() >= 0) {
                                 
                                if (_sampleData.loopPoint()>_sampleData.startPoint()) _sampleIndex = _sampleData.loopPoint();
                                else _sampleIndex = _sampleData.startPoint();
                            } else {
                                
                                _isIdling = true;
                                if (_samplerTable != null) _sampleData = null;
                                
                                break;
                            }
                        }
                    }
                } else {
                    
                   residue=len; i=0; imax=0;
 while( residue>0){
                        _extractedByteArray.clear();
                        processed = 0;
						//Std.int(_sampleData.soundData().extract(_extractedByteArray, cast(residue,Float), cast(_sampleIndex<<1,Float))); //HAXE no sound.extract
                        _sampleIndex += processed >> 1;
                        if (_sampleIndex > _sampleData.endPoint()) processed -= _sampleIndex - _sampleData.endPoint();
                        
                        
                        imax += processed << 1;
                        _extractedByteArray.position = 0;
                       
 while( i<imax){ _extractedSample[i] = _extractedByteArray.readFloat();  i++;
}
                        
                        
                        residue -= processed;
                        if (residue > 0) {
                            if (_sampleData.loopPoint() >= 0) {
                                 
                                if (_sampleData.loopPoint()>_sampleData.startPoint()) _sampleIndex = _sampleData.loopPoint();
                                else _sampleIndex = _sampleData.startPoint();
                            } else {
                                
                                _isIdling = true;
                                if (_samplerTable != null) _sampleData = null;
                                
                                break;
                            }
                        }
                    }
                    processed = len - residue;
                    
                    
                    if (_hasEffectSend) {
                       i=0;
 while( i<SiOPMModule.STREAM_SEND_SIZE){
                            if (_volumes[i]>0) {
                                stream = (_streams[i] != null) ? _streams[i] : _chip.streamSlot[i];
                                if (stream != null) {
                                    vol = _volumes[i] * _expression * _chip.samplerVolume;
                                    stream.writeVectorNumber(_extractedSample, 0, _bufferIndex, processed, vol, _samplePan, 2);
                                }
                            }
                         i++;
}
                    } else {
                        stream = (_streams[0] != null) ? _streams[0] : _chip.outputStream;
                        vol = _volumes[0] * _expression * _chip.samplerVolume;
                        stream.writeVectorNumber(_extractedSample, 0, _bufferIndex, processed, vol, _samplePan, 2);
                    }
                }
            }
            
            
            _bufferIndex += len;
        }
        
        
        
        override public function nop(len:Int) : Void
        {
            
            _bufferIndex += len;
        }
    }


