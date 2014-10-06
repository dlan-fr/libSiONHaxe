





package org.si.sion.sequencer ;
    import org.si.sion.sequencer.base.MMLSequence;
    import org.si.sion.module.SiOPMModule;
    import org.si.sion.module.SiOPMWavePCMTable;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.module.SiOPMChannelParam;
    import org.si.sion.module.channels.SiOPMChannelManager;
    import org.si.sion.module.channels.SiOPMChannelBase;

    
    
    class SiMMLChannelSetting
    {
    
    
        inline static public var SELECT_TONE_NOP   :Int = 0;
        inline static public var select_tone_normal:Int = 1;
        inline static public var select_tone_fm    :Int = 2;

        
        
        
    
    
        public   var type:Int;
        public var _selectToneType:Int;
        public var _pgTypeList: Array<Int>;
        public var _ptTypeList: Array<Int>;
        public var _initIndex:Int;
        public var _voiceIndexTable: Array<Int>;
        public var _channelType:Int;
        public var _isSuitableForFMVoice:Bool;
        public var _defaultOpeCount:Int;
        private  var _table:SiOPMTable;
        
        
        
        
    
    
        public function new(type:Int, offset:Int, length:Int, step:Int, channelCount:Int)
        {
            var i:Int, idx:Int;
            _table = SiOPMTable.instance();
            _pgTypeList = new Array<Int>();
            _ptTypeList = new Array<Int>();
           i=0; idx=offset;
 while( i<length){
                _pgTypeList[i] = idx;
                _ptTypeList[i] = _table.getWaveTable(idx).defaultPTType;
             i++; idx+=step;
}
            _voiceIndexTable = new Array<Int>();
           i=0;
 while( i<channelCount){ _voiceIndexTable[i] = i;  i++;
}
            
            this._initIndex = 0;
            this.type = type;
            _channelType = SiOPMChannelManager.CT_CHANNEL_FM;
            _selectToneType = select_tone_normal;
            _defaultOpeCount = 1;
            _isSuitableForFMVoice = true;
        }
        
        
        
        
    
    
        
        public function initializeTone(track:SiMMLTrack, chNum:Int, bufferIndex:Int) : Int
        {
            if (track.channel == null) {
                
                track.channel = SiOPMChannelManager.newChannel(_channelType, null, bufferIndex);
            } else 
            if (track.channel._channelType != _channelType) {
                
                var prev:SiOPMChannelBase = track.channel;
                track.channel = SiOPMChannelManager.newChannel(_channelType, prev, bufferIndex);
                SiOPMChannelManager.deleteChannel(prev);
            } else {
                
                track.channel.initialize(track.channel, bufferIndex);
                track._resetVolumeOffset();
            }

            
            
            var voiceIndex:Int = _initIndex; 
            if (chNum>=0 && chNum<_voiceIndexTable.length) voiceIndex = _voiceIndexTable[chNum];
            track._channelNumber = (chNum<0) ? 0 : chNum;
            track.channel.setChannelNumber(chNum);
            track.channel.setAlgorism(_defaultOpeCount, 0);
            selectTone(track, voiceIndex);
            
            
            return (chNum == -1) ? -1 : voiceIndex;
        }
        
        
        
        public function selectTone(track:SiMMLTrack, voiceIndex:Int) : MMLSequence
        {
            if (voiceIndex == -1) return null;
            
            var voice:SiMMLVoice, pcmTable:SiOPMWavePCMTable;
            
            switch (_selectToneType) {
            case select_tone_normal:
                if (voiceIndex <0 || voiceIndex >=_pgTypeList.length) voiceIndex = _initIndex;
                track.channel.setType(_pgTypeList[voiceIndex], _ptTypeList[voiceIndex]);
            case select_tone_fm: 
                if (voiceIndex<0 || voiceIndex>=SiMMLTable.VOICE_MAX) voiceIndex=0;
                voice = SiMMLTable.instance().getSiMMLVoice(voiceIndex);
                if (voice != null) {
                    if (voice.updateTrackParamaters) {
                        voice.updateTrackVoice(track);
                        return null;
                    } else {
                        
                        track.channel.setSiOPMChannelParam(voice.channelParam, false, false);
                        track._resetVolumeOffset();
                        return (voice.channelParam.initSequence.isEmpty()) ? null : voice.channelParam.initSequence;
                    }
                }
            default:
            }
            return null;
        }
    }


