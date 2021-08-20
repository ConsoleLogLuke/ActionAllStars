package com.sdg.view
{
	import com.sdg.net.Environment;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	public class BadgeIcon extends Sprite
	{
		protected var _badgeId:uint;
		protected var _badgeLevelIndex:uint;
		protected var _onComplete:Function;
		protected var _shield:Sprite;
		protected var _icon:Sprite;

		public function BadgeIcon(badgeId:uint, badgeLevelIndex:uint, onComplete:Function = null)
		{
			_badgeId = badgeId;
			_badgeLevelIndex = badgeLevelIndex;
			_onComplete = onComplete;

			_shield = new Sprite();

			_icon = new Sprite();

			var shieldUrl:String = 'swfs/pda/badges/animated_badge_' + _badgeLevelIndex + '.swf';
			var shieldRequest:URLRequest = new URLRequest(shieldUrl);
			var shieldLoader:Loader = new Loader();
			shieldLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAssetComplete);
			shieldLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onAssetError);
			shieldLoader.load(shieldRequest);

			var iconUrl:String = Environment.getApplicationUrl() + '/test/static/badgeLg?badgeId=' + _badgeId;
			var iconRequest:URLRequest = new URLRequest(iconUrl);
			var iconLoader:Loader = new Loader();
			iconLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAssetComplete);
			iconLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onAssetError);
			iconLoader.load(iconRequest);

			super();

			addChild(_shield);
			addChild(_icon);

			function onAssetComplete(e:Event):void
			{
				// Remove listeners.
				e.currentTarget.removeEventListener(Event.COMPLETE, onAssetComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onAssetError);

				var parent:Sprite = (e.currentTarget == shieldLoader.contentLoaderInfo) ? _shield : _icon;
				parent.addChild(LoaderInfo(e.currentTarget).content);

				if (_shield.numChildren > 0 && _icon.numChildren > 0)
				{
					// Call complete function.
					if (_onComplete != null) _onComplete();
				}
			}

			function onAssetError(e:IOErrorEvent):void
			{
				// Remove listeners.
				e.currentTarget.removeEventListener(Event.COMPLETE, onAssetComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onAssetError);
			}
		}

	}
}
