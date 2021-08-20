package com.sdg.view.pda
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	public class CheckBox extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _boxLineColor:uint;
		protected var _boxLineThickness:Number;
		protected var _checkColor:uint;
		protected var _isChecked:Boolean;
		protected var _checkMarkImage:DisplayObject;

		public function CheckBox()
		{
			super();

			// Set default values.
			_width = 20;
			_height = 20;
			_boxLineColor = 0xffffff;
			_boxLineThickness = 2;
			_checkColor = 0x00cc00;
			_isChecked = false;

			render();
		}

		////////////////////
		// INSTANCE METHODS
		////////////////////

		private function render():void
		{
			// Draw box.
			graphics.clear();
			graphics.lineStyle(_boxLineThickness, _boxLineColor);
			graphics.drawRect(0, 0, _width, _height);

			// Draw check.
			if (_isChecked == true)
			{
				// If check mark image is null, load the image.
				var checkMarkLoader:Loader;

				if (_checkMarkImage == null)
				{
					// Load the check mark image.
					var url:String = 'swfs/checkMark.swf';
					var request:URLRequest = new URLRequest(url);
					checkMarkLoader = new Loader();
					checkMarkLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageComplete);
					checkMarkLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageError);
					checkMarkLoader.load(request);

					function onImageComplete(e:Event):void
					{
						// Remove listeners.
						checkMarkLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onImageComplete);
						checkMarkLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onImageError);

						// Set image reference.
						_checkMarkImage = checkMarkLoader.content;
						addChild(_checkMarkImage);

						// Re-render.
						render();
					}

					function onImageError(e:IOErrorEvent):void
					{
						// Remove listeners.
						checkMarkLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onImageComplete);
						checkMarkLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onImageError);
					}
				}
				else
				{
					// Size check mark.
					var checkScale:Number = Math.min(_width / _checkMarkImage.width, _height / _checkMarkImage.height);
					_checkMarkImage.width *= checkScale;
					_checkMarkImage.height *= checkScale;
					_checkMarkImage.x = _width / 2 - _checkMarkImage.width / 2;
					_checkMarkImage.y = _height / 2 - _checkMarkImage.height / 2;

					// Show check mark.
					_checkMarkImage.visible = true;
				}
			}
			else if (_checkMarkImage != null)
			{
				_checkMarkImage.visible = false;
			}
		}

		////////////////////
		// GET/SET METHODS
		////////////////////

		override public function get width():Number
		{
			return _width;
		}

		override public function set width(value:Number):void
		{
			if (value == _width) return;
			_width = value;
			render();
		}

		override public function get height():Number
		{
			return _height;
		}

		override public function set height(value:Number):void
		{
			if (value == _height) return;
			_height = value;
			render();
		}

		public function get isChecked():Boolean
		{
			return _isChecked;
		}
		public function set isChecked(value:Boolean):void
		{
			if (value == _isChecked) return;
			_isChecked = value;
			render();
		}

	}
}
