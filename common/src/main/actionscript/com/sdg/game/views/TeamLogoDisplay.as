package com.sdg.game.views
{
	import com.sdg.game.events.UnityNBAEvent;
	import com.sdg.game.models.UnityNBATeam;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;

	public class TeamLogoDisplay extends Sprite
	{
		private var _team:UnityNBATeam;
		private var _width:Number;
		private var _height:Number;
		private var _useBitmap:Boolean;
		private var _logoBitmap:Bitmap;
		
		public function TeamLogoDisplay(team:UnityNBATeam, w:Number, h:Number, useBitmap:Boolean = false)
		{
			super();
			
			_team = team;
			_width = w;
			_height = h;
			_useBitmap = useBitmap;
			
			if (_team.logo == null)
			{
				_team.addEventListener(UnityNBAEvent.LOGO_LOADED, onLogoLoaded, false, 0, true);
			}
			else
			{
				refresh();
			}
		}
			
		private function onLogoLoaded(event:UnityNBAEvent):void
		{
			_team.removeEventListener(UnityNBAEvent.LOGO_LOADED, onLogoLoaded);
			refresh();
		}
		
		public function refresh():void
		{
			var logo:DisplayObject = _team.logo;
			
			if (logo == null) return;
			var scale:Number = Math.min(_width/logo.width, _height/logo.height);
			logo.scaleX *= scale;
			logo.scaleY *= scale;
			
			if (_useBitmap)
			{
				if (_logoBitmap == null)
				{
					var bd:BitmapData = new BitmapData(logo.width, logo.height, true, 0xffffff);
					var trans:Matrix = new Matrix();
					trans.scale(logo.scaleX, logo.scaleY);
					bd.draw(logo, trans);
					_logoBitmap = new Bitmap(bd);
					addChild(_logoBitmap);
					_logoBitmap.x = _width/2 - _logoBitmap.width/2;
					_logoBitmap.y = _height/2 - _logoBitmap.height/2;
				}
			}
			else
			{
				if (contains(logo) == false)
					addChild(logo);
				
				logo.x = _width/2 - logo.width/2;
				logo.y = _height/2 - logo.height/2;
				
				logo.cacheAsBitmap = true;
			}
		}
		
		public function destroy():void
		{
			_team.removeEventListener(UnityNBAEvent.LOGO_LOADED, onLogoLoaded);
		}
		
		public function get team():UnityNBATeam
		{
			return _team;
		}
	}
}