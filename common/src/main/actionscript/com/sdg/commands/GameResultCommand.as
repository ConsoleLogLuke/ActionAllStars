package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.GameResultEvent;
	import com.sdg.net.socket.SocketClient;
	
	import mx.rpc.IResponder;

	public class GameResultCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		private var _gameId:uint;
		private var _avatarId:uint;
		
		public function execute(event:CairngormEvent):void
		{
			var ev:GameResultEvent = event as GameResultEvent;
			
			// get the avatarId andt the gameId from result
			var xmlResult:XML = XML(ev.result);
			_gameId = xmlResult.gameId;
			_avatarId = xmlResult.avatarId;
			
			new SdgServiceDelegate(this).gameResult(ev.result);
		}
		
		public function result(data:Object):void
		{
			// send a "finish game" message to the socket server
	       	SocketClient.sendMessage("room_manager","finishGame","gameEvent", {gameId:_gameId, avatarId:_avatarId});
		}
	}
}