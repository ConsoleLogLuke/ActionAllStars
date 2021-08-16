package com.sdg.gameMenus
{
	import com.sdg.events.GameItemPurchaseEvent;
	import com.sdg.events.StartGameEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.store.StoreConstants;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class RBIView extends Sprite implements IGameView
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _controller:GameController;
		protected var _mainMenu:RBIMainMenu;
		protected var _currentMenu:DisplayObject;
		protected var _headingMenu:RBIHeadingMenu;
		protected var _backgroundMenu:RBIBackgroundMenu;
		protected var _statsBody:RBIStatsBody;
		protected var _storeBody:RBIStoreBody;
		protected var _teamSelectBody:RBITeamSelect;
		protected var _finalScoreBody:RBIFinalScoreBody;
		
		public function RBIView(controller:GameController, width:Number, height:Number)
		{
			super();
			_controller = controller;
			_width = width;
			_height = height;
		}
		
		public function showMainMenu():void
		{
			if (_mainMenu == null)
			{
				_mainMenu = new RBIMainMenu(_width, _height, 350, 40);
				
				var quickPlay:RBIMenuItem = new RBIMenuItem("Quick Play", null, playSinglePlayer);
				_mainMenu.addMenuItem(quickPlay);
				
				//var twoPlayer:RBIMenuItem = new RBIMenuItem("2 Player", null, showFinalScorePage);
				//_mainMenu.addMenuItem(twoPlayer);
				
				var myStats:RBIMenuItem = new RBIMenuItem("My Stats", null, showStatsPage);
				_mainMenu.addMenuItem(myStats);
				
				var buyTeams:RBIMenuItem = new RBIMenuItem("Buy Teams", null, showStorePage);
				_mainMenu.addMenuItem(buyTeams);
				
				var quit:RBIMenuItem = new RBIMenuItem("Quit", null, quitGame);
				_mainMenu.addMenuItem(quit);
				
				_mainMenu.highlightedMenuItem = quickPlay;
				
				addChild(_mainMenu);
			}
			
			currentMenu = _mainMenu;
		}
		
		public function showGameFinish(resultXml:XML):void
		{
			_finalScoreBody = new RBIFinalScoreBody(resultXml);
			_finalScoreBody.addEventListener("quit game", onQuitGame);
			
			headingMenu.body = _finalScoreBody;
			currentMenu = headingMenu;
		}
		
		protected function onQuitGame(event:Event):void
		{
			quitGame();
		}
		
		public function destroy():void
		{
			_mainMenu.destroy();
			_mainMenu = null;
			
			if (_statsBody)
			{
				_statsBody.destroy();
				_statsBody.removeEventListener("returnToMenu", onReturnToMenu);
				_statsBody = null;
			}
			
			if (_storeBody)
			{
				_storeBody.destroy();
				_storeBody.removeEventListener("returnToMenu", onReturnToMenu);
				_storeBody.removeEventListener(GameItemPurchaseEvent.PURCHASE_ITEM, onItemPurchase);
				_storeBody = null;
			}
			
			if (_teamSelectBody)
			{
				_teamSelectBody.destroy();
				_teamSelectBody.removeEventListener("returnToMenu", onReturnToMenu);
				_teamSelectBody.removeEventListener(StartGameEvent.START_GAME, onStartGame);
				_teamSelectBody = null;
			}
			
			if (_finalScoreBody)
			{
				_finalScoreBody.destroy();
				_finalScoreBody.removeEventListener("quit game", onQuitGame);
				_finalScoreBody = null;
			}
		}
		
		protected function showTeamSelect(numPlayers:int):void
		{
			if (_teamSelectBody == null)
			{
				_teamSelectBody = new RBITeamSelect(_controller.avatar);
				_teamSelectBody.addEventListener("returnToMenu", onReturnToMenu);
				_teamSelectBody.addEventListener(StartGameEvent.START_GAME, onStartGame);
			}
			_controller.getTeams(true);
			_teamSelectBody.numPlayers = numPlayers;
			
			backgroundMenu.body = _teamSelectBody;
			currentMenu = backgroundMenu;
		}
		
		public function showStorePage():void
		{
			if (_storeBody == null)
			{
				_storeBody = new RBIStoreBody(_controller.avatar);
				_storeBody.addEventListener("returnToMenu", onReturnToMenu);
				_storeBody.addEventListener(GameItemPurchaseEvent.PURCHASE_ITEM, onItemPurchase);
			}
			_controller.getTeams(false);
			//_controller.getStoreTeams();
			
			headingMenu.body = _storeBody;
			currentMenu = headingMenu;
		}
		
		protected function onItemPurchase(event:GameItemPurchaseEvent):void
		{
			trace(event.gameItem.name);
			_controller.purchaseItem(event.gameItem,StoreConstants.STORE_ID_RBI);
		}
		
		public function showStatsPage():void
		{
			if (_statsBody == null)
			{
				_statsBody = new RBIStatsBody(_controller.avatar);
				_statsBody.addEventListener("returnToMenu", onReturnToMenu);
				_controller.getStats();
			}
			
			headingMenu.body = _statsBody;
			LoggingUtil.sendClickLogging(LoggingUtil.RBI_STATS_PAGE);
			currentMenu = headingMenu;
		}
		
		protected function onStartGame(event:StartGameEvent):void
		{
			if (event.numPlayers == 1)
				_controller.playSinglePlayer(event.team1ItemId, event.team2ItemId);
		}
		
		protected function onReturnToMenu(event:Event):void
		{
			showMainMenu();
		}
		
		protected function playSinglePlayer():void
		{
			showTeamSelect(1);
		}
		
		protected function play2Players():void
		{
			showTeamSelect(2);
		}
		
		protected function quitGame():void
		{
			_controller.quitGame();
		}
		
		protected function get backgroundMenu():RBIBackgroundMenu
		{
			if (_backgroundMenu == null)
			{
				_backgroundMenu = new RBIBackgroundMenu(_width, _height);
				addChild(_backgroundMenu);
			}
			
			return _backgroundMenu;
		}
		
		protected function get headingMenu():RBIHeadingMenu
		{
			if (_headingMenu == null)
			{
				_headingMenu = new RBIHeadingMenu(_width, _height);
				addChild(_headingMenu);
			}
			return _headingMenu;
		}
		
		protected function set currentMenu(value:DisplayObject):void
		{
			if (_currentMenu)
				_currentMenu.visible = false;
			
			value.visible = true;
			_currentMenu = value;
		}
		
		public function set storeItems(value:Array):void
		{
			if (_storeBody)
				_storeBody.storeItems = value;
		}
		
		public function set teams(value:Array):void
		{
			if (_teamSelectBody)
				_teamSelectBody.teams = value;
		}
		
		public function set stats(value:Array):void
		{
			if (_statsBody)
				_statsBody.stats = value;
		}
		
		public function get display():DisplayObject
		{
			return this;
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function get height():Number
		{
			return _height;
		}
	}
}
