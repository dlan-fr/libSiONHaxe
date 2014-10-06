





package org.si.sion.effector ;
    import org.si.sion.module.SiOPMTable;
    import org.si.sion.sequencer.SiMMLTable;
    import org.si.utils.SLLint;
    
    
    
    class SiCtrlFilterBase extends SiEffectBase
    {
    
    
         static var _incEnvelopTable:SLLint = null;
         static var _decEnvelopTable:SLLint = null;
         var _p0r:Float;
         var _p1r:Float;
         var _p0l:Float;
         var _p1l:Float;
         var _cutIndex:Int;
         var _res:Float;
         var _table:SiOPMTable;
        
        private var _ptrCut:SLLint;
        private var _ptrRes:SLLint;
        private var _lfoStep:Int;
        private var _lfoResidueStep:Int;
        
        
        
        
    
    
        
        public function get_cutoff() : Float { return _cutIndex * 0.0078125; }
        public function cutoff(n:Float) : Void {
            _cutIndex = Std.int(get_cutoff()*128);
            if (_cutIndex > 128) _cutIndex = 128;
            else if (_cutIndex<0) _cutIndex = 0;
        }
        
        
        
        public function get_resonance() : Float { return _res; }
        public function resonance(n:Float) : Void {
            _res = get_resonance();
            if (_res > 1) _res = 1;
            else if (_res < 0) _res = 0;
        }
        
        
        
        
    
    
        
        function new() {
            if (_incEnvelopTable == null) {
                _incEnvelopTable = SLLint.allocList(129);
                _decEnvelopTable = SLLint.allocList(129);
                var ptrit:SLLint = _incEnvelopTable, 
                    ptrdt:SLLint = _decEnvelopTable;
               var i:Int=0;
 while( i<129){
                    ptrit.i = i;
                    ptrdt.i = 128-i;
                    ptrit = ptrit.next;
                    ptrdt = ptrdt.next;
                 i++;
}
            }
        }
        
        
        
        
    
    
        
        public function setParameters(cut:Int=255, res:Int=255, fps:Float=20) : Void {
            _table = SiOPMTable.instance();
            var simml:SiMMLTable = SiMMLTable.instance();
            _ptrCut = (cut>=0 && cut<255 && simml.getEnvelopTable(cut) != null) ? simml.getEnvelopTable(cut).head : null;
            _ptrRes = (res>=0 && res<255 && simml.getEnvelopTable(res) != null) ? simml.getEnvelopTable(res).head : null;
            _cutIndex = (_ptrCut != null) ? _ptrCut.i : 128;
            _res = (_ptrRes != null) ? (_ptrRes.i*0.007751937984496124) : 0;    
            _lfoStep = Std.int(44100/fps);
            if (_lfoStep <= 44) _lfoStep = 44;
            _lfoResidueStep = _lfoStep<<1;
        }
        
        
        
        public function control(cutoff:Float, resonance:Float) : Void
        {
            _lfoStep = 2048;
            _lfoResidueStep = 4096;
            
            if (cutoff > 1) cutoff=1;
            else if (cutoff<0) cutoff=0;
            _cutIndex = Std.int(cutoff*128);
            
            if (resonance > 1) resonance=1;
            else if (resonance<0) resonance=0;
            _res = resonance;
        }
        
        
        
        
    
    
        
        override public function initialize() : Void
        {
            setParameters();
        }
        

        
        override public function mmlCallback(args: Array<Float>) : Void
        {
            setParameters((!Math.isNaN(args[0])) ? Std.int(args[0]) : 255,
                          (!Math.isNaN(args[1])) ? Std.int(args[1]) : 255,
                          (!Math.isNaN(args[2])) ? Std.int(args[2]) : 20);
        }
        
        
        
        override public function prepareProcess() : Int
        {
            _lfoResidueStep = 0;
            _p0r = _p1r = _p0l = _p1l = 0;
            return 2;
        }
        
        
        
        override public function process(channels:Int, buffer: Array<Float>, startIndex:Int, length:Int) : Int
        {
            startIndex <<= 1;
            length <<= 1;
            
            var i:Int, imax:Int, istep:Int, c:Float, s:Float, l:Float, r:Float;
            istep = _lfoResidueStep;
            imax = startIndex + length;
           i=startIndex;
 while( i<imax-istep){
                processLFO(buffer, i, istep);
                if (_ptrCut != null) { _ptrCut = _ptrCut.next; _cutIndex = (_ptrCut != null) ? _ptrCut.i : 128; }
                if (_ptrRes != null) { _ptrRes = _ptrRes.next; _res = (_ptrRes != null) ? (_ptrRes.i*0.007751937984496124) : 0; }
                i += istep;
                istep = _lfoStep<<1;
            }
            processLFO(buffer, i, imax-i);
            _lfoResidueStep = istep - (imax - i);
            return channels;
        }
        
        
        
        function processLFO(buffer: Array<Float>, startIndex:Int, length:Int) : Void
        {
        }
    }


