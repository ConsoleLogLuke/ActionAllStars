package com.sdg.gameMenus
{
	import com.sdg.net.QuickLoader;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	public class RBIMainMenu extends Sprite implements IGameMainMenu
	{
		protected var _menuItemArray:Array;
		protected var _width:Number;
		protected var _height:Number;
		protected var _margin:Number;
		protected var _rowHeight:Number;
		protected var _highlightedMenuItem:RBIMenuItem;
		protected var _baseballIcon:DisplayObject;

		protected const DEFAULT_TEXT_COLOR:uint = 0x5F708A;
		protected const highlightED_TEXT_COLOR:uint = 0xffffff;

		public function RBIMainMenu(width:Number, height:Number, margin:Number, rowHeight:Number)
		{
			super();
			_width = width;
			_height = height;
			_margin = margin;
			_rowHeight = rowHeight;
			_menuItemArray = new Array();

			addChild(new QuickLoader("swfs/rbi/MainMenuBG.swf"));

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		public function addMenuItem(menuItem:IGameMenuItem):void
		{
			addChild(DisplayObject(menuItem));
			var arrayLength:uint = _menuItemArray.push(menuItem);
			menuItem.x = _width/2 - menuItem.width/2;
			menuItem.y = _margin + (_rowHeight * (arrayLength - 1));

			menuItem.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			menuItem.addEventListener(MouseEvent.CLICK, onClick);
		}

		public function destroy():void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			for each (var menuItem:IGameMenuItem in _menuItemArray)
			{
				menuItem.destroy();
				menuItem.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				menuItem.removeEventListener(MouseEvent.CLICK, onClick);
			}
		}

		protected function selectMenuItem(menuItem:IGameMenuItem):void
		{
			menuItem.onSelected();
		}

		protected function onClick(event:MouseEvent):void
		{
			selectMenuItem(event.currentTarget as IGameMenuItem);
		}

		protected function onMouseOver(event:MouseEvent):void
		{
			highlightedMenuItem = event.currentTarget as IGameMenuItem;
		}

		protected function onKeyDown(event:KeyboardEvent):void
		{
			if (_highlightedMenuItem == null) return;

			var index:int = _menuItemArray.indexOf(_highlightedMenuItem);
			if (index == -1) return;

			if (event.keyCode == Keyboard.ENTER)
			{
				selectMenuItem(_menuItemArray[index]);
			}
			if (event.keyCode == Keyboard.UP)
			{
				index--;
				if (index < 0)
					index = _menuItemArray.length - 1;
			}
			else if (event.keyCode == Keyboard.DOWN)
			{
				index++;
			}
			index = index % _menuItemArray.length;
			highlightedMenuItem = _menuItemArray[index];
		}

		protected function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		public function set highlightedMenuItem(value:IGameMenuItem):void
		{
			if (_highlightedMenuItem) _highlightedMenuItem.textColor = DEFAULT_TEXT_COLOR;

			_highlightedMenuItem = value as RBIMenuItem;

			if (_highlightedMenuItem == null) return;
			_highlightedMenuItem.textColor = highlightED_TEXT_COLOR;

			if (_baseballIcon == null)
				_baseballIcon = new QuickLoader("swfs/rbi/baseballIcon.swf", onComplete);

			positionBall();

			function onComplete():void
			{
				positionBall();
				addChild(_baseballIcon);
			}

			function positionBall():void
			{
				_baseballIcon.x = _highlightedMenuItem.x - 35;
				_baseballIcon.y = _highlightedMenuItem.y + _highlightedMenuItem.menuText.height/2 - _baseballIcon.height/2;
			}
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
