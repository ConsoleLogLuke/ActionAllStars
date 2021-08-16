package com.electrotank.electroserver4.message.event {
    import com.electrotank.electroserver4.connection.AbstractConnection;
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.errors.*;
       /**
         * If a text or binary connection to ElectroServer is closed then this event is dispatched.
         * @example
         * This shows how to listen for the ConnectionClosedEvent.
         * <listing>
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.event.ConnectionClosedEvent;
    //
    var es:ElectroServer;
    es.addEventListener(MessageType.ConnectionClosedEvent, "onConnectionClosedEvent", this);
    function onConnectionClosedEvent(e:ConnectionClosedEvent):void {
        trace("connection closed");
    }
         * </listing>
         */
    
    public class ConnectionClosedEvent extends EventImpl {

        private var connection:AbstractConnection;
        /**
         * Creates a new instance of the ConnectionClosedEvent.
         */
        public function ConnectionClosedEvent() {
            setMessageType(MessageType.ConnectionClosedEvent);
        }
        /**
         * @private
         * @param    con
         */
        public function setConnection(con:AbstractConnection):void {

            connection = con;
        }
        /**
         * Gets the Connection that was closed.
         * @return The Connection class instance that was closed.
         */
        public function getConnection():AbstractConnection {
            return connection;
        }
    }
}
