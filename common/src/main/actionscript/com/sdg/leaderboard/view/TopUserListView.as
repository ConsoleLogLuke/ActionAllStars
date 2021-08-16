package com.sdg.leaderboard.view
{
	import com.good.goodui.FluidView;
	import com.sdg.events.UserTitleBlockEvent;
	import com.sdg.leaderboard.model.TopUser;
	import com.sdg.leaderboard.model.TopUserCollection;
	import com.sdg.model.DisplayObjectCollection;
	import com.sdg.model.IIdObject;
	import com.sdg.model.IInitable;
	import com.sdg.view.VerticalListWindow;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TopUserListView extends FluidView implements IIdObject
	{
		protected var _id:uint;
		protected var _name:String;
		protected var _limit:uint;
		protected var _localUser:TopUser;
		protected var _topUsers:TopUserCollection;
		protected var _selectedIndex:int;
		protected var _glow:GlowFilter;
		protected var _items:Array;
		
		protected var _back:Sprite;
		protected var _titleField:TextField;
		protected var _listWindow:VerticalListWindow;
		protected var _localUserBlock:Sprite;
		protected var _isInit:Boolean;
		protected var _localUserMaxIndex:uint;
		
		public function TopUserListView(id:uint, name:String, limit:uint, localUser:TopUser, topUsers:TopUserCollection, width:Number, height:Number, autoInit:Boolean = false)
		{
			_id = id;
			_name = name;
			_limit = limit;
			_localUser = localUser;
			_topUsers = topUsers;
			_glow = new GlowFilter(0xffffff);
			_items = [];
			_selectedIndex = -1;
			_isInit = false;
			_localUserMaxIndex = 0;
			
			_back = new Sprite();
			
			_titleField = new TextField();
			_titleField.defaultTextFormat = new TextFormat('Arial', 22, 0xffffff, true);
			_titleField.autoSize = TextFieldAutoSize.LEFT;
			_titleField.selectable = false;
			_titleField.text = 'Top ' + _limit.toString() + ': ' + _name;
			
			if (localUser != null)
			{
				var userBlock:LeaderboardUserBlock = new LeaderboardUserBlock(localUser.id, localUser.name, localUser.level, localUser.points, localUser.teamId, localUser.teamName, localUser.color1, localUser.color2, 287, 54);
				userBlock.useTurfButton = false;
				userBlock.font = 'EuroStyle';
				userBlock.embedFonts = true;
				_localUserBlock = new IndexedUserTitleBlock(width - 50, 54, localUser.place, userBlock);
			}
			else
			{
				_localUserBlock = new Sprite();
				_localUserBlock.graphics.beginFill(0, 0);
				_localUserBlock.graphics.drawRect(0, 0, width - 50, 54);
			}
			
			// Create item list window.
			_listWindow = new VerticalListWindow(width - 20, height - _titleField.height - _localUserBlock.height - 50, 5, 0, 10, 0, 0, 6);
			
			// Add displays.
			addChild(_back);
			addChild(_listWindow);
			addChild(_titleField);
			addChild(_localUserBlock);
			
			super(width, height);
			
			render();
			
			if (autoInit == true) init();
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		public function init():void
		{
			// Make sure we only init once.
			if (_isInit == true) return;
			_isInit = true;
			
			// Create user blocks.
			var i:uint = 0;
			var len:uint = _topUsers.length;
			var items:DisplayObjectCollection = new DisplayObjectCollection();
			for (i; i < len; i++)
			{
				var topUser:TopUser = _topUsers.getAt(i);
				var userTitle:LeaderboardUserBlock = new LeaderboardUserBlock(topUser.id, topUser.name, topUser.level, topUser.points, topUser.teamId, topUser.teamName, topUser.color1, topUser.color2, 287, 54, false);
				userTitle.font = 'EuroStyle';
				userTitle.embedFonts = true;
				userTitle.buttonMode = true;
				userTitle.addEventListener(MouseEvent.CLICK, onUserBlockClick);
				var block:IndexedUserTitleBlock = new IndexedUserTitleBlock(287, 54, i + 1, userTitle);
				
				_items.push(userTitle);
				items.push(block);
				
				// Add to item list window.
				_listWindow.addItem(block);
			}
			
			selectedIndex = 0;
		}
		
		public function destroy():void
		{
			// Remove displays.
			removeChild(_back);
			removeChild(_listWindow);
			removeChild(_titleField);
			removeChild(_localUserBlock);
			
			// Destroy children.
			_listWindow.destroy();
			// Destroy items.
			for each (var item:EventDispatcher in _items)
			{
				item.removeEventListener(MouseEvent.CLICK, onUserBlockClick);
				var initableItem:IInitable = item as IInitable;
				if (initableItem != null) initableItem.destroy();
			}
			
			// Destroy references to help garbage collection.
			_items = null;
			_topUsers = null;
			_back = null;
			_listWindow = null;
			_titleField = null;
			_localUserBlock = null;
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			_titleField.x = 10;
			_titleField.y = 5;
			
			_listWindow.x = 10;
			_listWindow.y = _titleField.y + _titleField.height + 10;
			_listWindow.setSize(_width - 20, _height - _titleField.height - _localUserBlock.height - 50);
			
			_localUserBlock.x = 10;
			_localUserBlock.y = _listWindow.y + _listWindow.height + 20;
			
			_back.graphics.clear();
			_back.graphics.beginFill(0, 0);
			_back.graphics.drawRect(0, 0, _width, _height);
			_back.graphics.endFill();
			var lineY:Number = _listWindow.y + _listWindow.height + 10;
			_back.graphics.lineStyle(4, 0x555555);
			_back.graphics.moveTo(10, lineY);
			_back.graphics.lineTo(_width - 10, lineY);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get id():uint
		{
			return _id;
		}
		
		override public function get name():String
		{
			return _name;
		}
		override public function set name(value:String):void
		{
			_name = value;
			_titleField.text = 'Top ' + _limit.toString() + ': ' + _name;
		}
		
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
			var newItem:DisplayObject = _items[_selectedIndex] as DisplayObject;
			if (newItem != null) newItem.filters = [_glow];
			
			// Get reference to top user.
			var selectedUser:TopUser = _topUsers.getAt(_selectedIndex);
			
			// Dispatch a user select event.
			if (selectedUser != null) dispatchEvent(new UserTitleBlockEvent(UserTitleBlockEvent.USER_SELECT, selectedUser.id, selectedUser.name, selectedUser.teamId, true));
		}
		
		public function get localUserMaxIndex():uint
		{
			return _localUserMaxIndex;
		}
		public function set localUserMaxIndex(value:uint):void
		{
			if (value == _localUserMaxIndex) return;
			_localUserMaxIndex = value;
			
			var localUserBlock:IndexedUserTitleBlock = _localUserBlock as IndexedUserTitleBlock;
			if (localUserBlock != null) localUserBlock.maxIndex = _localUserMaxIndex;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onUserBlockClick(e:MouseEvent):void
		{
			// Determine index.
			var index:uint = _items.indexOf(e.currentTarget);
			
			// Set selected index.
			selectedIndex = index;
		}
		
	}
}