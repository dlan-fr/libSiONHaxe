package org.si.sion.module ;
    import flash.media.Sound;
    

    
    interface ISiOPMWaveInterface {
        
        function setPCMWave(index:Int, data:Dynamic, samplingNote:Float=69, keyRangeFrom:Int=0, keyRangeTo:Int=127, srcChannelCount:Int=2, channelCount:Int=0) : SiOPMWavePCMData;
        
        
        function setSamplerWave(index:Int, data:Dynamic, ignoreNoteOff:Bool=false, pan:Int=0, srcChannelCount:Int=2, channelCount:Int=0) : SiOPMWaveSamplerData;
    }


