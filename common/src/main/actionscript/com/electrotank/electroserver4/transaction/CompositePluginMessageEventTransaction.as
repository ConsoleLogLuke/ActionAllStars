package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.user.User;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.zone.*;
    
    public class CompositePluginMessageEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:CompositePluginMessageEvent = CompositePluginMessageEvent(mess);
            var events:Array = new Array();
            var obs:Array = message.getParameters();
            for (var i:Number=0;i<obs.length;++i) {
                var pe:PluginMessageEvent = new PluginMessageEvent();
                pe.setPluginName(message.getPluginName());
                pe.setOriginRoomId(message.getOriginRoomId());
                pe.setOriginZoneId(message.getOriginZoneId());
                pe.setEsObject(obs[i]);
                events.push(pe);
            }
            es.processCompositeMessages(events);
            es.dispatchEvent(message);
            //es.notifyListeners("onPluginMessage", {target:es, pluginName:message.getPluginName(), wasSentToRoom:message.wasSentToRoom(), roomId:message.getRoomId(), zoneId:message.getZoneId(), pairs:message.getPairs()});
        }
    }
}
