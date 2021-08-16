package com.electrotank.electroserver4.message.response {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.zone.*;
    
    public class GetZonesResponse extends ResponseImpl {

        private var zones:Array;
        public function GetZonesResponse() {
            setMessageType(MessageType.GetZonesResponse);
            zones = new Array();
        }
        public function addZone(zone:Zone):void {

            getZones().push(zone);
        }
        public function getZones():Array {
            return zones;
        }
    }
}
