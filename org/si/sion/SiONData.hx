






package org.si.sion ;
    import flash.media.Sound;
    import org.si.sion.sequencer.SiMMLVoice;
    import org.si.sion.sequencer.SiMMLData;
    import org.si.sion.sequencer.SiMMLEnvelopTable;
    import org.si.sion.sequencer.SiMMLEnvelopTable;
    import org.si.sion.utils.SiONUtil;
    import org.si.sion.module.ISiOPMWaveInterface;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.module.SiOPMWavePCMTable;
    import org.si.sion.module.SiOPMWavePCMData;
    import org.si.sion.module.SiOPMWaveSamplerTable;
    import org.si.sion.module.SiOPMWaveSamplerData;

    
    
    class SiONData extends SiMMLData implements ISiOPMWaveInterface
    {
    
    
        
        
        
        
    
    
        public function new()
        {
			super();
        }
        
        
        
        
    
    
        
        public function setPCMWave(index:Int, data:Dynamic, samplingNote:Float=69, keyRangeFrom:Int=0, keyRangeTo:Int=127, srcChannelCount:Int=2, channelCount:Int=0) : SiOPMWavePCMData
        {
            var pcmTable:SiOPMWavePCMTable = cast(_getPCMVoice(index).waveData, SiOPMWavePCMTable);
            return (pcmTable != null) ? pcmTable.setSample(new SiOPMWavePCMData(data, Std.int(samplingNote*64), srcChannelCount, channelCount), keyRangeFrom, keyRangeTo) : null;
        }
        
        
        
        public function setSamplerWave(index:Int, data:Dynamic, ignoreNoteOff:Bool=false, pan:Int=0, srcChannelCount:Int=2, channelCount:Int=0) : SiOPMWaveSamplerData
        {
            var bank:Int = (index>>SiOPMTable.NOTE_BITS) & (SiOPMTable.SAMPLER_TABLE_MAX-1);
            return samplerTables[bank].setSample(new SiOPMWaveSamplerData(data, ignoreNoteOff, pan, srcChannelCount, channelCount), index & (SiOPMTable.NOTE_TABLE_SIZE-1));
        }
        

        
        public function setPCMVoice(index:Int, voice:SiONVoice) : Void
        {
            pcmVoices[index & (pcmVoices.length-1)] = voice;
        }
        
        
        
        public function setSamplerTable(bank:Int, table:SiOPMWaveSamplerTable) : Void
        {
            samplerTables[bank & (samplerTables.length-1)] = table;
        }
        
        
        
        public function setPCMData(index:Int, data: Array<Float>, samplingOctave:Int=5, keyRangeFrom:Int=0, keyRangeTo:Int=127, isSourceDataStereo:Bool=false) : SiOPMWavePCMData
        {
            return setPCMWave(index, data, samplingOctave*12+8, keyRangeFrom, keyRangeTo, (isSourceDataStereo)?2:1);
        }
        
        
        
        public function setPCMSound(index:Int, sound:Sound, samplingOctave:Int=5, keyRangeFrom:Int=0, keyRangeTo:Int=127) : SiOPMWavePCMData
        {
            return setPCMWave(index, sound, samplingOctave*12+8, keyRangeFrom, keyRangeTo, 1, 0);
        }
        
        
        
        public function setSamplerData(index:Int, data: Array<Float>, ignoreNoteOff:Bool=false, channelCount:Int=1) : SiOPMWaveSamplerData
        {
            return setSamplerWave(index, data, ignoreNoteOff, 0, channelCount);
        }
        
        
        
        public function setSamplerSound(index:Int, sound:Sound, ignoreNoteOff:Bool=false, channelCount:Int=2) : SiOPMWaveSamplerData
        {
            return setSamplerWave(index, sound, ignoreNoteOff, 0, channelCount);
        }
    }


