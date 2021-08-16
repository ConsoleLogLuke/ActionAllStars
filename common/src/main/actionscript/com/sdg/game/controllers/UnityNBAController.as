package com.sdg.game.controllers
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.GetUnityNBATeamsEvent;
	import com.sdg.events.SocketEvent;
	import com.sdg.game.events.UnityNBAEvent;
	import com.sdg.game.models.IUnityNBAModel;
	import com.sdg.game.models.UnityNBAModel;
	import com.sdg.game.models.UnityNBATeam;
	import com.sdg.game.views.IGameMenuView;
	import com.sdg.game.views.IUnityNBAView;
	import com.sdg.game.views.UnityNBAView;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.utils.Constants;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class UnityNBAController extends EventDispatcher implements IGameMenuController
	{
		private var _view:IUnityNBAView;
		private var _model:IUnityNBAModel;
		
		public function UnityNBAController()
		{
			_model = new UnityNBAModel();
			_view = new UnityNBAView();
			_view.model = _model;
			
			_view.addEventListener(UnityNBAEvent.START_GAME, onStartGame, false, 0, true);
			_view.addEventListener(UnityNBAEvent.QUIT_GAME, onQuitGame, false, 0, true);
			
			CairngormEventDispatcher.getInstance().dispatchEvent(new GetUnityNBATeamsEvent(GetUnityNBATeamsEvent.GET_UNITY_NBA_TEAMS));
			CairngormEventDispatcher.getInstance().addEventListener(GetUnityNBATeamsEvent.UNITY_NBA_TEAMS_RETURNED, onUnityNBATeamsReturned);
		}
		
		private function onQuitGame(event:UnityNBAEvent):void
		{
			close();
		}
		
		private function onStartGame(event:UnityNBAEvent):void
		{
			var myTeam:UnityNBATeam = _model.myTeam;
			var opponentTeam:UnityNBATeam = _model.opponentTeam;
			
			if (myTeam == null || opponentTeam == null) return;
			
			SocketClient.getInstance().addEventListener(SocketEvent.PLUGIN_EVENT, onPluginEvent);
			RoomManager.getInstance().loadGame(Constants.NBA_ALLSTARS_GAME_ID, 0, 0, myTeam.teamId, opponentTeam.teamId);
		}
		
		protected function onPluginEvent(event:SocketEvent):void
		{
			switch (event.params.action)
			{
				case "unityGameResult":
					SocketClient.getInstance().removeEventListener(SocketEvent.PLUGIN_EVENT, onPluginEvent);
					_model.gameResult = event.params;
					break;
			}
		}
		
		private function close():void
		{
			_model.close();
			_view.close();
			dispatchEvent(new Event(Event.CLOSE, true));
		}
		
		private function onUnityNBATeamsReturned(event:GetUnityNBATeamsEvent):void
		{
			CairngormEventDispatcher.getInstance().removeEventListener(GetUnityNBATeamsEvent.UNITY_NBA_TEAMS_RETURNED, onUnityNBATeamsReturned);
			_model.inputData = event.returnData;
		}
		
		public function get view():IGameMenuView
		{
			return _view;
		}
	}
}