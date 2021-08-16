package com.electrotank.electroserver4.message {
    import com.electrotank.electroserver4.message.*;
    /**
     * Establishes a base set of methods that are used for all requests, responses, and events.
     */
    
    public class MessageImpl implements Message {

        private var messageId:Number;
        private var messageType:MessageType;
        private var isRealServerMessage:Boolean = true;
        public var type:String;
        public var target:Object;
        public function MessageImpl() {
        }
        /**
         * Used internally when one client-request needs to be remapped to a server request.
         * @return True or false.
         */
        public function getIsRealServerMessage():Boolean {
            return isRealServerMessage;
        }
        /**
         * Used internally when one client-request needs to be remapped to a server request.
         * @param    True or false.
         */
        public function setIsRealServerMessage(isRealServerMessage:Boolean):void {

            this.isRealServerMessage = isRealServerMessage;
        }
        /**
         * If this is not a real message, then get it.
         * @return The real message.
         */
        public function getRealMessage():Message {
            var otherMessage:Message;
            return otherMessage;
        }
        /**
         * The id of the message. Message ids are incremented so that message ordering is maintained.
         * @return The id of the message.
         */
        public function getMessageId():Number {
            return messageId;
        }
        /**
    
         * The id of the message. Message ids are incremented so that message ordering is maintained.
         * @param    The id of the message.
         */
        public function setMessageId(id:Number):void {

            messageId = id;
        }
        /**
         * This defines the type of message being used, such as LoginRequest or CreateRoomVariableRequest.
         * @param    The type of message being used.
         */
        public function setMessageType(mt:MessageType):void {

            messageType = mt;
            type = messageType.getMessageTypeName();
        }
        /**
         * The type of message being used.
         * @return The type of message being used.
         */
        public function getMessageType():MessageType {
            return messageType;
        }
        /**
         * Every messages have varying optional fields. This method applies validation to the message and returns a ValidationResponse with the results of that validation.
         * @return A ValidationResponse class instance.
         */
        public function validate():ValidationResponse {
            return new ValidationResponse(true, new Array());
        }
    }
}
