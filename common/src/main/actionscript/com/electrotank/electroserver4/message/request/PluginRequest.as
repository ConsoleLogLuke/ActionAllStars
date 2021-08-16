package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.esobject.*;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This class is used to send a message to a plugin. The plugin can be a server-level plugin or room-level plugin. If it is a room-level plugin then the room id and zone id need to be specified.
     * @example
     * This example shows how to send a request to a room plugin.
     * <listing>
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.PluginRequest;
    import com.electrotank.electroserver4.message.event.PluginMessageEvent;
    import com.electrotank.electroserver4.room.Room;
     //
    var es:ElectroServer;//Assume this was created, connection established, and login established already
    var myRoom:Room;
    //
    function init():void {
        es.addEventListener(MessageType.PluginMessageEvent, "onPluginMessageEvent", this);
    }
    function sendPluginMessage():void {
        //create the request to send to a room plugin
        var pr:PluginRequest = new PluginRequest();
        pr.setRoomId(myRoom.getRoomId());
        pr.setZoneId(myRoom.getZone().getZoneId());
        pr.setPluginName("TestPluginName");
        //build the EsObject to send to the plugin, and then set it on the request
        var esob:EsObject = new EsObject();
        esob.setString("Action", "ShootBullet");
        esob.setInteger("Angle", 45);
        pr.setEsObject(esob);
        //send it
        es.send(pr);
    }
    function onPluginMessageEvent(e:PluginMessageEvent):void {
    }
    init();
    sendPluginMessage();
    * </listing>
     */
    
    public class PluginRequest extends RequestImpl {

        private var zoneId:Number;
        private var roomId:Number;
        private var esObject:EsObject;
        private var pluginName:String;
        private var sentToRoom:Boolean;
        /**
         * Creates a new instance of the PluginRequest class.
         */
        public function PluginRequest() {
            setMessageType(MessageType.PluginRequest);
            esObject = new EsObject();
            setSentToRoom(false);
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * The EsObjec to be send to the plugin.
         * @return The EsObjec to be send to the plugin.
         */
        public function getEsObject():EsObject {
            return this.esObject;
        }
        /**
         * The EsObjec to be send to the plugin.
         * @param    The EsObjec to be send to the plugin.
         */
        public function setEsObject(esObject:EsObject):void {

            this.esObject = esObject;
        }
        /**
         * The instance name of the plugin. This was established at the plugin create time.
         * @param    Name of the plugin.
         */
        public function setPluginName(name:String):void {

            pluginName = name;
        }
        /**
         * Name of the plugin.
         * @return Name of the plugin.
         */
        public function getPluginName():String {
            return pluginName;
        }
        public function wasSentToRoom():Boolean {
            return sentToRoom;
        }
        private function setSentToRoom(val:Boolean):void {

            sentToRoom = val;
        }
        /**
         * The id of the zone that has the room.
         * @param    The id of the zone that has the room.
         */
        public function setZoneId(zId:Number):void {

            setSentToRoom(true);
            zoneId = zId;
        }
        /**
         * The id of the zone the has the room.
         * @return The id of the zone that has the room.
         */
        public function getZoneId():Number {
            return zoneId;
        }
        /**
         * The id of the room.
         * @param    The id of the room.
         */
        public function setRoomId(rId:Number):void {

            roomId = rId;
        }
        /**
         * The id of the room.
         * @return The id of the room.
         */
        public function getRoomId():Number {
            return roomId;
        }
    }
}
