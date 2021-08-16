package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This request allows you to remove a user as a buddy. Please use ElectroServer.removeBuddy instead of using this request directly.
        * @example 
        *         Shows how to remove a buddy.
        *         <listing>
    //import the needed classes
    import com.electrotank.electroserver4.ElectroServer;
    //
    //Add the buddy
    var es:ElectroServer;//It is assumed that this refers to an ElectroServer class instance that is connected to ElectroServer
    es.removeBuddy("crazy_face");
    </listing>
        * @see com.electrotank.electroserver4.ElectroServer#addBuddy()
        * @see com.electrotank.electroserver4.ElectroServer#removeBuddy()
        * @see com.electrotank.electroserver4.message.event.BuddyStatusUpdatedEvent
     */
    
    public class RemoveBuddyRequest extends RequestImpl {

        private var buddyName:String;
        /**
         * Creates a new instance of the RemoveBuddyRequest class.
         */
        public function RemoveBuddyRequest() {
            setMessageType(MessageType.RemoveBuddyRequest);
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * Specifies the name of the buddy to remove.
         * @param    The name of the buddy to remove.
         */
        public function setBuddyName(name:String):void {

            buddyName = name;
        }
        /**
         * Gets the name of the buddy to be removed.
         * @return The name of the buddy to be removed.
         */
        public function getBuddyName():String {
            return buddyName;
        }
    }
}
