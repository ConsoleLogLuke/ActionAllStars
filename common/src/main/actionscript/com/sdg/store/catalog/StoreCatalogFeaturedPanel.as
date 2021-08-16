package com.sdg.store.catalog
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.buttonstyle.ButtonSyle;
	import com.sdg.buttonstyle.IButtonStyle;
	import com.sdg.controls.BasicButton;
	import com.sdg.display.BoxStyle;
	import com.sdg.display.GradientFillStyle;
	import com.sdg.model.DisplayObjectCollection;
	import com.sdg.mvc.ViewBase;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	public class StoreCatalogFeaturedPanel extends ViewBase implements IStoreCatalogFeaturedPanel
	{
		protected var _background:DisplayObject;
		protected var _displaySet:DisplayObjectCollection;
		protected var _currentDisplayIndex:uint;
		protected var _currentDisplay:DisplayObject;
		protected var _windowMask:Sprite;
		protected var _featuredDisplayContainer:Sprite;
		protected var _windowBounds:Rectangle;
		protected var _windowBorder:Sprite;
		protected var _cycleTimer:Timer;
		protected var _cycleLength:uint;
		protected var _displayNavObjects:DisplayObjectCollection;
		protected var _navButtonStyle:IButtonStyle;
		protected var _animationManager:AnimationManager;
		
		public function StoreCatalogFeaturedPanel()
		{
			super();
			
			// Defaults.
			_width = 680;
			_height = 550;
			_cycleLength = 10000;
			_displayNavObjects = new DisplayObjectCollection();
			_animationManager = new AnimationManager();
			
			// Create nav button style.
			var offStyle:BoxStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x0a4d77, 0x002841], [1, 1], [1, 255], Math.PI / 2), 0xcccccc, 1, 1);
			var overStyle:BoxStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0x002841, 0x0a4d77], [1, 1], [1, 255], Math.PI / 2), 0xcccccc, 1, 1);
			_navButtonStyle = new ButtonSyle(offStyle, overStyle, overStyle);
			
			// Create window mask.
			_windowMask = new Sprite();
			_windowMask.graphics.beginFill(0x00ff00);
			drawWindow(_windowMask.graphics);
			addChild(_windowMask);
			
			// Set window bounds.
			_windowBounds = _windowMask.getBounds(this);
			
			// Create featured display container.
			_featuredDisplayContainer = new Sprite();
			_featuredDisplayContainer.x = _windowBounds.x;
			_featuredDisplayContainer.y = _windowBounds.y;
			_featuredDisplayContainer.mask = _windowMask;
			_featuredDisplayContainer.filters = [new GlowFilter(0x000000, 1, 12, 12, 2, 1, true)];
			addChild(_featuredDisplayContainer);
			
			// Create window border.
			_windowBorder = new Sprite();
			_windowBorder.graphics.lineStyle(1, 0xffffff, 0.5);
			drawWindow(_windowBorder.graphics);
			addChild(_windowBorder);
			
			// Create a timer, used to run through featured displays.
			_cycleTimer = new Timer(_cycleLength);
			_cycleTimer.addEventListener(TimerEvent.TIMER, onCycleTimerInterval);
			_cycleTimer.start();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		override public function destroy():void
		{
			// Destroy cycle timer.
			_cycleTimer.removeEventListener(TimerEvent.TIMER, onCycleTimerInterval);
			_cycleTimer.reset();
		}
		
		override public function render():void
		{
			if (_background != null)
			{
				_background.width = _width;
				_background.height = _height;
			}
			
			// Postion nav objects.
			var i:uint = 0;
			var len:uint = _displayNavObjects.length;
			var lastNav:DisplayObject;
			for (i; i < len; i++)
			{
				// Get reference to object.
				var navObject:DisplayObject = _displayNavObjects.getAt(i);
				
				// Determine new x position.
				var newX:Number = (lastNav != null) ? lastNav.x + lastNav.width + 10 : _windowBounds.x + 16;
				
				// Posiion the nav object.
				navObject.x = newX;
				navObject.y = _windowBounds.bottom + 8;
				
				// Save reference to this nav object.
				lastNav = navObject;
			}
		}
		
		protected function drawWindow(graphics:Graphics):void
		{
			graphics.moveTo(38, 32);
			graphics.lineTo(636, 32);
			graphics.curveTo(656, 32, 656, 52);
			graphics.lineTo(656, 495);
			graphics.lineTo(636, 511);
			graphics.lineTo(37, 511);
			graphics.curveTo(17, 511, 17, 491);
			graphics.lineTo(17, 48);
			graphics.lineTo(38, 32);
		}
		
		protected function goToDisplayIndex(i:uint):void
		{
			// Get a reference to the new display to show.
			var display:DisplayObject = _displaySet.getAt(i);
			if (display == null) return;
			
			// Reset the cycle timer.
			_cycleTimer.reset();
			_cycleTimer.start();
			
			// Get a reference to the current display.
			var oldDisplay:DisplayObject = _currentDisplay;
			
			// Set the new display.
			_currentDisplay = display;
			_currentDisplayIndex = i;
			
			// Center the display within the window.
			_currentDisplay.x = _windowBounds.width / 2 - _currentDisplay.width / 2;
			_currentDisplay.y = _windowBounds.height / 2 - _currentDisplay.height / 2;
			
			// Set alpha to 0 so we can fade it in.
			_currentDisplay.alpha = 0;
			
			// Add to container.
			_featuredDisplayContainer.addChild(_currentDisplay);
			
			// Fade in the new display.
			if (oldDisplay != null) _animationManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animationManager.alpha(_currentDisplay, 1, 1000, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			
			// Style nav objects.
			styleNavObjects();
			
			function onAnimFinish(e:AnimationEvent):void
			{
				// If the new display is done fading in,
				// Remove the old one.
				if (e.animTarget == _currentDisplay && _currentDisplay.alpha == 1)
				{
					// Remove event listener.
					_animationManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					
					// Remove the old display.
					_featuredDisplayContainer.removeChild(oldDisplay);
				}
			}
		}
		
		protected function buildFeaturedDisplayNav():void
		{
			// Clear previous navs.
			var i:uint = 0;
			var len:uint = _displayNavObjects.length;
			for (i; i < len; i++)
			{
				// Get reference to object.
				var navObject:DisplayObject = _displayNavObjects.getAt(i);
				
				// Remove event listeners.
				navObject.removeEventListener(MouseEvent.CLICK, onNavClick);
				
				// Remove from display.
				removeChild(navObject);
			}
			
			// Empty the collection for nav objects.
			_displayNavObjects.empty();
			
			// Create new nav objects.
			i = 0;
			len = _displaySet.length;
			for (i; i < len; i++)
			{
				// Create a nav object.
				var newNav:DisplayObject = createNavObject(uint(i + 1).toString());
				
				// Listen for clicks.
				newNav.addEventListener(MouseEvent.CLICK, onNavClick);
				
				// Add it to display.
				addChild(newNav);
				
				// Add the nav object to the collection.
				_displayNavObjects.push(newNav);
			}
			
			// Style nav objects.
			styleNavObjects();
			
			// Render
			render();
		}
		
		protected function createNavObject(label:String):DisplayObject
		{
			var nav:BasicButton = new BasicButton(label, 18, 18, _navButtonStyle);
			nav.labelFormat = new TextFormat('EuroStyle', 12, 0xffffff, true);
			nav.embedFonts = true;
			return nav;
		}
		
		protected function styleNavObjects():void
		{
			var i:uint = 0;
			var len:uint = _displayNavObjects.length;
			for (i; i < len; i++)
			{
				// Get reference to object.
				var navObject:DisplayObject = _displayNavObjects.getAt(i);
				
				// Set filters.
				navObject.filters = (i != _currentDisplayIndex) ? [] : [new GlowFilter(0xffffff, 1, 8, 8)];
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set background(value:DisplayObject):void
		{
			// Remove previous.
			if (_background != null)
			{
				removeChild(_background);
			}
			
			// Set new one.
			_background = value;
			addChildAt(_background, 0);
			
			render();
		}
		
		public function set featuredDisplaySet(value:DisplayObjectCollection):void
		{
			_displaySet = value;
			goToDisplayIndex(0);
			buildFeaturedDisplayNav();
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onCycleTimerInterval(e:TimerEvent):void
		{
			// If the mouse is not within the window area, cycle to next featured display.
			if (_windowBounds.contains(mouseX, mouseY) == false)
			{
				var newIndex:uint = (_currentDisplayIndex < _displaySet.length - 1) ? _currentDisplayIndex + 1 : 0;
				goToDisplayIndex(newIndex);
			}
		}
		
		private function onNavClick(e:MouseEvent):void
		{
			// Get a reference to the nav object.
			var navObject:DisplayObject = e.currentTarget as DisplayObject;
			
			// Determine index.
			var index:uint = _displayNavObjects.indexOf(navObject);
			
			// Show featured display at that inidex.
			goToDisplayIndex(index);
		}
		
	}
}