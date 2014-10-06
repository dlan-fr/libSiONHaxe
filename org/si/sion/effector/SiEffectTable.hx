





package org.si.sion.effector ;
    
    class SiEffectTable {
        
        public var sinTable: Array<Float>;
        
        
        
        function new()
        {
            var i:Int;
            sinTable = new Array<Float>();//384, true
            
           i=0;
 while( i<384){ sinTable[i] = Math.sin(i*0.02454369260617026); i++;
} 
        }
        
        
        
        static private var _instance:SiEffectTable = null;
        
        
        
        static public function instance():SiEffectTable
        {
            if (_instance == null) _instance = new SiEffectTable();
            return _instance;
        }
    }


