package com.electrotank.electroserver4.utils {
    import com.electrotank.electroserver4.utils.Dispatcher;
    
    public class Logger extends Dispatcher {

        //EVENTS
        static public var LOGGED:String = "logged";
        //
        //static private var logs:Array = new Array();
        static private var _instance:Logger;
        static public var info:Number = 4;
        static public var debug:Number = 2;
        static public var severe:Number = 1;
        static private var levelNames:Array = [null, "[SEVERE]", "[DEBUG]", null, "[INFO]"];
        static public var LogLevel:Number = info;
    /*    static public function getLogs(level:Number):Array {
            var lgs:Array = new Array();
            for (var i:Number=0;i<logs.length;++i) {
                if (logs[i].level <= level) {
                    lgs.push(logs[i]);
                }
            }
            return lgs;
        }*/
        static public function log(message:String, level:Number):void {

            if (level > LogLevel) {
                return;
            }
            var tab:String = "   ";
            message = levelNames[level]+" "+message;
            var ob:Object = {message:message, level:level};
            //logs.push(ob);
            var event:Object = {target:_instance, log:ob, type:LOGGED}
            _instance.dispatchEvent(event);
        }
        static public function init():void {

            _instance = new Logger();
        }
        static public function getInstance():Logger {
            return _instance;
        }
        public function Logger() {
        }
        
    }
}
