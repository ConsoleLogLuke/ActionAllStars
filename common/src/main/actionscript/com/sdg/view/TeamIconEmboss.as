package com.sdg.view
{
	import com.sdg.graphics.EmbossRect;
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	
	public class TeamIconEmboss extends FluidView
	{
		protected var _emboss:EmbossRect;
		protected var _isInit:Boolean;
		protected var _teamId:uint;
		protected var _logo:Sprite;
		protected static var _glow:GlowFilter;
		
		public function TeamIconEmboss(width:Number, height:Number, teamId:uint, autoInit:Boolean=true)
		{
			_isInit = false;
			_teamId = teamId;
			_glow = new GlowFilter(0xffffff, 1, 2, 2, 10);
			
			_emboss = new EmbossRect(width, height);
			
			_logo = new Sprite();
			
			super(width, height);
			
			addChild(_emboss);
			addChild(_logo);
			
			if (autoInit == true) init();
		}
		
		public function init():void
		{
			// Make sure we only init once.
			if (_isInit == true) return;
			_isInit = true;
			
			// Load logo.
			var logoUrl:String = AssetUtil.GetTeamLogoUrl(_teamId);
			var logo:Sprite = new QuickLoader(logoUrl, render);
			_logo.addChild(logo);
			_logo.filters = [_glow];
		}
		
		override protected function render():void
		{
			_emboss.width = width;
			_emboss.height = height;
			
			var logoScale:Number = Math.min(_width / _logo.width, _height / _logo.height);
			_logo.width *= logoScale;
			_logo.height *= logoScale;
			_logo.x = _width / 2 - _logo.width / 2;
			_logo.y = _height / 2 - _logo.height / 2;
		}
		
	}
}