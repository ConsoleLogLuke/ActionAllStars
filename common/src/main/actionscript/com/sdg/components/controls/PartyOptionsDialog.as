package com.sdg.components.controls
{
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.Party;
	import com.sdg.net.QuickLoader;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.utils.EmbeddedImages;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Label;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;

	public class PartyOptionsDialog extends Canvas
	{
		private var _timer:Timer;
		private var _themeComboBox:CustomComboBox;
		private var _effectComboBox:CustomComboBox;
		private var _soundComboBox:CustomComboBox;
		private var _dialogPartyOn:Boolean;

		private var _selectedTheme:Object;
		private var _selectedEffect:Object;
		private var _selectedSound:Object;
		private var _selectedPartyOn:Boolean;
		private var _modal:Canvas;
		private var _button:Sprite;
		private var _buttonBG:DisplayObject;
		private var _buttonLabel:TextField;
		private var _closeButton:DisplayObject;

		public function PartyOptionsDialog(party:Party)
		{
			super();

			width = 430;
			height = 215;

			var bgContainer:UIComponent = new UIComponent();
			addChild(bgContainer);

			var background:DisplayObject = new EmbeddedImages.popupPanel();
			bgContainer.addChild(background);
			background.scaleX *= width/background.width;
			background.scaleY *= height/background.height;

			var icon:DisplayObject = new QuickLoader("swfs/alert/discoBall.swf", onIconComplete);

			_closeButton = new QuickLoader("swfs/alert/closeButton.swf", onCloseButtonComplete);

			var titleLabel:Label = new Label();
			titleLabel.text = "Get the party started!";
			titleLabel.setStyle("fontFamily", "EuroStyle");
			titleLabel.setStyle("fontSize", 18);
			titleLabel.setStyle("fontWeight", "bold");
			titleLabel.setStyle("color", 0xfdc000);
			titleLabel.setStyle("horizontalCenter", 0);
			titleLabel.y = 17;
			addChild(titleLabel);
			titleLabel.filters = [new GlowFilter(0x000000, 1, 4, 4, 10)];

			var comboBoxContainer:VBox = new VBox();
			addChild(comboBoxContainer);
			comboBoxContainer.setStyle("horizontalAlign", "right");
			comboBoxContainer.setStyle("horizontalCenter", 0);
			comboBoxContainer.y = 55;

			var themeContainer:HBox = new HBox();
			comboBoxContainer.addChild(themeContainer);

			var themeLabel:Label = new Label();
			themeLabel.text = "Party Name";
			themeLabel.setStyle("fontFamily", "EuroStyle");
			themeLabel.setStyle("fontSize", 18);
			themeLabel.setStyle("fontWeight", "bold");
			themeLabel.setStyle("color", 0xffffff);
			themeContainer.addChild(themeLabel);
			themeLabel.filters = [new GlowFilter(0x000000, 1, 4, 4, 10)];

			var themeArray:ArrayCollection = new ArrayCollection();
			themeArray.addItem({label:"Party Time", linkId:4320});
			themeArray.addItem({label:"Fun and Games", linkId:4321});
			themeArray.addItem({label:"Birthday Bash", linkId:4322});
			themeArray.addItem({label:"Fashion Show", linkId:4324});
			themeArray.addItem({label:"Sports Convention", linkId:4325});
			themeArray.addItem({label:"Dance Fever", linkId:4326});
			themeArray.addItem({label:"Pet Show", linkId:4327});
			themeArray.addItem({label:"Dinner Banquet", linkId:4328});
			themeArray.addItem({label:"Turf Tour", linkId:4329});
			themeArray.addItem({label:"Victory Celebration", linkId:4330});
			themeArray.addItem({label:"Racetrack Madness", linkId:4331});

			_themeComboBox = new CustomComboBox();
			_themeComboBox.rowCount = 13;
			_themeComboBox.addEventListener(ListEvent.CHANGE, onChange, false, 0, true);
			_themeComboBox.dataProvider = themeArray;
			themeContainer.addChild(_themeComboBox);

			var effectContainer:HBox = new HBox();
			comboBoxContainer.addChild(effectContainer);

			var effectLabel:Label = new Label();
			effectLabel.text = "Effect";
			effectLabel.setStyle("fontFamily", "EuroStyle");
			effectLabel.setStyle("fontSize", 18);
			effectLabel.setStyle("fontWeight", "bold");
			effectLabel.setStyle("color", 0xffffff);
			effectContainer.addChild(effectLabel);
			effectLabel.filters = [new GlowFilter(0x000000, 1, 4, 4, 10)];

			var effectArray:ArrayCollection = new ArrayCollection();
			effectArray.addItem({label:" - none - ", effectId:0, enabled:true, linkId:4354});
			effectArray.addItem({label:"Confetti", effectId:219, enabled:true, linkId:4350});
			effectArray.addItem({label:"Disco Ball", effectId:220, enabled:true, linkId:4351});
			effectArray.addItem({label:"Color Bulbs", effectId:221, enabled:true, linkId:4352});
			effectArray.addItem({label:"Spotlights", effectId:222, enabled:true, linkId:4353});

			_effectComboBox = new CustomComboBox();
			_effectComboBox.addEventListener(ListEvent.CHANGE, onChange, false, 0, true);
			_effectComboBox.dataProvider = effectArray;
			effectContainer.addChild(_effectComboBox);

			var soundContainer:HBox = new HBox();
			comboBoxContainer.addChild(soundContainer);

			var soundLabel:Label = new Label();
			soundLabel.text = "Music";
			soundLabel.setStyle("fontFamily", "EuroStyle");
			soundLabel.setStyle("fontSize", 18);
			soundLabel.setStyle("fontWeight", "bold");
			soundLabel.setStyle("color", 0xffffff);
			soundContainer.addChild(soundLabel);
			soundLabel.filters = [new GlowFilter(0x000000, 1, 4, 4, 10)];

			var soundArray:ArrayCollection = new ArrayCollection();
			soundArray.addItem({label:" - none - ", soundId:0, enabled:true, linkId:4378});
			soundArray.addItem({label:"Electric Boulevard", soundId:170, enabled:true, linkId:4370});
			soundArray.addItem({label:"Sunshine Funk", soundId:171, enabled:true, linkId:4371});
			soundArray.addItem({label:"Finish Line Grind", soundId:172, enabled:true, linkId:4375});
			soundArray.addItem({label:"Scratch 'N Groove", soundId:173, enabled:true, linkId:4372});
			soundArray.addItem({label:"Future Fusion", soundId:174, enabled:true, linkId:4379});
			soundArray.addItem({label:"Turf Loungin'", soundId:175, enabled:true, linkId:4380});
			soundArray.addItem({label:"Chill Out - coming soon", soundId:0, enabled:false, linkId:4373});
			soundArray.addItem({label:"Disco - coming soon", soundId:0, enabled:false, linkId:4374});
			soundArray.addItem({label:"Pop - coming soon", soundId:0, enabled:false, linkId:4376});
			soundArray.addItem({label:"Country - coming soon", soundId:0, enabled:false, linkId:4377});

			_soundComboBox = new CustomComboBox();
			_soundComboBox.rowCount = 11;
			_soundComboBox.addEventListener(ListEvent.CHANGE, onChange, false, 0, true);
			_soundComboBox.dataProvider = soundArray;
			soundContainer.addChild(_soundComboBox);

			_button = new Sprite();

			_buttonLabel = new TextField();
			_buttonLabel.embedFonts = true;
			_buttonLabel.defaultTextFormat = new TextFormat('EuroStyle', 16, 0xffffff, true);
			_buttonLabel.autoSize = TextFieldAutoSize.LEFT;
			_buttonLabel.selectable = false;
			_button.addChild(_buttonLabel);
			_buttonLabel.mouseEnabled = false;
			_buttonLabel.filters = [new GlowFilter(0x000000, 1, 5, 5, 10)];

			bgContainer.addChild(_button);
			_button.addEventListener(MouseEvent.CLICK, onButtonClick, false, 0, true);
			_button.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver, false, 0, true);
			_button.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut, false, 0, true);

			//initializing
			var presetThemeIndex:int = 0;
			var presetEffectIndex:int = 0;
			var presetSoundIndex:int = 0;
			var presetPartyOn:Boolean = false;

			if (party != null)
			{
				var i:int;
				for (i = 0; i < themeArray.length; i++)
				{
					if (party.theme == themeArray[i].label)
					{
						presetThemeIndex = i;
						break;
					}
				}

				for (i = 0; i < effectArray.length; i++)
				{
					if (party.effectId == effectArray[i].effectId)
					{
						presetEffectIndex = i;
						break;
					}
				}

				for (i = 0; i < soundArray.length; i++)
				{
					if (party.soundId == soundArray[i].soundId)
					{
						presetSoundIndex = i;
						break;
					}
				}

				presetPartyOn = party.partyOn;
			}
			_themeComboBox.selectedIndex = presetThemeIndex;
			_effectComboBox.selectedIndex = presetEffectIndex;
			_soundComboBox.selectedIndex = presetSoundIndex;
			setButton(presetPartyOn);

			_selectedPartyOn = _dialogPartyOn;
			_selectedTheme = _themeComboBox.selectedItem;
			_selectedEffect = _effectComboBox.selectedItem;
			_selectedSound = _soundComboBox.selectedItem;

			var container:Canvas = new Canvas();

			_modal = new Canvas();
			_modal.width = 925;
			_modal.height = 665;
			_modal.addEventListener(MouseEvent.CLICK, onOutsideClick, false, 0, true);

			container.addChild(_modal);
			container.addChild(this);
			setStyle("horizontalCenter", 0);
			setStyle("verticalCenter", 0);

			PopUpManager.addPopUp(container, DisplayObject(Application.application));

			function onIconComplete():void
			{
				icon = QuickLoader(icon).content;
				bgContainer.addChild(icon);
				icon.x = -20;
				icon.y = -20;
			}

			function onCloseButtonComplete():void
			{
				_closeButton = QuickLoader(_closeButton).content;
				_closeButton.scaleX = _closeButton.scaleY = .7;
				bgContainer.addChild(_closeButton);
				Sprite(_closeButton).buttonMode = true;
				_closeButton.addEventListener(MouseEvent.CLICK, onCloseClick, false, 0, true);
				_closeButton.x = width - _closeButton.width - 15;
				_closeButton.y = 15;
			}
		}

		private function onCloseClick(event:MouseEvent):void
		{
			close();
		}

		private function setButton(partyOn:Boolean):void
		{
			_dialogPartyOn = partyOn;

			if (_buttonBG != null)
				_button.removeChild(_buttonBG);

			if (partyOn)
			{
				_buttonBG = new EmbeddedImages.popupRedButton();
				_buttonLabel.text = "PARTY OFF";
			}
			else
			{
				_buttonBG = new EmbeddedImages.popupGreenButton();
				_buttonLabel.text = "PARTY ON!";
			}

			_buttonBG.scaleX *= 150/_buttonBG.width;
			_buttonBG.scaleY *= 37/_buttonBG.height;
			_button.addChildAt(_buttonBG, 0);
			_button.graphics.clear();
			_button.graphics.drawRect(0, 0, 150, 37);

			_button.x = width/2 - _button.width/2;
			_button.y = 164;

			_buttonLabel.x = _button.width/2 - _buttonLabel.width/2;
			_buttonLabel.y = _button.height/2 - _buttonLabel.height/2 + 2;
		}

		private function onButtonMouseOver(event:MouseEvent):void
		{
			_buttonLabel.textColor = 0xfdc000;
		}

		private function onButtonMouseOut(event:MouseEvent):void
		{
			_buttonLabel.textColor = 0xffffff;
		}

		private function onButtonClick(event:MouseEvent):void
		{
			setTimer();
			setButton(!_dialogPartyOn);
		}

		private function onOutsideClick(event:MouseEvent):void
		{
			close();
		}

		public function close():void
		{
			if (_timer != null)
			{
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				_timer.stop();
			}

			_themeComboBox.removeEventListener(ListEvent.CHANGE, onChange);
			_effectComboBox.removeEventListener(ListEvent.CHANGE, onChange);
			_soundComboBox.removeEventListener(ListEvent.CHANGE, onChange);
			_button.removeEventListener(MouseEvent.CLICK, onButtonClick);
			_button.removeEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
			_button.removeEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
			_modal.removeEventListener(MouseEvent.CLICK, onOutsideClick);
			_closeButton.removeEventListener(MouseEvent.CLICK, onCloseClick);

			triggerValue();
			PopUpManager.removePopUp(parent as Canvas);
		}

		private function onChange(event:ListEvent):void
		{
			if (_dialogPartyOn)
				setTimer();
		}

		private function setTimer():void
		{
			if (_timer == null)
			{
				_timer = new Timer(1000, 1);
				_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete, false, 0, true);
			}

			_timer.reset();
			_timer.start();
		}

		private function onTimerComplete(event:TimerEvent):void
		{
			triggerValue();
		}

		private function triggerValue():void
		{
			var needsUpdate:Boolean = false;

			if (_selectedPartyOn != _dialogPartyOn)
			{
				_selectedPartyOn = _dialogPartyOn;
				needsUpdate = true;
			}

			if (_selectedPartyOn == true)
			{
				if (_selectedTheme != _themeComboBox.selectedItem)
				{
					_selectedTheme = _themeComboBox.selectedItem;
					needsUpdate = true;
				}

				if (_selectedEffect != _effectComboBox.selectedItem)
				{
					_selectedEffect = _effectComboBox.selectedItem;
					needsUpdate = true;
				}

				if (_selectedSound != _soundComboBox.selectedItem)
				{
					_selectedSound = _soundComboBox.selectedItem;
					needsUpdate = true;
				}
			}

			if (needsUpdate)
			{
				// send to server
				trace("send to server");
				var partyState:int = _selectedPartyOn ? 1 : 0;

				if (_selectedPartyOn)
				{
					LoggingUtil.sendClickLogging(_selectedTheme.linkId);
					LoggingUtil.sendClickLogging(_selectedEffect.linkId);
					LoggingUtil.sendClickLogging(_selectedSound.linkId);
				}
				SocketClient.getInstance().sendPluginMessage("avatar_handler", "setParty", {pn:_selectedTheme.label, efId:_selectedEffect.effectId, mId:_selectedSound.soundId, ps:partyState});

			}
		}
	}
}
