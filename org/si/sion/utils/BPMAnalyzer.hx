






package org.si.sion.utils ;
    import flash.media.*;


    
    class BPMAnalyzer {
    
    
        
        public var filterbanks: Array<PeakDetector>;
        
        private var _bpm:Int;
        private var _bpmProbability:Float;
        private var _pickedupCount:Int;
        private var _pickedupBPMList: Array<Int> = new Array<Int>(10, true);
        private var _pickedupBPMProbabilityList: Array<Float> = new Array<Float>(10, true);
        private var _snapShotIndex:Int;
        
        
        
        
    
    
        
        public function bpm() : Int { return _bpm; }
        
        
        public function bpmProbability() : Float { return _bpmProbability; }
        
        
        public function pickedupCount() : Int { return _pickedupCount; }
        
        
        public function pickedupBPMList() : Array<Int> { return _pickedupBPMList; }
        
        
        public function pickedupBPMProbabilityList() : Array<Float> { return _pickedupBPMProbabilityList; }
        
        
        public function snapShotPosition() : Float { return _snapShotIndex * 0.000022675736961451247; } 
        
        
        
        
    
    
        
        function new(filterbankCount:Int=3) {
            if (filterbankCount < 1 || filterbankCount > 4) filterbankCount = 4;
            filterbanks = new Array<PeakDetector>(filterbankCount);
            filterbanks[0] = new PeakDetector(5000, 0.50, 25);
            if (filterbankCount > 1) filterbanks[1] = new PeakDetector(2400, 0.50, 25);
            if (filterbankCount > 2) filterbanks[2] = new PeakDetector( 100, 0.50, 40);
            if (filterbankCount > 3) filterbanks[3] = new PeakDetector();
        }
        
        
        
        
    
    
        
        public function estimateBPM(sound:Sound, rememberFilterbanksSnapShot:Bool = false) : Int {
            var pickupIndex:Int, pickupStep:Int, i:Int, maxProb:Float, thres:Float, 
                probs: Array<Float> = _pickedupBPMProbabilityList, 
                bpms: Array<Int>=_pickedupBPMList, scores: Array<Float>;
            
            _pickedupCount = Std.int(sound.length / 20000);
            if (_pickedupCount == 0) _pickedupCount = 1;
            else if (_pickedupCount > 10) _pickedupCount = 10;
            scores = new Array<Float>(100, true);
            
            pickupStep = (sound.length - _pickedupCount * 4000) * 44.1 / (_pickedupCount + 1);
            if (pickupStep < 0) pickupStep = 0;
            maxProb = 0;
            
           pickupIndex=pickupStep; i=0;
 while( i<_pickedupCount){
                _estimateBPMFromSamples(SiONUtil.extract(sound, null, 1, 176400, pickupIndex), 1);
                probs[i] = _bpmProbability;
                bpms[i] = Std.int(_bpm);
                if (maxProb < _bpmProbability) {
                    maxProb = _bpmProbability;
                    _snapShotIndex = pickupIndex;
                }
             i++; pickupIndex+=176400+pickupStep;
}
            _bpmProbability = maxProb;
            
            thres = maxProb * 0.75;
           i=0;
 while( i<_pickedupCount){
                if (probs[i] > thres && 100<=bpms[i] && bpms[i]<200) scores[bpms[i]-100] += probs[i];
             i++;
}
            maxProb = 0;
           i=0;
 while( i<100){
                if (maxProb < scores[i]) {
                    maxProb = scores[i];
                    _bpm = i + 100;
                }
             i++;
}

            if (rememberFilterbanksSnapShot) _estimateBPMFromSamples(SiONUtil.extract(sound, null, 1, 176400, _snapShotIndex), 1);
            
            return _bpm;
        }
        
        
        
        public function estimateBPMFromSamples(sample: Array<Float>, channels:Int) : Int {
            _pickedupCount = 0;
            _estimateBPMFromSamples(sample, channels);
            return _bpm;
        }
        
        
        
        
    
    
        
        private function _estimateBPMFromSamples(sample: Array<Float>, channels:Int) : Void {
            var pd1:PeakDetector, pd2:PeakDetector, pmp:Float, pmr:Float, bpm:Float;
            var i:Int, banksCount:Int = filterbanks.length;
            
            
           i=0;
 while( i<banksCount){ filterbanks[i].setSamples(sample, channels); i++;
}
            
            
            if (banksCount > 1) {
                
                if (filterbanks[0].peaksPerMinuteProbability < filterbanks[1].peaksPerMinuteProbability) {
                    pd1 = filterbanks[1];
                    pd2 = filterbanks[0];
                } else {
                    pd1 = filterbanks[0];
                    pd2 = filterbanks[1];
                }
               i=2;
 while( i<banksCount){
                    if (pd2.peaksPerMinuteProbability < filterbanks[i].peaksPerMinuteProbability) {
                        if (pd1.peaksPerMinuteProbability < filterbanks[i].peaksPerMinuteProbability) {
                            pd2 = pd1;
                            pd1 = filterbanks[i];
                        } else {
                            pd2 = filterbanks[i];
                        }
                    }
                 i++;
}
                
                pmp = pd1.peaksPerMinuteProbability / pd2.peaksPerMinuteProbability;
                pmr = pd1.peaksPerMinute / pd2.peaksPerMinute;
                if (pmp > 1.333 || pmr > 1.1 || pmr < 0.9) bpm = pd1.peaksPerMinute;
                else bpm = (pd1.peaksPerMinute + pd2.peaksPerMinute) * 0.5;
                _bpm = Std.int(bpm+0.5);
                _bpmProbability = pd1.peaksPerMinuteProbability;
            } else {
                
                _bpm = filterbanks[0].peaksPerMinute;
                _bpmProbability = filterbanks[0].peaksPerMinuteProbability;
            }
        }
    }


