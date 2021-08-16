package com.sdg.view.pda
{
	import com.sdg.graphics.customShapes.BevelShape;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import mx.core.UIComponent;
	
	public class PDAMainBacking2 extends UIComponent
	{
		private var _topCornerRadius:Number = 20;
		private var _bottomCornerRadius:Number = 15;
		private var _topBevelHeight:Number = 5;
		private var _bottomBevelHeight:Number = 20;
		private var _topBevelXStart:Number = 20;
		private var _bottomBevelXStart:Number = 10;
		private var _topBevelControlYAdjustment:Number = 3;
		private var _bottomBevelControlYAdjustment:Number = 7;
		
		private var _screenWidthDifference:Number = 28;
		private var _screenHeightDifference:Number = 46;
		private var _screenY:Number = 20;
		
		private var _headerHeight:Number = 55;
		private var _buttonAreaSize:Number = 55;
		
		private var _header:Sprite;
		
		public function PDAMainBacking2()
		{
			super();
			_header = new Sprite();
			addChild(_header);
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			
			var gradientBoxMatrix:Matrix = new Matrix();
			
			graphics.clear();
			
			graphics.lineStyle(2, 0x000000, 1, true);
			
			// backing
			var pdaBevel:BevelShape = new BevelShape(w, h,
												_topCornerRadius, _bottomCornerRadius,
												_topBevelHeight, _bottomBevelHeight,
												_topBevelXStart, _bottomBevelXStart,
												_topBevelControlYAdjustment, _bottomBevelControlYAdjustment);
			
			gradientBoxMatrix.createGradientBox(w, h, Math.PI/2, 0, 0);
			graphics.beginGradientFill(GradientType.LINEAR, [0xD7E3EE, 0x3D3D3D], [1, 1], [0, 255], gradientBoxMatrix);
			pdaBevel.draw(graphics);
			graphics.endFill();
			
			
			// screen
			var screenWidth:Number = w - _screenWidthDifference;
			var screenHeight:Number = h - screenHeightDifference;
			var screenTopCornerRadius:Number = _topCornerRadius - 5;
			var screenBottomCornerRadius:Number = _topCornerRadius;
			
			var screenBevel:BevelShape = new BevelShape(screenWidth, screenHeight,
														screenTopCornerRadius, screenBottomCornerRadius, 0, 5,
														screenTopCornerRadius, screenBottomCornerRadius);
			
			graphics.beginFill(0x1B1B1B);
			screenBevel.draw(graphics, w/2 - screenWidth/2, _screenY);
			graphics.endFill();
			
			
			// body
			var bodyHeight:Number = screenHeight - _buttonAreaSize;
			
			gradientBoxMatrix.createGradientBox(screenWidth, bodyHeight, Math.PI/2, 0, 0);
			graphics.beginGradientFill(GradientType.LINEAR, [0x90D1FF, 0x10429D], [1, 1], [0, 255], gradientBoxMatrix);
			graphics.drawRoundRectComplex(w/2 - screenWidth/2,
										_screenY, screenWidth, bodyHeight,
										screenTopCornerRadius - 2, screenTopCornerRadius - 2,
										screenBottomCornerRadius - 2, screenBottomCornerRadius - 2);
			graphics.endFill();
						
			// highlight
			var highlightThickness:Number = 5;
			var highlightY:Number = 3;
			
			graphics.lineStyle();
			graphics.beginFill(0xffffff);
			graphics.moveTo(2, _topBevelHeight + _topCornerRadius + highlightThickness + highlightY);
			graphics.curveTo(0, _topBevelHeight + _topBevelControlYAdjustment + highlightY, _topBevelXStart, _topBevelHeight + highlightY);
			graphics.curveTo(w/2, -_topBevelHeight + highlightY, w - 2 - _topBevelXStart, _topBevelHeight + highlightY);
			graphics.curveTo(w, _topBevelHeight + _topBevelControlYAdjustment + highlightY, w - 2, _topBevelHeight + _topCornerRadius + highlightY);
			graphics.curveTo(w, _topBevelHeight + _topBevelControlYAdjustment + highlightThickness + highlightY, w - 2 - _topBevelXStart, _topBevelHeight + highlightThickness + highlightY);
			graphics.curveTo(w/2, -_topBevelHeight + highlightThickness + highlightY, _topBevelXStart, _topBevelHeight + highlightThickness + highlightY);
			graphics.curveTo(0, _topBevelHeight + _topBevelControlYAdjustment + highlightThickness + highlightY, 2, _topBevelHeight + _topCornerRadius + highlightThickness + highlightY);
			graphics.endFill();
			
			// header
			_header.graphics.lineStyle(2, 0x000000, 1, true);
			gradientBoxMatrix.createGradientBox(screenWidth, _headerHeight, Math.PI/2, 0, 0);
			_header.graphics.beginGradientFill(GradientType.LINEAR, [0x1B1B1B, 0x5F5F5F], [1, 1], [0, 255], gradientBoxMatrix);
			_header.graphics.drawRoundRectComplex(w/2 - screenWidth/2, _screenY,
												screenWidth, _headerHeight,
												screenTopCornerRadius - 2, screenTopCornerRadius - 2, 0, 0);
			_header.graphics.endFill();
		}
		
		public function set useHeader(value:Boolean):void
		{
			_header.visible = value;
		}
		
		public function set buttonAreaSize(value:Number):void
		{
			if (_buttonAreaSize == value) return;
			_buttonAreaSize = value;
			invalidateDisplayList();
		}
		
		public function get buttonAreaSize():Number
		{
			return _buttonAreaSize;
		}
		
		public function set headerHeight(value:Number):void
		{
			if (_headerHeight == value) return;
			_headerHeight = value;
			invalidateDisplayList();
		}
		
		public function get headerHeight():Number
		{
			return _headerHeight;
		}
		
		public function set screenWidthDifference(value:Number):void
		{
			if (_screenWidthDifference == value) return;
			_screenWidthDifference = value;
			invalidateDisplayList();
		}
		
		public function get screenWidthDifference():Number
		{
			return _screenWidthDifference;
		}
		
		public function set screenHeightDifference(value:Number):void
		{
			if (_screenHeightDifference == value) return;
			_screenHeightDifference = value;
			invalidateDisplayList();
		}
		
		public function get screenHeightDifference():Number
		{
			return _screenHeightDifference;
		}
		
		public function set screenY(value:Number):void
		{
			if (_screenY == value) return;
			_screenY = value;
			invalidateDisplayList();
		}
		
		public function get screenY():Number
		{
			return _screenY;
		}
		
		public function set bottomBevelControlYAdjustment(value:Number):void
		{
			if (_bottomBevelControlYAdjustment == value) return;
			_bottomBevelControlYAdjustment = value;
			invalidateDisplayList();
		}
		
		public function get bottomBevelControlYAdjustment():Number
		{
			return _bottomBevelControlYAdjustment;
		}
		
		public function set topBevelControlYAdjustment(value:Number):void
		{
			if (_topBevelControlYAdjustment == value) return;
			_topBevelControlYAdjustment = value;
			invalidateDisplayList();
		}
		
		public function get topBevelControlYAdjustment():Number
		{
			return _topBevelControlYAdjustment;
		}
		
		public function set bottomBevelXStart(value:Number):void
		{
			if (_bottomBevelXStart == value) return;
			_bottomBevelXStart = value;
			invalidateDisplayList();
		}
		
		public function get bottomBevelXStart():Number
		{
			return _bottomBevelXStart;
		}
		
		public function set topBevelXStart(value:Number):void
		{
			if (_topBevelXStart == value) return;
			_topBevelXStart = value;
			invalidateDisplayList();
		}
		
		public function get topBevelXStart():Number
		{
			return _topBevelXStart;
		}
		
		public function set bottomBevelHeight(value:Number):void
		{
			if (_bottomBevelHeight == value) return;
			_bottomBevelHeight = value;
			invalidateDisplayList();
		}
		
		public function get bottomBevelHeight():Number
		{
			return _bottomBevelHeight;
		}
		
		public function set topBevelHeight(value:Number):void
		{
			if (_topBevelHeight == value) return;
			_topBevelHeight = value;
			invalidateDisplayList();
		}
		
		public function get topBevelHeight():Number
		{
			return _topBevelHeight;
		}
		
		public function set bottomCornerRadius(value:Number):void
		{
			if (_bottomCornerRadius == value) return;
			_bottomCornerRadius = value;
			invalidateDisplayList();
		}
		
		public function get bottomCornerRadius():Number
		{
			return _bottomCornerRadius;
		}
		
		public function set topCornerRadius(value:Number):void
		{
			if (_topCornerRadius == value) return;
			_topCornerRadius = value;
			invalidateDisplayList();
		}
		
		public function get topCornerRadius():Number
		{
			return _topCornerRadius;
		}
	}
}