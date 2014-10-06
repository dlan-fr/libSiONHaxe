





package org.si.sion.module.channels ;
    import org.si.sion.module.SiOPMModule;
	import org.si.sion.module.channels.SiOPMChannelBase;
    
    
    
    class SiOPMChannelManager
    {
    
    
        inline static public var CT_CHANNEL_FM:Int = 0;
        inline static public var CT_CHANNEL_PCM:Int = 1;
        inline static public var CT_CHANNEL_SAMPLER:Int = 2;
        inline static public var CT_CHANNEL_KS:Int = 3;
        inline static public var CT_MAX:Int = 4;
        
        
        
        
    
    
        
        private var _channelClass:Class<SiOPMChannelBase>;
        
        private var _channelType:Int;
        
        private var _term:SiOPMChannelBase;
        
        private var _length:Int;
        
        
        
    
    
        
        public function length() : Int { return _length; }
        
        
        
        
    
    
        
        function new(channelClass:Class<SiOPMChannelBase>, channelType:Int)
        {
            _channelType  = channelType;
            _channelClass = channelClass;
            _term = new SiOPMChannelBase(_chip);
            _term._isFree = false;
            _term._next = _term;
            _term._prev = _term;
            _length = 0;
        }
        
        
        
        
    
    
        
        private function _alloc(count:Int) : Void
        {
            var i:Int, newInstance:SiOPMChannelBase, imax:Int = count - _length;
            
           i=0;
 while( i<imax){
                newInstance = Type.createInstance(_channelClass,[ _chip]);
                newInstance._channelType = _channelType;
                newInstance._isFree = true;
                newInstance._prev = _term._prev;
                newInstance._next = _term;
                newInstance._prev._next = newInstance;
                newInstance._next._prev = newInstance;
                _length++;
             i++;
}
        }
        
        
        
        private function _newChannel(prev:SiOPMChannelBase, bufferIndex:Int) : SiOPMChannelBase
        {
            var newChannel:SiOPMChannelBase;
            if (_term._next._isFree) {
                
                newChannel = _term._next;
                newChannel._prev._next = newChannel._next;
                newChannel._next._prev = newChannel._prev;
            } else {
                
                
                newChannel = Type.createInstance(_channelClass,[ _chip]);
                newChannel._channelType = _channelType;
                _length++;
            }
            
            
            newChannel._isFree = false;
            newChannel._prev = _term._prev;
            newChannel._next = _term;
            newChannel._prev._next = newChannel;
            newChannel._next._prev = newChannel;
            
            
            newChannel.initialize(prev, bufferIndex);
            
            return newChannel;
        }
        
        
        
        private function _deleteChannel(ch:SiOPMChannelBase) : Void
        {
            ch._isFree = true;
            ch._prev._next = ch._next;
            ch._next._prev = ch._prev;
            ch._prev = _term;
            ch._next = _term._next;
            ch._prev._next = ch;
            ch._next._prev = ch;
        }
        
        
        
        private function _initializeAll() : Void
        {
            var ch:SiOPMChannelBase;
           ch=_term._next;
 while( ch!=_term){
                ch._isFree = true;
                ch.initialize(null, 0);
             ch=ch._next;
}
        }
        
        
        
        private function _resetAll() : Void
        {
            var ch:SiOPMChannelBase;
           ch=_term._next;
 while( ch!=_term){
                ch._isFree = true;
                ch.reset();
             ch=ch._next;
}
        }
        
        
        
        
    
    
        static private var _chip:SiOPMModule;                               
        static private var _channelManagers: Array<SiOPMChannelManager>;   
        
        
        
        static public function initialize(chip:SiOPMModule) : Void 
        {
            _chip = chip;
            _channelManagers = new Array<SiOPMChannelManager>();
            _channelManagers[CT_CHANNEL_FM]      = new SiOPMChannelManager(SiOPMChannelFM,      CT_CHANNEL_FM);
            _channelManagers[CT_CHANNEL_PCM]     = new SiOPMChannelManager(SiOPMChannelPCM,     CT_CHANNEL_PCM);
            _channelManagers[CT_CHANNEL_SAMPLER] = new SiOPMChannelManager(SiOPMChannelSampler, CT_CHANNEL_SAMPLER);
            _channelManagers[CT_CHANNEL_KS]      = new SiOPMChannelManager(SiOPMChannelKS,      CT_CHANNEL_KS);
        }
        
        
        
        static public function initializeAllChannels() : Void
        {
            
            for (mng in _channelManagers) {
                mng._initializeAll();
            }
        }
        
        
        
        static public function resetAllChannels() : Void
        {
            
            for (mng in _channelManagers) {
                mng._resetAll();
            }
        }
        
        
        
        static public function newChannel(type:Int, prev:SiOPMChannelBase, bufferIndex:Int) : SiOPMChannelBase
        {
            return _channelManagers[type]._newChannel(prev, bufferIndex);
        }
        
        
        
        static public function deleteChannel(channel:SiOPMChannelBase) : Void
        {
            _channelManagers[channel._channelType]._deleteChannel(channel);
        }
    }


