package com.sdg.leaderboard.view
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.good.goodui.FluidView;
	import com.sdg.events.GridItemEvent;
	import com.sdg.leaderboard.model.TopUser;
	import com.sdg.leaderboard.model.TopUserCollection;
	import com.sdg.model.DisplayObjectCollection;
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;
	import com.sdg.util.ServerFeedUtil;
	import com.sdg.view.ItemListWindow;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class AllStarHallView extends FluidView
	{
		protected static const _BACKGROUND_URL:String = AssetUtil.GetGameAssetUrl(74, 'all_star_hall_background.swf');
		
		protected var _back:Sprite;
		protected var _userCard:Sprite;
		protected var _listCardContainer:Sprite;
		protected var _isInit:Boolean;
		protected var _allStars:TopUserCollection;
		protected var _listWindow:ItemListWindow;
		protected var _listBack:Sprite;
		protected var _selectedIndex:int;
		protected var _glow:GlowFilter;
		protected var _items:Array;
		protected var _animManager:AnimationManager;
		protected var _dropShadow:DropShadowFilter;
		protected var _cardArea:Rectangle;
		
		public function AllStarHallView(width:Number, height:Number, autoInit:Boolean = false)
		{
			_isInit = false;
			_glow = new GlowFilter(0xffffff);
			_items = [];
			_selectedIndex = -1;
			_animManager = new AnimationManager();
			_dropShadow = new DropShadowFilter(2, 45, 0, 0.7, 10, 10);
			_cardArea = new Rectangle();
			
			_back = new Sprite();
			
			_listBack = new Sprite();
			_listBack.graphics.beginFill(0, 0.8);
			_listBack.graphics.drawRect(0, 0, 10, 10);
			_listBack.filters = [_dropShadow];
			
			_listCardContainer = new Sprite();
			_listCardContainer.filters = [_dropShadow];
			
			super(width, height);
			
			if (autoInit) init();
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function init():void
		{
			if (_isInit == true) return;
			_isInit = true;
			
			_back = new QuickLoader(_BACKGROUND_URL, render);
			
			_userCard = new Sprite();
			_userCard.graphics.beginFill(0, 0);
			_userCard.graphics.drawRect(0, 0, 10, 10);
			
			_listWindow = new ItemListWindow(width / 2, height, 1, 100, 6);
			_listWindow.widthHeightRatio = 6.3 / 1;
			_listWindow.addEventListener(GridItemEvent.INTO_VISIBILITY, onItemIntoVisibility);
			
			addChild(_back);
			addChild(_listCardContainer);
			_listCardContainer.addChild(_listBack);
			_listCardContainer.addChild(_listWindow);
			_listCardContainer.addChild(_userCard);
			
			loadAllStars();
		}
		
		public function destroy():void
		{
			_animManager.dispose();
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		override protected function render():void
		{
			_back.x = _width / 2 - _back.width / 2;
			_back.y = _height / 2 - _back.height / 2;
			
			var goldPlateArea:Rectangle = new Rectangle(_back.x + 5, _back.y + 58, 737, 405);
			var marginX:Number = 40;
			var marginY:Number = 16;
			var w:Number = goldPlateArea.width - marginX * 2;
			var h:Number = goldPlateArea.height - marginY * 2;
			
			_listBack.width = 376;
			_listBack.height = h;
			
			if (_listWindow)
			{
				_listWindow.width = _listBack.width - 20;
				_listWindow.height = _listBack.height - 30;
				_listWindow.x = _listWindow.y = 10;
			}
			
			_cardArea.width = w - _listBack.width - 20;
			_cardArea.height = h;
			_cardArea.x = _listBack.x + _listBack.width + 20 + _cardArea.width / 2;
			_cardArea.y = _cardArea.height / 2;
			
			if (_userCard)
			{
				_userCard.width = _cardArea.x;
				_userCard.height = _cardArea.height;
				_userCard.x = _cardArea.x;
				_userCard.y = _cardArea.y;
			}
			
			_listCardContainer.x = goldPlateArea.x + marginX;
			_listCardContainer.y = goldPlateArea.y + marginY;
		}
		
		protected function loadAllStars():void
		{
			var url:String = ServerFeedUtil.AllStarHallUserList();
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Parse xml.
				var allStarUsersXml:XML = new XML(loader.data);
				
				// Parse users.
				var allStars:TopUserCollection = parseTopUsers(allStarUsersXml.topUserPointsList.users);
				
				// Create user blocks.
				var i:uint = 0;
				var len:uint = allStars.length;
				var items:DisplayObjectCollection = new DisplayObjectCollection();
				for (i; i < len; i++)
				{
					var topUser:TopUser = allStars.getAt(i);
					var userTitle:LeaderboardUserBlock = new LeaderboardUserBlock(topUser.id, topUser.name, topUser.level, topUser.points, topUser.teamId, topUser.teamName, topUser.color1, topUser.color2, 287, 54, false);
					userTitle.usePoints = false;
					userTitle.cacheAsBitmap = true;
					userTitle.buttonMode = true;
					userTitle.font = 'EuroStyle';
					userTitle.embedFonts = true;
					userTitle.addEventListener(MouseEvent.CLICK, onItemClick);
					
					items.push(userTitle);
				}
				
				render();
				
				_items = items.toArray();
				_listWindow.items = items;
				selectedIndex = 0;
			}
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.removeEventListener(Event.COMPLETE, onComplete);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		protected function parseTopUsers(userList:XMLList):TopUserCollection
		{
			var i:uint = 0;
			var topUsers:TopUserCollection = new TopUserCollection();
			while (userList.u[i] != null)
			{
				var user:XML = userList.u[i];
				var topUser:TopUser = parseTopUser(user);
				topUsers.push(topUser);
				
				i++;
			}
			
			return topUsers;
		}
		
		protected function parseTopUser(user:XML):TopUser
		{
			var id:uint = (user.@id != null) ? user.@id : 0;
			var place:uint = (user.@place != null) ? user.@place : int.MAX_VALUE;
			var name:String = (user.n != null) ? user.n : '';
			var points:int = (user.pts != null) ? user.pts : 0;
			var level:uint = (user.l > 0) ? user.l : 1;
			var teamId:uint = (user.team.@id != null) ? user.team.@id : 1;
			var teamName:String = 'Team Name';
			var color1:uint = parseInt('0x' + user.team.c[0]);
			var color2:uint = parseInt('0x' + user.team.c[1]);
			
			var topUser:TopUser = new TopUser(id, name, place, level, points, teamId, teamName, color1, color2);
			
			return topUser;
		}
		
		protected function getCardUrl(avatarId:uint):String
		{
			return AssetUtil.GetGameAssetUrl(74, 'all_star_card_' + avatarId.toString() + '.swf');
		}
		
		protected function swapCard(avatarId:uint):void
		{
			// Load new card.
			var url:String = getCardUrl(avatarId);
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onError(e:IOErrorEvent):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			}
			
			function onComplete(e:Event):void
			{
				// Remove event listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				
				// Swap out old card.
				var oldCard:Sprite = _userCard;
				var newCard:Sprite = new Sprite();
				var cardCopy:Sprite = getBitmapCopy(loader.content);
				cardCopy.x = -cardCopy.width / 2;
				cardCopy.y = -cardCopy.height / 2;
				newCard.addChild(cardCopy);
				var scale:Number = _cardArea.height / newCard.height;
				newCard.width *= scale;
				newCard.height *= scale;
				newCard.x = _cardArea.x;
				newCard.y = _cardArea.y;
				newCard.alpha = 0;
				_userCard = newCard;
				_listCardContainer.addChild(newCard);
				_animManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
				_animManager.rotation(oldCard, oldCard.rotation + 360, 1000, 1, Transitions.ELASTIC_OUT, RenderMethod.ENTER_FRAME);
				_animManager.rotation(newCard, newCard.rotation + 360, 1000, 1, Transitions.ELASTIC_OUT, RenderMethod.ENTER_FRAME);
				_animManager.alpha(newCard, 1, 400, Transitions.CUBIC_IN, RenderMethod.ENTER_FRAME);
				
				function onAnimFinish(e:AnimationEvent):void
				{
					if (e.animTarget == oldCard)
					{
						// Remove event listener.
						_animManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
						
						// Remove old card.
						_listCardContainer.removeChild(oldCard);
					}
				}
			}
		}
		
		protected function getBitmapCopy(original:DisplayObject):Sprite
		{
			var bitmapData:BitmapData = new BitmapData(original.width, original.height, false, 0);
			bitmapData.draw(original);
			var bitmap:Bitmap = new Bitmap(bitmapData, 'auto', true);
			var copy:Sprite = new Sprite();
			copy.addChild(bitmap);
			
			return copy;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		public function set selectedIndex(value:int):void
		{
			if (value == _selectedIndex) return;
			
			// Remove styling from previously selected item.
			var oldItem:DisplayObject = _items[_selectedIndex] as DisplayObject;
			if (oldItem != null) oldItem.filters = [];
			
			// Set new index.
			_selectedIndex = value;
			
			// Style new selected item.
			var newItem:DisplayObject = _items[_selectedIndex];
			newItem.filters = [_glow];
			
			// Swap card.
			swapCard(LeaderboardUserBlock(_items[_selectedIndex]).id);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onItemIntoVisibility(e:GridItemEvent):void
		{
			LeaderboardUserBlock(e.display).init();
		}
		
		private function onItemClick(e:MouseEvent):void
		{
			// Determine index.
			var index:uint = _items.indexOf(e.currentTarget);
			
			// Set selected index.
			selectedIndex = index;
		}
		
	}
}