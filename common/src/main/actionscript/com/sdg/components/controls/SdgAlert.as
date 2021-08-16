package com.sdg.components.controls
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.containers.ControlBar;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.Text;
	
	[Style(name="buttonMinWidth", type="Number", inherit="no")]
	
	[Style(name="buttonMinHeight", type="Number", inherit="no")]
	
	[Style(name="buttonStyleName", type="String", inherit="no")]
	
	[Style(name="defaultButtonStyleName", type="String", inherit="no")]
	
	[Style(name="messageStyleName", type="String", inherit="no")]
	
	[Bindable]
	public class SdgAlert extends PopUpPanel
	{	
		public static const YES:int = 0x01;
		public static const NO:int = 0x02;
		public static const OK:int = 0x04;
		public static const CANCEL:int = 0x08;

		private static const DEFAULT_BUTTON_DESCRIPTORS:Object = 
		{
			0x01:{ label:'Yes' },
			0x02:{ label:'No' },
			0x04:{ label:'Ok' },
			0x08:{ label:'Cancel' }
		}

		private static const MAX_BUTTON_FLAG:int = 0x08;
		
		protected var buttonBar:ControlBar;
		protected var buttons:Array = [];
		protected var buttonDescriptors:Object = {};
		protected var buttonsChanged:Boolean;
		//protected var messageField:IUITextField;
		protected var messageField:Text;
		protected var messageChanged:Boolean;
		protected var messageWidth:Number;
		
		private var _buttonFlags:int;
		private var _defaultButtonFlag:int;
		private var _message:String;

		public function get buttonFlags():int
		{
			return _buttonFlags;
		}

		public function set buttonFlags(value:int):void
		{
			_buttonFlags = value;
			buttonsChanged = true;
			invalidateProperties();
		}

		public function get defaultButtonFlag():int
		{
			return _defaultButtonFlag;
		}

		public function set defaultButtonFlag(value:int):void
		{
			_defaultButtonFlag = value;
			buttonsChanged = true;
			invalidateProperties();
		}

		public function get message():String
		{
			return _message;
		}

		public function set message(value:String):void
		{
			_message = value;
			messageChanged = true;
			invalidateProperties();
		}
		
		/**
		 * Static show method.
		 */
		public static function show(message:String, title:String, 
									buttonFlags:int = 0x04, defaultButtonFlag:int = 0x04,
									closeHandler:Function = null, parent:Sprite = null, 
									modal:Boolean = true, closeButton:Boolean = false, width:int = 430):SdgAlert
		{
			var alert:SdgAlert = new SdgAlert(width);

			alert.message = message;
			alert.title = title;
			alert.buttonFlags = buttonFlags;
			alert.defaultButtonFlag = defaultButtonFlag;
			alert.showCloseButton = closeButton;
			alert.show(closeHandler, parent, modal);
			
			return alert;
		}
		
		/**
		 * Constructor.
		 */
		public function SdgAlert(width:int = 430)
		{
			this.width = width;
			this.setStyle("paddingLeft", 10);
			this.setStyle("paddingRight", 10);
			this.setStyle("horizontalAlign", "center");
		}
		
		public function setButtonDescriptor(flag:int, label:String, styleName:Object = null):void
		{
			buttonDescriptors[flag] = { label:label, styleName:styleName };
			buttonsChanged = true;
			invalidateProperties();
		}

		public function setButtonLabel(flag:int, label:String):void
		{
			getButtonDescriptor(flag).label = label;
			buttonsChanged = true;
			invalidateProperties();
		}

		public function setButtonLabels(...list:Array):void
		{
			for (var i:int = 0; i < list.length; i++)
			{
				getButtonDescriptor(int(list[i])).label = String(list[++i]);
			}

			buttonsChanged = true;
			invalidateProperties();
		}

		public function setButtonStyleName(flag:int, styleName:Object):void
		{
			getButtonDescriptor(flag).styleName = styleName;
			buttonsChanged = true;
			invalidateProperties();
		}

		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);

			var allStyles:Boolean = (styleProp == null || styleProp == "styleName");

			if (buttons.length)
			{
				var i:int;
				var numButtons:int = buttons.length;

				if (allStyles || styleProp == "buttonMinWidth" || styleProp == "buttonMinHeight")
				{
					buttonsChanged = true;
					invalidateProperties();
				}

				if (allStyles || styleProp == "buttonStyleName")
				{
					buttonsChanged = true;
					invalidateProperties();
				}

				if (allStyles || styleProp == "defaultButtonStyleName")
				{
					buttonsChanged = true;
					invalidateProperties();
				}
			}

			if (allStyles || styleProp == "messageStyleName")
			{
				if (messageField) 
				{
					messageField.styleName = 
						getStyle("messageStyleName") ? getStyle("messageStyleName") : this;
				}
			}
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}

		override protected function commitProperties():void
		{
			super.commitProperties();

			if (buttonsChanged)
			{
				if (_buttonFlags && !buttonBar)
				{
					createButtonBar();
				}
				
				updateButtons();
				buttonsChanged = false;
				
				if (!_buttonFlags && buttonBar)
				{
					if (contains(buttonBar)) removeChild(buttonBar);
					buttonBar = null;
					controlBar = null;
					invalidateSize();
				}
			}

			if (messageChanged)
			{
				messageField.text = _message;
				messageChanged = false;
			}
		}

		override protected function createChildren():void
		{
			super.createChildren();

			// create message field
			if (!messageField) createMessageField();
		}

		protected function createButton():Button
		{
			return new Button();
		}
		
		protected function createButtonBar():void
		{
			buttonBar = new ControlBar();
			buttonBar.addEventListener(MouseEvent.CLICK, handleControlBarClick);
			addChild(buttonBar);
			createComponentsFromDescriptors();
		}
		
		protected function createMessageField():void
		{
//			messageField = Text(createInFontContext(Text));
//			messageField.multiline = true;
//			messageField.wordWrap = true;
			//messageField.autoSize = "center";
			messageField = new Text();
			messageField.setStyle("color", "#133870");
			messageField.setStyle("fontSize", 15);
			messageField.setStyle("fontWeight", "normal");
			
			messageField.text = _message;
			messageField.width = this.width - 30;
			addChildAt(DisplayObject(messageField), 0);
		}

