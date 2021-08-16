package com.sdg.view.pda
{
	import com.sdg.components.controls.VerticalScrollBar;
	import com.sdg.control.PDAController;
	import com.sdg.control.ScrollWindowController;
	import com.sdg.model.AvatarAchievement;
	import com.sdg.model.AvatarAchievementCollection;
	import com.sdg.model.QuestListItemFormat;
	import com.sdg.quest.QuestManager;
	import com.sdg.view.pda.interfaces.IPDAMainPanel;
	import com.sdg.view.pda.interfaces.IPDASidePanel;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class QuestApplication extends Sprite implements IPDAMainPanel
	{
		public static const LIST_ITEM_SELECT:String = 'list item select';
		
		protected var _width:Number;
		protected var _height:Number;
		protected var _panelSplit:Number;
		protected var _panelName:String;
		protected var _listWindow:Sprite;
		protected var _scrollBarWidth:Number;
		protected var _backing:Sprite;
		protected var _listItems:Array;
		protected var _questListStack:Sprite;
		protected var _listScrollBar:VerticalScrollBar;
		protected var _quedQuest:AvatarAchievement;
		protected var _questSummaryPanel:QuestSummaryPanel;
		protected var _questManager:QuestManager;
		protected var _activeQuests:AvatarAchievementCollection;
		protected var _quedListIndex:int;
		protected var _noQuestsMessage:TextField;
		protected var _defaultListItemFormatA:QuestListItemFormat;
		protected var _defaultListItemFormatB:QuestListItemFormat;
		protected var _quedListItemFormat:QuestListItemFormat;
		protected var _rollOverListItemFormat:QuestListItemFormat;
		protected var _isInitialized:Boolean;
		
		public function QuestApplication()
		{
			super();
			
			// Set default values.
			_width = 280;
			_height = 300;
			_panelName = 'Missions';
			_panelSplit = 0.4;
			_scrollBarWidth = 18;
			_listItems = [];
			_questManager = QuestManager.getInstance();
			_activeQuests = QuestManager.activeUserQuests;
			_quedListIndex = -1;
			_defaultListItemFormatA = new QuestListItemFormat(0x03203E, new TextFormat('GillSans', 16, 0x4EA0CF, false));
			_defaultListItemFormatB = new QuestListItemFormat(0x021427, _defaultListItemFormatA.titleFormat);
			_rollOverListItemFormat = new QuestListItemFormat(0x0069b7, new TextFormat('GillSans', 16, 0xffffff, false));
			_quedListItemFormat = new QuestListItemFormat(0x1079c7, new TextFormat('GillSans', 16, 0xffffff, true));
			_isInitialized = false;
			
			// Listen for updates on the quest manager.
			_questManager.addEventListener(QuestManager.ACTIVE_QUESTS_UPDATE, onActiveQuestsUpdate);
			
			// Create backing.
			_backing = new Sprite();
			addChild(_backing);
			
			// Create a window.
			_listWindow = new Sprite();
			_listWindow.graphics.beginFill(0x00ff00);
			_listWindow.graphics.drawRect(0, 0, _width, _height * _panelSplit);
			addChild(_listWindow);
			
			// Create a stack of quest list items.
			_questListStack = new Sprite();
			_questListStack.mask = _listWindow;
			addChild(_questListStack);
			
			// Create a new vertical scroll bar.
			_listScrollBar = new VerticalScrollBar();
			_listScrollBar.scrollButton1 = new ArrowButtonUp();
			_listScrollBar.scrollButton2 = new ArrowButtonDown();
			_listScrollBar.scrollBarBacking = new ScrollBacking();
			_listScrollBar.scrollBarGrabber = new ScrollBarGrabber();
			_listScrollBar.width = _scrollBarWidth;
			_listScrollBar.height = _height * _panelSplit;
			_listScrollBar.x = _width - _scrollBarWidth;
			addChild(_listScrollBar);
			
			// Create window controller.
			var windowController:ScrollWindowController = new ScrollWindowController();
			windowController.content = _questListStack;
			windowController.window = _listWindow;
			windowController.vScrollBar = _listScrollBar;
			
			// Create a no quests message.
			// This is displayed when the user has no quests.
			_noQuestsMessage = new TextField();
			_noQuestsMessage.defaultTextFormat = new TextFormat('GillSans', 24, 0xffffff, true, null, null, null, null, TextFormatAlign.CENTER);
			_noQuestsMessage.multiline = _noQuestsMessage.wordWrap = true;
			_noQuestsMessage.text = 'You do not have any quests yet.';
			_noQuestsMessage.embedFonts = true;
			_noQuestsMessage.visible = false;
			addChild(_noQuestsMessage);
			
			render();
			
			buildList();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function init(controller:PDAController = null):void
		{
			
		}
		
		public function close():void
		{
			// Handle cleanup.
			
			// Remove event listeners.
			_questManager.removeEventListener(QuestManager.ACTIVE_QUESTS_UPDATE, onActiveQuestsUpdate);
		}
		
		public function refresh():void
		{
			
		}
		
		protected function render():void
		{
			// Create local.
			var topPanelHeight:Number = _height * _panelSplit;
			var panelDevideWidth:Number = 6;
			var hasQuests:Boolean = (_listItems.length > 0);
			
			// Draw backing.
			_backing.graphics.clear();
			//_backing.graphics.beginFill(0);
			//_backing.graphics.drawRect(0, 0, _width, _height);
			//_backing.graphics.endFill();
			if (hasQuests == true)
			{
				_backing.graphics.beginFill(0x333333);
				_backing.graphics.drawRect(0, topPanelHeight, _width, panelDevideWidth);
			}
			
			// List window.
			_listWindow.graphics.clear();
			_listWindow.graphics.beginFill(0x00ff00);
			_listWindow.graphics.drawRect(0, 0, _width, topPanelHeight);
			
			// List items.
			var i:int = 0;
			var len:int = _listItems.length;
			var listItem:DisplayObject;
			for (i; i < len; i++)
			{
				listItem = _listItems[i] as DisplayObject;
				if (listItem == null) continue;
				
				listItem.width = _width - _scrollBarWidth;
			}
			
			// Scroll bar.
			_listScrollBar.height = topPanelHeight;
			_listScrollBar.x = _width - _scrollBarWidth;
			_listScrollBar.visible = hasQuests;
			
			// Quest summary panel.
			if (_questSummaryPanel != null)
			{
				_questSummaryPanel.x = 0;
				_questSummaryPanel.y = topPanelHeight + panelDevideWidth;
				_questSummaryPanel.width = _width;
				_questSummaryPanel.height = _height - topPanelHeight - panelDevideWidth;
			}
			
			// No quests message.
			if (hasQuests == true)
			{
				_noQuestsMessage.visible = false;
			}
			else
			{
				_noQuestsMessage.x = 10;
				_noQuestsMessage.y = 10;
				_noQuestsMessage.width = _width - 20;
				_noQuestsMessage.height = _height - 20;
				_noQuestsMessage.visible = true;
			}
		}
		
		protected function buildList():void
		{
			// Get locals.
			var quests:AvatarAchievementCollection = _activeQuests;
			if (quests == null) return;
			
			// Sort list by newest first.
			quests.sort(sortNewest);
			
			// Clear current list.
			clearList();
			
			// Build new list.
			var i:int = 0;
			var len:int = quests.length;
			var quest:AvatarAchievement;
			var listItem:QuestListItem;
			var format:TextFormat = new TextFormat('GillSans', 14, 0x4EA0CF);
			var listItems:Array = [];
			for (i; i < len; i++)
			{
				quest = quests.getAt(i);
				if (quest == null) continue;
				
				// If the priority is 2, don't show it in the quest app.
				if (quest.priority == '2') continue;
				
				// Create new list item.
				var isComplete:Boolean = (quest.status == AvatarAchievement.COMPLETED) ? true : false;
				var isMandatory:Boolean = (quest.priority == AvatarAchievement.MANDATORY) ? true : false;
				listItem = new QuestListItem(quest.id, quest.name, isComplete, isMandatory);
				listItems.push(listItem);
				var listItemsLength:uint = listItems.length;
				listItem.backingColor = (listItemsLength % 2 > 0) ? _defaultListItemFormatA.backingColor : _defaultListItemFormatB.backingColor;
				listItem.width = _width - _scrollBarWidth;
				listItem.height = 32;
				listItem.y = Math.floor(listItem.height * (listItemsLength - 1));
				listItem.titleFormat = (i % 2 > 0) ? _defaultListItemFormatA.titleFormat : _defaultListItemFormatB.titleFormat;
				listItem.embedFonts = true;
				listItem.buttonMode = true;
				listItem.addEventListener(MouseEvent.MOUSE_OVER, onListItemOver);
				_listItems.push(listItem);
				_questListStack.addChild(listItem);
			}
			
			_listScrollBar.contentSize = _questListStack.height;
			
			render();
			
			// If there is atleast 1 list item and there is not already a selected list item.
			// Default to select the first.
			if (_listItems.length > 0)
			{
				if (_quedListIndex < 0)
				{
					// Currently, there is not a qued list item.
					// Default to que the first one.
					queListItem(0);
				}
				else
				{
					// Re-que the previously qued list item.
					queListItem(_quedListIndex);
				}
			}
			
			function sortNewest(a:AvatarAchievement, b:AvatarAchievement):int
			{
				if (a.startDate == null || b.startDate == null)
				{
					return 0;
				}
				else if (a.startDate.time < b.startDate.time)
				{
					return 1;
				}
				else if (a.startDate.time > b.startDate.time)
				{
					return -1;
				}
				else
				{
					return 0;
				}
			}
		}
		
		protected function clearList():void
		{
			var i:int = 0;
			var len:int = _listItems.length;
			var listItem:DisplayObject;
			for (i; i < len; i++)
			{
				listItem = _listItems[i] as DisplayObject;
				if (listItem == null) continue;
				
				listItem.removeEventListener(MouseEvent.MOUSE_OVER, onListItemOver);
				_questListStack.removeChild(listItem);
			}
			
			_listItems = [];
		}
		
		private function queQuest(quest:AvatarAchievement):void
		{
			// Set new quest.
			if (quest == _quedQuest) return;
			_quedQuest = quest;
			
			// Remove the current quest summary panel.
			if (_questSummaryPanel != null)
			{
				if (contains(_questSummaryPanel) == true) removeChild(_questSummaryPanel);
				_questSummaryPanel.destroy();
			}
			
			// Create new quest summary panel.
			_questSummaryPanel = new QuestSummaryPanel(_quedQuest, _width, _height * (1 - _panelSplit));
			addChild(_questSummaryPanel);
			
			render();
		}
		
		private function queListItem(index:int):Boolean
		{
			// Returns true if a new list item is successfuly qued.
			
			if (index == _quedListIndex) return false;
			
			// Get a reference to the list item.
			var listItem:QuestListItem = _listItems[index] as QuestListItem;
			if (listItem == null) return false;
			
			// Return the previously qued list item to the default formatting.
			var previousListItem:QuestListItem = _listItems[_quedListIndex] as QuestListItem;
			if (previousListItem != null)
			{
				previousListItem.backingColor = (_quedListIndex % 2 > 0) ? _defaultListItemFormatA.backingColor : _defaultListItemFormatB.backingColor;
				previousListItem.titleFormat = (_quedListIndex % 2 > 0) ? _defaultListItemFormatA.titleFormat : _defaultListItemFormatB.titleFormat;
			}
			
			// Set new value.
			_quedListIndex = index;
			
			// Change the backing color and title format of the list item.
			listItem.backingColor = _quedListItemFormat.backingColor;
			listItem.titleFormat = _quedListItemFormat.titleFormat;
			
			// Que a quest.
			var quest:AvatarAchievement = _activeQuests.getFromId(listItem.questId);
			queQuest(quest);
			
			return true;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get sidePanel():IPDASidePanel
		{
			return null;
		}
		
		public function get panelName():String
		{
			return _panelName;
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function set width(value:Number):void
		{
			if (value == _width) return;
			_width = value;
			render();
		}
		
		override public function get height():Number
		{
			return _height;
		}
		
		override public function set height(value:Number):void
		{
			if (value == _height) return;
			_height = value;
			render();
		}
		
		public function get isInitialized():Boolean
		{
			return _isInitialized;
		}
		
		public function set controller(value:PDAController):void
		{
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onListItemOver(e:MouseEvent):void
		{
			// Get a reference to the quest list item.
			var listItem:QuestListItem;
			listItem = e.currentTarget as QuestListItem;
			if (listItem == null) return;
			
			// Determine the index of the list item within all list items.
			var index:int = _listItems.indexOf(listItem);
			if (index < 0) return;
			
			// Get a reference to active quests.
			var quests:AvatarAchievementCollection = _activeQuests;
			
			// Listen for mouse out.
			listItem.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			// Listen for mouse down.
			listItem.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			// If this list item is not the qued list item,
			// Format the list item.
			if (index != _quedListIndex)
			{
				// Format the list item.
				listItem.backingColor = _rollOverListItemFormat.backingColor;
				listItem.titleFormat = _rollOverListItemFormat.titleFormat;
			}
			
			function onMouseOut(e:MouseEvent):void
			{
				// Remove listeners.
				listItem.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				listItem.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				
				// If this list item is not the qued list item,
				// Return it to original formatting.
				if (index != _quedListIndex)
				{
					// Return to original formatting.
					listItem.backingColor = (index % 2 > 0) ? _defaultListItemFormatA.backingColor : _defaultListItemFormatB.backingColor;
					listItem.titleFormat = (index % 2 > 0) ? _defaultListItemFormatA.titleFormat : _defaultListItemFormatB.titleFormat;
				}
			}
			
			function onMouseDown(e:MouseEvent):void
			{
				// Remove listeners.
				listItem.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				listItem.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				
				// Que the list item.
				var successfulQue:Boolean = queListItem(index);
			}
		}
		
		private function onActiveQuestsUpdate(e:Event):void
		{
			// The active quests have updated.
			// Update our reference.
			_activeQuests = QuestManager.activeUserQuests;
			
			// Rebuild the quest list.
			buildList();
		}
		
	}
}