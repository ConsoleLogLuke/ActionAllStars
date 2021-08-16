package com.sdg.controls
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class TabListControl extends Sprite
	{
		public static const TAB_SELECT:String = 'tab select';
		
		protected var _values:Array;
		protected var _tabHeight:Number;
		protected var _maxWidth:Number;
		protected var _isInit:Boolean;
		protected var _margin:Number;
		protected var _selectedIndex:uint;
		protected var _deselectedAlpha:Number;
		protected var _selectedTab:BasicTab;
		
		protected var _tabs:Array;
		
		public function TabListControl(tabValues:Array, tabHeight:Number = 30, maxWidth:Number = 400, autoInit:Boolean = true)
		{
			super();
			
			_values = tabValues;
			_tabHeight = tabHeight;
			_maxWidth = maxWidth;
			_isInit = false;
			_margin = 10;
			_tabs = [];
			_selectedIndex = 0;
			_deselectedAlpha = 0.5;
			
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
			
			// Create tabs.
			var i:uint = 0;
			for each (var tabValue:String in _values)
			{
				var tab:BasicTab = new BasicTab(tabValue, _tabHeight);
				tab.buttonMode = true;
				tab.addEventListener(MouseEvent.ROLL_OVER, onTabOver);
				addChild(tab);
				_tabs.push(tab);
				
				// If it's not the selected tab, change it's appearance.
				if (i != _selectedIndex)
				{
					tab.alpha = _deselectedAlpha;
				}
				else
				{
					_selectedTab = tab;
				}
				
				i++;
			}
			
			render();
		}
		
		public function destroy():void
		{
			// Remove all event listeners.
			for each (var tab:BasicTab in _tabs)
			{
				tab.removeEventListener(MouseEvent.ROLL_OVER, onTabOver);
			}
			
			_tabs = null;
			_values = null;
		}
		
		public function render():void
		{
			// Position tabs.
			var lastTabX:Number = 0;
			for each (var tab:BasicTab in _tabs)
			{
				tab.x = lastTabX + _margin;
				lastTabX = tab.x + tab.width;
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get tabHeight():Number
		{
			return _tabHeight;
		}
		
		public function get selectedIndex():uint
		{
			return _selectedIndex;
		}
		public function set selectedIndex(value:uint):void
		{
			if (value == _selectedIndex) return;
			
			// Make sure it is a valid index.
			var newSelectedTab:BasicTab = _tabs[value] as BasicTab;
			if (newSelectedTab == null) return;
			
			// Change appearance of currently selected tab.
			_selectedTab.alpha = _deselectedAlpha;
			
			// Set new tab.
			_selectedIndex = value;
			_selectedTab = newSelectedTab;
			
			// Change appearance of newly selected tab.
			_selectedTab.alpha = 1;
			
			// Dispatch a tab selected event.
			dispatchEvent(new Event(TAB_SELECT));
		}
		
		public function get selectedValue():String
		{
			return _values[_selectedIndex] as String;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onTabOver(e:MouseEvent):void
		{
			// Get reference to tab.
			var tab:BasicTab = e.currentTarget as BasicTab;
			
			// If it's the currently selected tab, do nothing.
			if (tab == _selectedTab) return;
			
			// Listen for roll out and click.
			tab.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			tab.addEventListener(MouseEvent.CLICK, onClick);
			
			// Change appearance.
			tab.alpha = 1;
			
			function onRollOut(e:MouseEvent):void
			{
				// Remove event listeners.
				tab.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				tab.removeEventListener(MouseEvent.CLICK, onClick);
				
				// Change appearance.
				tab.alpha = _deselectedAlpha;
			}
			
			function onClick(e:MouseEvent):void
			{
				// Remove event listeners.
				tab.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				tab.removeEventListener(MouseEvent.CLICK, onClick);
				
				// Select this tab.
				selectedIndex = _tabs.indexOf(tab);
			}
		}
		
	}
}