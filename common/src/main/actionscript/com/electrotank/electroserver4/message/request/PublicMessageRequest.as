package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This class is used to send a public message to a room. A public message can contain a message and an optional EsObject. To send a public message to a room you must specify the room id and zone id.<br/>
     * Public messages can be captured by plugin event handlers and modified or stopped. If the room has language filters enabled then the message will be applied to the filter.
    * @example 
    *         This shows how to send a simple public message to a room with no EsObject attached.
    *         <listing>
    * 
        import com.electrotank.electroserver4.ElectroServer;
        import com.electrotank.electroserver4.message.MessageType;
        import com.electrotank.electroserver4.message.request.*;
        import com.electrotank.electroserver4.message.response.*;
        import com.electrotank.electroserver4.message.event.*;
    
        private var es:ElectroServer;
         private var roomId:Number;
         private var zoneId:Number;
         
         function init():void {
             es.addEventListener(MessageType.PublicMessageEvent, "onPublicMessageEvent", this);
         }
        function sendPublicMessage(msg:String):void {
            //Create the PublicMessageRequest object and populate it
            var pmr:PublicMessageRequest = new PublicMessageRequest();
            pmr.setMessage(msg);
            pmr.setRoomId(roomId);
            pmr.setZoneId(zoneId);
            //Send the request
            es.send(pmr);
        }
        function onPublicMessageEvent(e:PublicMessageEvent):void {
            var from:String = e.getUserName();
            var msg:String = e.getMessage();
            trace(from+": "+msg);
        }
        init();
        sendPublicMessage("Hello world");
         </listing>
             This shows how to send a public message to a room with an EsObject attached.
             <listing>
        import com.electrotank.electroserver4.ElectroServer;
        import com.electrotank.electroserver4.message.MessageType;
        import com.electrotank.electroserver4.message.request.*;
        import com.electrotank.electroserver4.message.response.*;
        import com.electrotank.electroserver4.message.event.*;
        
         private var es:ElectroServer;
         private var roomId:Number;
         private var zoneId:Number;
         
         function init():void {
             es.addEventListener(MessageType.PublicMessageEvent, "onPublicMessageEvent", this);
         }
        function sendPublicMessage(msg:String):void {
            //Create an EsObject that contains custom information to send to the room
            var esob:EsObject = new EsObject();
            esob.setString("SoundFx", "Boom.mp3");
            esob.setInteger("Loops", 4);
            //Create the PublicMessageRequest object and populate it
            var pmr:PublicMessageRequest = new PublicMessageRequest();
            pmr.setMessage(msg);
            pmr.setRoomId(roomId);
            pmr.setZoneId(zoneId);
            pmr.setEsObject(esob);
            //Send the request
            es.send(pmr);
        }
        function onPublicMessageEvent(e:PublicMessageEvent):void {
            var from:String = e.getUserName();
            var msg:String = e.getMessage();
            //Get the EsObject
            var esob:EsObject = e.getEsObject();
            trace("SoundFx: "+esob.getString("SoundFx"));
            trace("Loops: "+esob.getInteger("Loops"));
            trace(from+": "+msg);
        }
        init();
        sendPublicMessage("Hello world");
    *     </listing>
     */
    
    public class PublicMessageRequest extends RequestImpl {

        private var zoneId:Number;
        private var roomId:Number;
        private var message:String;
        private var esObject:EsObject;
        /**
         * Creates a new instance of the PublicMessageRequest class.
         */
        public function PublicMessageRequest() {
            setMessageType(MessageType.PublicMessageRequest);
        }
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            if (isNaN(getZoneId())) {
                problems.push("zoneId cannot be null");
            }
            if (isNaN(getRoomId())) {
                problems.push("roomId cannot be null");
            }
            if (getMessage() == null) {
                problems.push("message cannot be null");
            }
            if (problems.length > 0) {
                valid = false;
            }
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * Sets the optional EsObject to be sent along with chat message to the room.
         * @param    The optional EsObject to be attached to the message.
         */
        public function setEsObject(eob:EsObject):void {

            esObject = eob;
        }
        /**
         * Gets the optional EsObjec to be sent with the message.
         * @return Returns the option EsObjec to be sent with the message.
         */
        public function getEsObject():EsObject {
            return esObject;
        }
        /**
         * The message text to be sent to the room.
         * @param    The message text to be sent to the room.
         */
        public function setMessage(message:String):void {

            this.message = message;
        }
        /**
         * Returns the message text to be sent to the room.
         * @return Returns the message text to be sent to the room.
         */
        public function getMessage():String {
            return message;
        }
        /**
         * The id of the zone that holds the room to which the message is being sent.
         * @param    The id of the zone that holds the room to which the message is being sent.
         */
        public function setZoneId(zId:Number):void {

            zoneId = zId;
        }
        /**
         * Returns the zone id of the room to which the message is being sent.
         * @return Returns the zone id of the room to which the message is being sent.
         */
        public function getZoneId():Number {
            return zoneId;
        }
        /**
         * The room id of the room to which the message is being sent.
         * @param    The room id of the room to which the message is being sent.
         */
        public function setRoomId(rId:Number):void {

            roomId = rId;
        }
        /**
         * Returns the room id of the room to which the message is being sent.
         * @return Returns the room id of the room to which the message is being sent.
         */
        public function getRoomId():Number {
            return roomId;
        }
    }
}
