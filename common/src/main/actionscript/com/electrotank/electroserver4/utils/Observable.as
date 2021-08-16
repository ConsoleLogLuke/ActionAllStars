package com.electrotank.electroserver4.utils {
    import com.electrotank.electroserver4.utils.*;
    import com.electrotank.electroserver4.message.*;
    
    
    public class Observable {

    
        private var listeners:Array;
        private var events:Object;
        public function Observable() {
            listeners = new Array();
            events = new Object();
        }
        ///////////////////////////////////
        //    Listener stuff
        //////////////////////////////////
        public function notifyListeners(eventName:String, eventOb:Object):void {

    
            var arr:Array = listeners.slice(0);
            for (var i:Number = 0; i<arr.length; ++i) {
                var listener:Object = arr[i];
                listener[eventName](eventOb);
            }
        }
        public function removeListener(ob:Object):void {

    
            for (var i:Number = 0; i<listeners.length; ++i) {
                var listener:Object = listeners[i];
                if (listener == ob) {
                    listeners.splice(i, 1);
                    break;
                }
            }
        }
        public function dispatchEvent(eventOb:MessageImpl):void {

    
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
        public function addEventListener(mt:MessageType, funcName:String, scope:Object, first:Boolean = false):void {

    
            var eventName:String = mt.getMessageTypeName();
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
                if ( first ) {
                    events[eventName].unshift({scope:scope, funcName:funcName});
                } else {
                    events[eventName].push({scope:scope, funcName:funcName});
                }
            }
        }
        public function removeEventListener(mt:MessageType, funcName:String, scope:Object):void {

    
            var eventName:String = mt.getMessageTypeName();
            if (events[eventName] != null) {
                for (var i:Number=0;i<events[eventName].length;++i) {
                    if (events[eventName][i].scope == scope && events[eventName][i].funcName == funcName) {
                        events[eventName].splice(i, 1);
                        break;
                    }
                }
                if (events[eventName].length == 0) {
                    events[eventName] = null;
                }
            }
        }
        public function addListener(ob:Object):void {

    
            getListeners().push(ob);
        }
        private function getListeners():Array {
            return listeners;
        }
    }
}
