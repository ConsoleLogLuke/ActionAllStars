package com.sdg.tileeditor
{
	import com.sdg.view.FluidView;
	
	import flash.display.Sprite;
	import flash.geom.Point;

	public class TileEditorTile extends FluidView
	{
		protected var _fillColor:uint;
		protected var _fillAlpha:Number;
		protected var _mapCoords:Point;
		protected var _fillLayer:Sprite;
		protected var _lineLayer:Sprite;
		protected var _lineColor:uint;
		protected var _lineAlpha:Number;
		
		public function TileEditorTile(width:Number, height:Number, mapCoords:Point)
		{
			super(width, height);
			
			_fillColor = 0xffffff;
			_fillAlpha = 0;
			_lineColor = 0;
			_lineAlpha = 1;
			_mapCoords = mapCoords;
			
			_fillLayer = new Sprite();
			addChild(_fillLayer);
			
			_lineLayer = new Sprite();
			addChild(_lineLayer);
			
			render();
		}
		
		override protected function render():void
		{
			super.render();
			
			_fillLayer.graphics.clear();
			_fillLayer.graphics.beginFill(_fillColor, _fillAlpha);
			_fillLayer.graphics.drawRect(0, 0, _width, _height);
			
			_lineLayer.graphics.clear();
			_lineLayer.graphics.lineStyle(1, _lineColor, _lineAlpha);
			_lineLayer.graphics.drawRect(0, 0, _width, _height);
		}
		
		public function get mapCoords():Point
		{
			return _mapCoords;
		}
		
		public function get fillColor():uint
		{
			return _fillColor;
		}
		public function set fillColor(value:uint):void
		{
			if (value == _fillColor) return;
			_fillColor = value;
			render();
		}
		
		public function get fillAlpha():Number
		{
			return _fillAlpha;
		}
		public function set fillAlpha(value:Number):void
		{
			if (value == _fillAlpha) return;
			_fillAlpha = value;
			render();
		}
		
		public function get lineColor():uint
		{
			return _lineColor;
		}
		public function set lineColor(value:uint):void
		{
			if (value == _lineColor) return;
			_lineColor = value;
			render();
		}
		
		public function get lineAlpha():Number
		{
			return _lineAlpha;
		}
		public function set lineAlpha(value:Number):void
		{
			if (value == _lineAlpha) return;
			_lineAlpha = value;
			render();
		}
		
		public function get fillBlendMode():String
		{
			return _fillLayer.blendMode;
		}
		public function set fillBlendMode(value:String):void
		{
			_fillLayer.blendMode = value;
		}
		
	}
}