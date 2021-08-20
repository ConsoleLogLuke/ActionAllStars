package com.sdg.gameMenus
{
	import com.sdg.net.QuickLoader;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class MatchupIcon extends Sprite
	{
		protected var _playerIcon:DisplayObject;
		protected var _nameTextField:TextField;
		protected var _width:Number;
		protected var _height:Number;

		public function MatchupIcon(pName:String, firstPlayer:Boolean = true, width:Number = 100, height:Number = 100)
		{
			super();

			_width = width;
			_height = height;

			if (firstPlayer)
				_playerIcon = new QuickLoader("swfs/rbi/blueHat.swf", onComplete);
			else
				_playerIcon = new QuickLoader("swfs/rbi/redHat.swf", onComplete);

			function onComplete():void
			{
				addChild(_playerIcon);
				playerText = pName;
				render();
			}
		}

		protected function set playerText(value:String):void
		{
			if (value == null)
			{
				if (_nameTextField != null)
				{
					removeChild(_nameTextField);
					_nameTextField = null;
				}
				_playerIcon.transform.colorTransform = new ColorTransform(0, 0, 0, 1, 155, 155, 155, 0);
			}
			else
			{
				if (_nameTextField == null)
				{
					_nameTextField = new TextField();
					_nameTextField.defaultTextFormat = new TextFormat('EuroStyle', 25, 0xffffff, true);
					_nameTextField.embedFonts = true;
					_nameTextField.autoSize = TextFieldAutoSize.LEFT;
					_nameTextField.selectable = false;
					_nameTextField.mouseEnabled = false;
					addChild(_nameTextField);
				}

				_nameTextField.text = value;
				_playerIcon.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
			}
		}

		public function set playerName(value:String):void
		{
			playerText = value;
			render();
		}

		public function get hasPlayer():Boolean
		{
			return _nameTextField != null;
		}

		protected function render():void
		{
			var componentHeight:Number = _playerIcon.height;

			if (_nameTextField)
			{
				componentHeight += _nameTextField.height;

				_nameTextField.x = _width/2 - _nameTextField.width/2;
				_nameTextField.y = _height/2 - componentHeight/2 + _playerIcon.height;
			}

			_playerIcon.x = _width/2 - _playerIcon.width/2;
			_playerIcon.y = _height/2 - componentHeight/2;
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
