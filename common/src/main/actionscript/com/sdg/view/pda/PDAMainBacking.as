package com.sdg.view.pda
{
	import com.sdg.graphics.customShapes.BevelShape;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	
	[Bindable]
	public class PDAMainBacking extends Canvas
	{
		public const innerLayerWidthDifference:int = 18;
		public const innerLayerHeightDifference:int = 52;
		public const innerLayerTopBevelHeight:int = 0;
		public const innerLayerBottomBevelHeight:int = 8;
		public const innerLayerY:int = 15;
		
		public const screenWidthDifference:int = 10;
		public const screenHeightDifference:int = 4;
		public const screenY:int = 5;
		
		public var topCornerRadius:int;
		public var bottomCornerRadius:int;
		
		public var topBevelHeight:int;
		public var bottomBevelHeight:int;
		public var topBevelXStart:int;
		public var bottomBevelXStart:int;
		public var topBevelControlYAdjustment:int;
		public var bottomBevelControlYAdjustment:int;
		
		public var primaryColor:uint;
		public var secondaryColor:uint;
		
		private var _outerSkin:PDASkin;
		private var _outerHighlight:UIComponent;
		private var _innerSkin:PDASkin;
		private var _innerHighlight:UIComponent;
		public var pdaScreen:Canvas;
		private var _star:UIComponent;
		
		public function PDAMainBacking(width:int = 0, height:int = 0, topCornerRadius:int = 0, bottomCornerRadius:int = 0,
										primaryColor:uint = 0x000000, secondaryColor:uint = 0x000000)
		{
			super();
			this.width = width;
			this.height = height;
			this.topCornerRadius = topCornerRadius;
			this.bottomCornerRadius = bottomCornerRadius;
			this.primaryColor = primaryColor;
			this.secondaryColor = secondaryColor;
			
			_outerSkin = super.addChild(new PDASkin()) as PDASkin;
			_outerHighlight = super.addChild(new UIComponent()) as UIComponent;
			
			_star = super.addChild(new UIComponent()) as UIComponent;
			_star.graphics.lineStyle(2, 0xffffff, 1);
			_star.graphics.beginFill(0xcccccc,1);
			_star.graphics.moveTo(2,16);
			_star.graphics.lineTo(17,16);
			_star.graphics.lineTo(27,3);
			_star.graphics.lineTo(28,16);
			_star.graphics.lineTo(44,16);
			_star.graphics.lineTo(30,25);
			_star.graphics.lineTo(30,41);
			_star.graphics.lineTo(19,32);
			_star.graphics.lineTo(4,41);
			_star.graphics.lineTo(12,25);
			_star.graphics.lineTo(2,16);
			_star.scaleX = .6;
			_star.scaleY = .6;
			_star.blendMode = "overlay";
			
			_innerSkin = super.addChild(new PDASkin()) as PDASkin;
			_innerHighlight = super.addChild(new UIComponent()) as UIComponent;
			
			pdaScreen = super.addChild(new Canvas()) as Canvas;
			pdaScreen.verticalScrollPolicy = "off";
			pdaScreen.horizontalScrollPolicy = "off";
		}
		
		public function addChildToBacking(child:DisplayObject):DisplayObject
		{
			super.addChild(child);
			return child;
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			pdaScreen.addChild(child);
			return child;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			var gradientBoxMatrix:Matrix = new Matrix();

			_outerSkin.color = primaryColor;
			_outerSkin.shape = new BevelShape(width, height,
												topCornerRadius, bottomCornerRadius,
												topBevelHeight, bottomBevelHeight,
												topBevelXStart, bottomBevelXStart,
												topBevelControlYAdjustment, bottomBevelControlYAdjustment);
			
			gradientBoxMatrix.createGradientBox(width, height, Math.PI/2, 0, 0);
			
			_outerHighlight.graphics.clear();
			//_outerHighlight.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff], [.3, .55, .85, .45, 0], [0, 40, 94, 160, 255], gradientBoxMatrix);
			_outerHighlight.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff], [0, .1, .85, .65, .05], [0, 30, 134, 160, 255], gradientBoxMatrix);
			_outerSkin.shape.draw(_outerHighlight.graphics);
			_outerHighlight.graphics.endFill();
			
			_star.setStyle("horizontalCenter", -16);
			_star.y = _outerSkin.height - 30;
			
			var innerLayerWidth:int = width - innerLayerWidthDifference;
			var innerLayerHeight:int = height - innerLayerHeightDifference;
			
			_innerSkin.color = secondaryColor;
			_innerSkin.shape = new BevelShape(innerLayerWidth, innerLayerHeight,
												topCornerRadius, topCornerRadius,
												innerLayerTopBevelHeight, innerLayerBottomBevelHeight,
												topCornerRadius, topCornerRadius);
												
			_innerSkin.x = innerLayerWidthDifference/2;
			_innerSkin.y = topBevelHeight + innerLayerY;
			
			gradientBoxMatrix.createGradientBox(innerLayerWidth, innerLayerHeight);
			
			_innerHighlight.graphics.clear();
			_innerHighlight.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xffffff, 0xffffff, 0xffffff, 0xffffff], [.15, .5, .75, .5, .15], [0, 64, 128, 192, 255], gradientBoxMatrix);
			_innerSkin.shape.draw(_innerHighlight.graphics);
			_innerHighlight.graphics.endFill();
			
			_innerHighlight.x = innerLayerWidthDifference/2;
			_innerHighlight.y = topBevelHeight + innerLayerY;
			
			pdaScreen.width = width - innerLayerWidthDifference - screenWidthDifference;
			pdaScreen.height = height - innerLayerHeightDifference - innerLayerTopBevelHeight - innerLayerBottomBevelHeight - screenHeightDifference;
			
			var screenBevel:BevelShape = new BevelShape(pdaScreen.width, pdaScreen.height,
														topCornerRadius - 5, topCornerRadius, 0, 5,
														topCornerRadius - 5, topCornerRadius);
			
			pdaScreen.graphics.clear();
			pdaScreen.graphics.beginFill(0x000000);
			screenBevel.draw(pdaScreen.graphics);
			pdaScreen.graphics.endFill();
			
			pdaScreen.setStyle("horizontalCenter", 0);
			pdaScreen.y = topBevelHeight + innerLayerY + screenY;
		}
	}
}