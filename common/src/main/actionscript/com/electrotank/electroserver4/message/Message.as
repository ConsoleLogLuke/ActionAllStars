package com.electrotank.electroserver4.message {
    import com.electrotank.electroserver4.message.*;
    /**
     * Interface that all requests, responses, and events must implement.
     */
    
    public interface Message {

        function getMessageId():Number;
        function setMessageId(num:Number):void;

        function setMessageType(messageType:MessageType):void;

        function getMessageType():MessageType;
        function validate():ValidationResponse;
        function getIsRealServerMessage():Boolean;
        function getRealMessage():Message;
    }
}
