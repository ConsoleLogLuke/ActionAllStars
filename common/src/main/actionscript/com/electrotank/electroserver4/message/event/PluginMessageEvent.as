package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.esobject.*;
    
    public class PluginMessageEvent extends EventImpl {

        private var originZoneId:Number;
        private var originRoomId:Number;
        private var destinationZoneId:Number;
        private var destinationRoomId:Number;
        private var esObject:EsObject;
        private var pluginName:String;
        private var sentToRoom:Boolean;
        private var isRoomLevelPlugin:Boolean;
        public function PluginMessageEvent() {
            setMessageType(MessageType.PluginMessageEvent);
            setIsRoomLevelPlugin(false);
        }
        public function setIsRoomLevelPlugin(val:Boolean):void {

            isRoomLevelPlugin = val;
        }
        public function getIsRoomLevelPlugin():Boolean {
            return isRoomLevelPlugin;
        }
        public function setPluginName(str:String):void {

            pluginName = str;
        }
        public function getPluginName():String {
            return pluginName;
        }
        public function wasSentToRoom():Boolean {
            return sentToRoom;
        }
        public function setSentToRoom(val:Boolean):void {

            sentToRoom = val;
        }
        public function setEsObject(esObject:EsObject):void {

            this.esObject = esObject;
        }
        public function getEsObject():EsObject {
            return this.esObject;
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
        public function setDestinationZoneId(num:Number):void {

            destinationZoneId = num;
        }
        public function getDestinationZoneId():Number {
            return destinationZoneId;
        }
        public function setDestinationRoomId(num:Number):void {

            destinationRoomId = num;
        }
        public function getDestinationRoomId():Number {
            return destinationRoomId;
        }
    }
}
