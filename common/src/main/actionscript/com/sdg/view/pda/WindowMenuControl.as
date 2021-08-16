package com.sdg.view.pda
{
	import com.sdg.view.pda.interfaces.IPDAButton;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	public class WindowMenuControl extends VBox
	{
		public var windowSize:int = 7;
		public var fontSize:int = 15;
		public var fontThickness:int = 250;
		private var container:HBox = new HBox();
		private var leftArrow:UIComponent = new UIComponent();
		private var rightArrow:UIComponent = new UIComponent();
		private var _buttonsList:ArrayCollection = new ArrayCollection();
		private var _label:Label = new Label();
		private var _startingIndex:int = 0;
		private var _selectedButton:IPDAButton;
		
		public function WindowMenuControl()
		{
			super();
			this.setStyle("horizontalAlign", "center");
			this.setStyle("verticalGap", 0);
			this.addChild(_label);
			_label.setStyle("fontSize", fontSize);
			_label.setStyle("fontWeight", "bold");
			_label.setStyle("fontThickness", fontThickness);
			_label.setStyle("paddingTop", 0);
			_label.setStyle("paddingBottom", 0);
			_label.height = 22;
			_label.filters = [new GlowFilter(0x000000, 1, 6, 6, 10)];
			
			//var canvas:Canvas = new Canvas();
			var hbox:HBox = new HBox();
			this.addChild(hbox);
			hbox.percentWidth = 100;
			hbox.percentHeight = 100;
			hbox.setStyle("horizontalGap", 3);
			hbox.setStyle("verticalAlign", "middle");
			
			//hbox.addChild(leftArrow);
			//leftArrow.setStyle("left", 0);
			//leftArrow.setStyle("verticalCenter", 10);
			leftArrow.width = 8;
			leftArrow.height = 16;
			leftArrow.buttonMode = true;
			
			leftArrow.graphics.clear();
			leftArrow.graphics.beginFill(0xffffff);
			leftArrow.graphics.moveTo(0, leftArrow.height/2);
			leftArrow.graphics.lineTo(leftArrow.width, 0);
			leftArrow.graphics.lineTo(leftArrow.width, leftArrow.height);
			leftArrow.graphics.lineTo(0, leftArrow.height/2);
			leftArrow.graphics.endFill();
			leftArrow.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {startingIndex--});
			
			hbox.addChild(container);
			//container.setStyle("horizontalCenter", 0);
			//container.setStyle("verticalCenter", 10);
			container.percentWidth = 100;
			container.percentHeight = 100;
			container.setStyle("horizontalAlign", "center");
			container.setStyle("paddingTop", 2);
			//container.setStyle("paddingBottom", 1);
			container.addEventListener(FlexEvent.CREATION_COMPLETE, drawGradient);
			
			//hbox.addChild(rightArrow);
			//rightArrow.setStyle("right", 0);
			//rightArrow.setStyle("verticalCenter", 10);
			rightArrow.width = 8;
			rightArrow.height = 16;
			rightArrow.buttonMode = true;
			
			rightArrow.graphics.clear();
			rightArrow.graphics.beginFill(0xffffff);
			rightArrow.graphics.moveTo(rightArrow.width, rightArrow.height/2);
			rightArrow.graphics.lineTo(0, 0);
			rightArrow.graphics.lineTo(0, rightArrow.height);
			rightArrow.graphics.lineTo(rightArrow.width, rightArrow.height/2);
			rightArrow.graphics.endFill();
			rightArrow.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {startingIndex++});
			
			//updateWindow();
		}
		
		private function drawGradient(event:FlexEvent):void
		{
			container.removeEventListener(FlexEvent.CREATION_COMPLETE, drawGradient);
			
			var containerBG:Sprite = new Sprite();
			
			var updownGradient:Sprite = new Sprite();
			containerBG.addChild(updownGradient);
			var gradientBoxMatrix:Matrix = new Matrix();
			gradientBoxMatrix.createGradientBox(container.width, container.height, Math.PI/2, 0, 0);
			//_outerHighlight.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff], [.3, .55, .85, .45, 0], [0, 40, 94, 160, 255], gradientBoxMatrix);
			updownGradient.graphics.beginGradientFill(GradientType.LINEAR, [0x999999, 0x999999], [.6, 0], [0, 255], gradientBoxMatrix);
			updownGradient.graphics.drawRect(0, 0, container.width, container.height);
			updownGradient.graphics.endFill();
			updownGradient.cacheAsBitmap = true;
			
			var fadeOutGradient:Sprite = new Sprite();
			containerBG.addChild(fadeOutGradient);
			var gradientBoxMatrix2:Matrix = new Matrix();
			gradientBoxMatrix2.createGradientBox(container.width, container.height, 0, 0, 0);
			fadeOutGradient.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff],
														[0, .9, 1, .9, 0], [0, 64, 128, 192, 255], gradientBoxMatrix2);
			fadeOutGradient.graphics.drawRect(0, 0, container.width, container.height);
			fadeOutGradient.graphics.endFill();
			fadeOutGradient.cacheAsBitmap = true;
			updownGradient.mask = fadeOutGradient;
			
			container.rawChildren.addChildAt(containerBG, 0);
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			var button:IPDAButton = child as IPDAButton;
			
			if (button)
			{
				_buttonsList.addItem(button);
				button.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {selected = button});
			}
			else
				super.addChild(child);
			
			updateWindow();
			return child;
		}
		
		private function get startingIndex():int
		{
			return _startingIndex;
		}
		
		private function set startingIndex(value:int):void
		{
			_startingIndex = value;
			updateWindow();
		}
		
		public function removeAllButtons():void
		{
			_buttonsList.removeAll();
			updateWindow();
		}
		
		private function updateWindow():void
		{
			container.removeAllChildren();
			for (var i:int = _startingIndex; i < _buttonsList.length && i < _startingIndex + windowSize; i++)
				container.addChild(UIComponent(_buttonsList.getItemAt(i)));
			leftArrow.visible = _startingIndex > 0;
			rightArrow.visible = _startingIndex + windowSize < _buttonsList.length;
		}
		
		public function set selectedIndex(value:int):void
		{
			selected = _buttonsList.getItemAt(value) as IPDAButton;
		}
		
		public function get selected():IPDAButton
		{
			return _selectedButton;
		}
		
		public function set selected(value:IPDAButton):void
		{
			if (_selectedButton)
				_selectedButton.selected = false;
			
			if (value)
			{
				value.selected = true;
				_label.text = value.labelText;
			}
			else
				_label.text = "";
			
			_selectedButton = value;
			
			
			if (value.callBack != null)
			{
				if (value.params != null)
					value.callBack(value.params);
				else
					value.callBack();
			}
		}
	}
}
