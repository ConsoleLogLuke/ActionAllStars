package com.sdg.pet.card
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.audio.EmbeddedAudio;
	import com.sdg.events.SelectedEvent;
	import com.sdg.events.room.item.RoomItemCircleMenuEvent;
	import com.sdg.net.Environment;
	import com.sdg.ui.TextFieldPanelWithArrow;
	import com.sdg.ui.TextListPanelPaged;
	import com.sdg.utils.StringUtil;
	import com.sdg.view.FluidView;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class PetInfoPanel extends FluidView implements IPetNameEditDelegate
	{
		public static const SELECTED_PET_NAME:String = 'selected pet name';
		public static const ATTEMPT_NAME_PET:String = 'attempt name pet';
		
		private static const _STROKE_FILTER:GlowFilter = new GlowFilter(0x000000, 1, 4, 4, 10);
		private static const _ACTION_BUTTON_STROKE:GlowFilter = new GlowFilter(0xffffff, 1, 4, 4, 10);
		
		private static var _validFirstPetNames:Array;
		private static var _validSecondPetNames:Array;
		
		private var _back:Sprite;
		private var _mask:Sprite;
		private var _maskedDisplay:Sprite;
		private var _border:Sprite;
		private var _image:DisplayObject;
		private var _awards:PetTrophyPanel;
		private var _food:PetFoodPanel;
		private var _energyMeter:PetEnergyPanel;
		private var _happyMeter:PetHappinessPanel;
		private var _nameField:TextFieldPanelWithArrow;
		private var _toolTipField:TextField;
		private var _actionButtonsContainer:Sprite;
		private var _actionButtons:Array;
		private var _clickEvents:Array;
		private var _clickLabels:Array;
		private var _overSound:Sound;
		private var _openSound:Sound;
		private var _toolTipItems:Array;
		private var _animMan:AnimationManager;
		private var _isNameEditMode:Boolean;
		private var _firstName:String;
		private var _secondName:String;
		private var _currentNameEditPanel:PetNameEditPanel;
		private var _isLocalPet:Boolean;
		private var _isLeashed:Boolean;
		private var _currentNameSelectionList:DisplayObject;
		private var _petFoodCount:int;
		private var _canName:Boolean;
		
		public function PetInfoPanel(firstName:String, secondName:String, isLocalPet:Boolean = false, isLeashed:Boolean = false, petFoodCount:int = 0, canName:Boolean = false, width:Number = 230, height:Number = 320)
		{
			_actionButtons = [];
			_clickEvents = [];
			_clickLabels = [];
			_overSound = new EmbeddedAudio.OverSound();
			_openSound = new EmbeddedAudio.OpenSound();
			_firstName = firstName;
			_secondName = secondName;
			_toolTipItems = [];
			_animMan = new AnimationManager();
			_isNameEditMode = false;
			_isLocalPet = isLocalPet;
			_isLeashed = isLeashed;
			_petFoodCount = petFoodCount;
			_canName = canName;
			
			_mask = new Sprite();
			
			_back = new Sprite();
			
			_maskedDisplay = new Sprite();
			_maskedDisplay.mask = _mask;
			
			_border = new Sprite();
			
			var defaultImage:Sprite = new Sprite();
			defaultImage.graphics.beginFill(0);
			defaultImage.graphics.drawRoundRect(0, 0, 100, 100, 10, 10);
			_image = defaultImage;
			
			_awards = new PetTrophyPanel();
			_awards.setCount(0);
			_awards.name = 'Coming soon.';
			addToolTipItem(_awards);
			
			_food = new PetFoodPanel();
			_food.setCount(petFoodCount);
			_food.name = 'Food';
			addToolTipItem(_food);
			
			_nameField = new TextFieldPanelWithArrow(_width, 32);
			_nameField.value = StringUtil.GetStringWithinCharacterLimit(_firstName + ' ' + _secondName, 19);
			_nameField.name = 'Name Pet';
			if (_isLocalPet)
			{
				addToolTipItem(_nameField);
			}
			else
			{
				_nameField.useArrow = false;
			}
			
			_energyMeter = new PetEnergyPanel();
			_energyMeter.name = 'Food increases energy.'
			addToolTipItem(_energyMeter);
			
			_happyMeter = new PetHappinessPanel();
			_happyMeter.name = 'Play increases happiness.'
			addToolTipItem(_happyMeter);
			
			_toolTipField = new TextField();
			_toolTipField.defaultTextFormat = new TextFormat('EuroStyle', 14, 0xffffff, true);
			_toolTipField.autoSize = TextFieldAutoSize.LEFT;
			_toolTipField.selectable = false;
			_toolTipField.mouseEnabled = false;
			_toolTipField.embedFonts = true;
			_toolTipField.filters = [_STROKE_FILTER];
			
			_actionButtonsContainer = new Sprite();
			
			// Add listeners.
			_nameField.addEventListener(MouseEvent.MOUSE_DOWN, onNameMouseDown);
			
			super(width, height);
			
			// Add buttons.
			setupActionButtons();
			
			render();
			
			// Add displays.
			addChild(_mask);
			addChild(_maskedDisplay);
			_maskedDisplay.addChild(_back);
			_maskedDisplay.addChild(_awards);
			_maskedDisplay.addChild(_food);
			_maskedDisplay.addChild(_energyMeter);
			_maskedDisplay.addChild(_happyMeter);
			addChild(_nameField);
			addChild(_toolTipField);
			addChild(_border);
			addChild(_image);
			addChild(_actionButtonsContainer);
		}
		
		////////////////////
		// PUBLIC FUNCTION
		////////////////////
		
		public function destroy():void
		{
			// Handle clean up.
			
			// Remove listeners.
			_nameField.removeEventListener(MouseEvent.MOUSE_DOWN, onNameMouseDown);
			
			// Clean object cleanup methods.
			_animMan.dispose();
			_nameField.destroy();
			
			// Remove displays.
			removeChild(_mask);
			removeChild(_maskedDisplay);
			removeChild(_nameField);
			removeChild(_toolTipField);
			removeChild(_border);
			removeChild(_image);
			removeChild(_actionButtonsContainer);
			
			// Remove references.
			_animMan = null;
			_overSound = null;
			_openSound = null;
			_mask = null;
			_maskedDisplay = null;
			_nameField = null;
			_toolTipField = null;
			_border = null;
			_image = null;
			_actionButtonsContainer = null;
		}
		
		public function onFirstNameEditStart():void
		{
			// Show a list of available first names for the user to choose for their pet.
			var names:Array = _validFirstPetNames;
			showNameSelectionList(names, true);
		}
		
		public function onSecondNameEditStart():void
		{
			// Show a list of available second names for the user to choose for their pet.
			var names:Array = _validSecondPetNames;
			showNameSelectionList(names, false);
		}
		
		public function doImageSwap(image:DisplayObject, fadeDuration:int = 200, onCompleteCallback:Function = null):void
		{
			// Swap in a new image with an animation.
			var oldImage:DisplayObject = _image;
			_image = image;
			
			// Size and position the new image.
			var scale:Number = Math.min(100 / _image.width, 100 / _image.height);
			_image.width *= scale;
			_image.height *= scale;
			_image.x = 10;
			_image.y = -10;
			// Set alpha to 0 so we can fade it in.
			_image.alpha = 0;
			// Add new image to display.
			addChildAt(_image, getChildIndex(_border) + 1);
			
			// Fade out old image.
			_animMan.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animMan.alpha(oldImage, 0, fadeDuration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			// Fade in new image.
			_animMan.alpha(_image, 1, fadeDuration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			function onAnimFinish(e:AnimationEvent):void
			{
				// Make sure fade is complete.
				if (e.animTarget == oldImage && oldImage.alpha == 0)
				{
					_animMan.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					// Remove old image.
					removeChild(oldImage);
					oldImage = null;
					
					// Callback.
					if (onCompleteCallback != null) onCompleteCallback();
					onCompleteCallback = null;
				}
			}
		}
		
		public function setEnergyLevel(value:Number):void
		{
			_energyMeter.bar.gotoAndStop(getMeterFrameFromLevel(value));
		}
		
		public function setHappinessLevel(value:Number):void
		{
			_happyMeter.bar.gotoAndStop(getMeterFrameFromLevel(value));
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		override protected function render():void
		{
			var corner:int = 20;
			
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_width, _height, Math.PI / 2);
			_back.graphics.clear();
			_back.graphics.beginGradientFill(GradientType.LINEAR, [0x89c1f4, 0x263ca1], [1, 1], [1, 255], gradMatrix);
			_back.graphics.drawRoundRect(0, 0, _width, _height, corner, corner);
			
			// Masks.
			_mask.graphics.clear();
			_mask.graphics.beginFill(0);
			_mask.graphics.drawRoundRect(0, 0, _width, _height, corner, corner);
			
			_border.graphics.clear();
			_border.graphics.lineStyle(2, 0, 1, true);
			_border.graphics.drawRoundRect(0, 0, _width, _height, corner, corner);
			
			_image.x = 10;
			_image.y = -10;
			
			_awards.x = _width - _awards.width - 10;
			_awards.y = 10;
			
			_food.x = _width - _food.width - 10;
			_food.y = _awards.y + _awards.height + 5;
			
			_nameField.width = _width - 20;
			_nameField.x = 10;
			_nameField.y = _image.y + _image.height + 10;
			
			_energyMeter.x = _width / 2 - _energyMeter.width / 2;
			_energyMeter.y = _nameField.y + _nameField.height + 10;
			
			_happyMeter.x = _width / 2 - _happyMeter.width / 2;
			_happyMeter.y = _energyMeter.y + _energyMeter.height + 10;
			
			renderActionButtons();
			
			renderActionButtonLabel();
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function addActionButton(btn:Sprite, clickEvent:String, clickLabel:String):void
		{
			var btnRect:Rectangle = btn.getRect(btn);
			var btnContainer:Sprite = new Sprite();
			btn.x = -btnRect.x;
			btn.y = -btnRect.y;
			btnContainer.addChild(btn);
			btn = btnContainer;
			
			btn.name = clickLabel;
			addToolTipItem(btn);
			
			btn.addEventListener(MouseEvent.ROLL_OVER, onActionButtonOver);
			btn.addEventListener(MouseEvent.ROLL_OUT, onActionButtonRollOut);
			btn.addEventListener(MouseEvent.MOUSE_DOWN, onActionButtonMouseDown);
			
			btn.buttonMode = true;
			_actionButtonsContainer.addChild(btn);
			_actionButtons.push(btn);
			_clickEvents.push(clickEvent);
			_clickLabels.push(clickLabel);
		}
		
		private function renderActionButtons():void
		{
			var i:int = 0;
			var len:int = _actionButtons.length;
			var lastBtnRight:Number = 0;
			var space:Number = 5;
			for (i; i < len; i++)
			{
				var btn:Sprite = _actionButtons[i];
				btn.x = lastBtnRight;
				lastBtnRight = btn.x + btn.width + space;
			}
			
			_actionButtonsContainer.x = _width / 2 - _actionButtonsContainer.width / 2;
			_actionButtonsContainer.y = _height - _actionButtonsContainer.height * 0.7;
		}
		
		private function renderActionButtonLabel():void
		{
			_toolTipField.x = _width / 2 - _toolTipField.width / 2;
			_toolTipField.y = _actionButtonsContainer.y - _toolTipField.height - 10;
		}
		
		private function setActionLabel(text:String):void
		{
			_toolTipField.text = text;
			renderActionButtonLabel();
		}
		
		private function addToolTipItem(item:DisplayObject):void
		{
			// Make sure the item has not already been added.
			var index:int = _toolTipItems.indexOf(item);
			if (index > -1) return;
			
			item.addEventListener(MouseEvent.ROLL_OVER, onToolTipItemOver);
			_toolTipItems.push(item);
		}
		
		private function removeToolTipItem(item:DisplayObject):void
		{
			var index:int = _toolTipItems.indexOf(item);
			if (index < 0) return;
			
			item.removeEventListener(MouseEvent.ROLL_OVER, onToolTipItemOver);
			
			_toolTipItems.splice(index);
		}
		
		private function removeAllToolTipItems():void
		{
			var i:int = 0;
			var len:int = _toolTipItems.length;
			for (i; i < len; i++)
			{
				var item:DisplayObject = _toolTipItems[i];
				item.removeEventListener(MouseEvent.ROLL_OVER, onToolTipItemOver);
			}
			
			_toolTipItems = [];
		}
		
		private function hideActionButtons():void
		{
			_animMan.alpha(_actionButtonsContainer, 0, 500, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.alpha(_toolTipField, 0, 500, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}
		
		private function showActionButtons():void
		{
			_animMan.alpha(_actionButtonsContainer, 1, 500, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.alpha(_toolTipField, 1, 500, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}
		
		private function showNameSelectionList(names:Array, isFirstName:Boolean = true):void
		{
			// Show a list of available names for the user to choose for their pet.
			// Determine index of currently selected name.
			var currentName:String = (isFirstName) ? _firstName : _secondName;
			// Sort name list alphabetically.
			names = names.sort();
			var index:int = names.indexOf(currentName);
			var nameList:TextListPanelPaged = new TextListPanelPaged(names, index, _width - 20, _height + 20);
			nameList.addEventListener(SelectedEvent.SELECTED, onNameSelected);
			
			// Store reference to name selection list.
			_currentNameSelectionList = nameList;
			
			// Play open sound.
			_openSound.play();
			
			// Animate in the name list.
			var duration:int = 200;
			var minScale:Number = 0.5;
			nameList.alpha = 0;
			nameList.scaleX = nameList.scaleY = minScale;
			var x1:Number = _width / 2 - nameList.width * minScale / 2;
			var y1:Number = _height / 2 - nameList.height * minScale / 2;
			nameList.x = x1;
			nameList.y = y1;
			addChild(nameList);
			_animMan.alpha(nameList, 1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.scale(nameList, 1, 1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.move(nameList, 10, -10, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			function onNameSelected(e:SelectedEvent):void
			{
				// Remove listener.
				nameList.removeEventListener(SelectedEvent.SELECTED, onNameSelected);
				
				// Set name based on selection.
				var name:String = nameList.getTextAt(e.index);
				if (isFirstName)
				{
					firstName = name;
				}
				else
				{
					secondName = name;
				}
				
				// Hide name list.
				hideNameSelectionList();
			}
		}
		
		private function hideNameSelectionList():void
		{
			// Hide name list.
			// Animate in the name list.
			var duration:int = 200;
			var minScale:Number = 0.5;
			var x1:Number = _width / 2 - _currentNameSelectionList.width * minScale / 2;
			var y1:Number = _height / 2 - _currentNameSelectionList.height * minScale / 2;
			_animMan.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animMan.alpha(_currentNameSelectionList, 0, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.scale(_currentNameSelectionList, minScale, minScale, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.move(_currentNameSelectionList, x1, y1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			function onAnimFinish(e:AnimationEvent):void
			{
				// CHeck if done hiding name list.
				if (e.animTarget == _currentNameSelectionList && _currentNameSelectionList.alpha == 0)
				{
					// Done hiding name list.
					_animMan.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					removeChild(_currentNameSelectionList);
					
					// Remove reference.
					_currentNameSelectionList = null;
				}
			}
		}
		
		private function setupActionButtons():void
		{
			removeActionButtons();
			
			// Add buttons.
			
			// Only show the feed button if the pet is owned by the local user.
			if (_isLocalPet) addActionButton(new CircleIconPetsFeed(), RoomItemCircleMenuEvent.CLICK_FEED_PET, 'Feed');
			addActionButton(new CircleIconPetsPlay(), RoomItemCircleMenuEvent.CLICK_PLAY_PET, 'Play');
			
			// Use leash or unleash button. (ONLY IF PET IS OWNED BY LOCAL USER)
			if (_isLocalPet) addActionButton(new CircleIconPetsLeash(), RoomItemCircleMenuEvent.CLICK_LEASH_PET, (_isLeashed) ? 'Unleash' : 'Leash');
			
			// Render action buttons.
			renderActionButtons();
		}
		
		private function removeActionButtons():void
		{
			// Remove all action buttons.
			var i:int = 0;
			var len:int = _actionButtons.length;
			if (!len) return;
			for (i; i < len; i++)
			{
				// Remove event listeners.
				var btn:DisplayObject = _actionButtons[i];
				btn.removeEventListener(MouseEvent.ROLL_OVER, onActionButtonOver);
				btn.removeEventListener(MouseEvent.ROLL_OUT, onActionButtonRollOut);
				btn.removeEventListener(MouseEvent.MOUSE_DOWN, onActionButtonMouseDown);
				
				// Remove from display.
				_actionButtonsContainer.removeChild(btn);
			}
			
			// Empty action buttons arrays.
			_actionButtons = [];
			_clickEvents = [];
			_clickLabels = [];
		}
		
		private function loadValidPetNames():void
		{
			var url:String = Environment.getApplicationUrl() + '/test/petName';
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onNameListComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onNameListError);
			loader.load(request);
		}
		
		private function getMeterFrameFromLevel(level:Number):int
		{
			// Get a frame number that the energy/happiness bar should be set to based on a level from 0 to 1.
			var totalFrames:int = 4;
			return Math.ceil(totalFrames * level);
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public function get firstName():String
		{
			return _firstName;
		}
		public function set firstName(value:String):void
		{
			if (value == _firstName) return;
			_firstName = value;
			_nameField.value = StringUtil.GetStringWithinCharacterLimit(_firstName + ' ' + _secondName, 19);
			if (_currentNameEditPanel) _currentNameEditPanel.firstName = _firstName;
		}
		
		public function get secondName():String
		{
			return _secondName;
		}
		public function set secondName(value:String):void
		{
			if (value == _secondName) return;
			_secondName = value;
			_nameField.value = StringUtil.GetStringWithinCharacterLimit(_firstName + ' ' + _secondName, 19);
			if (_currentNameEditPanel) _currentNameEditPanel.secondName = _secondName;
		}
		
		public function get isLeashed():Boolean
		{
			return _isLeashed;
		}
		public function set isLeashed(value:Boolean):void
		{
			if (value == _isLeashed) return;
			_isLeashed = value;
			setupActionButtons();
		}
		
		public function get image():DisplayObject
		{
			return _image;
		}
		
		public function get petFoodCount():int
		{
			return _petFoodCount;
		}
		public function set petFoodCount(value:int):void
		{
			if (value == _petFoodCount) return;
			_petFoodCount = value;
			_food.setCount(_petFoodCount);
		}
		
		public function get foodVisible():Boolean
		{
			return _food.visible;
		}
		public function set foodVisible(value:Boolean):void
		{
			_food.visible = value;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onActionButtonOver(e:MouseEvent):void
		{
			var btn:DisplayObject = e.currentTarget as DisplayObject;
			var index:int = _actionButtons.indexOf(btn);
			var clickLabel:String = _clickLabels[index];
			
			btn.filters = [_ACTION_BUTTON_STROKE];
			setActionLabel(clickLabel);
			
			// Play over sound.
			_overSound.play();
		}
		
		private function onActionButtonRollOut(e:MouseEvent):void
		{
			var btn:DisplayObject = e.currentTarget as DisplayObject;
			
			btn.filters = [];
		}
		
		private function onActionButtonMouseDown(e:MouseEvent):void
		{
			var btn:DisplayObject = e.currentTarget as DisplayObject;
			var index:int = _actionButtons.indexOf(btn);
			var clickEvent:String = _clickEvents[index];
			
			// PLay open sound.
			_openSound.play();
			
			dispatchEvent(new Event(clickEvent));
		}
		
		private function onToolTipItemOver(e:MouseEvent):void
		{
			var toolTipItem:DisplayObject = e.currentTarget as DisplayObject;
			setActionLabel(toolTipItem.name);
			
			toolTipItem.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			
			function onRollOut(e:MouseEvent):void
			{
				toolTipItem.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				if (_toolTipField) _toolTipField.text = '';
			}
		}
		
		private function onNameMouseDown(e:MouseEvent):void
		{
			// Go into name edit mode.
			// Make sure it is the local pet. (Owned by the local user)
			if (!_isLocalPet) return;
			if (_isNameEditMode) return;
			
			// Make sure we should be able to name pet.
			if (!_canName)
			{
				dispatchEvent(new Event(ATTEMPT_NAME_PET));
				return;
			}
			
			_isNameEditMode = true;
			
			// Use an animation effect to make it look like the bottom half of the card slides down to reveal an underlying interface.
			// To do this, we will make a bitmap copy of the bottom portion of the card.
			// Then we will animate that bitmap downward.
			// We will also create the name editing interface which will be revealed once the bitmap copy has slid all the way down.
			
			// Set up parameters and make a bitmap copy of the bottom portion of the card.
			// Determine the Y coordinate of where the bottom portion starts.
			// We want this to be just below the name field.
			var cutOffY:Number = _nameField.y + _nameField.height + 5;
			var bitmapData2:BitmapData = new BitmapData(_width, _height - cutOffY, false, 0x00ff00);
			_maskedDisplay.mask = null;
			bitmapData2.draw(_maskedDisplay, new Matrix(1, 0, 0, 1, 0, -cutOffY));
			_maskedDisplay.mask = _mask;
			var bitmap2:Bitmap = new Bitmap(bitmapData2);
			var bottomOfCard:Sprite = new Sprite();
			bottomOfCard.addChild(bitmap2);
			bottomOfCard.y = cutOffY;
			// Determine how far down the bitmap should slide.
			var bottom:Number = _height - 60;
			
			// Create the interface that will be revealed underneath the bottom of the card.
			var nameEditInterface:PetNameEditPanel = new PetNameEditPanel(_width, bottom - cutOffY, _firstName, _secondName);
			nameEditInterface.delegate = this;
			nameEditInterface.y = cutOffY;
			_currentNameEditPanel = nameEditInterface;
			
			// Determine if the list of valid pet names have already been loaded.
			if (!_validFirstPetNames)
			{
				// The list of valid names has not been loaded.
				// Load the list.
				nameEditInterface.showFields = false;
				nameEditInterface.showStatusMessage = true;
				loadValidPetNames();
			}
			else
			{
				// The list of valid names has already been loaded.
				nameEditInterface.showStatusMessage = false;
			}
			
			// Add the name editing interface and the bitmap copy that will be animated down.
			_maskedDisplay.addChild(nameEditInterface);
			_maskedDisplay.addChild(bottomOfCard);
			
			// Hide the action buttons.
			hideActionButtons();
			
			// Play open sound.
			_openSound.play();
			
			// Create a list of objects that, if clicked, will trigger the bottom of the card to move back into its original position.
			var closeObjects:Array = [_back, _border, _image, _awards, _food, _nameField, bottomOfCard];
			
			// Animate the bitmap (bottom of the card).
			_animMan.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animMan.move(bottomOfCard, bottomOfCard.x, bottom, 400, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			function onAnimFinish(e:AnimationEvent):void
			{
				// Determine which animation has finished.
				if (e.animTarget == bottomOfCard && bottomOfCard.y == bottom)
				{
					// The bottom of the card has fully animated down.
					// Open.
					
					// Remove listener.
					_animMan.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					
					// Listen for mouse click so we know when to move the card back up.
					handleCloseTriggerListeners(true);
				}
				else if (e.animTarget == bottomOfCard && bottomOfCard.y == cutOffY)
				{
					// The bottom of the card has finished moving back up.
					// Closed.
					
					// Remove listener.
					_animMan.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					
					// Remove bitmap copy of the bottom of the card and remove the name editing interface.
					_maskedDisplay.removeChild(nameEditInterface);
					_maskedDisplay.removeChild(bottomOfCard);
					
					// Cleanup.
					clean();
					
					// Set flag.
					_isNameEditMode = false;
				}
			}
			
			function onCloseObjectMouseDown(e:MouseEvent):void
			{
				// When the mouse has been clicked on a designated object, hide the name editing interface.
				
				// Make sure we are not currently selecting a name from the name drop down.
				if (_currentNameSelectionList)
				{
					hideNameSelectionList();
					return;
				}
				
				// Remove listeners.
				handleCloseTriggerListeners(false);
				
				// Animate the bottom of the card back into its original position.
				_animMan.addEventListener(AnimationEvent.FINISH, onAnimFinish);
				_animMan.move(bottomOfCard, bottomOfCard.x, cutOffY, 400, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				
				// Show the action buttons again.
				showActionButtons();
				
				// Dispatch an event that signifies a new pet name has been selected.
				dispatchEvent(new Event(SELECTED_PET_NAME));
			}
			
			function handleCloseTriggerListeners(addListeners:Boolean):void
			{
				// Add/remove listeners to a list of objects that will trigger the bottom of the card to move into its original position.
				var i:int = 0;
				var len:int = closeObjects.length;
				for (i; i < len; i++)
				{
					var object:DisplayObject = closeObjects[i];
					if (addListeners)
					{
						object.addEventListener(MouseEvent.MOUSE_DOWN, onCloseObjectMouseDown);
					}
					else
					{
						object.removeEventListener(MouseEvent.MOUSE_DOWN, onCloseObjectMouseDown);
					}
				}
			}
			
			function clean():void
			{
				// Handle some cleanup work.
				
				nameEditInterface.destroy();
				
				_currentNameEditPanel = null;
				closeObjects = null;
				bitmapData2.dispose();
				bitmapData2 = null;
				bitmap2 = null;
				bottomOfCard = null;
				nameEditInterface = null;
			}
		}
		
		private function onNameListComplete(e:Event):void
		{
			// Finished loading the list of valid pet names.
			// Parse them and store them in a static variable.
			var petNamesXml:XML = new XML(URLLoader(e.currentTarget).data);
			var firstNamesXml:XML = petNamesXml.PetNames.firstNames[0];
			var secondNamesXml:XML = petNamesXml.PetNames.lastNames[0];
			
			// Parse out names and store in an array.
			var i:int = 0;
			var len:int = firstNamesXml.children().length();
			var firstNames:Array = [];
			for (i; i < len; i++)
			{
				var firstName:String = firstNamesXml.firstName[i].@name;
				firstNames.push(firstName);
			}
			
			// Parse out second names and store in an array.
			i = 0;
			len = secondNamesXml.children().length();
			var secondNames:Array = [];
			for (i; i < len; i++)
			{
				var secondName:String = secondNamesXml.lastName[i].@name;
				secondNames.push(secondName);
			}
			
			// Set in static variables.
			_validFirstPetNames = firstNames;
			_validSecondPetNames = secondNames;
			
			// If there is a current name edit panel.
			// Change the status.
			_currentNameEditPanel.showStatusMessage = false;
			_currentNameEditPanel.showFields = true;
		}
		
		private function onNameListError(e:IOErrorEvent):void
		{
			// Unable to load the list of valid pet names, for some reason.
			trace(e.text);
		}
		
	}
}