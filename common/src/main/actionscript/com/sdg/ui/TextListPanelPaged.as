package com.sdg.ui
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.audio.EmbeddedAudio;
	import com.sdg.events.SelectedEvent;
	import com.sdg.view.FluidView;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TextListPanelPaged extends FluidView
	{
		private var _back:Sprite;
		private var _mask:Sprite;
		private var _maskedDisplay:Sprite;
		private var _border:Sprite;
		private var _corner:int;
		private var _textList:Array;
		private var _viewCount:int;
		private var _length:int;
		private var _pages:int;
		private var _pageIndex:int;
		private var _selIndex:int;
		private var _currentItems:Array;
		private var _margin:int;
		private var _controlHeight:Number;
		private var _itemHeight:Number;
		private var _pageLabel:TextField;
		private var _leftBtn:ArrowButtonYellow;
		private var _rightBtn:ArrowButtonYellow;
		private var _animMan:AnimationManager;
		private var _currentItemViewContainer:Sprite;
		private var _backColor:uint;
		private var _evenColor:uint;
		private var _oddColor:uint;
		private var _selColor:uint;
		private var _overSound:Sound;
		private var _openSound:Sound;
		
		public function TextListPanelPaged(textList:Array, selectedIndex:int, width:Number = 100, height:Number = 200, cornerSize:Number = 20)
		{
			// Make list of strings.
			_textList = [];
			for each (var s:String in textList)
			{
				_textList.push(s);
			}
			
			_corner = cornerSize;
			_selIndex = selectedIndex;
			_length = _textList.length;
			_viewCount = 10;
			_pages = Math.ceil(_length / _viewCount);
			_pageIndex = Math.max(Math.floor(_selIndex / _viewCount), 0);
			_currentItems = [];
			_margin = 0;
			_animMan = new AnimationManager();
			_backColor = 0x222222;
			_evenColor = 0x555555;
			_oddColor = 0x444444;
			_selColor = 0x324cab;
			_overSound = new EmbeddedAudio.OverSound();
			_openSound = new EmbeddedAudio.OpenSound();
			
			_back = new Sprite();
			
			_mask = new Sprite();
			
			_maskedDisplay = new Sprite();
			_maskedDisplay.mask = _mask;
			
			_border = new Sprite();
			
			_pageLabel = new TextField();
			_pageLabel.defaultTextFormat = new TextFormat('EuroStyle', 18, 0xffffff, true);
			_pageLabel.autoSize = TextFieldAutoSize.LEFT;
			_pageLabel.selectable = false;
			_pageLabel.mouseEnabled = false;
			_pageLabel.embedFonts = true;
			_pageLabel.text = (_pageIndex + 1).toString() + '/' + _pages;
			
			_leftBtn = new ArrowButtonYellow();
			_leftBtn.rotation = 180;
			_leftBtn.useRollOverState = true;
			_leftBtn.buttonMode = true;
			_leftBtn.addEventListener(MouseEvent.MOUSE_DOWN, onLeftBtnDown);
			
			_rightBtn = new ArrowButtonYellow();
			_rightBtn.useRollOverState = true;
			_rightBtn.buttonMode = true;
			_rightBtn.addEventListener(MouseEvent.MOUSE_DOWN, onRightBtnDown);
			
			_controlHeight = _leftBtn.height + 20;
			_itemHeight = (height - _margin - _controlHeight) / _viewCount;
			
			super(width, height);
			
			// Build list view.
			var i:int = 0;
			var index:int = _pageIndex * _viewCount + i;
			_currentItemViewContainer = new Sprite();
			for (i; index < _length && i < _viewCount; i++)
			{
				var item:TextBox = createItemView(i);
				_currentItemViewContainer.addChild(item);
				_currentItems.push(item);
				
				// Add interaction listener.
				item.addEventListener(MouseEvent.ROLL_OVER, onItemRollOver);
				
				index++;
			}
			
			// Add current item view container to display.
			_maskedDisplay.addChild(_currentItemViewContainer);
			
			render();
			
			// Add displays.
			addChild(_back);
			addChild(_mask);
			addChild(_maskedDisplay);
			addChild(_border);
			
			addChild(_pageLabel);
			addChild(_leftBtn);
			addChild(_rightBtn);
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function getTextAt(index:int):String
		{
			return _textList[index];
		}
		
		////////////////////
		// PROTECED FUNCTIONS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			_back.graphics.clear();
			_back.graphics.beginFill(_backColor);
			_back.graphics.drawRoundRect(0, 0, _width, _height, _corner, _corner);
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0x222222);
			_mask.graphics.drawRoundRect(0, 0, _width, _height, _corner, _corner);
			
			_border.graphics.clear();
			_border.graphics.lineStyle(3, 0, 1, true);
			_border.graphics.drawRoundRect(0, 0, _width, _height, _corner, _corner);
			
			// Page label.
			renderPageLabel();
			
			_leftBtn.x = _leftBtn.width / 2 + 10;
			_leftBtn.y = _height - _leftBtn.height / 2 - 10
			
			_rightBtn.x = _width - _rightBtn.width / 2 - 10;
			_rightBtn.y = _leftBtn.y;
			
			// Update page button visibility.
			updatePageButtons();
			
			// Render current items.
			renderCurrentItemViews();
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function createItemView(index:int):TextBox
		{
			var isOdd:Boolean = (index % 2) > 0;
			var totalIndex:int = _pageIndex * _viewCount + index;
			var text:String = _textList[totalIndex];
			var boxColor:uint = (totalIndex == _selIndex) ? _selColor : (isOdd) ? _evenColor : _oddColor;
			
			var textBox:TextBox = new TextBox(text, boxColor, _width, _itemHeight);
			textBox.buttonMode = true;
			
			return textBox;
		}
		
		private function renderCurrentItemViews():void
		{
			// Render current items.
			var i:int = 0;
			var len:int = _currentItems.length;
			var lastItemY:Number = _margin;
			for (i; i < len; i++)
			{
				var item:TextBox = _currentItems[i];
				item.width = _width;
				item.y = lastItemY;
				
				lastItemY = lastItemY + item.height;
			}
		}
		
		private function updatePageButtons():void
		{
			// Update page button visibility.
			_leftBtn.visible = _pageIndex > 0;
			_rightBtn.visible = (_pageIndex + 1) < _pages;
		}
		
		private function renderPageLabel():void
		{
			_pageLabel.x = _width / 2 - _pageLabel.width / 2;
			_pageLabel.y = _height - _pageLabel.height - 10;
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public function get pageIndex():int
		{
			return _pageIndex;
		}
		public function set pageIndex(value:int):void
		{
			// Make sure were not currently animating a page.
			value = Math.max(value, 0);
			value = Math.min(value, _pages);
			if (value == _pageIndex) return;
			
			var pageDir:int = value - _pageIndex;
			trace('pageDir = ' + pageDir);
			_pageIndex = value;
			
			// Update page label.
			_pageLabel.text = (_pageIndex + 1).toString() + '/' + _pages;
			renderPageLabel();
			
			// Remove interaction listeners from current item views.
			var i:int = 0;
			var len:int = _currentItems.length;
			var item:TextBox;
			for (i; i < len; i++)
			{
				item = _currentItems[i];
				item.removeEventListener(MouseEvent.ROLL_OVER, onItemRollOver);
			}
			
			// Clear list of current views.
			_currentItems = [];
			
			// Create a new set of item views to show.
			i = _viewCount * _pageIndex;
			var index:int = 0;
			var itemContainer:Sprite = new Sprite();
			var lastY:Number = _margin;
			for (i; i < _length && index < _viewCount; i++)
			{
				item = createItemView(index);
				item.y = lastY;
				itemContainer.addChild(item);
				_currentItems.push(item);
				lastY = item.y + item.height;
				
				// Add interaction listener.
				item.addEventListener(MouseEvent.ROLL_OVER, onItemRollOver);
				
				index++;
			}
			
			// Position the new item views so we can animate them in.
			itemContainer.x = (pageDir > 0) ? _width : -_width;
			_maskedDisplay.addChild(itemContainer);
			// Animate out the current item views, animate in the new item views.
			var oldItemViewContainer:Sprite = _currentItemViewContainer;
			_currentItemViewContainer = itemContainer;
			var duration:int = 300;
			var oldItemContainerDestX:Number = (pageDir > 0) ? -_width : _width;
			_animMan.addEventListener(AnimationEvent.FINISH, onAnimFinish);
			_animMan.move(oldItemViewContainer, oldItemContainerDestX, oldItemViewContainer.y, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_animMan.move(_currentItemViewContainer, 0, 0, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			// Update page button visibility.
			updatePageButtons();
			
			function onAnimFinish(e:AnimationEvent):void
			{
				// Check if animation is complete.
				if (e.animTarget == _currentItemViewContainer && _currentItemViewContainer.x == 0)
				{
					// Animation is complete.
					// Remove listener.
					_animMan.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
					
					// Remove old item view container.
					_maskedDisplay.removeChild(oldItemViewContainer);
				}
			}
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onLeftBtnDown(e:MouseEvent):void
		{
			pageIndex--;
		}
		
		private function onRightBtnDown(e:MouseEvent):void
		{
			pageIndex++;
		}
		
		private function onItemRollOver(e:MouseEvent):void
		{
			// Change color of text box for a roll over effect.
			// Get item reference.
			var item:TextBox = e.currentTarget as TextBox;
			if (item == null) return;
			var initColor:uint = item.backColor;
			item.backColor = 0x000000;
			
			// Play over sound.
			_overSound.play();
			
			// Listen for roll out or mouse down.
			item.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			item.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			function onRollOut(e:MouseEvent):void
			{
				// Remove listeners.
				item.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				item.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				
				// Return item to its original color.
				item.backColor = initColor;
			}
			
			function onMouseDown(e:MouseEvent):void
			{
				// Remove listeners.
				item.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
				item.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				
				// Determine index of item.
				var currentListIndex:int = _currentItems.indexOf(item);
				if (currentListIndex < 0) return;
				var totalIndex:int = _pageIndex * _viewCount + currentListIndex;
				
				// Play open sound.
				_openSound.play();
				
				// Dispatch selected event.
				dispatchEvent(new SelectedEvent(SelectedEvent.SELECTED, totalIndex));
			}
		}
		
	}
}