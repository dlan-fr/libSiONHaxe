package org.si.utils ;
    import flash.display.DisplayObjectContainer;
	import flash.Lib;
    import flash.text.TextField;
    import flash.events.Event;
    import flash.utils.Timer;
    import flash.text.TextFieldAutoSize;
	import StringTools;
    
    
    class Timer {
        static public var title:String = "";
        static private var _text:TextField = null;
        static private var _time: Array<Int>;
        static private var _sum : Array<Int>;
        static private var _stat: Array<String>;
        static private var _cnt : Int;
        static private var _avc:Int;
        
        
        
        static public function initialize(parent:DisplayObjectContainer, averagingCount:Int, stat:Array<String>) : Void {
            if (_text == null) parent.addChild(_text = new TextField());
            _avc  = averagingCount;
            //_stat = Array<String>(stat);
            _time = new Array<Int>();
            _sum  = new Array<Int>();
            _cnt  = 0;
            _text.background = true;
            _text.backgroundColor = 0x80c0f0;
            _text.autoSize = TextFieldAutoSize.LEFT;
            _text.multiline = true;
            parent.addEventListener("enterFrame", _onEnterFrame);
			
        }
        
        
        static public function start(slot:Int=0) : Void { _time[slot] = Lib.getTimer(); }
        
        
        static public function pause(slot:Int=0) : Void { _sum[slot] += Lib.getTimer() - _time[slot]; }
        
        
        static private function _onEnterFrame(e:Event) : Void {
            if (++_cnt == _avc) {
                _cnt = 0;
                var str:String = "", line:String;
               var slot:Int = 0;
 while ( slot < _sum.length) {
					line = _stat[slot];
					StringTools.replace(line, "##", Std.string(_sum[slot] / _avc).substr(0, 3));
                    str += line + "\n";
                    _sum[slot] = 0;
                 slot++;
}
                _text.text = title + "\n" + str;
            }
        }
    }


