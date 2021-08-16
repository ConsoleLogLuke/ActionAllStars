package com.sdg.view.room
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.audio.EmbeddedAudio;
	import com.sdg.events.room.item.RoomItemCircleMenuEvent;
	import com.sdg.model.button.ButtonDefinition;
	import com.sdg.util.AssetUtil;
	import com.sdg.view.list.CircleListView;
	import com.sdg.view.list.CircleListViewWithPages;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class RoomItemCircleMenu extends Sprite
	{
		private static var _jabIcons:Array = []; // Mapped [jabId:int] > [jabIcon:DisplayObject]
		private static var _emoteIcons:Array = []; // Mapped [emoteId:int] > [emoteIcon:DisplayObject]
		
		protected var _animMan:AnimationManager;
		protected var _defaultRadius:Number;
		protected var _label:TextField;
		protected var _startMax:Number;
		protected var _endMax:Number;
		
		private var _isShown:Boolean;
		private var _defaultLabel:String;
		private var _buttonDefinitions:Array;
		private var _circleViews:Array;
		private var _currentCircleViewIndex:int;
		private var _buttons:Array;
		private var _openSound:Sound;
		private var _overSound:Sound;
		
		public function RoomItemCircleMenu(defaultLabel:String = 'Item', defaultRadius:Number = 60)
		{
			super();
			
			_animMan = new AnimationManager();
			
			_defaultRadius = defaultRadius;
			_isShown = true;
			_defaultLabel = defaultLabel;
			_startMax = -Math.PI * 1.3;
			_endMax = Math.PI * 0.3;
			_buttonDefinitions = [];
			_circleViews = [];
			_currentCircleViewIndex = 0;
			_buttons = [];
			_openSound = new EmbeddedAudio.OpenSound();
			_overSound = new EmbeddedAudio.OverSound();
			
			_label = new TextField();
			_label.defaultTextFormat = new TextFormat('EuroStyle', 16, 0xffffff, true);
			_label.autoSize = TextFieldAutoSize.LEFT;
			_label.filters = [new GlowFilter(0x000000, 1, 5, 5, 10)];
			_label.mouseEnabled = false;
			_label.embedFonts = true;
			setLabel(_defaultLabel);
			
			var lb:Sprite = new CircleIconArrowLeft();
			setupButton(lb, 'left', 'More');
			var rb:Sprite = new CircleIconArrowRight();
			setupButton(rb, 'right', 'More');
			
			var rootCircleView:CircleListView = new CircleListViewWithPages(_defaultRadius, 6, lb, rb);
			rootCircleView.start = _startMax;
			rootCircleView.end = _endMax;
			_circleViews.push(rootCircleView);
			
			addChild(rootCircleView);
			addChild(_label);
		}
		
		//////////////////////
		// PUBLIC FUNCTIONS
		//////////////////////
		
		public static function addEmoteIcon(emoteId:int):void
		{
			// Load the emote icon and store it in a static array.
			// If we already have an icon at this id, do nothing.
			if (_emoteIcons[emoteId]) return;
			var url:String = AssetUtil.GetEmoteIconUrl(emoteId);
			addRemoteIcon(emoteId, url, _emoteIcons);
		}
		
		public static function addJabIcon(jabId:int):void
		{
			// Load the jab icon and store it in a static array.
			// If we already have an icon at this id, do nothing.
			if (_jabIcons[jabId]) return;
			var url:String = AssetUtil.GetJabIconUrl(jabId);
			addRemoteIcon(jabId, url, _jabIcons);
		}
		
		public static function getJabIcon(id:int):DisplayObject
		{
			return _jabIcons[id];
		}
		
		public static function getEmoteIcon(id:int):DisplayObject
		{
			return _emoteIcons[id];
		}
		
		public function destroy():void
		{
			_animMan.removeAll();
			
			// Remove label from display.
			removeChild(_label);
			
			// Remove current circle view from display.
			var currentCircleView:CircleListView = getCurrentCircleView();
			removeChild(currentCircleView);
			
			// Un-setup ALL buttons.
			var i:int = 0;
			var len:int = _buttonDefinitions.length;
			for (i; i < len; i++)
			{
				var def:ButtonDefinition = _buttonDefinitions[i];
				var btn:Sprite = def.display;
				btn.removeEventListener(MouseEvent.CLICK, onButtonClick);
				btn.removeEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			}
			
			// Destroy ALL circle views.
			len = _circleViews.length;
			i = len - 1;
			for (i; i > -1; i--)
			{
				var view:CircleListView = _circleViews[i];
				view.destroy();
			}
			
			// Remove object references.
			_buttons = null;
			_buttonDefinitions = null;
			_circleViews = null;
			_label = null;
			_animMan = null;
			_openSound = null;
			_overSound = null;
			
			dispatchEvent(new RoomItemCircleMenuEvent(RoomItemCircleMenuEvent.DESTROY));
		}
		
		public function hide(animate:Boolean = false):void
		{
			// Hide the current circle view.
			
			// Dispatch a hide start event.
			dispatchEvent(new RoomItemCircleMenuEvent(RoomItemCircleMenuEvent.HIDE_START));
			
			// Get reference to current circle view.
			var currentCircleView:CircleListView = getCurrentCircleView();
			
			if (!animate)
			{
				currentCircleView.visible = false;
				currentCircleView.alpha = 0;
				_label.visible = false;
				_label.alpha = 0;
				
				dispatchEvent(new RoomItemCircleMenuEvent(RoomItemCircleMenuEvent.HIDE_FINISH));
			}
			else
			{
				var duration:Number = 200;
				_label.alpha = 1;
				currentCircleView.radius = _defaultRadius;
				currentCircleView.start = _startMax;
				currentCircleView.end = _endMax;
				_animMan.addEventListener(AnimationEvent.FINISH, onAnimFinish);
				_animMan.property(currentCircleView, 'start', -Math.PI * 1.5, duration, Transitions.BACK_IN, RenderMethod.TIMER);
				_animMan.property(currentCircleView, 'end', -Math.PI * 1.5, duration, Transitions.BACK_IN, RenderMethod.TIMER);
				_animMan.property(currentCircleView, 'radius', 0, duration, Transitions.BACK_IN, RenderMethod.TIMER);
				_animMan.alpha(currentCircleView, 0, duration, Transitions.BACK_IN, RenderMethod.TIMER);
				
				_animMan.alpha(_label, 0, duration, Transitions.EXPO_OUT, RenderMethod.TIMER);
			}
			
			_isShown = false;
			
			function onAnimFinish(e:AnimationEvent):void
			{	
				if (e.animTarget == _label && e.animProperty == 'alpha' && _label.alpha == 0)
				{
					// Remove event listener.
					_animMan.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					
					currentCircleView.visible = false;
					_label.visible = false;
					
					dispatchEvent(new RoomItemCircleMenuEvent(RoomItemCircleMenuEvent.HIDE_FINISH));
				}
			}
		}
		
		public function show(animate:Boolean = false):void
		{
			// Show the current circle view.
			
			// Get reference to current circle view.
			var currentCircleView:CircleListView = getCurrentCircleView();
			
			if (!animate)
			{
				currentCircleView.start = _startMax;
				currentCircleView.end = _endMax;
				currentCircleView.alpha = 1;
				currentCircleView.visible = true;
				_label.alpha = 1;
				_label.visible = true;
				
				// Set flag.
				_isShown = true;
				
				dispatchEvent(new RoomItemCircleMenuEvent(RoomItemCircleMenuEvent.SHOW_FINISH));
			}
			else
			{
				var duration:Number = 400;
				_label.alpha = 0;
				_label.visible = true;
				currentCircleView.alpha = 0;
				currentCircleView.visible = true;
				currentCircleView.radius = 0;
				currentCircleView.start = currentCircleView.end = -Math.PI * 1.5;
				_animMan.addEventListener(AnimationEvent.FINISH, onAnimFinish);
				_animMan.property(currentCircleView, 'start', _startMax, duration, Transitions.BACK_OUT, RenderMethod.TIMER);
				_animMan.property(currentCircleView, 'end', _endMax, duration, Transitions.BACK_OUT, RenderMethod.TIMER);
				_animMan.property(currentCircleView, 'radius', _defaultRadius, duration, Transitions.BACK_OUT, RenderMethod.TIMER);
				_animMan.alpha(currentCircleView, 1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				
				_animMan.alpha(_label, 1, duration, Transitions.EXPO_OUT, RenderMethod.TIMER);
			}
			
			// Play a sound.
			_openSound.play();
			
			function onAnimFinish(e:AnimationEvent):void
			{	
				if (e.animTarget == _label && e.animProperty == 'alpha' && _label.alpha == 1)
				{
					// Remove event listener.
					_animMan.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					
					// Set flag.
					_isShown = true;
					
					dispatchEvent(new RoomItemCircleMenuEvent(RoomItemCircleMenuEvent.SHOW_FINISH));
				}
			}
		}
		
		public function get radius():int
		{
			return _defaultRadius;
		}
		
		//////////////////////
		// PROTECTED FUNCTIONS
		//////////////////////
		
		protected function addButton(definition:ButtonDefinition):void
		{
			// Add definitions to an array.
			_buttonDefinitions.push(definition);
			// Add button displays to an array.
			_buttons.push(definition.display);
			// Setup button interactions.
			setupButton(definition.display, definition.clickEvent, definition.label);
			// Add button to list view.
			getCurrentCircleView().addItem(definition.display);
		}
		
		protected function setupButton(btn:Sprite, clickEvent:String, labelText:String):void
		{
			btn.addEventListener(MouseEvent.CLICK, onButtonClick);
			btn.addEventListener(MouseEvent.MOUSE_OVER, onButtonOver);
			
			btn.buttonMode = true;
			btn.mouseChildren = false;
		}
		
		//////////////////////
		// PRIVATE FUNCTIONS
		//////////////////////
		
		private static function addRemoteIcon(id:int, url:String, storage:Array):void
		{
			// Load the icon and store it in an array.
			var request:URLRequest = new URLRequest(url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
			
			function onComplete(e:Event):void
			{
				// Store the loaded icon in a static array.
				var icon:Sprite = new Sprite();
				icon.addChild(loader.content);
				storage[id] = icon;
				clean();
			}
			
			function onError(e:IOErrorEvent):void
			{
				clean();
			}
			
			function clean():void
			{
				// Remove listeners.
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				// Clean up references.
				loader = null;
				request = null;
			}
		}
		
		private function setLabel(value:String):void
		{
			_label.text = value;
			_label.x = -_label.width / 2;
			_label.y = _defaultRadius - _label.height / 2;
		}
		
		private function getButtonDefinitionFromMouseEvent(mouseEvent:MouseEvent):ButtonDefinition
		{
			// Get button.
			var button:DisplayObject = mouseEvent.currentTarget as DisplayObject;
			// Get index of clciked button.
			var index:int = _buttons.indexOf(button);
			if (index < 0) return null;
			// Get button definition.
			var buttonDefinition:ButtonDefinition = _buttonDefinitions[index];
			
			return buttonDefinition;
		}
		
		private function getCurrentCircleView():CircleListView
		{
			return getCircleView(_currentCircleViewIndex);
		}
		
		private function getCircleView(index:int):CircleListView
		{
			return _circleViews[index];
		}
		
		private function showChildMenu(childButtons:Array):void
		{
			var lb:Sprite = new CircleIconArrowLeft();
			setupButton(lb, 'left', 'More');
			var rb:Sprite = new CircleIconArrowRight();
			setupButton(rb, 'right', 'More');
			
			// Instantiate child menu.
			var circleMenu:CircleListViewWithPages = new CircleListViewWithPages(_defaultRadius, 5, lb, rb);
			circleMenu.start = _startMax;
			circleMenu.end = _endMax;
			// Set current circle view.
			var parentCircleMenu:CircleListView = getCurrentCircleView();
			_circleViews.push(circleMenu);
			_currentCircleViewIndex++;
			var childCircleMenu:CircleListView = circleMenu;
			// Add buttons.
			var i:int = 0;
			var len:int = childButtons.length;
			for (i; i < len; i++)
			{
				var buttonDefinition:ButtonDefinition = childButtons[i];
				addButton(buttonDefinition);
			}
			
			// Animate hide the main circle menu.
			_animMan.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animMan.scale(parentCircleMenu, 0.5, 0.5, 200, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.alpha(parentCircleMenu, 0, 200, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			// Animate show the child menu.
			childCircleMenu.scaleX = childCircleMenu.scaleY = 1.5;
			childCircleMenu.alpha = 0;
			// Add under the label.
			addChildAt(childCircleMenu, getChildIndex(_label));
			_animMan.scale(childCircleMenu, 1, 1, 200, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.alpha(childCircleMenu, 1, 200, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			function onAnimFinish(e:AnimationEvent):void
			{	
				if (e.animTarget == parentCircleMenu && e.animProperty == 'alpha' && parentCircleMenu.alpha == 0)
				{
					// Remove event listener.
					_animMan.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					
					// Remove the parent menu.
					removeChild(parentCircleMenu);
				}
			}
		}
		
		//////////////////////
		// GET/SET METHODS
		//////////////////////
		
		public function get isShown():Boolean
		{
			return _isShown;
		}
		
		//////////////////////
		// EVENT HANDLERS
		//////////////////////
		
		private function onButtonClick(e:MouseEvent):void
		{
			// Get button definition and dispatch event.
			var buttonDefinition:ButtonDefinition = getButtonDefinitionFromMouseEvent(e);
			if (!buttonDefinition) return;
			
			// Dispatch event.
			dispatchEvent(new RoomItemCircleMenuEvent(buttonDefinition.clickEvent, buttonDefinition.eventParams));
			
			// Determine if there are child buttons.
			var childButtons:Array = buttonDefinition.children;
			if (childButtons && childButtons.length > 0)
			{
				// Show a child circle menu with child buttons.
				showChildMenu(childButtons);
			}
			
			// Play a sound.
			_openSound.play();
		}
		
		private function onButtonOver(e:MouseEvent):void
		{
			// Get button definition
			var buttonDefinition:ButtonDefinition = getButtonDefinitionFromMouseEvent(e);
			
			// Make sure the circle menu is considered shown, before continuing.
			if (!_isShown) return;
			
			// Set label text.
			if (buttonDefinition) setLabel(buttonDefinition.label);
			
			var btn:DisplayObject = e.currentTarget as DisplayObject;
			btn.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown,false,0,true);
			btn.addEventListener(MouseEvent.MOUSE_UP, onMouseUp,false,0,true);
			btn.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut,false,0,true);
			addEventListener(RoomItemCircleMenuEvent.DESTROY, onDestroy);
			
			var duration:Number = 100;
			var scale:Number = 1.3;
			
			btn.transform.colorTransform = new ColorTransform(1.4, 1.4, 1.4);
			
			_animMan.scale(btn, scale, scale, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			// Play a sound.
			_overSound.play();
			
			function onMouseOut(e:MouseEvent):void
			{
				// Remove listeners.
				removeEventListener(RoomItemCircleMenuEvent.DESTROY, onDestroy);
				btn.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				btn.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				btn.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				
				btn.transform.colorTransform = new ColorTransform();
				
				setLabel(_defaultLabel);
				
				_animMan.scale(btn, 1, 1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			}
			
			function onMouseDown(e:MouseEvent):void
			{
				_animMan.scale(btn, scale * 1.2, scale, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			}
			
			function onMouseUp(e:MouseEvent):void
			{
				_animMan.scale(btn, scale, scale, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			}
			
			function onDestroy(e:RoomItemCircleMenuEvent):void
			{
				// Remove listeners.
				btn.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				btn.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				btn.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				removeEventListener(RoomItemCircleMenuEvent.DESTROY, onDestroy);
			}
		}
		
	}
}