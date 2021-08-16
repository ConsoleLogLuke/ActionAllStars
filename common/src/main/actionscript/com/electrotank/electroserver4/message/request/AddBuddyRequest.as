package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * Use the ElectroServer.addBuddy method to add a new buddy. The AddBuddyRequest is used by the ElectroServer class to add the buddy with ElectroServer. You use the ElectroServer.addBuddy method because buddies are managed on the client as well as the server. When a buddy logs in or leaves the server a BuddyStatusUpdatedEvent is fired off to you.
        * @example 
        *         Shows how to add a buddy and listen for BuddyStatusUpdatedEvents.
        *         <listing>
    //import the needed classes
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.message.event.BuddyStatusUpdatedEvent;
    import com.electrotank.electroserver4.message.MessageType;
    //
    //Add the buddy
    var es:ElectroServer;//It is assumed that this refers to an ElectroServer class instance that is connected to ElectroServer
    es.addBuddy("crazy_face", new EsObject());
    //
    //Configure the event listener to know when your buddy's online status changes
    es.addEventListener(MessageType.BuddyStatusUpdatedEvent, "onBuddyStatusUpdatedEvent", this);
    public function onBuddyStatusUpdatedEvent(e:BuddyStatusUpdatedEvent):void {
        var u:User = e.getUser();
        switch(e.getActionId()) {
            case BuddyStatusUpdatedEvent.LoggedIn:
                trace(u.getUserName()+" logged in.");
                break;
            case BuddyStatusUpdatedEvent.LoggedOut:
                trace(u.getUserName()+" logged out.");
                break;
            default:
                trace("Update event not handled.");
                break;
        }
    }
        *         </listing>
        * @see com.electrotank.electroserver4.ElectroServer#addBuddy()
        * @see com.electrotank.electroserver4.message.event.BuddyStatusUpdatedEvent
     */
    
    public class AddBuddyRequest extends RequestImpl {

        private var buddyName:String;
        private var esObject:EsObject;
        /**
         * Creates a new instance of the AddBuddyRequest
         */
        public function AddBuddyRequest() {
            setMessageType(MessageType.AddBuddyRequest);
        }
        
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        /**
         * This associates an optional EsObject with your buddy. Event handlers on the server can use this EsObject to perform custom logic to make more intricate buddy behaviors.
         * @param    esob EsObject to be associated with your buddy.
         */
        public function setEsObject(esob:EsObject):void {

            esObject = esob;
        }
        /**
         * Gets the optional EsObject associated with the buddy in this request.
         * @return EsObject associated with the buddy.
         */
        public function getEsObject():EsObject {
            return esObject;
        }
        /**
         * Sets the name of the buddy. When a user logs in (or out) with this user name a BuddyStatusUpdatedEvent is fired.
         * @param    name
         */
        public function setBuddyName(name:String):void {

            buddyName = name;
        }
        /**
         * Gets the buddy name.
         * @return Returns the buddy name.
         */
        public function getBuddyName():String {
            return buddyName;
        }
    
    }
}
