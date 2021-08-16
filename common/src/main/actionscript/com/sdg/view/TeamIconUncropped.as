package com.sdg.view
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class TeamIconUncropped extends TeamIcon
	{
		protected var _highlight:Sprite;
		protected var _highlightMask:Sprite;
		protected var _customLogoUrl:String;
		protected var _usingTeamIcon:Boolean = true;
		
		public function TeamIconUncropped(width:Number, height:Number, color1:uint, color2:uint, teamId:uint = 0, customLogoUrl:String = null, highlightRadius:Number = 80)
		{
			_customLogoUrl = customLogoUrl;
			if (_customLogoUrl != null)
				_usingTeamIcon = false;
			
			super(width, height, teamId, color1, color2, true);
			
			_highlight = new Sprite();
			_highlight.graphics.clear();
			_highlight.graphics.beginFill(0xffffff, .4);
			_highlight.graphics.drawCircle(0, 0, highlightRadius);
			_highlight.x = _width/2;
			_highlight.y = -_highlight.height/2 + _height/2;
			addChild(_highlight);
			
			_highlightMask = new Sprite();
			_highlightMask.graphics.beginFill(0x000000);
			_highlightMask.graphics.drawRoundRect(0, 0, _width - 2, _height - 2, 10, 10);
			_highlightMask.x = -_highlightMask.width/2
			_highlightMask.y = _highlight.height/2 - _highlightMask.height/2;
			_highlight.addChild(_highlightMask);
			_highlight.mask = _highlightMask;
			
			mouseChildren = false;
		}
		
		override public function init():void
		{
			// Make sure we only init once.
			if (_isInit == true) return;
			_isInit = true;
			
			loadLogo(_customLogoUrl);
		}
		
		override public function setParams(teamId:uint, color1:uint, color2:uint):void
		{			
			super.setParams(teamId, color1, color2);
			_usingTeamIcon = true;
		}
		
		override protected function placeLogo():void
		{
			// Remove previous logo.
			if (_logo != null) _back.removeChild(_logo);
			
			_logo = new Sprite();
			var logo:DisplayObject = _loader.content;
			var maxW:Number = _width;
			var maxH:Number = _height;
			var scale:Number = Math.min(maxW / logo.width, maxH / logo.height);
			logo.width *= scale;
			logo.height *= scale;
			logo.x = - logo.width / 2;
			logo.y = - logo.height / 2;
			_logo.addChild(logo);
			_logo.x = _width / 2;
			_logo.y = _height / 2;
			//_logo.rotation = -10;
			_back.addChild(_logo);
		}
		
		public function get usingTeamIcon():Boolean
		{
			return _usingTeamIcon;
		}
	}
}