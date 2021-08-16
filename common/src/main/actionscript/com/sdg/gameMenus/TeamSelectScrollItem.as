package com.sdg.gameMenus
{
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class TeamSelectScrollItem extends Sprite implements IScrollObject
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _team:GameTeamItem;
		protected var _teamIcon:DisplayObject;
		protected var _selected:Boolean;
		protected var _selectedScale:Number;
		protected var _defaultScale:Number;
		
		public function TeamSelectScrollItem(team:GameTeamItem, width:Number, height:Number)
		{
			super();
			_width = width;
			_height = height;
			_team = team;
			_selected = false;
			
//			graphics.lineStyle(1);
//			graphics.beginFill(0xfff000);
//			graphics.drawRect(0, 0, _width, _height);
			
			var teamIcon:DisplayObject = new QuickLoader(AssetUtil.GetTeamLogoUrl(team.teamId), onComplete);
			
			function onComplete():void
			{
				addChild(teamIcon);
				_selectedScale = 1.6;
				_defaultScale = .65;
				_teamIcon = teamIcon;
				render();
			}
		}
		
		protected function render():void
		{
			if (_teamIcon == null) return;
			
			var scale:Number = _defaultScale;
			
			if (_selected)
				scale = _selectedScale;
			
			_teamIcon.scaleX = _teamIcon.scaleY = scale;
			
			_teamIcon.x = _width/2 - _teamIcon.width/2;
			_teamIcon.y = _height/2 - _teamIcon.height/2;
		}
		
		public function get team():GameTeamItem
		{
			return _team;
		}
		
		public function set selected(value:Boolean):void
		{
			_selected = value;
			render();
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