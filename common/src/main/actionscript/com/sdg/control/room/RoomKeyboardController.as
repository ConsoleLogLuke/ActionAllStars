package com.sdg.control.room
{
	import com.sdg.core.KeyboardCapture;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;

	public class RoomKeyboardController extends EventDispatcher
	{
		public static const INPUT_DIRECTION:String = 'input direction';
		private static const _DEFAULT_INPUT_DIRECTION_DELAY:int = 100;
		
		private var _keyboardControl:KeyboardCapture;
		private var _inputDirection:Point;
		private var _keyDownHandlers:Array;
		private var _keyUpHandlers:Array;
		private var _inputDirectionDelay:int;
		private var _inputDelayTimer:Timer;
		private var _inputDirectionTemp:Point;
		private var _keyIsDown:Array;
		
		public function RoomKeyboardController(stage:Stage)
		{
			super();
			
			_inputDirection = new Point();
			_inputDirectionTemp = new Point();
			_keyDownHandlers = [];
			_keyUpHandlers = [];
			_keyIsDown = [];
			_inputDirectionDelay = _DEFAULT_INPUT_DIRECTION_DELAY;
			_inputDelayTimer = new Timer(_inputDirectionDelay);
			
			// Add listeners.
			_inputDelayTimer.addEventListener(TimerEvent.TIMER, onInputDelayTimer);
			
			// W, A, S, D
			_keyboardControl = new KeyboardCapture(stage);
			_keyboardControl.addKeyCodes(87, 65, 83, 68);
			_keyboardControl.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_keyboardControl.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		public function destroy():void
		{
			_inputDelayTimer.removeEventListener(TimerEvent.TIMER, onInputDelayTimer);
			_inputDelayTimer.reset();
			_inputDelayTimer = null;
			
			_keyboardControl.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_keyboardControl.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			_keyboardControl.removeAllKeyCodes();
			_keyboardControl = null;
			_keyDownHandlers = null;
			_keyUpHandlers = null;
		}
		
		public function addKeyDownHandler(keyCode:uint, keyHandler:Function):void
		{
			// Attach handler funtions to specfic key presses.
			// Keep track of them in an array.
			// Each key code can have multiple handlers.
			var keyDownHandlers:Array = _keyDownHandlers[keyCode];
			if (!keyDownHandlers) keyDownHandlers = [];
			keyDownHandlers.push(keyHandler);
			_keyDownHandlers[keyCode] = keyDownHandlers;
			
			// Make sure the keyboard controller is set to handle this key code.
			_keyboardControl.addKeyCode(keyCode);
		}
		
		public function addKeyUpHandler(keyCode:uint, keyHandler:Function):void
		{
			// Attach handler funtions to specfic key releases.
			// Keep track of them in an array.
			// Each key code can have multiple handlers.
			var keyUpHandlers:Array = _keyUpHandlers[keyCode];
			if (!keyUpHandlers) keyUpHandlers = [];
			keyUpHandlers.push(keyHandler);
			_keyUpHandlers[keyCode] = keyUpHandlers;
			
			// Make sure the keyboard controller is set to handle this key code.
			_keyboardControl.addKeyCode(keyCode);
		}
		
		public function removeKeyDownHandler(keyCode:uint, keyHandler:Function):void
		{
			// Remove a specific key down handler attached to a key code.
			var keyDownHandlers:Array = _keyDownHandlers[keyCode];
			if (!keyDownHandlers) return;
			var index:int = keyDownHandlers.indexOf(keyHandler);
			if (index > -1) keyDownHandlers.splice(index, 1);
		}
		
		public function removeKeyUpHandler(keyCode:uint, keyHandler:Function):void
		{
			// Remove a specific key up handler attached to a key code.
			var keyUpHandlers:Array = _keyUpHandlers[keyCode];
			if (!keyUpHandlers) return;
			var index:int = keyUpHandlers.indexOf(keyHandler);
			if (index > -1) keyUpHandlers.splice(index, 1);
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function setTempInputDirection(x:Number, y:Number):void
		{
			// Use a delay in input direction.
			// This prevents rapid unintentional changes in input direction from the user.
			// For example if the user is pressing right, then quickly releases right and presses up;
			// We want to ignore the period of time that the input direction is momentarily 0.
			// Adjust "_inputDirectionDelay" as needed.
			_inputDirectionTemp.x = x;
			_inputDirectionTemp.y = y;
			_inputDelayTimer.reset();
			if (x == 0 && y == 0)
			{
				_inputDelayTimer.start();
			}
			else
			{
				_inputDirection.x = x;
				_inputDirection.y = y;
				dispatchEvent(new Event(INPUT_DIRECTION));
			}
		}
		
		private function areAnyOfTheseKeysDown(keyCodes:Array):Boolean
		{
			var i:int = 0;
			var len:int = keyCodes.length;
			for (i; i < len; i++)
			{
				if (_keyIsDown[keyCodes[i]]) return true;
			}
			
			return false;
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public function get inputDirection():Point
		{
			return _inputDirection.clone();
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			// Handle input direction.
			switch (e.keyCode)
			{
				case 87:
					// W
					setTempInputDirection(_inputDirectionTemp.x - 1, _inputDirectionTemp.y - 1);
					break;
				case 65:
					// A
					setTempInputDirection(_inputDirectionTemp.x - 1, _inputDirectionTemp.y + 1);
					break;
				case 83:
					// S
					setTempInputDirection(_inputDirectionTemp.x + 1, _inputDirectionTemp.y + 1);
					break;
				case 68:
					// D
					setTempInputDirection(_inputDirectionTemp.x + 1, _inputDirectionTemp.y - 1);
					break;
			}
			
			// Set key down flag.
			_keyIsDown[e.keyCode] = true;
			
			// Call key down handlers.
			var keyDownHandlers:Array = _keyDownHandlers[e.keyCode];
			var i:int = 0;
			var len:int = (keyDownHandlers) ? keyDownHandlers.length : 0;
			for (i; i < len; i++)
			{
				var handler:Function = keyDownHandlers[i];
				handler(e);
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			// Handle input direction.
			switch (e.keyCode)
			{
				case 87:
					// W
					setTempInputDirection(_inputDirectionTemp.x + 1, _inputDirectionTemp.y + 1);
					break;
				case 65:
					// A
					setTempInputDirection(_inputDirectionTemp.x + 1, _inputDirectionTemp.y - 1);
					break;
				case 83:
					// S
					setTempInputDirection(_inputDirectionTemp.x - 1, _inputDirectionTemp.y - 1);
					break;
				case 68:
					// D
					setTempInputDirection(_inputDirectionTemp.x - 1, _inputDirectionTemp.y + 1);
					break;
			}
			
			// Set key down flag.
			_keyIsDown[e.keyCode] = false;
			
			// If no direction keys are down, set input direction to 0.
			// This is to address an issue where the input direction would become stuck in invalid values.
			if ((_inputDirectionTemp.x != 0 && _inputDirectionTemp.y != 0) && !areAnyOfTheseKeysDown([87, 65, 83, 68])) setTempInputDirection(0, 0);
			
			// Call key up handlers.
			var keyUpHandlers:Array = _keyUpHandlers[e.keyCode];
			var i:int = 0;
			var len:int = (keyUpHandlers) ? keyUpHandlers.length : 0;
			for (i; i < len; i++)
			{
				var handler:Function = keyUpHandlers[i];
				handler(e);
			}
		}
		
		private function onInputDelayTimer(e:TimerEvent):void
		{
			_inputDelayTimer.reset();
			if (_inputDirection.x == _inputDirectionTemp.x && _inputDirection.y == _inputDirectionTemp.y) return;
			_inputDirection.x = _inputDirectionTemp.x;
			_inputDirection.y = _inputDirectionTemp.y;
			dispatchEvent(new Event(INPUT_DIRECTION));
		}
		
	}
}