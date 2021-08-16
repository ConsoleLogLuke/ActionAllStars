package com.electrotank.electroserver4.rtmpconnection {
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.message.event.RtmpConnectionClosedEvent;
    import com.electrotank.electroserver4.message.event.RtmpConnectionEvent;
    import com.electrotank.electroserver4.message.event.RtmpOnStatusEvent;
    import com.electrotank.electroserver4.utils.Logger;
    
      
    import flash.net.NetStream;
    import flash.net.NetConnection;
    import flash.net.ObjectEncoding;
    import flash.events.NetStatusEvent;
    import flash.events.SecurityErrorEvent;
      
    
    
    public class RtmpConnection {

        private var netConnection:NetConnection;
        private var es:ElectroServer;
        private var netStreams:Array;
        private var isConnected:Boolean;
        public function RtmpConnection(es:ElectroServer) {
            this.es = es;
     NetConnection.defaultObjectEncoding = ObjectEncoding.AMF0;
            netConnection = new NetConnection();
            netStreams = new Array();
            isConnected = false;
        }
        public function getNetConnection():NetConnection {
            return this.netConnection;
        }
        public function disposeOfNetStream(ns:NetStream):void {

            ns.close();
            for (var i:Number=0;i<netStreams.length;++i) {
                if (netStreams[i] == ns) {
                    netStreams.splice(i, 1);
                    break;
                }
            }
        }
        public function getIsConnected():Boolean {
            return isConnected;
        }
        public function getNewNetStream():NetStream {
            var ns:NetStream = new NetStream(netConnection);
            netStreams.push(ns);
            /*ns.onMetaData = function(info:Object) {
                trace("==========");
                for (var i in info) {
                    trace(i+": "+info[i]);
                }
            }*/
            /*
             * canSeekToEnd: true
                audiocodecid: 2
                audiodelay: 0.038
                audiodatarate: 96
                videocodecid: 4
                framerate: 30
                videodatarate: 400
                height: 240
                width: 320
                duration: 4290.29
             */
            
            return ns;
        }
        public function getNetStreams():Array {
            return netStreams;
        }
        public function onStatus(info:Object):void {

            var cone:RtmpConnectionEvent;
            Logger.log(info.code, Logger.info);
            if (info.level == "status") {
                switch(info.code) {
                    case "NetConnection.Connect.Success":
                        isConnected = true;
                        cone = new RtmpConnectionEvent();
                        cone.setAccepted(true);
                        es.dispatchEvent(cone);
                        break;
                    case "NetConnection.Connect.Closed":
                        isConnected = false;
                        var closeEvent:RtmpConnectionClosedEvent = new RtmpConnectionClosedEvent();
                        es.dispatchEvent(closeEvent);
                        break;
                    default:
                        //trace("onStatus event not handled: "+info.code);
                        //trace(info.description);
                        break;
                }
            } else if (info.level == "error") {
                switch(info.code) {
                    case "NetConnection.Connect.Failed":
                        isConnected = false;
                        cone = new RtmpConnectionEvent();
                        cone.setAccepted(false);
                        es.dispatchEvent(cone);
                        break;
                    case "NetConnection.Connect.Rejected":
                        isConnected = false;
                        cone = new RtmpConnectionEvent();
                        cone.setAccepted(false);
                        es.dispatchEvent(cone);
                        //break;
                    case "NetConnection.Call.Failed":
                        
                        //break;
                    case "NetConnection.Connect.AppShutdown":
                        
                        //break;
                    case "NetConnection.Connect.InvalidApp":
                        
                        //break;
                    default:
                        //trace("onStatus event not handled: "+info.code);
                        //trace(info.description);
                        break;
                }
            }
            var onStatusEvent:RtmpOnStatusEvent = new RtmpOnStatusEvent();
            onStatusEvent.setInfo(info);
            es.dispatchEvent(onStatusEvent);
        }
    
      
            private function netStatusHandler(e:NetStatusEvent):void {
                onStatus(e.info);
            }
            private function securityErrorHandler(e:SecurityError):void {
                trace("security error")
                trace(e);
            }
      
        
        public function connect(connectionString:String):void {

      
     netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
     netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            netConnection.connect(connectionString);
        }
        public function close():void {

            netConnection.close();
        }
        
    }
}
