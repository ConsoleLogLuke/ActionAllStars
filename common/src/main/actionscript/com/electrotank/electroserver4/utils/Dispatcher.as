package com.electrotank.electroserver4.utils {
    
    public class Dispatcher {

        private var listeners:Array;
        private var events:Object;
        public function Dispatcher() {
            listeners = new Array();
            events = new Object();
        }
        ///////////////////////////////////
        //    Listener stuff
        //////////////////////////////////
        public function dispatchEvent(eventOb:Object):void {

            eventOb.target = this;
            var eventName:String = eventOb.type;
            var arr:Array = events[eventName];
            if (arr != null) {
                for (var i:Number = 0; i<arr.length; ++i) {
                    var listener:Object = arr[i].scope;
                    var funcName:String = arr[i].funcName;
                    listener[funcName](eventOb);
                }
            }
        }
        public function addEventListener(eventName:String, funcName:String, scope:Object):void {

            if (events[eventName] == null) {
                events[eventName] = new Array();
            }
            var exists:Boolean = false;
            for (var i:Number=0;i<events[eventName].length;++i) {
                if (events[eventName][i].scope == scope && events[eventName][i].funcName == funcName) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                events[eventName].push({scope:scope, funcName:funcName});
            }
        }
        public function removeEventListener(eventName:String, funcName:String, scope:Object):void {

            for (var i:Number=0;i<events[eventName].length;++i) {
                if (events[eventName][i].scope == scope && events[eventName][i].funcName == funcName) {
                    events[eventName].splice(i, 1);
                    break;
                }
            }
            if (events[eventName].length == 0) {
                delete events[eventName];
            }
        }
        private function getListeners():Array {
            return listeners;
        }
    }
}
