package com.sdg.display
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.font.FontStyles;
	import com.sdg.util.GridUtil;
	import com.sdg.util.LayoutUtil;
	
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class PrizeOfTheWeekStamps extends Container
	{
		private var _quarterWidth:Number;
		private var _fifthWidth:Number;
		private var _halfHeight:Number;
		private var _sixStampGrid:Grid;
		private var _deviderLineStyle:LineStyle;
		private var _deviderLineLayer:Sprite;
		private var _7thContainer:Container;
		private var _stampDisplayClass:Class = GameStamp;
		private var _animationManager:AnimationManager;
		private var _lastStamp:DisplayObject;
		private var _newStamp:Boolean;
		private var _prizeThumbnailURL:String;
		
		public function PrizeOfTheWeekStamps(width:Number=0, height:Number=0, stampCount:int = 0, newStamp:Boolean = false, prizeThumbnailURL:String = '')
		{
			super(width, height, false);
			
			_quarterWidth = _width / 4;
			_fifthWidth = _width / 5;
			_halfHeight = _height / 2;
			_deviderLineStyle = new LineStyle(0x000000, 0.2, 2);
			_deviderLineLayer = new Sprite();
			_addChild(_deviderLineLayer);
			_7thContainer = new Container(_fifthWidth * 2, _height);
			_7thContainer.alignX = _7thContainer.alignY = AlignType.MIDDLE;
			_newStamp = newStamp;
			_animationManager = new AnimationManager();
			_prizeThumbnailURL = prizeThumbnailURL;
			
			// Create a grid used to represent stamps 1 - 6.
			_sixStampGrid = new Grid(3, 2, _quarterWidth, _halfHeight);
			_sixStampGrid.useDeviderLines = true;
			_sixStampGrid.deviderLineStyle = _deviderLineStyle;
			content = _sixStampGrid;
			
			// Fill the grid with numbers.
			var i:int = 1;
			var len:int = 7;
			var number:TextField;
			var format:TextFormat = new TextFormat('GillSans', 80, 0xbdc5cf, true);
			var dropShadowFilter:DropShadowFilter = new DropShadowFilter(2, 45, 0, 0.4, 0, 0);
			for (i; i < len; i++)
			{
				number = new TextField();
				number.defaultTextFormat = format;
				number.styleSheet = FontStyles.GILL_SANS;
				number.autoSize = TextFieldAutoSize.LEFT;
				number.selectable = false;
				number.mouseEnabled = false;
				number.embedFonts = true;
				number.text = i.toString();
				//number.filters = [dropShadowFilter];
				_sixStampGrid.addObject(number);
			}
			
			// Create the 7th stamp area.
			var textStack:Stack = new Stack(AlignType.VERTICAL);
			var container:Container;
			var txt:TextField = new TextField();
			txt.defaultTextFormat = new TextFormat('GillSans', 24, 0x9ea7b1, true, false, false, null, null, 'center');
			txt.styleSheet = FontStyles.GILL_SANS;
			txt.autoSize = TextFieldAutoSize.CENTER;
			txt.selectable = false;
			txt.mouseEnabled = false;
			txt.embedFonts = true;
			txt.text = 'Grand Prize!';
			container = new Container();
			container.content = txt;
			textStack.addContainer(container);
			number = new TextField();
			number.defaultTextFormat = format;
			number.styleSheet = FontStyles.GILL_SANS;
			number.autoSize = TextFieldAutoSize.CENTER;
			number.selectable = false;
			number.mouseEnabled = false;
			number.embedFonts = true;
			number.text = '7';
			container = new Container();
			container.alignX = AlignType.MIDDLE;
			container.width = txt.width;
			container.content = number;
			textStack.addContainer(container);
			_7thContainer.content = textStack;
			_addChild(_7thContainer);
			
			// Create stylized backing for this container.
			var panelBacking:Box = new Box(0, 0, 12);
			panelBacking.style = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0xa1d6fe, 0xffffff], [1, 1], [1, 180], Math.PI/2), 0x0872c6, 1, 6, 18);
			backing = panelBacking;
			
			// Add stamps according to stamp count.
			i = 0;
			len = Math.min(stampCount, 6);
			var stamp:Sprite;
			var pos:Point;
			for (i; i < len; i++)
			{
				stamp = new _stampDisplayClass();
				styleStamp(stamp);
				pos = GridUtil.GetCenter(_sixStampGrid, i);
				LayoutUtil.CenterObject(stamp, pos.x, pos.y);
				_addChild(stamp);
			}
			
			if (stampCount > 6)
			{
				// Make a 7th stamp.
				stamp = new _stampDisplayClass();
				//styleStamp(stamp);
				pos = new Point(_7thContainer.x + _7thContainer.width / 2, _7thContainer.y + _7thContainer.height / 2);
				//LayoutUtil.CenterObject(stamp, pos.x, pos.y);
				//_addChild(stamp);
				
				// If the 7th stamp is new and we have a prize thumbnail URL.
				// Load the thumbnail and show it.
				if (_prizeThumbnailURL.length > 0)
				{
					var request:URLRequest = new URLRequest(_prizeThumbnailURL);
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPreviewThumbnailComplete);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onPreviewThumbnailIOError);
					trace('PrizeOfTheWeekStamps loading prize thumbnail: ' + _prizeThumbnailURL);
					loader.load(request);
					
					function onPreviewThumbnailComplete(e:Event):void
					{
						removeListeners();
						var prizeThumbnail:DisplayObject = loader.content;
						var prizeContainer:Container = new Container();
						prizeContainer.backing = new Box();
						prizeContainer.backing.style = new BoxStyle(new FillStyle(0xffffff, 1), 0x074270, 1, 6, 12);
						prizeContainer.content = prizeThumbnail;
						prizeContainer.padding = 24;
						_7thContainer.content = prizeContainer;
					}
					function onPreviewThumbnailIOError(e:IOErrorEvent):void
					{
						removeListeners();
						trace(e.toString());
					}
					function removeListeners():void
					{
						loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onPreviewThumbnailComplete);
						loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onPreviewThumbnailIOError);
					}
				}
			}
			
			_lastStamp = stamp;
			
			if (_newStamp == true)
			{
				_lastStamp.alpha = 0.8;
				_lastStamp.width *= 1.1;
				_lastStamp.height *= 1.1;
				_lastStamp.transform.colorTransform = new ColorTransform(1.3);
				LayoutUtil.CenterObject(_lastStamp, pos.x, pos.y);
			}
			
			function styleStamp(stamp:Sprite):void
			{
				stamp.blendMode = BlendMode.MULTIPLY;
				stamp.alpha = 0.5;
				stamp.rotation = Math.random() * 10 - 5;
			}
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function animate():void
		{
			// If there is a new stamp. Animate the stamp.
			if (_newStamp == true)
			{
				var duration:Number = 500;
				var stampX:Number = _lastStamp.x;
				var stampY:Number = _lastStamp.y;
				var stampWidth:Number = _lastStamp.width;
				var stampHeight:Number = _lastStamp.height;
				_lastStamp.x -= stampWidth;
				_lastStamp.y -= stampHeight;
				_lastStamp.width *= 3;
				_lastStamp.height *= 3;
				_lastStamp.alpha = 0;
				_animationManager.addEventListener(AnimationEvent.FINISH, onAnimationFinish);
				_animationManager.property(_lastStamp, 'x', stampX, duration, Transitions.CUBIC_IN, RenderMethod.TIMER);
				_animationManager.property(_lastStamp, 'y', stampY, duration, Transitions.CUBIC_IN, RenderMethod.TIMER);
				_animationManager.property(_lastStamp, 'alpha', 0.8, duration, Transitions.CUBIC_IN, RenderMethod.TIMER);
				_animationManager.property(_lastStamp, 'width', stampWidth, duration, Transitions.CUBIC_IN, RenderMethod.TIMER);
				_animationManager.property(_lastStamp, 'height', stampHeight, duration, Transitions.CUBIC_IN, RenderMethod.TIMER);
			}
			
			function onAnimationFinish(e:AnimationEvent):void
			{
				if (e.animTarget == _lastStamp)
				{
					// Remove the event listener and play a sound.
					_animationManager.removeEventListener(AnimationEvent.FINISH, onAnimationFinish);
					
					var soundChannel:SoundChannel;
					var stampSound:StampSound = new StampSound();
					soundChannel = stampSound.play();
				}
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		override protected function _render():void
		{
			super._render();
			
			_sixStampGrid.unitWidth = _fifthWidth;
			_sixStampGrid.unitHeight = _halfHeight;
			
			// Draw a line that devides the 1 - 6 stamps and the 7th stamp area.
			var lineX:Number = _sixStampGrid.width;
			_deviderLineLayer.graphics.clear();
			_deviderLineLayer.graphics.lineStyle(_deviderLineStyle.thickness, _deviderLineStyle.color, _deviderLineStyle.alpha);
			_deviderLineLayer.graphics.moveTo(lineX, 0);
			_deviderLineLayer.graphics.lineTo(lineX, _height);
			
			// Position the 7th stamp container.
			_7thContainer.x = lineX;
			_7thContainer.width = _fifthWidth * 2;
			_7thContainer.height = _height;
		}
		
		override public function set width(value:Number):void
		{
			_quarterWidth = value / 4;
			_fifthWidth = _width / 5;
			super.width = value;
		}
		
		override public function set height(value:Number):void
		{
			_halfHeight = _height / 2;
			super.height = value;
		}
		
	}
}