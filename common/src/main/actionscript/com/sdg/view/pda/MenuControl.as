package com.sdg.view.pda
{
	import com.sdg.display.DirectionalBox;
	import com.sdg.view.pda.interfaces.IPDAButton;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.containers.Box;
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	public class MenuControl extends Canvas
	{
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		
		private static const _toggleButtonWidth:int = 20;
		private static const _toggleButtonHeight:int = 6;
		private static const _toggleButtonGap:int = 3;
		
		private var _slotsPerLine:int;
		private var _buttonAlignment:String;
		private var _skinContainer:SkinableContainer;
		private var _menuContainer:DirectionalBox;
		private var _buttonsContainer:DirectionalBox;
		private var _isExpanded:Boolean = false;
		private var _toggleButton:ToggleButton;
		private var _changeWatcher:ChangeWatcher;
		private var _buttonList:ArrayCollection = new ArrayCollection();
		
		private var _closedMenuWidth:int;
		private var _closedMenuHeight:int;
		
		private var _paddingLeft:int = 3;
		private var _paddingRight:int = 3;
		private var _paddingTop:int = 3;
		private var _paddingBottom:int = 3;
		
		public var lineGap:int = 5;
		public var buttonGap:int = 5;
		
		public var rememberSelection:Boolean = true;
		
		public function MenuControl(slotsPerLine:int = 6, buttonAlignment:String = TOP)
		{
			super();
			_slotsPerLine = slotsPerLine;
			_buttonAlignment = buttonAlignment;
			
			setupMenu();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			_skinContainer.width = w;
			_skinContainer.height = h;
			_skinContainer.setStyle("backgroundAlpha", getStyle("backgroundAlpha"));
			
			if(!_isExpanded)
				closeMenu();
			else
				expandMenu();
		}
		
		private function setupMenu():void
		{
			// cleanup
			this.removeAllChildren();
			if (_changeWatcher)
				_changeWatcher.unwatch();
			
			_skinContainer = this.addChild(new SkinableContainer()) as SkinableContainer;
			//_skinContainer.skin = new ;
			_skinContainer.horizontalScrollPolicy = "off";
			_skinContainer.verticalScrollPolicy = "off";
			
			_menuContainer = _skinContainer.addChild(new DirectionalBox()) as DirectionalBox;
			//_menuContainer.setStyle("backgroundColor", "#fff000");
			
			_menuContainer.setStyle("paddingLeft", _paddingLeft);
			_menuContainer.setStyle("paddingRight", _paddingRight);
			_menuContainer.setStyle("paddingTop", _paddingTop);
			_menuContainer.setStyle("paddingBottom", _paddingBottom);
			
			_buttonsContainer = _menuContainer.addChild(new DirectionalBox()) as DirectionalBox;
			//_buttonsContainer.setStyle("backgroundColor", "#00ff00");
			_buttonsContainer.setStyle("verticalAlign", "middle");
			_buttonsContainer.setStyle("horizontalAlign", "center");
			_buttonsContainer.setStyle("verticalGap", lineGap);
			_buttonsContainer.setStyle("horizontalGap", lineGap);
			
			if (_buttonAlignment == TOP || _buttonAlignment == BOTTOM)
			{
				_menuContainer.direction = "vertical";
				_menuContainer.setStyle("horizontalCenter", 0);
				_menuContainer.setStyle("horizontalAlign", "center");
			}
			else
			{
				_menuContainer.direction = "horizontal";
				_menuContainer.setStyle("verticalCenter", 0);
				_menuContainer.setStyle("verticalAlign", "middle");
			}
			
			if (_buttonAlignment == TOP || _buttonAlignment == LEFT)
				_menuContainer.addChildInReverse = true;
			
			_menuContainer.setStyle(_menuContainer.direction + "Gap", _toggleButtonGap);
			_menuContainer.setStyle(_buttonAlignment, 0);
			
			_buttonsContainer.direction = _menuContainer.direction;
			_buttonsContainer.addChildInReverse = !_menuContainer.addChildInReverse;
			
			for each (var button:IPDAButton in _buttonList)
				addButtonToStage(button);
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			var button:IPDAButton = child as IPDAButton;
			if (button)
				addButton(button);
			else
				super.addChild(child);
			
			return child;
		}
		
		private function addButtonToStage(button:IPDAButton):IPDAButton
		{
			var lastChildBox:Box = _buttonsContainer.lastChildAdded as Box;
			
			if (lastChildBox == null || lastChildBox.numChildren >= _slotsPerLine)
				lastChildBox = addNewButtonLine();
			
			lastChildBox.addChild(UIComponent(button));
			return button;
		}
		
		public function addButton(button:IPDAButton):IPDAButton
		{
			button.addEventListener(MouseEvent.CLICK, onClick);
			_buttonList.addItem(button);
			return addButtonToStage(button);
		}
		
		private function addNewButtonLine():Box
		{
			var direction:String;
			var chain:String;
			var actualButtonWidth:int;
			var actualButtonHeight:int;
			
			if (_buttonAlignment == TOP || _buttonAlignment == BOTTOM)
			{
				direction = "horizontal";
				chain = "height";
				actualButtonWidth = _toggleButtonWidth;
				actualButtonHeight = _toggleButtonHeight;
			}
			else
			{
				direction = "vertical";
				chain = "width";
				actualButtonWidth = _toggleButtonHeight;
				actualButtonHeight = _toggleButtonWidth;
			}
			
			var box:Box = _buttonsContainer.addChild(new Box()) as Box;
			box.direction = direction;
			box.setStyle(direction + "Gap", buttonGap);
			
			if (_buttonsContainer.numChildren == 1)
			{
				_changeWatcher = BindingUtils.bindProperty(this, "firstLineSize", _buttonsContainer.firstChildAdded, chain);
			}
			else if (_buttonsContainer.numChildren == 2)
			{
				_toggleButton = _menuContainer.addChild(new ToggleButton()) as ToggleButton;
				_toggleButton.direction = direction;
				_toggleButton.pointsTo = _buttonAlignment;
				
				_toggleButton.addEventListener(MouseEvent.CLICK, onToggleButtonClicked);
				_toggleButton.setStyle(direction + "Center", 0);
				_toggleButton.width = actualButtonWidth;
				_toggleButton.height = actualButtonHeight;
			}
			return box;
		}
		
		private function onClick(event:MouseEvent):void
		{
			selected = event.currentTarget as IPDAButton;
			if (!rememberSelection)
				selected = null;
		}
		
		private function onToggleButtonClicked(event:MouseEvent):void
		{
			if (!_isExpanded)
				expandMenu();
			else
				closeMenu();
			_toggleButton.flipArrow();
		}
		
		private function closeMenu():void
		{
			_isExpanded = false;
			
			if (_buttonAlignment == TOP || _buttonAlignment == BOTTOM)
				_skinContainer.height = _closedMenuHeight;
			else
				_skinContainer.width = _closedMenuWidth;
		}
		
		private function expandMenu():void
		{
			_isExpanded = true;
			
			if (_buttonAlignment == TOP || _buttonAlignment == BOTTOM)
				_skinContainer.height = _menuContainer.height;
			else
				_skinContainer.width = _menuContainer.width;
		}
		
		public function set firstLineSize(value:int):void
		{
			var buttonHeightPlusGap:int = 0;
			var buttonWidthPlusGap:int = 0;
			
			if (_toggleButton)
			{
				buttonHeightPlusGap = _toggleButton.height + _toggleButtonGap;
				buttonWidthPlusGap = _toggleButton.width + _toggleButtonGap;
			}
			
			_closedMenuHeight = paddingTop +  buttonHeightPlusGap + value + paddingBottom;
			_closedMenuWidth = paddingLeft +  buttonWidthPlusGap + value + paddingRight;
			this.invalidateDisplayList();
		}
		
		public function set paddingLeft(value:int):void
		{
			_paddingLeft = value;
			
			if (_menuContainer)
				_menuContainer.setStyle("paddingLeft", _paddingLeft);
		}
		
		public function get paddingLeft():int
		{
			return _paddingLeft;
		}
		
		public function set paddingRight(value:int):void
		{
			_paddingRight = value;
			
			if (_menuContainer)
				_menuContainer.setStyle("paddingRight", _paddingRight);
		}
		
		public function get paddingRight():int
		{
			return _paddingRight;
		}
		
		public function set paddingTop(value:int):void
		{
			_paddingTop = value;
			
			if (_menuContainer)
				_menuContainer.setStyle("paddingTop", _paddingTop);
		}
		
		public function get paddingTop():int
		{
			return _paddingTop;
		}
		
		public function set paddingBottom(value:int):void
		{
			_paddingBottom = value;
			
			if (_menuContainer)
				_menuContainer.setStyle("paddingBottom", _paddingBottom);
		}
		
		public function get paddingBottom():int
		{
			return _paddingBottom;
		}
		
		public function set buttonAlignment(value:String):void
		{
			_buttonAlignment = value;
			setupMenu();
		}
		
		public function set slotsPerLine(value:int):void
		{
			_slotsPerLine = value;
			setupMenu();
		}
		
		public function get skin():PDASkin
		{
			return _skinContainer.skin;
		}
		
		[Bindable]
		public function get selected():IPDAButton
		{
			var selectedButton:IPDAButton;
			
			for each (var boxLine:Box in _buttonsContainer.getChildren())
			{
				for each (var button:IPDAButton in boxLine.getChildren())
				{
					if (button.selected)
					{
						selectedButton = button;
						break;
					}
				}
			}
			return selectedButton;
		}
		
		public function set selected(value:IPDAButton):void
		{
			for each (var boxLine:Box in _buttonsContainer.getChildren())
			{
				for each (var button:IPDAButton in boxLine.getChildren())
				{
					if (button != value)
						button.selected = false
					else
						button.selected = true;
				}
			}
		}
	}
}