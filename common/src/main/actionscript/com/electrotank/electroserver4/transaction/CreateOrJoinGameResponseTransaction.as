package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.ElectroServer;
    
    public class CreateOrJoinGameResponseTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:CreateOrJoinGameResponse = CreateOrJoinGameResponse(mess);
            es.dispatchEvent(message);
            //es.notifyListeners("onZonesLoaded", {target:es, zones:message.getZones()});
    
        }
    }
}
