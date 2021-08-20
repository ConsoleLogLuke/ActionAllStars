package com.sdg.components.controls
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.good.goodgraphics.GoodArrow;
	import com.sdg.events.ScrollEvent;
	import com.sdg.ui.GoodCloseButton;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	import mx.core.FlexGlobals; // Non-SDG - Application to FlexGlobals

	public class ChatLogPanel extends Sprite
	{
		protected var _animManager:AnimationManager;
		protected var _backing:Sprite;
		protected var _titleField:TextField;
		protected var _logField:TextField;
		protected var _topBar:Sprite;
		//protected var _toggleCatch:Sprite;
		protected var _scrollBar:ScrollBar;
		protected var _closeBtn:GoodCloseButton;

		protected var _expanded:Boolean;
		protected var _width:Number;
		protected var _height:Number;
		protected var _margin:Number;
		protected var _anchor:Point;
		protected var _expandedAnchor:Point;
		protected var _dragArea:Rectangle;

		public function ChatLogPanel()
		{
			super();

			this.visible = false;
			_expanded = false;
			_margin = 10;

			_anchor = new Point();
			_expandedAnchor = new Point();

			_backing = new Sprite();
			addChild(_backing);

			_topBar = new Sprite();
			_topBar.addEventListener(MouseEvent.MOUSE_DOWN, onTopBarMouseDown);
			addChild(_topBar);

			_titleField = new TextField();
			_titleField.defaultTextFormat = new TextFormat('EuroStyle', 12, 0xffffff, true);
			_titleField.text = 'CHAT LOG';
			_titleField.autoSize = TextFieldAutoSize.LEFT;
			_titleField.embedFonts = true;
			_titleField.selectable = false;
			addChild(_titleField);

			_logField = new TextField();
			_logField.defaultTextFormat = new TextFormat('EuroStyle', 12, 0xffffff);
			_logField.multiline = true;
			_logField.wordWrap = true;
			_logField.embedFonts = true;
			_logField.selectable = false;
			_logField.width = _logField.height = 0;
			addChild(_logField);

			_closeBtn = new GoodCloseButton('Hide');
			_closeBtn.scaleX = 0.6;
			_closeBtn.scaleY = 0.6;
			_closeBtn.buttonMode = true;
			_closeBtn.addEventListener(MouseEvent.CLICK, onToggleClick);
			addChild(_closeBtn);

			_width = 280;
			_height = 150;

			//_toggleCatch = new Sprite();
			//_toggleCatch.graphics.beginFill(0, 0);
			//_toggleCatch.graphics.drawRect(0, 0, _width, _height);
			//_toggleCatch.buttonMode = true;
			//_toggleCatch.addEventListener(MouseEvent.CLICK, onToggleClick);
			//_toggleCatch.addEventListener(MouseEvent.ROLL_OVER, onToggleRollOver);
			//_toggleCatch.addEventListener(MouseEvent.ROLL_OUT, onToggleRollOut);
			//addChild(_toggleCatch);

			_scrollBar = new VerticalScrollBar();
			_scrollBar.width = 12;
			_scrollBar.height = _height;
			_scrollBar.addEventListener(ScrollEvent.SCROLL, onScroll);
			//_scrollBar.visible = false;
			_scrollBar.visible = true;
			addChild(_scrollBar);

			// Style the scroll bar.
			var upButton:Sprite = new Sprite();
			upButton.graphics.beginFill(0x00ff00, 0);
			upButton.graphics.drawRect(0, 0, 100, 100);
			var upArrow:GoodArrow = new GoodArrow(70, 70, 0xffffff);
			upArrow.x = upButton.width / 2;
			upArrow.y = upButton.height / 2;
			upArrow.rotation = -90;
			upButton.addChild(upArrow);
			var downButton:Sprite = new Sprite();
			downButton.graphics.beginFill(0x00ff00, 0);
			downButton.graphics.drawRect(0, 0, 100, 100);
			var downArrow:GoodArrow = new GoodArrow(70, 70, 0xffffff);
			downArrow.x = downButton.width / 2;
			downArrow.y = downButton.height / 2;
			downArrow.rotation = 90;
			downButton.addChild(downArrow);
			var bar:Sprite = new Sprite();
			bar.graphics.beginFill(0, 0);
			bar.graphics.drawRect(0, 0, 10, 10);
			bar.graphics.beginFill(0xdddddd);
			bar.graphics.drawRect(2, 0, 6, 10);
			var barBack:Sprite = new Sprite();
			barBack.graphics.beginFill(0xff0000, 0);
			barBack.graphics.drawRect(0, 0, 10, 10);

			_scrollBar.scrollButton1 = upButton;
			_scrollBar.scrollButton2 = downButton;
			_scrollBar.scrollBarGrabber = bar;
			_scrollBar.scrollBarBacking = barBack;

			render();
		}

		protected function render():void
		{
			var cornerSize:Number = 8;
			var offX:Number;
			var offY:Number;
			//var collapsedArea:Rectangle = new Rectangle(0, 0, _titleField.width, _titleField.height);

			offX = -_width;
			offY = -_height;

			// Draw backing.
			_backing.graphics.clear();
			_backing.graphics.beginFill(0x2E000D, 0.7);
			_backing.graphics.drawRoundRect(offX, offY, _width, _height, cornerSize, cornerSize);
			//_backing.graphics.drawRoundRect(_expandedAnchor.x, _expandedAnchor.y, 280, 150, cornerSize, cornerSize);

			_topBar.graphics.clear();

			// Position title field.
			_titleField.x = offX + _margin;
			_titleField.y = offY;

			//_toggleCatch.x = offX;
			//_toggleCatch.y = offY;

			//if (!_expanded)
			//{
			//	_logField.visible = false;
			//}
			//else
			//{

			_topBar.graphics.beginFill(0x750025);
			_topBar.graphics.lineStyle(1, 0x000000, 1);
			_topBar.graphics.drawRoundRect(offX-1, offY-1, _width+1, 19, cornerSize, cornerSize);
			//_topBar.graphics.drawRoundRect(offX, offY, _width, collapsedArea.height, cornerSize, cornerSize);
			_topBar.graphics.endFill();
			//_topBar.graphics.lineStyle(1, 0x000000, 1);
			//_topBar.graphics.moveTo(lineX, offY + collapsedArea.height * 1/3);
			//_topBar.graphics.lineTo(lineX + lineLength, offY + collapsedArea.height * 1/3);
			//_topBar.graphics.moveTo(lineX, offY + collapsedArea.height * 1/2);
			//_topBar.graphics.lineTo(lineX + lineLength, offY + collapsedArea.height * 1/2);
			//_topBar.graphics.moveTo(lineX, offY + collapsedArea.height * 2/3);
			//_topBar.graphics.lineTo(lineX + lineLength, offY + collapsedArea.height * 2/3);

			_logField.x = offX + _margin;
			_logField.y = _titleField.y + _topBar.height + _margin / 2;
			_logField.width = _width - ((_scrollBar.visible) ? _scrollBar.width : 0) - _margin * 2;
			//_logField.height = _height - collapsedArea.height;
			_logField.height = _height - 19;

			_closeBtn.x = offX + _width - (_closeBtn.width * _closeBtn.scaleX) - _margin / 2;
			_closeBtn.y = offY + _margin / 4;

			_scrollBar.x = offX + _width - _scrollBar.width - _margin / 2;
			_scrollBar.y = offY + _topBar.height + _margin / 2;
			_scrollBar.contentSize = _logField.textHeight;

			var scrollPosition:Number = _logField.scrollV - 1 / _logField.maxScrollV - 1;
			_scrollBar.scrollPosition = (scrollPosition > 0) ? scrollPosition : 0;

			// fixed it so that the scroll doesnt move if you are looking at older messages
			if (_logField.scrollV > 1)
				_logField.scrollV += 1;

			renderScrollBar();
		}

		protected function renderScrollBar():void
		{
			_scrollBar.visible = (_expanded && _logField.maxScrollV > 1);
			_scrollBar.height = _logField.height - _margin;
			_scrollBar.windowSize = _logField.height;
			_scrollBar.contentSize = _logField.textHeight;
		}

		////////////////////
		// INSTANCE METHODS
		////////////////////

		public function logChat(name:String, chatText:String):void
		{
			_logField.htmlText = '<font><font color="#FFD800">' + name + ': </font>' + chatText + '</font><br />' + _logField.htmlText;

			if (_scrollBar.visible == false && _expanded == true && _logField.maxScrollV > 1)
			{
				_scrollBar.visible = true;
			}

			renderScrollBar();
		}

		public function saveAnchorPosition():void
		{
			_anchor.x = x;
			_anchor.y = y;
			_expandedAnchor.x = x;
			_expandedAnchor.y = y;
		}

		public function clear():void
		{
			_logField.htmlText = '';
			renderScrollBar();
		}

		////////////////////
		// GET/SET METHODS
		////////////////////

		override public function set width(value:Number):void
		{
			if (value == _width) return;
			_width = value;
			//render();
		}

		override public function set height(value:Number):void
		{
			if (value == _height) return;
			_height = value;
			//render();
		}

		public function get dragArea():Rectangle
		{
			return _dragArea;
		}
		public function set dragArea(value:Rectangle):void
		{
			_dragArea = value;
		}

		////////////////////
		// EVENT HANDLERS
		////////////////////

		private function onToggleClick(e:MouseEvent):void
		{
			// Toggle expansion.
			_expanded = (!_expanded);
			this.visible = _expanded;

			//_animManager.addEventListener(AnimationEvent.FINISH, onAnimFinish);

			/*
			if (_expanded)
			{
				_animManager.size(this, 280, 150, 500, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
				_animManager.move(this, _expandedAnchor.x, _expandedAnchor.y, 500, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
				//_animManager.rotation(_toggleArrow, 0, 500, 1, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
			}
			else
			{
				_animManager.size(this, _titleField.width, _titleField.height, 500, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
				_animManager.move(this, _anchor.x, _anchor.y, 500, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);
				//_animManager.rotation(_toggleArrow, 180, 500, 1, Transitions.CUBIC_OUT, RenderMethod.ENTER_FRAME);

				_scrollBar.visible = false;
			}

			render();
			*/

			//function onAnimFinish(e:AnimationEvent):void
			//{
				//if (e.animTarget == _toggleArrow && e.animProperty == 'rotation')
				//{
				//	_animManager.removeEventListener(AnimationEvent.FINISH, onAnimFinish);
				//
				//	_scrollBar.visible = (_expanded && _logField.maxScrollV > 1);
				//	_scrollBar.height = _logField.height - _margin;
				//	_scrollBar.windowSize = _logField.height;
				//	_scrollBar.contentSize = _logField.textHeight;
				//}
			//}
		}

		private function onTopBarMouseDown(e:MouseEvent):void
		{
			FlexGlobals.topLevelApplication.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			FlexGlobals.topLevelApplication.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

			// Get mouse offset.
			var offX:Number = mouseX;
			var offY:Number = mouseY;

			function onMouseUp(e:MouseEvent):void
			{
				// Remove event listeners.
				FlexGlobals.topLevelApplication.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				FlexGlobals.topLevelApplication.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}

			function onMouseMove(e:MouseEvent):void
			{
				var newX:Number = parent.mouseX - offX;
				var newY:Number = parent.mouseY - offY;

				if (_dragArea)
				{
					var bounds:Rectangle = _backing.getBounds(_backing.parent);
					newX = Math.max(_dragArea.x - bounds.left, newX);
					newX = Math.min(_dragArea.right - bounds.right, newX);
					newY = Math.max(_dragArea.y - bounds.top, newY);
					newY = Math.min(_dragArea.bottom - bounds.bottom, newY);
				}

				x = newX;
				y = newY;
				_expandedAnchor.x = x;
				_expandedAnchor.y = y;
			}
		}

		//private function onToggleRollOver(e:MouseEvent):void
		//{
		//	_toggleArrow.filters = [new GlowFilter(0xffffff, 0.9, 6, 6)];
		//}

		//private function onToggleRollOut(e:MouseEvent):void
		//{
			//_toggleArrow.filters = [];
		//}

		private function onScroll(e:ScrollEvent):void
		{
			_logField.scrollV = Math.ceil(e.scrollPosition * _logField.numLines) + 1;
		}

		//////////////////////////
		// MANAGE VISIBILITY
		//////////////////////////

		public function toggleFromConsole():void
		{
			this.onToggleClick(new MouseEvent(MouseEvent.CLICK));
		}

		//public function getExpandedStatus():Boolean
		//{
		//	return this._expanded;
		//}

		//public function setVisible(value:Boolean):void
		//{
		//	if (this.visible != value)
		//	{
		//		this.visible = value;
		//	}
		//}

		//public function getVisible():Boolean
		//{
		//	return this.visible;
		//}

	}
}
