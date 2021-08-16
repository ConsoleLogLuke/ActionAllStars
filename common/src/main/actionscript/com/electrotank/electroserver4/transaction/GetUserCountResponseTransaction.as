package com.electrotank.electroserver4.transaction {
    import com.electrotank.electroserver4.transaction.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.event.*;
    import com.electrotank.electroserver4.message.request.*;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.zone.Zone;
    import com.electrotank.electroserver4.room.Room;
    import com.electrotank.electroserver4.ElectroServer;
    
    public class GetUserCountResponseTransaction extends TransactionImpl {

        override public function execute(mess:Message, es:ElectroServer):void {

            var message:GetUserCountResponse = GetUserCountResponse(mess);
            es.dispatchEvent(message);
            //es.notifyListeners("onUserCountLoaded", {target:es, count:message.getCount()});
        }
    }
}
