package com.sdg.view
{
	import com.sdg.model.Team;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import mx.core.UIComponent;

	public class TopTeamPick extends UIComponent
	{
		protected var _width:Number = 68;
		protected var _height:Number = 46;
		protected var _team:Team;
		protected var _highlightRadius:Number = 80;
		
		protected var _edge:Sprite;
		protected var _icon:TeamIconUncropped;
		
		public function TopTeamPick()
		{
			super();
			
			_edge = new Sprite();
			addChild(_edge);
			
			buttonMode = true;
		}
		
		public function set highlightRadius(value:Number):void
		{
			_highlightRadius = value;
			render();
		}
		
		override public function set width(value:Number):void
		{
			super.width = value;
			_width = value;
			render();
		}
		
		override public function set height(value:Number):void
		{
			super.height = value;
			_height = value;
			render();
		}
		
		public function get team():Team
		{
			return _team;
		}
		
		public function set team(value:Team):void
		{			
			if (_team == value) return;
			
			_team = value;
			
			if (_icon == null)
				render();
			else
				_icon.setParams(_team.teamId, _team.teamColor1, _team.teamColor2);
		}
		
		private function render():void
		{
			if (_team == null) return;
			
			var gradientBoxMatrix:Matrix = new Matrix();
			gradientBoxMatrix.createGradientBox(_width, _height, Math.PI/2);
			_edge.graphics.clear();
			_edge.graphics.beginGradientFill(GradientType.LINEAR, [0xbbbbbb, 0x333333], [1, 1], [0, 255], gradientBoxMatrix);
			_edge.graphics.drawRoundRect(0, 0, _width, _height, 12, 12);
			
			if (_icon != null) removeChild(_icon);
			_icon = new TeamIconUncropped(_width - 6, _height - 6, _team.teamColor1, _team.teamColor2, _team.teamId, null, _highlightRadius);
			_icon.x = _edge.width/2 - _icon.width/2;
			_icon.y = _edge.height/2 - _icon.height/2;
			addChild(_icon);
		}
	}
}