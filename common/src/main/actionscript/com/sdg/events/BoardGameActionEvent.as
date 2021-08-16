package com.sdg.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class BoardGameActionEvent extends CairngormEvent
	{
		public static const BOARD_GAME_ACTION:String = "boardGameAction";
		
		private var _senderAvatarId:int;
		private var _recieverAvatarIds:Array;
		private var _actionName:String; 
		private var _actionValue:String
		private var _gameSessionId:String
		
		public function BoardGameActionEvent(gameSessionId:String, senderAvatarId:int, recieverAvatarIds:Array, actionName:String, actionValue:String)
		{
			super(BOARD_GAME_ACTION);
			_gameSessionId = gameSessionId;
			_senderAvatarId = senderAvatarId;
			_recieverAvatarIds = recieverAvatarIds;
			_actionName = actionName;
			_actionValue = actionValue;
		}
		
		public function get gameSessionId():String
		{
			return _gameSessionId;
		}
		
		public function get senderAvatarId():int
		{
			return _senderAvatarId;
		}
		
		public function get recieverAvatarIds():Array
		{
			return _recieverAvatarIds;			
		}

		public function get actionName():String
		{
			return _actionName;
		}

		public function get actionValue():String
		{
			return _actionValue;
		}
	}
}