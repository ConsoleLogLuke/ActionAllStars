package com.sdg.gameMenus
{
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.components.controls.CustomMVPAlert;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.GetStatsEvent;
	import com.sdg.events.GetTeamsEvent;
	import com.sdg.events.ItemPurchaseEvent;
	import com.sdg.events.SocketEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.StoreCategory;
	import com.sdg.model.StoreItem;
	import com.sdg.net.Environment;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.utils.Constants;
	import com.sdg.utils.MainUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.events.CloseEvent;
	
	public class GameController extends EventDispatcher
	{
		protected var _view:IGameView;
		protected var _gameId:int;
		protected var _avatar:Avatar;
		
		public function GameController(gameId:int)
		{
			_gameId = gameId;
			
			_avatar = ModelLocator.getInstance().avatar;
			
			if (_gameId == Constants.RBI_GAME_ID)
				_view = new RBIView(this, 925, 665);
			
			_view.showMainMenu();
		}
		
		public function playSinglePlayer(team1ItemId:int, team2ItemId:int):void
		{
			SocketClient.getInstance().addEventListener(SocketEvent.PLUGIN_EVENT, onPluginEvent);
			RoomManager.getInstance().loadGame(_gameId, 0, 0, team1ItemId, team2ItemId);
		}
		
		protected function onPluginEvent(event:SocketEvent):void
		{
			switch (event.params.action)
			{
				case "unityGameResult":
					SocketClient.getInstance().removeEventListener(SocketEvent.PLUGIN_EVENT, onPluginEvent);
					var	gameResult:XML = XML(event.params.unityGameResult);
					_view.showGameFinish(gameResult);
					break;
			}
		}
		
		public function quitGame():void
		{
			_view.destroy();
			dispatchEvent(new Event("quit game"));
		}
		
		protected function createGameTeamItem(teamXml:XML):GameTeamItem
		{
			var gameTeamItem:GameTeamItem;
			
			if (_gameId == Constants.RBI_GAME_ID)
			{
				var rbiTeamItem:RBITeamItem = new RBITeamItem();
				rbiTeamItem.teamId = teamXml.teamId;
				rbiTeamItem.wins = teamXml.wins;
				rbiTeamItem.losses = teamXml.losses;
				rbiTeamItem.offensiveRank = teamXml.offensiveRank;
				rbiTeamItem.pitchingRank = teamXml.pitchingRank;
				
				gameTeamItem = rbiTeamItem;
			}
			gameTeamItem.id = teamXml.id;
			gameTeamItem.name = teamXml.name;
			gameTeamItem.tokens = teamXml.tokens;
			gameTeamItem.owned = teamXml.owned == 1 ? true : false;
			
			return gameTeamItem;
		}
		
		public function purchaseItem(item:GameItem, storeId:int):void
		{
			// Check MVP Status First
			if (avatar.membershipStatus == Constants.MEMBER_STATUS_FREE)
			{
				LoggingUtil.sendClickLogging(LoggingUtil.MVP_UPSELL_VIEW_RBI_BASEBALL_STORE);
				CustomMVPAlert.show(Environment.getApplicationUrl() + "/test/gameSwf/gameId/82/gameFile/mvp_upsell_popUp_Store.swf",
											LoggingUtil.MVP_UPSELL_CLICK_RBI_BASEBALL_STORE, onClose);
				return;
			}
			function onClose(event:CloseEvent):void
			{
				var identifier:int = event.detail;
				if (identifier == LoggingUtil.MVP_UPSELL_CLICK_RBI_BASEBALL_STORE)
					MainUtil.goToMVP(identifier);
			}
			
			if (avatar.currency < item.tokens)
			{
				SdgAlertChrome.show("Hey there, it looks like you need more tokens!", "TIME OUT!");
				return;
			}
			
			CairngormEventDispatcher.getInstance().addEventListener(ItemPurchaseEvent.SUCCESS, onPurchaseSuccess);
			
			var storeItem:StoreItem = new StoreItem(item.id, item.name, null, item.tokens, 0, 0, false, 0, null, null,
													new StoreCategory("", 2331, 2330, 0, "", 0), 0, 0, 0, 0, 0, 0);
			
			CairngormEventDispatcher.getInstance().dispatchEvent(new ItemPurchaseEvent(_avatar, storeItem, storeId));
			
			function onPurchaseSuccess(event:ItemPurchaseEvent):void
			{
				if (event.storeItem != storeItem) return;
				SocketClient.getInstance().sendPluginMessage("avatar_handler", "uiEvent", { uiEvent:"<uiEvent><uiId>3</uiId><avUp>1</avUp></uiEvent>" });
				item.owned = true;
			}
		}
		
		public function getStoreTeams():void
		{
			//CairngormEventDispatcher.getInstance().dispatchEvent(new StoreItemsEvent(2330, 1000, _avatar.avatarId));
		}
		
		public function getTeams(owned:Boolean):void
		{
			CairngormEventDispatcher.getInstance().addEventListener(GetTeamsEvent.TEAMS_RECEIVED, onTeamsReceived);
			CairngormEventDispatcher.getInstance().addEventListener(GetTeamsEvent.GET_TEAMS_ERROR, onTeamsError);
			CairngormEventDispatcher.getInstance().dispatchEvent(new GetTeamsEvent(GetTeamsEvent.GET_TEAMS, owned));
			
			function onTeamsReceived(event:GetTeamsEvent):void
			{
				CairngormEventDispatcher.getInstance().removeEventListener(GetTeamsEvent.TEAMS_RECEIVED, onTeamsReceived);
				CairngormEventDispatcher.getInstance().removeEventListener(GetTeamsEvent.GET_TEAMS_ERROR, onTeamsError);
				
				var teamsArray:Array = new Array();
				
				for each (var teamXml:XML in event.teamsXml.team)
				{
					var team:GameTeamItem = createGameTeamItem(teamXml);
					teamsArray.push(team);
				}
				
				if (owned)
					_view.teams = teamsArray;
				else
					_view.storeItems = teamsArray;
			}
			
			function onTeamsError(event:GetTeamsEvent):void
			{
				CairngormEventDispatcher.getInstance().removeEventListener(GetTeamsEvent.TEAMS_RECEIVED, onTeamsReceived);
				CairngormEventDispatcher.getInstance().removeEventListener(GetTeamsEvent.GET_TEAMS_ERROR, onTeamsError);
			}
		}
		
		public function getStats():void
		{
			CairngormEventDispatcher.getInstance().addEventListener(GetStatsEvent.STATS_RECEIVED, onStatsReceived);
			CairngormEventDispatcher.getInstance().addEventListener(GetStatsEvent.GET_STATS_ERROR, onStatsError);
			CairngormEventDispatcher.getInstance().dispatchEvent(new GetStatsEvent(GetStatsEvent.GET_STATS, _gameId));
			
			function onStatsReceived(event:GetStatsEvent):void
			{
				CairngormEventDispatcher.getInstance().removeEventListener(GetStatsEvent.STATS_RECEIVED, onStatsReceived);
				CairngormEventDispatcher.getInstance().removeEventListener(GetStatsEvent.GET_STATS_ERROR, onStatsError);
				
				var statsArray:Array = new Array();
				
				for each (var stat:XML in event.statsXml.children())
					statsArray.push({category:stat.localName().replace(/_/g, " "), value:stat});
				
				_view.stats = statsArray;
			}
			
			function onStatsError(event:GetStatsEvent):void
			{
				CairngormEventDispatcher.getInstance().removeEventListener(GetStatsEvent.STATS_RECEIVED, onStatsReceived);
				CairngormEventDispatcher.getInstance().removeEventListener(GetStatsEvent.GET_STATS_ERROR, onStatsError);
			}
		} 
		
		public function get avatar():Avatar
		{
			return _avatar;
		}
		
		public function get view():IGameView
		{
			return _view;
		}
	}
}
