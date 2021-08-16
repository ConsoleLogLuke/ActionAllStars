package com.electrotank.electroserver4.message.response {
    import com.electrotank.electroserver4.message.MessageImpl;
    import com.electrotank.electroserver4.message.response.*;
    import com.electrotank.electroserver4.message.*;
    import com.electrotank.electroserver4.errors.*;
    import com.electrotank.electroserver4.esobject.EsObject;
    
    public class FindGamesResponse extends ResponseImpl {

        private var games:Array;
        public function FindGamesResponse() {
            setMessageType(MessageType.FindGamesResponse);
        }
        public function setGames(games:Array):void {

            this.games = games;
        }
        public function getGames():Array {
            return this.games;
        }
    }
}
