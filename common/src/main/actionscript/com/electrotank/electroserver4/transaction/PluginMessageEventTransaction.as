package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.ElectroServer;
    import com.electrotank.electroserver4.user.User;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.zone.*;
    
    public class PluginMessageEventTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:PluginMessageEvent = PluginMessageEvent(mess);
            es.dispatchEvent(message);
            //es.notifyListeners("onPluginMessage", {target:es, pluginName:message.getPluginName(), wasSentToRoom:message.wasSentToRoom(), roomId:message.getRoomId(), zoneId:message.getZoneId(), pairs:message.getPairs()});
        }
    }
}
