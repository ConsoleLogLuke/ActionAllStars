package com.sdg.components.controls
{
	import com.sdg.net.Environment;

	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	public class BadgeShield extends Sprite
	{
		public static const BADGE_COMPLETED:String = 'badge_completed';

		private var _shield:DisplayObject;
		private var _shieldIcon:DisplayObject;
		private var _badgeWidth:Number;
		private var _badgeHeight:Number;
		private var _shieldCompleted:Boolean;
		private var _iconCompleted:Boolean;

		public function BadgeShield()
		{
			super();
		}

		public function validateBadge():Boolean
		{
			try
			{
				var temp:Object = this.getChildAt(0);
				var temp2:Object = this.getChildAt(1);
				if (!temp) return false;
				if (!temp2) return false;
			} catch (r:RangeError)
			{
				return false;
			}

			return true;
		}

		public function set badgeWidth(value:Number):void
		{
			_badgeWidth = value;
			checkBadgeCompleted();
		}

		public function set badgeHeight(value:Number):void
		{
			_badgeHeight = value;
			checkBadgeCompleted();
		}

		private function scaleIcon():void
		{
			scaleX = scaleY = 1;
			var scale:Number = Math.min(_badgeWidth/width, _badgeHeight/height);
			scaleX = scaleY = scale;
		}

		private function checkBadgeCompleted():void
		{
			if (_shieldCompleted && _iconCompleted)
			{
				scaleIcon();
				dispatchEvent(new Event(BADGE_COMPLETED));
			}
		}

		public function get shield():DisplayObject
		{
			return _shield;
		}

		public function get shieldIcon():DisplayObject
		{
			return _shieldIcon;
		}

		public function set level(value:int):void
		{
			_shieldCompleted = false;

			var request:URLRequest = new URLRequest('swfs/pda/badges/animated_badge_' + value + '.swf');
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.load(request);

			function onLoadComplete(event:Event):void
			{
				if (_shield != null)
				{
					removeChild(_shield);
					_shield = null;
				}

				_shield = loader.content;
				addChild(_shield);
				setChildIndex(_shield, 0);

				//scaleIcon();
				_shieldCompleted = true;
				checkBadgeCompleted();
			}

			function onLoadError(event:Event):void
			{
				_shieldCompleted = true;
				checkBadgeCompleted();
			}
		}

		public function set badgeId(value:int):void
		{
			_iconCompleted = false;
			//var request:URLRequest = new URLRequest('swfs/pda/badges/badge_sportPsychic_image.swf');
			var request:URLRequest = new URLRequest(Environment.getApplicationUrl() + '/test/static/badgeLg?badgeId=' + value);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.INIT, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loader.load(request);

			function onLoadComplete(event:Event):void
			{
				if (_shieldIcon != null)
				{
					removeChild(_shieldIcon);
					_shieldIcon = null;
				}

				_shieldIcon = loader.content;
				addChild(_shieldIcon);

				_iconCompleted = true;
				checkBadgeCompleted();
			}

			function onLoadError(event:Event):void
			{
				_iconCompleted = true;
				checkBadgeCompleted();
			}
		}
	}
}
