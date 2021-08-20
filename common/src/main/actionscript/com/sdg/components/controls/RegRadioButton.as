package com.sdg.components.controls
{
	import com.sdg.events.SelectedEvent;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;

	import mx.core.FlexGlobals; // Non-SDG
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.styles.CSSStyleDeclaration;
	// import mx.styles.StyleManager; // Non-SDG

	[Event(name="select", type="com.sdg.events.SelectedEvent")]

	[Bindable]
	public class RegRadioButton extends Canvas
	{
		private var _mouseOver:Boolean;
		private var _selected:Boolean;
		private var _value:Object;
		private var _label:Label;
		private var _icon:Image;

		// Set the default CSS styles for GradientCanvas
		private static var classConstructed:Boolean = classConstruct();

		private static function classConstruct():Boolean
		{
			var style:CSSStyleDeclaration = FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("RegRadioButton"); // Non-SDG - stop using StyleManager
			if (!style)
			{
				style = new CSSStyleDeclaration();
			}

			// set the default values
			style.defaultFactory = function():void
				{
					this.backgroundColor = 0x00ff00;
					this.borderStyle = "solid";
					this.cornerRadius = 10;
					this.borderColor = 0xfff000;
				};

			FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("RegRadioButton", style, true); // Non-SDG - stop using StyleManager
			return true;
		}

		public function RegRadioButton()
		{
			super();
			this.mouseChildren = false;
			_selected = false;
			this.addEventListener(MouseEvent.CLICK, onClick);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

			function onClick(event:MouseEvent):void
			{
				selected = true;
			}

			function onMouseOver(event:MouseEvent):void
			{
				mouseOver = true;
			}

			function onMouseOut(event:MouseEvent):void
			{
				mouseOver = false;
			}
		}

		public function set iconSource(value:String):void
		{
			if (_icon == null)
			{
				_icon = new Image();
				addChild(_icon);
				_icon.setStyle("horizontalCenter", 0);
				_icon.setStyle("verticalCenter", 0);
				_icon.percentWidth = 100;
				_icon.percentHeight = 100;
			}

			_icon.source = value;
			_icon.addEventListener(Event.INIT, onInit);

			function onInit(event:Event):void
			{
				_icon.removeEventListener(Event.INIT, onInit);
				trace("init");

				setIconSelection();
			}
		}

		private function setIconSelection():void
		{
			try
			{
				var iconObject:Object = Object(_icon);
				iconObject.content.selected = _selected;
			}
			catch(e:Error) {}
		}

		override public function set label(value:String):void
		{
			super.label = value;

			if (_label == null)
			{
				_label = new Label();
				_label.setStyle("fontFamily", "EuroStyle");
				_label.setStyle("fontSize", getStyle("fontSize"));
				_label.setStyle("fontWeight", getStyle("fontWeight"));
				_label.setStyle("horizontalCenter", 0);
				_label.setStyle("verticalCenter", 0);
				addChild(_label);
			}

			_label.text = value;
		}

		public function set selected(value:Boolean):void
		{
			_selected = value;

			var filters:Array = [];

			if (_label)
				_label.filters = filters;

			setIconSelection();

			if (value == true)
			{
				filters.push(new GlowFilter(0xffffff, .5, 10, 10, 2, 10));
				dispatchEvent(new SelectedEvent(SelectedEvent.SELECTED));
			}
		}

		public function get selected():Boolean
		{
			return _selected;
		}

		public function set mouseOver(value:Boolean):void
		{
			_mouseOver = value;
		}

		public function get mouseOver():Boolean
		{
			return _mouseOver;
		}

		public function set value(value:Object):void
		{
			_value = value;
		}

		public function get value():Object
		{
			return _value;
		}
	}
}
