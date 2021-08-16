package com.sdg.leaderboard.list
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.good.goodui.FluidView;
	import com.sdg.controls.TabListControl;
	import com.sdg.leaderboard.model.LeaderboardTimeFrame;
	import com.sdg.leaderboard.model.LeaderboardUserSet;
	import com.sdg.leaderboard.model.TopUser;
	import com.sdg.leaderboard.model.TopUserCollection;
	import com.sdg.leaderboard.view.TopUserListView;
	import com.teso.ui.DropDown;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class LeaderboardUserListControl extends FluidView
	{
		public static const TIME_FRAME_SELECT:String = 'time frame select';
		public static const USER_SET_SELECT:String = 'user set select';
		
		public static const MAX_LOCAL_USER_RANK:uint = 1000;
		
		protected var _tabControl:TabListControl;
		protected var _back:Sprite;
		protected var _topUserList:TopUserListView;
		protected var _userSetDropDown:DropDown;
		protected var _animManager:AnimationManager;
		protected var _userListContainer:Sprite;
		protected var _selectedUserSetId:uint;
		protected var _errorField:TextField;
		protected var _selectionEnabled:Boolean;
		protected var _isInit:Boolean;
		protected var _topUsers:TopUserCollection;
		
		public function LeaderboardUserListControl(localUser:TopUser = null, topUsers:TopUserCollection = null, width:Number = 510, height:Number = 467, autoInit:Boolean = false)
		{
			_animManager = new AnimationManager();
			_selectionEnabled = true;
			_isInit = false;
			_topUsers = (topUsers != null) ? topUsers : new TopUserCollection();
			
			_back = new Sprite();
			
			var tabNames:Array = [LeaderboardTimeFrame.GetName(LeaderboardTimeFrame.WEEK), LeaderboardTimeFrame.GetName(LeaderboardTimeFrame.MONTH), LeaderboardTimeFrame.GetName(LeaderboardTimeFrame.ALL_TIME)];
			_tabControl = new TabListControl(tabNames, 24);
			
			_topUserList = new TopUserListView(0, 'Users', _topUsers.length, localUser, _topUsers, 510, 440, false);
			_topUserList.localUserMaxIndex = MAX_LOCAL_USER_RANK;
			
			// Create user set dropdown.
			var userSetArray:Array = new Array();
			userSetArray.push( {title:LeaderboardUserSet.GetName(LeaderboardUserSet.FRIENDS), name:LeaderboardUserSet.GetName(LeaderboardUserSet.FRIENDS)} );
			userSetArray.push( {title:LeaderboardUserSet.GetName(LeaderboardUserSet.TEAM), name:LeaderboardUserSet.GetName(LeaderboardUserSet.TEAM)} );
			userSetArray.push( {title:LeaderboardUserSet.GetName(LeaderboardUserSet.WORLD), name:LeaderboardUserSet.GetName(LeaderboardUserSet.WORLD)} );
			var dropFmat:TextFormat = new TextFormat('Arial', 14, 0xffffff, true);
			_userSetDropDown = new DropDown(140, 23, " Users: ", dropFmat, 0x285890, userSetArray, "down", onUserSetSelect);
			_userSetDropDown.selectOptionByName(LeaderboardUserSet.GetName(LeaderboardUserSet.FRIENDS));
			
			_selectedUserSetId = LeaderboardUserSet.FRIENDS;
			
			_userListContainer = new Sprite();
			
			_errorField = new TextField();
			_errorField.defaultTextFormat = new TextFormat('Arial', 28, 0xffffff, true, null, null, null, null, TextFormatAlign.CENTER);
			_errorField.autoSize = TextFieldAutoSize.CENTER;
			_errorField.selectable = false;
			_errorField.multiline = true;
			_errorField.wordWrap = true;
			_errorField.text = 'There was an error.';
			_errorField.visible = false;
			
			// Add displays.
			addChild(_back);
			addChild(_tabControl);
			addChild(_userListContainer);
			_userListContainer.addChild(_topUserList);
			addChild(_userSetDropDown);
			addChild(_errorField);
			
			super(width, height);
			
			render();
			
			if (autoInit == true) init();
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function init():void
		{
			// Make sure we only init once.
			if (_isInit == true) return;
			_isInit = true;
			
			_topUserList.init();
			
			_tabControl.addEventListener(TabListControl.TAB_SELECT, onTabSelect);
		}
		
		public function destroy():void
		{
			_tabControl.removeEventListener(TabListControl.TAB_SELECT, onTabSelect);
			
			_tabControl.destroy();
			_topUserList.destroy();
			_userSetDropDown = null;
			_animManager.dispose();
		}
		
		public function setListData(localUser:TopUser, topUsers:TopUserCollection, listName:String = 'Users'):void
		{
			// Make sure error message is hidden.
			_errorField.visible = false;
			
			// Create new top user list.
			var newListView:TopUserListView = new TopUserListView(0, listName, topUsers.length, localUser, topUsers, 510, 440, false);
			newListView.localUserMaxIndex = MAX_LOCAL_USER_RANK;
			
			// Swap out the old one.
			var oldListView:TopUserListView = _topUserList;
			_animManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animManager.move(oldListView, oldListView.x - oldListView.width, oldListView.y, 1000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			_animManager.alpha(oldListView, 0, 1000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			
			function onAnimFinish(e:AnimationEvent):void
			{
				if (e.animTarget == oldListView)
				{
					// Remove event listener.
					_animManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					
					// Remove old list ivew.
					_userListContainer.removeChild(oldListView);
					oldListView.destroy();
					
					// Add new list view.
					addNewListView();
				}
			}
			
			function addNewListView():void
			{
				_topUserList = newListView;
				_topUserList.x = _topUserList.width;
				_topUserList.y = _tabControl.height;
				_topUserList.alpha = 0;
				_userListContainer.addChild(_topUserList);
				_topUserList.init();
				
				_animManager.move(_topUserList, 0, _topUserList.y, 1000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
				_animManager.alpha(_topUserList, 1, 1000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			}
		}
		
		public function showError(message:String = 'There was an error.'):void
		{
			// Swap out the old list view.
			var oldListView:TopUserListView = _topUserList;
			_animManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animManager.move(oldListView, oldListView.x - oldListView.width, oldListView.y, 1000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			
			function onAnimFinish(e:AnimationEvent):void
			{
				if (e.animTarget == oldListView)
				{
					// Remove event listener.
					_animManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					
					// Show the error message.
					_errorField.visible = true;
				}
			}
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			var tabH:Number = _tabControl.tabHeight;
			
			_back.graphics.clear();
			_back.graphics.beginFill(0, 0.8);
			_back.graphics.drawRect(0, tabH, _width, _height - tabH);
			
			_topUserList.width = _width;
			_topUserList.height = _height - tabH;
			_topUserList.y = tabH
			
			_userSetDropDown.x = _width - _userSetDropDown.width;
			//_userSetDropDown.y = tabH - _userSetDropDown.height;
			
			_errorField.width = _width;
			_errorField.x = _width / 2 - _errorField.width / 2;
			_errorField.y = _height / 2 - _errorField.height / 2;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get selectedTimeFrameId():uint
		{
			return LeaderboardTimeFrame.GetId(_tabControl.selectedValue);
		}
		
		public function get selectedUserSetId():uint
		{
			return _selectedUserSetId;
		}
		
		public function get selectionEnabled():Boolean
		{
			return _selectionEnabled;
		}
		public function set selectionEnabled(value:Boolean):void
		{
			_selectionEnabled = value;
			_tabControl.mouseEnabled = _tabControl.mouseChildren = value;
			_userSetDropDown.mouseEnabled = _userSetDropDown.mouseChildren = value;
		}
		
		public function get listName():String
		{
			return _topUserList.name;
		}
		public function set listName(value:String):void
		{
			_topUserList.name = value;
		}
		
		public function getUserSetVisibility():Boolean
		{
			return _userSetDropDown.visible;
		}
		
		public function setUserSetVisibility(value:Boolean):void
		{
			_userSetDropDown.visible = value;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onUserSetSelect(e:Event):void
		{
			_selectedUserSetId = LeaderboardUserSet.GetId(e.currentTarget.name);
			
			// Dispatch a user set select event.
			dispatchEvent(new Event(USER_SET_SELECT));
		}
		
		private function onTabSelect(e:Event):void
		{
			// Dispatch a time frame select event.
			dispatchEvent(new Event(TIME_FRAME_SELECT));
		}
		
	}
}