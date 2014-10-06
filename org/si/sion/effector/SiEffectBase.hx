





package org.si.sion.effector ;
    
    class SiEffectBase
    {
    
    
        
        public var _isFree:Bool = true;
        
        
        
    
    
        
        function SiEffectBase() {}
        
        
        
        
    
    
        
        public function initialize() : Void
        {
        }
        
        
        
        public function mmlCallback(args: Array<Float>) : Void
        {
        }
        
        
        
        public function prepareProcess() : Int
        {
            return 1;
        }
        
        
        
        public function process(channels:Int, buffer: Array<Float>, startIndex:Int, length:Int) : Int
        {
            return channels;
        }
    }


