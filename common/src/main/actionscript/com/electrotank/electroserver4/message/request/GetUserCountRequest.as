package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This class allows you to request the number of users currently connected to ElectroServer. The GetUserCountResponse event is fired when the response is received.
    @example
        This example shows how to request the user count from the server.
        <Listing>
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.GetUserCountRequest;
    import com.electrotank.electroserver4.message.response.GetUserCountResponse;
    //
    var es:ElectroServer;//assume this was already created and you are logged in
    function init():void {

        es.addEventListener(MessageType.GetUserCountResponse, "onGetUserCountResponse", this);
    }
    function onGetUserCountResponse(e:GetUserCountResponse):void {

        trace("Users connected: "+e.getCount());
    }
    init();
    var gucr:GetUserCountRequest = new GetUserCountRequest();
    es.send(gucr);
        </Listing>
     */
    
    public class GetUserCountRequest extends RequestImpl {

        /**
         * Creates a new instance of the GetUserCountRequest class.
         */
        public function GetUserCountRequest() {
            setMessageType(MessageType.GetUserCountRequest);
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        
    }
}