//		override protected function measure():void
//		{
//			var bm:EdgeMetrics = this.viewMetricsAndPadding;
//			var width:Number = (controlBar) ? Math.max(minWidth, controlBar.measuredWidth) : minWidth;
//			
//			messageWidth = width - bm.left - bm.right;
//			messageField.width = messageWidth;
//			super.measure();
//		}

		protected function getButtonDescriptor(flag:int):Object
		{
			var descriptor:Object = buttonDescriptors[flag];

			if (!descriptor)
			{
				var defaultDesc:Object = DEFAULT_BUTTON_DESCRIPTORS[flag];

				if (!defaultDesc)
					descriptor = { label:"", styleName:null };
				else
					descriptor = { label:defaultDesc.label, styleName:defaultDesc.styleName };

				buttonDescriptors[flag] = descriptor;
			}

			return descriptor;
		}

		protected function updateButtons():void
		{
			var defaultBtn:Button;
			var button:Button;
			var buttonStyleName:String = getStyle("buttonStyleName");
			var descriptor:Object;
			var buttonCount:int = 0;
			var flag:int = 1;

			while (flag <= MAX_BUTTON_FLAG)
			{
				button = buttons[buttonCount];
				descriptor = getButtonDescriptor(flag);

				// Add and update buttons.
				if ((_buttonFlags & flag) && descriptor)
				{
					if (!button)
					{
						button = buttons[buttonCount] = createButton();
						buttonBar.addChild(button);
					}

					button.data = flag;
					button.label = descriptor.label;
					button.minWidth = getStyle("buttonMinWidth");
					button.minHeight = getStyle("buttonMinHeight");

					if (flag == _defaultButtonFlag)
						defaultBtn = button;
					else
						button.styleName = (descriptor.styleName) ? descriptor.styleName : buttonStyleName;

					buttonCount++;
				}

				flag += flag;
			}

			// Remove extra buttons.
			if (buttonCount < buttons.length)
			{
				for (var i:int = buttonCount; i < buttons.length; i++)
				{
					buttonBar.removeChild(Button(buttons[i]));
				}

				buttons.length = buttonCount;
			}

			if (buttonCount > 0)
			{
				// If no defaultButton was set, use the last button.
				if (!defaultBtn) defaultBtn = buttons[buttonCount - 1];

				// Set the default button style.
				descriptor = getButtonDescriptor(int(defaultBtn.data));
				defaultBtn.styleName = (descriptor.styleName) ? descriptor.styleName : 
					getStyle("defaultButtonStyleName") ? getStyle("defaultButtonStyleName") : buttonStyleName;
			}

			// Set the default button.
			if (defaultBtn != defaultButton)
			{
				defaultButton = defaultBtn;

				if (defaultBtn)
				{
					//systemManager.activate(this);
					defaultBtn.setFocus();
				}
			}
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			
			//messageField.width = messageWidth;
			//trace('messageField', messageField.textWidth, messageField.textHeight);
			messageField.setActualSize(messageWidth, messageField.getExplicitOrMeasuredHeight());
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ESCAPE)
			{
				if ((buttonFlags & SdgAlert.CANCEL) || !(buttonFlags & SdgAlert.NO))
					close(SdgAlert.CANCEL);
				else if (buttonFlags & SdgAlert.NO)
					close(SdgAlert.NO);
			}
		}

		private function handleControlBarClick(event:MouseEvent):void
		{
			var button:Button = event.target as Button;
			if (button) close(int(button.data));
		}
	}
}