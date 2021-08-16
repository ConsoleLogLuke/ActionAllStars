package com.electrotank.electroserver4.message.request {
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.ValidationResponse;
    /**
     * This request loads the list of all zones on the server. It responds with a list of zone names and zone ids.
     * @example
     * This example shows how to load all of the zones on the server and capture the response.
     * <listing>
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.message.MessageType;
    import com.electrotank.electroserver4.message.request.GetZonesRequest;
    import com.electrotank.electroserver4.message.response.GetZonesResponse;
    import com.electrotank.electroserver4.zone.Zone;
    //
    var es:ElectroServer;//assume this is created elsewhere and a connection is made and you're logged in.
    function init():void {
        es.addEventListener(MessageType.GetZonesResponse, "onGetZonesResponse", this);
    }
    function loadAllZones():void {
        var gzr:GetZonesRequest = new GetZonesRequest();
        es.send(gzr);
    }
    function onGetZonesResponse(e:GetZonesResponse):void {
        var zones:Array = e.getZones();
        for (var i:int=0;i &gt zones.length;++i) {
            var zone:Zone = zones[i];
            trace("ZoneName: "+zone.getZoneName());
        }
    }
    init();
    loadAllZones();
     * </listing>
     */
    
    public class GetZonesRequest extends RequestImpl {

        public function GetZonesRequest() {
            setMessageType(MessageType.GetZonesRequest);
        }
    
     override public function validate():ValidationResponse {    
            var valid:Boolean = true;
            var problems:Array = new Array();
            var vr:ValidationResponse = new ValidationResponse(valid, problems);
            return vr;
        }
        
    }
}
