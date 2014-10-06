





package org.si.sion.sequencer ;
    import org.si.sion.module.channels.*;
    import org.si.sion.module.SiOPMChannelParam;
    import org.si.sion.module.SiOPMWaveBase;
    import org.si.sion.module.SiOPMWavePCMTable;
    import org.si.sion.module.SiOPMWavePCMData;
    import org.si.sion.module.SiOPMWaveTable;
    import org.si.sion.module.SiOPMWaveSamplerTable;
    
    
    
    class SiMMLVoice
    {
    
    
        
        public var chipType:String;
        
        
        public var updateTrackParamaters:Bool;
        
        public var updateVolumes:Bool;
        
        
        public var moduleType:Int;
        
        public var channelNum:Int;
        
        public var toneNum:Int;
        
        public var preferableNote:Int;
        
        
        public var channelParam:SiOPMChannelParam;
        
        public var waveData:SiOPMWaveBase;
        
        public var pmsTension:Int;
        
        
        
        
        public var defaultGateTime:Float;
        
        public var defaultGateTicks:Int;
        
        public var defaultKeyOnDelayTicks:Int;
        
        public var pitchShift:Int;
        
        public var noteShift:Int;
        
        public var portament:Int;
        
        public var releaseSweep:Int;
        
        
        
        public var velocity:Int;
        
        public var expression:Int;
        
        public var velocityMode:Int;
        
        public var vcommandShift:Int;
        
        public var expressionMode:Int;
        
        
        
        public var amDepth:Int;
        
        public var amDepthEnd:Int;
        
        public var amDelay:Int;
        
        public var amTerm:Int;
        
        public var pmDepth:Int;
        
        public var pmDepthEnd:Int;
        
        public var pmDelay:Int;
        
        public var pmTerm:Int;
        
        
        
        public var noteOnToneEnvelop:SiMMLEnvelopTable;
        
        public var noteOnAmplitudeEnvelop:SiMMLEnvelopTable;
        
        public var noteOnFilterEnvelop:SiMMLEnvelopTable;
        
        public var noteOnPitchEnvelop:SiMMLEnvelopTable;
        
        public var noteOnNoteEnvelop:SiMMLEnvelopTable;
        
        public var noteOffToneEnvelop:SiMMLEnvelopTable;
        
        public var noteOffAmplitudeEnvelop:SiMMLEnvelopTable;
        
        public var noteOffFilterEnvelop:SiMMLEnvelopTable;
        
        public var noteOffPitchEnvelop:SiMMLEnvelopTable;
        
        public var noteOffNoteEnvelop:SiMMLEnvelopTable;
        
        
        
        public var noteOnToneEnvelopStep:Int;
        
        public var noteOnAmplitudeEnvelopStep:Int;
        
        public var noteOnFilterEnvelopStep:Int;
        
        public var noteOnPitchEnvelopStep:Int;
        
        public var noteOnNoteEnvelopStep:Int;
        
        public var noteOffToneEnvelopStep:Int;
        
        public var noteOffAmplitudeEnvelopStep:Int;
        
        public var noteOffFilterEnvelopStep:Int;
        
        public var noteOffPitchEnvelopStep:Int;
        
        public var noteOffNoteEnvelopStep:Int;
        
        
        
        
    
    
        
        public function isFMVoice() : Bool { return (moduleType == 6); }
        
        
        public function isPCMVoice() : Bool { return (Std.is(waveData,SiOPMWavePCMTable) || Std.is(waveData,SiOPMWavePCMData)); }
        
        
        public function isSamplerVoice() : Bool { return (Std.is(waveData,SiOPMWaveSamplerTable)); }
        
        
        public function isWaveTableVoice() : Bool { return (Std.is(waveData,SiOPMWaveTable)); }
        
        
        public function _isSuitableForFMVoice() : Bool {
            return updateTrackParamaters || (SiMMLTable.isSuitableForFMVoice(moduleType) && waveData == null);
        }
        
        
        
        public function setModuleType(moduleType:Int, channelNum:Int=0, toneNum:Int=-1) : Void
        {
            this.moduleType = moduleType;
            this.channelNum = channelNum;
            this.toneNum    = toneNum;
            var pgType:Int = SiMMLTable.getPGType(moduleType, channelNum, toneNum);
            if (pgType != -1) channelParam.operatorParam[0].setPGType(pgType);
        }
        
        
        
        
    
    
        
        public function new()
        {
            channelParam = new SiOPMChannelParam();
            initialize();
        }
        
        
        
        
    
    
        
        public function updateTrackVoice(track:SiMMLTrack) : SiMMLTrack
        {
            
            switch (moduleType) {
            case 6:  
                track.setChannelModuleType(6, channelNum);
    
            case 11: 
                track.setChannelModuleType(11, 1);
                track.channel.setSiOPMChannelParam(channelParam, false);
                track.channel.setAllReleaseRate(pmsTension);
                if (isPCMVoice()) track.channel.setWaveData(waveData);
     
            default: 
                if (waveData != null) {
                    
                    track.setChannelModuleType(waveData.moduleType, -1);
                    track.channel.setSiOPMChannelParam(channelParam, updateVolumes);
                    track.channel.setWaveData(waveData);
                } else {
                    track.setChannelModuleType(moduleType, channelNum, toneNum);
                    track.channel.setSiOPMChannelParam(channelParam, updateVolumes);
                }

            }
            
            
            
            
            if (!Math.isNaN(defaultGateTime)) track.quantRatio = defaultGateTime;
            track.pitchShift = pitchShift;
            track.noteShift = noteShift;
            track._vcommandShift = vcommandShift;
            track.velocityMode (velocityMode);
            track.expressionMode(expressionMode);
            if (updateVolumes) {
                track.velocity(velocity);
                track.expression(expression);
            }
            
            track.setPortament(portament);
            track.setReleaseSweep(releaseSweep);
            track.setModulationEnvelop(false, amDepth, amDepthEnd, amDelay, amTerm);
            track.setModulationEnvelop(true,  pmDepth, pmDepthEnd, pmDelay, pmTerm);
            {
            track.setToneEnvelop(1, noteOnToneEnvelop, noteOnToneEnvelopStep);
            track.setAmplitudeEnvelop(1, noteOnAmplitudeEnvelop, noteOnAmplitudeEnvelopStep);
            track.setFilterEnvelop(1, noteOnFilterEnvelop, noteOnFilterEnvelopStep);
            track.setPitchEnvelop(1, noteOnPitchEnvelop, noteOnPitchEnvelopStep);
            track.setNoteEnvelop(1, noteOnNoteEnvelop, noteOnNoteEnvelopStep);
            track.setToneEnvelop(0, noteOffToneEnvelop, noteOffToneEnvelopStep);
            track.setAmplitudeEnvelop(0, noteOffAmplitudeEnvelop, noteOffAmplitudeEnvelopStep);
            track.setFilterEnvelop(0, noteOffFilterEnvelop, noteOffFilterEnvelopStep);
            track.setPitchEnvelop(0, noteOffPitchEnvelop, noteOffPitchEnvelopStep);
            track.setNoteEnvelop(0, noteOffNoteEnvelop, noteOffNoteEnvelopStep);
            }
            return track;
        }
        
        
        
        public function setTrackVoice(track:SiMMLTrack) : SiMMLTrack { 
            return updateTrackVoice(track); 
        }

        
        
        
    
    
        
        public function initialize() : Void
        {
            chipType = "";
            
            updateTrackParamaters = false;
            updateVolumes = false;
            
            moduleType = 5;
            channelNum = 0;
            toneNum = -1;
            preferableNote = -1;
            
            channelParam.initialize();
            waveData = null;
            pmsTension = 8;
            
            defaultGateTime = Math.NaN;
            defaultGateTicks = -1;
            defaultKeyOnDelayTicks = -1;
            pitchShift = 0;
            noteShift = 0;
            portament = 0;
            releaseSweep = 0;
            
            velocity = 256;
            expression = 128;
            vcommandShift = 4;
            velocityMode = 0;
            expressionMode = 0;
            
            amDepth = 0;
            amDepthEnd = 0;
            amDelay = 0;
            amTerm = 0;
            pmDepth = 0;
            pmDepthEnd = 0;
            pmDelay = 0;
            pmTerm = 0;

            noteOnToneEnvelop = null;
            noteOnAmplitudeEnvelop = null;
            noteOnFilterEnvelop = null;
            noteOnPitchEnvelop = null;
            noteOnNoteEnvelop = null;
            noteOffToneEnvelop = null;
            noteOffAmplitudeEnvelop = null;
            noteOffFilterEnvelop = null;
            noteOffPitchEnvelop = null;
            noteOffNoteEnvelop = null;
            
            noteOnToneEnvelopStep = 1;
            noteOnAmplitudeEnvelopStep = 1;
            noteOnFilterEnvelopStep = 1;
            noteOnPitchEnvelopStep = 1;
            noteOnNoteEnvelopStep = 1;
            noteOffToneEnvelopStep = 1;
            noteOffAmplitudeEnvelopStep = 1;
            noteOffFilterEnvelopStep = 1;
            noteOffPitchEnvelopStep = 1;
            noteOffNoteEnvelopStep = 1;
        }
        
        
        
        public function copyFrom(src:SiMMLVoice) : Void
        {
            chipType = src.chipType;

            updateTrackParamaters = src.updateTrackParamaters;
            updateVolumes = src.updateVolumes;
            
            moduleType = src.moduleType;
            channelNum = src.channelNum;
            toneNum = src.toneNum;
            preferableNote = src.preferableNote;
            channelParam.copyFrom(src.channelParam);
            
            waveData = src.waveData;
            pmsTension = src.pmsTension;
            
            defaultGateTime = src.defaultGateTime;
            defaultGateTicks = src.defaultGateTicks;
            defaultKeyOnDelayTicks = src.defaultKeyOnDelayTicks;
            pitchShift = src.pitchShift;
            noteShift = src.noteShift;
            portament = src.portament;
            releaseSweep = src.releaseSweep;
            
            velocity = src.velocity;
            expression = src.expression;
            vcommandShift = src.vcommandShift;
            velocityMode = src.velocityMode;
            expressionMode = src.expressionMode;
            
            amDepth = src.amDepth;
            amDepthEnd = src.amDepthEnd;
            amDelay = src.amDelay;
            amTerm = src.amTerm;
            pmDepth = src.pmDepth;
            pmDepthEnd = src.pmDepthEnd;
            pmDelay = src.pmDelay;
            pmTerm = src.pmTerm;
            
            if (src.noteOnToneEnvelop != null)  noteOnToneEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOnToneEnvelop);
            if (src.noteOnAmplitudeEnvelop != null) noteOnAmplitudeEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOnAmplitudeEnvelop);
            if (src.noteOnFilterEnvelop != null) noteOnFilterEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOnFilterEnvelop);
            if (src.noteOnPitchEnvelop != null) noteOnPitchEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOnPitchEnvelop);
            if (src.noteOnNoteEnvelop != null) noteOnNoteEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOnNoteEnvelop);
            if (src.noteOffToneEnvelop != null) noteOffToneEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOffToneEnvelop);
            if (src.noteOffAmplitudeEnvelop != null) noteOffAmplitudeEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOffAmplitudeEnvelop);
            if (src.noteOffFilterEnvelop != null) noteOffFilterEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOffFilterEnvelop);
            if (src.noteOffPitchEnvelop != null) noteOffPitchEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOffPitchEnvelop);
            if (src.noteOffNoteEnvelop != null) noteOffNoteEnvelop = new SiMMLEnvelopTable().copyFrom(src.noteOffNoteEnvelop);
            
            noteOnToneEnvelopStep = src.noteOnToneEnvelopStep;
            noteOnAmplitudeEnvelopStep = src.noteOnAmplitudeEnvelopStep;
            noteOnFilterEnvelopStep = src.noteOnFilterEnvelopStep;
            noteOnPitchEnvelopStep = src.noteOnPitchEnvelopStep;
            noteOnNoteEnvelopStep = src.noteOnNoteEnvelopStep;
            noteOffToneEnvelopStep = src.noteOffToneEnvelopStep;
            noteOffAmplitudeEnvelopStep = src.noteOffAmplitudeEnvelopStep;
            noteOffFilterEnvelopStep = src.noteOffFilterEnvelopStep;
            noteOffPitchEnvelopStep = src.noteOffPitchEnvelopStep;
            noteOffNoteEnvelopStep = src.noteOffNoteEnvelopStep;
        }
        
        
        
        public function _newBlankPCMVoice(channelNum:Int) : SiMMLVoice {
            var pcmTable:SiOPMWavePCMTable = new SiOPMWavePCMTable();
            this.moduleType = 7;
            this.channelNum = channelNum;
            this.waveData = pcmTable;
            return this;
        }
    }



