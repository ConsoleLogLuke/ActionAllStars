package com.sdg.components.controls.store
{
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.display.LineStyle;
	import com.sdg.graphics.GradientStyle;
	import com.sdg.graphics.RoundRectStyle;
	import com.sdg.graphics.customShapes.RoundRectComplex;
	import com.sdg.store.nav.StoreNavView;
	import com.sdg.ui.IButtonWithGradient;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class StoreNavBar extends Sprite implements IButtonWithGradient
	{
		// Exposed Variables 
		protected var _width:Number;
		protected var _height:Number;
		protected var _label:String;
		protected var _labelFormat:TextFormat;
		protected var _labelX:Number;
		protected var _backgroundStyle:String;
		protected var _backgroundColor:uint;
		protected var _backgroundAlpha:Number;
		protected var _gradient:GradientStyle;
		protected var _gradient_rollover:GradientStyle;
		protected var _backgroundShape:String;
		protected var _roundRectStyle:RoundRectStyle;
		protected var _complexRectStyle:RoundRectComplex;
		protected var _borderStyle:LineStyle;
		protected var _upperLeftCorner:Shape;
		protected var _bottomRightCorner:Shape;

		// Child Objects
		protected var _displayedText:TextField = new TextField();
		
		// Hidden Variables
		private var _textScale:Number;
		private var _isItalics:Boolean;
		private var _textFont:String;
		
		public function StoreNavBar(width:Number = 1,height:Number = 1,label:String = 'ERROR',bColor:uint = 0x000000,bAlpha:Number = 1)
		{
			super();
			
			// set defaults for initial render
			_backgroundColor = bColor;
			_backgroundAlpha = bAlpha;			
			_width = width;
			_height = height;
			_label = label;
			// Label Format Defaults (EuroStyle,20,White Text,Bold,No Italics)
			_labelFormat = new TextFormat('EuroStyle',20,0xFFFFFF,true,false);
			mouseChildren = false;
			buttonMode = true;

			render();
		}
		
		public function redraw():void
		{
			render();
		}
		
		public function blackenUpperLeftCorner():void
		{
			var h:uint = 13;
			
			_upperLeftCorner = new Shape();
			
			_upperLeftCorner.x = 0;
			_upperLeftCorner.y = 0;
			
			_upperLeftCorner.graphics.lineStyle(1,0x000000);
			_upperLeftCorner.graphics.beginFill(0x000000);
			_upperLeftCorner.graphics.moveTo(0,0);
			_upperLeftCorner.graphics.lineTo(h,0);
			_upperLeftCorner.graphics.lineTo(0,h);
			_upperLeftCorner.graphics.lineTo(0,0);
			
			addChild(_upperLeftCorner);
		}
		
		public function blackenBottomRightCorner():void
		{
			var h:uint = 13;
			
			_bottomRightCorner = new Shape();
			
			_bottomRightCorner.x = _width;
			_bottomRightCorner.y = _height;
			
			_bottomRightCorner.graphics.lineStyle(1,0x000000);
			_bottomRightCorner.graphics.beginFill(0x000000);
			_bottomRightCorner.graphics.moveTo(_width,_height);
			_bottomRightCorner.graphics.lineTo(_width,(_height - h));
			_bottomRightCorner.graphics.lineTo((_width - h),_height);
			_bottomRightCorner.graphics.lineTo(_width,_height);
			
			_bottomRightCorner.x = 0;
			_bottomRightCorner.y = 0;
			
			addChild(_bottomRightCorner);
		}
		
		public function destroy():void
		{
		}
		
		public function enableTemporaryEffect(mouseEvent:String,funct:Function):void
		{
			addEventListener(mouseEvent,funct);
		}
		
		public function recolorGradient(e:MouseEvent):void
		{
			if (_backgroundStyle == "Gradient")
			{
				//Invert Gradient
				var newGradient:GradientStyle = new GradientStyle(GradientType.LINEAR,[StoreNavView.GRADIENT_COLOR_2,StoreNavView.GRADIENT_BLACK],_gradient.alphas,_gradient.ratios,_gradient.matrix,_gradient.spreadMethod,_gradient.interpolationMethod,_gradient.focalPointRatio);
				this.gradient = newGradient;
			}
			addEventListener(MouseEvent.ROLL_OUT, restoreButton);
			
			function restoreButton(e:MouseEvent):void
			{
				// Remove event listener.
				removeEventListener(MouseEvent.ROLL_OUT, restoreButton);
				
				if (_backgroundStyle == "Gradient")
				{
					//Invert Gradient Back
					var newGradient2:GradientStyle = new GradientStyle(GradientType.LINEAR,[StoreNavView.GRADIENT_COLOR_1,StoreNavView.GRADIENT_BLACK],_gradient.alphas,_gradient.ratios,_gradient.matrix,_gradient.spreadMethod,_gradient.interpolationMethod,_gradient.focalPointRatio);
					var navBar:StoreNavBar = e.currentTarget as StoreNavBar;
					navBar.gradient = newGradient2;
				}
			}
		}
		
		////////////////////
		// INTERFACES
		////////////////////
		
		public function set labelFilters(value:Array):void
		{
			_displayedText.filters = value;
			render();
		}
		
		public function get labelWidth():Number
		{
			return _displayedText.width;
		}
		
		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			if (value == _label) return;
			_label = value;
			removeChild(_displayedText);
			render();
		}
		
		public function set labelColor(value:uint):void
		{
			_labelFormat.color = value;
			render();
		}
		
		public function get labelFormat():TextFormat
		{
			return _labelFormat;
		}
		
		public function set labelFormat(value:TextFormat):void
		{
			_labelFormat = value;
			render();
		}
		
		public function get labelX():Number
		{
			return _labelX;
		}
		
		public function set labelX(value:Number):void
		{
			_labelX = value;
			render();
		}
		
		public function get backgroundStyle():String
		{
			return _backgroundStyle;
		}
		
		public function set backgroundStyle(value:String):void
		{
			_backgroundStyle = value;
		}
		
		public function get backgroundColor():uint
		{
			return _backgroundColor;
		}
		
		public function set backgroundColor(value:uint):void
		{
			_backgroundColor = value;
			render();
		}
		
		public function get backgroundAlpha():Number
		{
			return _backgroundAlpha;
		}
		
		public function set backgroundAlpha(value:Number):void
		{
			_backgroundAlpha = value;
			render();
		}
		
		public function get gradient():GradientStyle
		{
			return _gradient;
		}
		
		public function set gradient(value:GradientStyle):void
		{
			_backgroundStyle = "Gradient";
			_gradient = value;
			render();
		}
		
		public function get gradient_rollover():GradientStyle
		{
			return _gradient_rollover;
		}
		
		public function set gradient_rollover(value:GradientStyle):void
		{
			_gradient_rollover = value;
		}
		
		public function get backgroundShape():String
		{
			return _backgroundShape;
		}
		
		public function set backgroundShape(value:String):void
		{
			_backgroundShape = value;
		}
		
		public function get roundRectStyle():RoundRectStyle
		{
			return _roundRectStyle;
		}

		public function set roundRectStyle(value:RoundRectStyle):void
		{
			_backgroundShape = "RoundRect";
			_roundRectStyle = value;
			render();
		}

		public function get complexRectStyle():RoundRectComplex
		{
			return _complexRectStyle;
		}

		public function set complexRectStyle(value:RoundRectComplex):void
		{
			_backgroundShape = "ComplexRoundRect";
			_complexRectStyle = value;
			_complexRectStyle.width = _width;
			_complexRectStyle.height = _height;
			render();
		}
		
		public function get borderStyle():LineStyle
		{
			return _borderStyle;
		}

		public function set borderStyle(value:LineStyle):void
		{
			_borderStyle = value;
			render();
		}
		
		public function get display():DisplayObject
		{
			return this;
		}
		
		/////////////////////////
		// RENDERING METHODS
		/////////////////////////
		
		public function render():void
		{
			graphics.clear();
			renderBackground();
			renderText();
			renderCheck();
		}
		
		// Returns: 0 if object seems ok; 1 if no text child; 2 if too many child objects
		public function renderCheck():uint
		{
			// Is the display text object there?
			try
			{
				this.getChildIndex(_displayedText);
			}
			catch (error:ArgumentError)
			{			
				//SdgAlertChrome.show("Display Text Object is Missing!","Time Out!");
				return 1;
			}
			
			// Are there too many children? (child object pollution)
			if (numChildren > 2)
			{			
				//SdgAlertChrome.show("Too Many Child Objects!: "+numChildren,"Time Out!");
				return 2;
			}
			return 0;
		}
		
		protected function renderBackground():void
		{

			// SET FILL
			if (_backgroundStyle == "Gradient")
				graphics.beginGradientFill(_gradient.type,_gradient.colors,_gradient.alphas,_gradient.ratios,_gradient.matrix,_gradient.spreadMethod,_gradient.interpolationMethod,_gradient.focalPointRatio);
			else 
				//Default to Solid Fill
				graphics.beginFill(_backgroundColor,_backgroundAlpha);
				
			// SET BORDER
			if (_borderStyle)
				graphics.lineStyle(_borderStyle.thickness,_borderStyle.color,_borderStyle.alpha);
				
			// DRAW BACKGROUND				
			if (_backgroundShape == "RoundRect")
				graphics.drawRoundRect(0,0,_width,_height,_roundRectStyle.ellipseWidth,_roundRectStyle.ellipseHeight);
			else if (_backgroundShape == "ComplexRoundRect")
			{
				_complexRectStyle.draw(graphics);
			}
			else
				// Default is rectangle
				graphics.drawRect(0,0,_width,_height);
		}
		
		protected function renderText():void
		{
			//Remove Child if already there
			if (this.contains(_displayedText))
			{
				this.removeChild(_displayedText);
			}
			
			// Initialize Textbox
			_displayedText.embedFonts = true;
			_displayedText.defaultTextFormat = _labelFormat;
			//_displayedText.setTextFormat(_labelFormat);
			
			if (_label == "")
			{
				SdgAlertChrome.show("Label Text Missing!: "+label,"Time Out!");
			}
			
			_displayedText.text = _label;
			
			//_displayedText.setTextFormat(new TextFormat('EuroStyle',20,0xFFFFFF,true,true,null,null,null,null,null,null,10));
			_displayedText.autoSize = TextFieldAutoSize.LEFT;
			addChild(_displayedText);
			_displayedText.x = _labelX;
			_displayedText.y = _height/2 - _displayedText.height/2;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			if (value == _width) return;
				_width = value;
				render();
		}
		
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			if (value == _height) return;
				_height = value;
				render();
		}
	}
}