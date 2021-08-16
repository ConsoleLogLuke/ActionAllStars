package com.electrotank.electroserver4.message {
    import com.electrotank.electroserver4.connection.AbstractConnection;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.protocol.MessageReader;
    /**
     * This class is used by the ElectroServer class to store a queued message.
     */
    
    public class QueuedMessage {

        private var messageReader:MessageReader;
        private var _messageId:Number;
        private var id:String;
        private var connection:AbstractConnection;
        /**
         * Creates a new instance of the QueuedMessage class.
         * @param    Id of the message
         * @param    The message
         */
        public function QueuedMessage(messageReader:MessageReader, id:String, messageId:Number, con:AbstractConnection) {
            //setMessageId(mesId);
            this.messageReader = messageReader;
            this.id = id;
            this._messageId = messageId;
            this.connection = con;
        }
        public function getConnection():AbstractConnection {
            return connection;
        }
        public function getMessageReader():MessageReader {
            return messageReader;
        }
        public function get messageId():Number {
            return _messageId;
        }
        public function getId():String {
            return id;
        }
    
    }
}
