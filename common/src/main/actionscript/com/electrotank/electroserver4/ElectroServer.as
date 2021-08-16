package com.electrotank.electroserver4 {
    
    import com.electrotank.electroserver4.*;
    import com.electrotank.electroserver4.connection.*;
    import com.electrotank.electroserver4.protocol.As2ProtocolHandler;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.protocol.MessageReader;
    import com.electrotank.electroserver4.protocol.MessageWriter;
    import com.electrotank.electroserver4.protocol.text.*;
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.errors.*;
    import com.electrotank.electroserver4.utils.Observable;
    import com.electrotank.electroserver4.utils.Logger;
    import com.electrotank.electroserver4.zone.*;
    import com.electrotank.electroserver4.room.*;
    import com.electrotank.electroserver4.user.*;
    import com.electrotank.electroserver4.plugin.*;
    import com.electrotank.electroserver4.entities.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.rtmpconnection.RtmpConnection;
    
     
    import com.electrotank.electroserver4.protocol.binary.BinaryMessageReader;
    import com.electrotank.electroserver4.protocol.binary.BinaryMessageWriter;
    import flash.utils.getTimer;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    
     
    
    
    //
    /**
     * The ElectroServer class is the most-used clsas in the ElectroServer API. You use it to send requests to the server, create new server connections, create an RTMP connection, and to get at the managered zones, rooms, and users.
     */
    
    public class ElectroServer extends Observable {

        private var protocol:String;
        private var connections:Array;
        private var as2ProtocolHandler:As2ProtocolHandler;
        private var transactionHandler:TransactionHandler;
        private var zoneManager:ZoneManager;
        private var userManager:UserManager;
        private var debug:Boolean;
        private var buddyList:Object;
        private var messageQueue:Array;
        private var history:Array;
        private var additionalLoginPassword:String;
        private var isConnected:Boolean;
        private var expectedInboundId:Number;
        private var isLoggedIn:Boolean;
        private var rtmpConnection:RtmpConnection;
        private var isSimulatingLatency:Boolean;
        private var simulatedLatency:Number;
        private var inboundLatencyQueue:Array;
        private var outboundLatencyQueue:Array;
        private var timerId:Number;
     private var latencyTimer:Timer;
            
        /**
         * Creates a new ElectroServer class instance.
         */
        public function ElectroServer() {
            initialize();
        }
        /**
        *  
        * Adds a user to the client's buddy list. The list is maintained by the server. Buddy online/offline status updates are sent to the client.
        * @param    name The buddy's user name.
        * @param    esob An EsObject to store with the buddy entry.
        * @see #removeBuddy
        * @see #getBuddyList
        */
        public function addBuddy(name:String, esob:EsObject):void {

            var abr:AddBuddyRequest = new AddBuddyRequest();
            abr.setBuddyName(name);
            abr.setEsObject(esob);
            getBuddyList()[name] = esob;
            send(abr);
        }
        /**
         * @private
         */
        public function additionalLogin(loginRequest:LoginRequest):void {

            additionalLoginPassword = loginRequest.getSharedSecret();
            send(loginRequest);
        }
        /**
        *  
        * Closes all open connections with ElectroServer
        * @see #createConnection
        * @see #createRtmpConnection
        * @see com.electrotank.electroserver4.message.event.RtmpConnectionClosedEvent
        */
        public function close():void {

            if (getRtmpConnection() != null) {
                if (getRtmpConnection().getIsConnected()) {
                    getRtmpConnection().close();
                }
            }
            for (var i:Number=0;i<getConnections().length;++i) {
                var conn:AbstractConnection = getConnections()[i];
                conn.close();
            }
        }
        /**
        *  
        * Closes the RtmpConnection.
        * @example 
        *         Closes the RTMP connection.
        *         <listing>
                     import com.electrotank.electroserver4.ElectroServer;
                    var es:ElectroServer;//created and connected somewhere else
        *             es.closeRtmpConnection();
        *         </listing>
        * @see #createRtmpConnection
        * @see com.electrotank.electroserver4.rtmpconnection.RtmpConnection
        * @see com.electrotank.electroserver4.message.event.RtmpConnectionClosedEvent
        */
        public function closeRtmpConnection():void {

            rtmpConnection.close();
        }
        /**
        *  Creates a new Connection instance and returns it. Internally a new XMLSocket (string protocol) or Socket (AS3 binary) is created and used to communicate with the server via text or binary protocol.
        * @example <listing>
                     import com.electrotank.electroserver4.ElectroServer;
                     import com.electrotank.electroserver4.connection;
                    import com.electrotank.electroserver4.message.MessageType;
                    import com.electrotank.electroserver4.message.event.*;
                    //
                    var es:ElectroServer = new ElectroServer();
                    es.addEventListener(MessageType.ConnectionEvent, "onConnectionEvent", this);
                    public function onConnectionEvent(e:ConnectionEvent):void {

                        if (e.getAccepted()) {
                            //connection accepted
                        } else {
                            //connection failed
                        }
                    }
        *         </listing>
        * @see com.electrotank.electroserver4.connection.Connection
        * @see com.electrotank.electroserver4.message.event.ConnectionEvent
        * 
        */
        public function createConnection(ip:String, port:Number):Connection {
            var con:Connection = new Connection(ip, port, getProtocol());
            con.setId(getConnections().length);
            con.addListener(this);
            con.connect();
            addConnection(con);
            return con;
        }
     
        /**
        *  Creates a new HttpConnection instance and returns it. Internally a new URLLoader/URLRequest is created and used to communicate with the server via binary protocol.
        * @example <listing>
                     import com.electrotank.electroserver4.ElectroServer;
                     import com.electrotank.electroserver4.connection;
                    import com.electrotank.electroserver4.message.MessageType;
                    import com.electrotank.electroserver4.message.event.*;
                    //
                    var es:ElectroServer = new ElectroServer();
                    es.addEventListener(MessageType.ConnectionEvent, "onConnectionEvent", this);
                    public function onConnectionEvent(e:ConnectionEvent):void {

                        if (e.getAccepted()) {
                            //connection accepted
                        } else {
                            //connection failed
                        }
                    }
        *         </listing>
        * @see com.electrotank.electroserver4.connection.Connection
        * @see com.electrotank.electroserver4.message.event.ConnectionEvent
        * 
        */
        public function createHttpConnection(ip:String, port:Number):HttpConnection {
            if( getProtocol() != Protocol.BINARY ) {
                throw new Error("ElectroServer#getProtocol() must be Protocol.BINARY");
            }
    
            var con:HttpConnection = new HttpConnection(ip, port, this);
            con.setId(getConnections().length);
            con.addListener(this);
            con.connect();
            addConnection(con);
            return con;
        }
    
        /**
         
        Creates a new RtmpConnection with ElectroServer. RtmpConnection is used to create new NetStream instances that are used to publish or subscribe to audio and video streams. RtmpConnection internally creates a NetConnection class instance to manage its connection with ElectroServer using the Flash player's built-in RTMP support.
        @example 
        This example shows how to use the createRtmpConnection method:
                    <listing>
                     import com.electrotank.electroserver4.ElectroServer;
                    import com.electrotank.electroserver4.message.MessageType;
                    import com.electrotank.electroserver4.message.event.RtmpConnectionEvent;
                    var es:ElectroServer;
                     var ip:String = "127.0.0.1";
                     var port:Number = 1935;
                     es.addEventListener(MessageType.RtmpConnectionEvent, "onRtmpConnection", this);
                     es.createRtmpConnection(ip, port);
                    public function onRtmpConnection(e:RtmpConnectionEvent):void {

                        if (e.getAccepted()) {
                            //connection accepted
                        } else {
                            //connecton failed
                        }
                    }
                    </listing>
        @return RtmpConnection
        @see flash.net.NetStream
        @see flash.net.NetConnection
        */
        public function createRtmpConnection(ip:String, port:Number):RtmpConnection {
            rtmpConnection = new RtmpConnection(this);
            //rtmp://myserver:443/myapp
            var escapedUserName:String = escape(userManager.getMe().getUserName());
            additionalLoginPassword = Math.round(1000000 * Math.random()).toString();
            //var ip:String = con.getIp();
            var connectionString:String = "rtmp://"+ip+":"+port+"/"+escapedUserName+"/"+additionalLoginPassword;
            rtmpConnection.connect(connectionString);
            return this.rtmpConnection;
        }
        /**
        *  
        * Returns an Object of of buddies stored by user name.
        * @return Object containing buddies by user name.
        * @see #addBuddy
        * @see #removeBuddy
        */
        public function getBuddyList():Object {
            return buddyList;
        }
        /**
         *  
         * Gets the list of open connections. 
         * @return Array of connections. Each element is of type Connection
         */
        public function getConnections():Array {
            return connections;
        }
        /**
        *  
        * Gets the debug status and returns it as a Boolean value. If debugging is turned on then message traffic is traced to the output window in the Flash IDE and logged.
        * @return The debug status as a Boolean.
        * @see #setDebug
        */
        public function getDebug():Boolean {
            return this.debug;
        }
        /**
        *  
        * Returns true if the client is logged in and false if not logged in.
        * @example 
        *         Get your logged in status.
        *         <listing>
                     import com.electrotank.electroserver4.ElectroServer;
                    var es:ElectroServer;//created and connected somewhere else
        *             var isLoggedIn:Boolean = es.getIsLoggedIn();
        *             </listing>
        */
        public function getIsLoggedIn():Boolean {
            return isLoggedIn;
        }
        /**
        *  
        * Returns the RtmpConnection.
        * @example <listing>
                     import com.electrotank.electroserver4.ElectroServer;
                     import com.electrotank.electroserver4.rtmpconnection.RtmpConnection;
                    //
                    var es:ElectroServer;//created and already connected somewhere else
        *             var rtmpConnection:RtmpConnection = es.getRtmpConnection();
        *         </listing>
        * @return RtmpConnection
        * @see com.electrotank.electroserver4.rtmpconnection.RtmpConnection
        * @see #closeRtmpConnection
        */
        public function getRtmpConnection():RtmpConnection {
            return rtmpConnection;
        }
        /**
         * 
         * Returns the UserManager instance. The UserManager is used to keep track of users that you should be able to see. If you see a user in multiple rooms it points back to the same User instance.
         * @return Returns the UserManager
         * @see com.electrotank.electroserver4.user.User
         * @see com.electrotank.electroserver4.user.UserManager
         */
        public function getUserManager():UserManager {
            return userManager;
        }
        /**
        *  Returns the ZoneManager. One instance of ZoneManager exists and keeps track of the zones.
        * @example 
        *             Get the zone manager and loop through its list of rooms tracing out the room names.
        * <listing>
                     import com.electrotank.electroserver4.ElectroServer;
                     import com.electrotank.electroserver4.connection;
                    import com.electrotank.electroserver4.message.MessageType;
                    import com.electrotank.electroserver4.message.event.*;
                    //
                    var es:ElectroServer;//created and connected somewhere else
                     var zm:ZoneManager = es.getZoneManager();
                     var rooms:Array = zm.getZone("Lobby Zone").getRooms();
                     for (var i:Number=0;i<rooms.length;++i) {
                         trace(rooms[i].getRoomName());
                     }
        *         </listing>
        * @return Returns the ZoneManager instance.
        * @see com.electrotank.electroserver4.zone.Zone
        * @see com.electrotank.electroserver4.room.Room
        */
        public function getZoneManager():ZoneManager {
            return zoneManager;
        }
        /**
         * @private
         */
        public function handleError(error:GenericErrorResponse):void {

            Logger.log("Error occurred", Logger.info);
            var mt:MessageType = error.getRequestMessageType();
            Logger.log(mt.getMessageTypeName(), Logger.info);
            Logger.log(error.getErrorType().getDescription(), Logger.info);
        }
        /**
         * @private
         */
        public function handleLoginResponse(lr:LoginResponse):void {

            if (!isLoggedIn && lr.getAccepted() ) {
                isLoggedIn = true;
                var u:User = new User();
                u.setUserId(lr.getUserId());
                u.setUserName(lr.getUserName());
                u.setIsMe(true);
                //handle user variables
                u.setUserVariables(lr.getUserVariables());
                //handle buddies
                buddyList = lr.getBuddies();
                userManager.addUser(u);
                userManager.addReference(u);
                userManager.setMe(u);
            }
        }
        /**
         * @private
         */
        public function processCompositeMessages(events:Array):void {

            for (var i:Number=0;i<events.length;++i) {
                var message:Message = Message(events[i]);
                var messageType:MessageType = message.getMessageType();
                transactionHandler.getTransaction(messageType).execute(message, this);
            }
        }
        /**
        *  
        * Removes a buddy from the buddy list.
        * @param name The user name of the buddy to remove.
        * @see #addBuddy
        * @see #getBuddyList
        */
        public function removeBuddy(name:String):void {

            var rbr:RemoveBuddyRequest = new RemoveBuddyRequest();
            rbr.setBuddyName(name);
            getBuddyList()[name] = null;
            send(rbr);
        }
        /**
        * 
        * Sends a request or response object to the server. A client can only communicate with the server via this method and via RtmpConnection.
        * @param message The request object to send to the server. This is one of the most commonly used methods of the ElectroServer class. First you build a request object and populate it with information (such as LoginRequest), and then you send it using this method. The message is first validated before the API sends it. If the messages fails validation then SendStatus.getIsSent() returns false.
        * @return Returns a SendStatus object which contains information saying if the message passed validation and was sent, or not.
        * @see com.electrotank.electroserver4.SendStatus
        * @example
        *         <listing>
                     import com.electrotank.electroserver4.ElectroServer;
                    import com.electrotank.electroserver4.message.request.LoginRequest;
                    import com.electrotank.electroserver4.message.response.LoginResponse;
                    import com.electrotank.electroserver4.message.MessageType;
                     //Build a request, send it, capture the response
                    var lr:LoginRequest = new LoginRequest();
                    lr.setUserName("McLovin");
                    es.send(lr);
                    //
                    public function onLoginResponse(e:LoginResponse):void {

                        if (e.getAccepted()) {
                            //login accepted
                        } else {
                            //login failed
                        }
                    }
        *         </listing>
        */
        public function send(message:Message):SendStatus {
            var sendStatus:SendStatus = new SendStatus();
            if (!isSimulatingLatency) {
                sendStatus = reallySend(message);
            } else {
                addToOutboundLatencyQueue( { time:getTimer(), message:message } );
            }
            return sendStatus;
        }
        private function addToOutboundLatencyQueue(ev:Object):void {

            outboundLatencyQueue.push(ev);
        }
        private function reallySend(message:Message):SendStatus {
            var sendStatus:SendStatus = new SendStatus();
            if (!isConnected) {
                sendStatus.setIsSent(false);
                sendStatus.setReason(SendStatus.NOT_CONNECTED);
                return sendStatus;
            }
            var validationResponse:ValidationResponse = message.validate();
            sendStatus.setValidationResponse(validationResponse);
            //
            if (!validationResponse.getIsValid()) {
                sendStatus.setIsSent(false);
                sendStatus.setReason(SendStatus.VALIDATION_FAILED);
                Logger.log("Request failed validation for these reasons:", Logger.info);
                for (var i:Number=0;i<validationResponse.getProblems().length;++i) {
                    var problem:String = validationResponse.getProblems()[i];
                    Logger.log(problem, Logger.info);
                }
                return sendStatus;
            }
            //If the message is a client conveienience message, then get the real server transaction message out of it
            while(!message.getIsRealServerMessage()) {
                message = message.getRealMessage();
            }
            
            var con:AbstractConnection = getConnections()[getConnections().length-1];
            
            if (message.getMessageType().getMessageTypeId() == "&") {
                //trace("TODO: Fix the way additional login validation is handled")
                con = getConnections()[0];
            }
            
            //create a new message writer
            var sw:MessageWriter = getMessageWriter();
            //define the message type
            sw.writeCharacter(message.getMessageType().getMessageTypeId());
            //grab the next outbound message number and write it
            var outId:Number = con.getNextOutboundId();
            sw.writeInteger(outId, MessageConstants.MESSAGE_ID_SIZE);
            //encode the request
            as2ProtocolHandler.getMessageCodec(message.getMessageType()).encode(sw, message);
            //notifyListeners("onSend", {target:this, message:sw.getMessage(), messageType:message.getMessageType().getMessageTypeName()});
            Logger.log("--> Sending :: conId: "+con.getId(), Logger.info);
            Logger.log(message.getMessageType().getMessageTypeName()+": "+sw.getData(), Logger.info);
            //store outbound message so we know what errored if we get an error response
            storeMessage(outId, message);
                if (getProtocol() == Protocol.TEXT) {
                    con.send(sw.getData());
                } else if (getProtocol() == Protocol.BINARY) {
     con.sendBinary(BinaryMessageWriter(sw).getBuffer());
                }
            //
            sendStatus.setIsSent(true);
            return sendStatus;
        }
        /**
        *  
        * This method is used to toggle all message taffic from being traced in the output console. Pass in true or false to enable or disable log messages getting traced to the output window in the Flash IDE. If debugging is on then all message traffic is traced to the output window when the onLog event is called. You can listen for log events directly by using the Logger class.
        * @param debug True or false to enable/disable log messages tracing to the output window.
        * @see #getDebug
        * @see com.electrotank.electroserver4.utils.Logger
        */
        public function setDebug(debug:Boolean):void {

            this.debug = debug;
        }
        /**
         * Sets the protocol. The default is Protocol.TEXT. Valid options are Protocol.TEXT and Protocol.BINARARY (AS3 and above).
         * @param protocol The protocol to use.
         */
        public function setProtocol(protocol:String):void {

            this.protocol = protocol;
        }
        /**
         * Gets the protocol being used.
         * @return The protocol being used.
         */
        public function getProtocol():String {
            return protocol;
        }
        /**
         * Called when a new client-bound message is received by one of the open connections.
         * @private
         * @param ev Contains the connection class instance and the data
         */
        public function onStringData(ev:Object):void {

            if (!isSimulatingLatency) {
                processStringData(ev);
            } else {
                ev.protocol = Protocol.TEXT;
                addToInboundLatencyQueue(ev);
            }
        }
        private function processStringData(ev:Object):void {

            var con:AbstractConnection = AbstractConnection(ev.target);
            var msr:MessageReader = getMessageReader();
            StringMessageReader(msr).setMessage(ev.data);
            var id:String = msr.nextCharacter();
            if (id != "<") {
                var messageId:Number = msr.nextInteger(MessageConstants.MESSAGE_ID_SIZE);
                processMessage(msr, id, messageId, con);
            }
        }
        /**
         * This method starts a latency simulation. The actual latency simulated will be the real latency of this client plus the value passed in here.
         * @param latency The latency to simulate.
         */
        public function startSimulatingLatency(latency:Number):void {

            isSimulatingLatency = true;
            simulatedLatency = latency;
     
     
            latencyTimer = new Timer(30);
            latencyTimer.start();
            latencyTimer.addEventListener(TimerEvent.TIMER, checkLatencyQueueEvent);
    
        }
        /**
         * Stops the latency simulation.
         */
        public function stopSimulatingLatency():void {

            isSimulatingLatency = false;
      
     
            if (latencyTimer != null) {
                latencyTimer.stop();
                latencyTimer.removeEventListener(TimerEvent.TIMER, checkLatencyQueueEvent);
                latencyTimer = null;
            }
    
            purgeLatencyQueue();
        }
        private function purgeLatencyQueue():void {

            purgeOutboundLatencyQueue();
            purgeInboundLatencyQueue();
        }
        private function purgeInboundLatencyQueue():void {

            for (var i:Number = 0; i < inboundLatencyQueue.length;++i) {
                var ev:Object = inboundLatencyQueue[i];
                if (ev.protocol == Protocol.TEXT) {
                    processStringData(ev);
                } else if (ev.protocol == Protocol.BINARY) {
     processBinaryData(ev);
                }
            }
            inboundLatencyQueue = new Array();
        }
        private function addToInboundLatencyQueue(ev:Object):void {

            ev.time = getTimer();
            inboundLatencyQueue.push(ev);
        }
     private function checkLatencyQueueEvent(e:TimerEvent):void {
            checkLatencyQueue();
        }
        private function checkLatencyQueue():void {

            checkInboundLatencyQueue();
            checkOutboundLatencyQueue();
        }
        private function checkInboundLatencyQueue():void {

            if (inboundLatencyQueue.length > 0) {
                var now:Number = getTimer();
                var i:Number = 0;
                var ev:Object = inboundLatencyQueue[i];
                if (now >= ev.time +simulatedLatency) {
                    if (ev.protocol == Protocol.TEXT) {
                        processStringData(ev);
                    } else if (ev.protocol == Protocol.BINARY) {
     processBinaryData(ev);
                    }
                    inboundLatencyQueue.shift();
                    checkLatencyQueue();
                }
            }
        }
        private function checkOutboundLatencyQueue():void {

            if (outboundLatencyQueue.length > 0) {
                var now:Number = getTimer();
                var i:Number = 0;
                var ev:Object = outboundLatencyQueue[i];
                if (now >= ev.time +simulatedLatency) {
                    reallySend(ev.message);
                    outboundLatencyQueue.shift();
                    checkOutboundLatencyQueue();
                }
            }
        }
        private function purgeOutboundLatencyQueue():void {

            for (var i:Number = 0; i < outboundLatencyQueue.length;++i) {
                reallySend(outboundLatencyQueue[i].message);
            }
            outboundLatencyQueue = new Array();
        }
        
        
     
            public function onBinaryData(ev:Object):void {//xxx
                if (!isSimulatingLatency) {
                    processBinaryData(ev);
                } else {
                    ev.protocol = Protocol.BINARY;
                    addToInboundLatencyQueue(ev);
                }
            }
            private function processBinaryData(ev:Object):void {
                var con:AbstractConnection = AbstractConnection(ev.target);
                var msr:MessageReader = getMessageReader();
                BinaryMessageReader(msr).setBuffer(ev.data);
                var id:String = msr.nextCharacter();
                var messageId:Number = msr.nextInteger(MessageConstants.MESSAGE_ID_SIZE);
                processMessage(msr, id, messageId, con);
            }
     
        
        /**
         * Checks to see if the message contains the next expected message id. If it does, then it processes the message. If it doesn't, then it queues the message and will use it later when the time is right.
         * @param    MessageReader class that contains the inbound message data.
         * @param    The id of the message. This tells use what the message type is.
         * @param    The number of the message. This ensures that we receive and process messages in the correct order.
         * @param    The connection over which the message was received.
         * @private
         */
        private function processMessage(msr:MessageReader, id:String, messageId:Number, con:AbstractConnection):void {

            var messageType:MessageType = MessageType.findTypeById(id);
            if (expectedInboundId == messageId || messageId == 0) {
                //1) find message type 2) decode it into its message instance 3) handle it
                //notifyListeners("onData", {target:this, message:mess, messageType:messageType.getMessageTypeName()});
                //
                Logger.log("<-- Receiving :: conId: "+con.getId(), Logger.info);
                Logger.log(messageType.getMessageTypeName(), Logger.info);
                //
                var message:Message = as2ProtocolHandler.getMessageCodec(messageType).decode(msr);
                message.setMessageId(messageId);
                transactionHandler.getTransaction(messageType).execute(message, this);
                if (con.getId() == 0) {
                    expectedInboundId = messageId+1;
                } else {
                    if (messageId != 0) {
                        expectedInboundId++;
                    }
                }
                checkQueue();
            } else {
                //This handles GateWayKickUserRequest
                if (messageId == -1) {
                    var expectedId:Number = expectedInboundId;
                    processMessage(msr, id, expectedId, con);
                    expectedInboundId = expectedId;
                    return;
                }
                Logger.log("<-- Receiving [QUEUED] :: conId: "+con.getId(), Logger.info);
                Logger.log(messageType.getMessageTypeName(), Logger.info);
                //received out of order - queue it up
                var qm:QueuedMessage = new QueuedMessage(msr, id, messageId, con);
                messageQueue.push(qm);
                messageQueue.sortOn("messageId", Array.NUMERIC);
            }
        }
        /**
         * Checks the queued messages to see if it is time to use one.
         * @private
         */
        private function checkQueue():void {

            if (messageQueue.length > 0) {
                var qm:QueuedMessage = messageQueue[0];
                if (qm.messageId == expectedInboundId) {
                    messageQueue.shift();
                    processMessage(qm.getMessageReader(), qm.getId(), qm.messageId, qm.getConnection());
                }
            }
        }
        /**
         * Gets a MessageWriter class instance for the current protocol used
         * @private
         * @return MessageWriter class instance.
         */
        private function getMessageWriter():MessageWriter {
            var msw:MessageWriter;
            switch (getProtocol()) {
                case Protocol.TEXT:
                    msw = new StringMessageWriter();
                    break;
                case Protocol.BINARY:
     msw = new BinaryMessageWriter();
                    break;
                default:
                    throw new Error("Protocol not supported: "+getProtocol());
                    break;
            }
            return msw;
        }
        /**
         * Returns a MessageReader class instance for the protocol used.
         * @private
         * @return MessageReader class instance.
         */
        private function getMessageReader():MessageReader {
            var msr:MessageReader;
            switch (getProtocol()) {
                case Protocol.TEXT:
                    msr = new StringMessageReader();
                    break;
                case Protocol.BINARY:
     msr = new BinaryMessageReader();
                    break;
                default:
                    throw new Error("Protocol not supported: "+getProtocol());
                    break;
            }
            return msr;
        }
        /**
         * Stores a small number of sent messages just incase there is an error response to tie them to.
         * @private
         * @param    outId The outbound message id. This is sent back to the client if the request caused an error.
         * @param    message The actual message.
         */
        private function storeMessage(outId:Number, message:Message):void {

            var ob:Object = new Object();
            ob.outId = outId;
            ob.message = message;
            history.unshift(ob);
            if (history.length > 10) {
                history.pop();
            }
        }
        /**
         * Gets one of the stored messages based on the message id.
         * @private
         * @param    outId The id used for this message when it was sent.
         * @return Returns the Message class instance associated with the message id passed in.
         */
        private function getOldMessage(outId:Number):Message {
            var msg:Message;
            for (var i:Number=0;i<history.length;++i) {
                var ob:Object = history[i];
                if (ob.id == outId) {
                    msg = ob.message;
                    break;
                }
            }
            return msg;
        }
        /**
         * Event handler called when a connection is made.
         * @param    ev Event object that contains the Connection class instance.
         * @private
         */
        public function onConnect(ev:Object):void {

            isConnected = false;
            var con:AbstractConnection;
            for (var i:Number=0;i<connections.length;++i) {
                con = connections[i];
                if (con.getIsConnected()) {
                    isConnected = true;
                    break;
                }
            }
            if (ev.success) {
            } else {
                var cone:ConnectionEvent = new ConnectionEvent();
                cone.setAccepted(false);
                cone.setEsError(Errors.FailedToConnect);
                dispatchEvent(cone);
                //notifyListeners(MessageType.ConnectionEvent, {target:this, success:false});
            }
        }
        /**
         * Event handler for when one of the connections closes.
         * @private
         * @param    ev Event object containing a reference to the closed connection.
         */
        public function onClose(ev:Object):void {

            var con:AbstractConnection = AbstractConnection(ev.target);
            Logger.log("--connection closed-- id: "+con.getId(), Logger.info);
            //notifyListeners("onClose", {target:this});
            var cce:ConnectionClosedEvent = new ConnectionClosedEvent();
            cce.setConnection(con);
            dispatchEvent(cce);
        }
        /**
         * Event handler for the interal Logger class
         * @private
         * @param    e Event object that contains the log information
         */
        public function onLog(e:Object):void {

            var log:Object = e.log;
            if (debug) {
                trace(log.message);
            }
        }
        /**
         * Internal method used to initialize Arrays and other values.
         * @private
         */
        private function initialize():void {

            setProtocol(Protocol.TEXT);
            setDebug(false);
            expectedInboundId = 0;
            isConnected = false;
            Logger.init();
            Logger.getInstance().addEventListener(Logger.LOGGED, "onLog", this);
            
            history = new Array();
            connections = new Array();
            messageQueue = new Array();
            buddyList = new Object();
            as2ProtocolHandler = new As2ProtocolHandler();
            transactionHandler = new TransactionHandler();
            zoneManager = new ZoneManager();
            userManager = new UserManager();
            isSimulatingLatency = false;
            inboundLatencyQueue = new Array();
            outboundLatencyQueue = new Array();
            this.addEventListener(MessageType.ValidateAdditionalLoginRequest, "onValidateAdditionalLoginRequest", this);
        }
        /**
         * Event handler used to auto-validate a 2nd login rquest
         * @private
         * @param    e The ValidateAdditionalLoginRequest class instance used to validate the additional login request
         */
        public function onValidateAdditionalLoginRequest(e:ValidateAdditionalLoginRequest):void {

            var valid:Boolean = e.getSecret() == additionalLoginPassword;
            var res:ValidateAdditionalLoginResponse = new ValidateAdditionalLoginResponse();
            res.setApproved(valid);
            res.setSecret(additionalLoginPassword);
            
            send(res);
        }
        /**
         * Adds a connection to the connections array.
         * @private
         * @param    con The connection class instance
         */
        private function addConnection(con:AbstractConnection):void {

            getConnections().push(con);
        }
    }
}
