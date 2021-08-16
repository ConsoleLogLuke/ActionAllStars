package com.electrotank.electroserver4.protocol.codec {
    import com.electrotank.electroserver4.entities.ServerGame;
    import com.electrotank.electroserver4.esobject.EsObject;
    import com.electrotank.electroserver4.MessageConstants;
    import com.electrotank.electroserver4.protocol.codec.*;
    import com.electrotank.electroserver4.protocol.*;
    import com.electrotank.electroserver4.message.Message;
    import com.electrotank.electroserver4.message.response.*;
    
    public class FindGamesResponseCodec extends MessageCodecImpl {

        override public function decode(reader:MessageReader):Message {
                var requestId:String = reader.nextInteger(MessageConstants.MESSAGE_ID_SIZE).toString();
            
            var response:FindGamesResponse = new FindGamesResponse();
            
            var numGames:Number = reader.nextInteger();
            
    
            var games:Array = new Array();
            response.setGames(games);
            
            for(var i:Number = 0; i < numGames; i++) {
                var gameId:Number = reader.nextInteger();
                //var roomId:Number = reader.nextInteger();
                //var zoneId:Number = reader.nextInteger();
                var locked:Boolean = reader.nextBoolean();
                var passwordProtected:Boolean = reader.nextBoolean();
                var details:EsObject = null;
                if(reader.nextBoolean()) {
                    details = EsObjectCodec.decode(reader);
                }
                var game:ServerGame = new ServerGame();
                game.setGameId(gameId);
                game.setLocked(locked);
                game.setPasswordProtected(passwordProtected);
                game.setGameDetails(details);
                games.push(game);
            }
            
    
            return response;
        }
    
    }
}
