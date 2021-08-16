package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.esobject.*;
    /**
     * Many plugin messages may have been grouped together so they don't spam the client. If they are grouped together then they are sent as this message type.
     * @private
     */
    
    public class CompositePluginMessageEvent extends EventImpl {

        private var parameters:Array;
        private var pluginName:String;
        private var originZoneId:Number;
        private var originRoomId:Number;
        public function CompositePluginMessageEvent() {
            setMessageType(MessageType.CompositePluginMessageEvent);
        }
        public function setOriginZoneId(num:Number):void {

            originZoneId = num;
        }
        public function getOriginZoneId():Number {
            return originZoneId;
        }
        public function setOriginRoomId(num:Number):void {

            originRoomId = num;
        }
        public function getOriginRoomId():Number {
            return originRoomId;
        }
        public function setPluginName(str:String):void {

            pluginName = str;
        }
        public function getPluginName():String {
            return pluginName;
        }
        public function setParameters(arr:Array):void {

            parameters = arr;
        }
        public function getParameters():Array {
            return parameters;
        }
    }
}
