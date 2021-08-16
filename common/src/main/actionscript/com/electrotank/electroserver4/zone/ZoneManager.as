package com.electrotank.electroserver4.zone {
    import com.electrotank.electroserver4.zone.*;
    
    public class ZoneManager {

        private var zones:Array;
        private var zonesById:Object;
        private var zonesByName:Object;
        public function ZoneManager() {
            zones = new Array();
            zonesById = new Object();
            zonesByName = new Object();
        }
        public function getZones():Array {
            return zones;
        }
        public function removeZone(id:Number):void {

            var zone:Zone = getZoneById(id);
            if (zone != null) {
                zonesById[id.toString()] = null;
                zonesByName[zone.getZoneName()] = null;
                for (var i:Number=0;i<zones.length;++i) {
                    var tmp:Zone = zones[i];
                    if (tmp.getZoneId() == id) {
                        zones.splice(i, 1);
                        break;
                    }
                }
            } else {
                trace("Error: Tried removing zone that wasn't being managed by the ZoneManager.");
            }
        }
        public function addZone(zone:Zone):void {

            if (zonesById[zone.getZoneId().toString()] == null) {
                getZones().push(zone);
                zonesByName[zone.getZoneName()] = zone;
                zonesById[zone.getZoneId().toString()] = zone;
            } else {
                trace("Error: this zone has already been added. zoneId: "+zone.getZoneId().toString());            
            }
        }
        public function getZoneById(num:Number):Zone {
            var zone:Zone = zonesById[num.toString()];
            if (zone == null) {
                trace("Error: getZoneById() could not find a zone with this id: "+num);
            }
            return zone;
        }
        public function getZoneByName(str:String):Zone {
            var zone:Zone = zonesByName[str];
            if (zone == null) {
                trace("Error: getZoneByName() could not find a zone with this name: "+str);
            }
            return zone;
        }
            
    }
}
