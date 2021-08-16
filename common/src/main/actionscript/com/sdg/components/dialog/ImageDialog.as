package com.sdg.components.dialog
{
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.containers.Canvas;
	import mx.managers.PopUpManager;

	/**
	 * 
	 * This is used in broadcast center when someone clicks on an image.
	 * It passes in an array of images to zoom though.
	 * In theory could be used with any params that pass in "info"
	 * that have a url and an optional caption.
	 * 
	 * @author molly.jameson
	*/
	public class ImageDialog extends Canvas implements ISdgDialog
	{
		protected var _display:Sprite;
		protected var m_RightArrow:Sprite;
		protected var m_LeftArrow:Sprite;
		private var m_Caption:TextField;

		// Contains an object with a quickloader and an optional caption.
		private var m_ArrImagesInfo:Array;
		private var m_CurrIndex:int;
		
		public function ImageDialog()
		{
			super();
			m_ArrImagesInfo = new Array();
			m_CurrIndex = 0;
		}
		
		public function init(params:Object):void
		{
			// caption and Image to load!
			
			if (params && params.info)
			{
				var infoArr:Array = params.info;
				for(var i:int = 0; i < infoArr.length; ++i)
				{
					var singleInfo:Object = infoArr[i];
					if(singleInfo.hasOwnProperty("HeadLine"))
					{
						singleInfo.headline = singleInfo.HeadLine;
					}
					else
					{
						singleInfo.headline = "";
					}
					if(i == 0)
					{
						singleInfo.image = new QuickLoader(singleInfo.photoURL, loadCompleteHandler,loadFailed,3);
					}
					else
					{
						singleInfo.image = new QuickLoader(singleInfo.photoURL, null,loadFailed,3);
					}
					
					m_ArrImagesInfo.push(singleInfo);
				}
			}
			else
			{
				this.close();
			}
			_display = new Sprite();
			_display.graphics.beginFill(0,0.7);
			_display.graphics.drawRect(0,0,925,665);
			_display.graphics.endFill();
			this.rawChildren.addChild(_display);
			
			//m_Image = new QuickLoader(_url, loadCompleteHandler,loadFailed,3);
			
			_display.buttonMode = _display.useHandCursor = true;
		}
		
		public function close():void
		{
			_display.removeEventListener(MouseEvent.CLICK,onClick);
			PopUpManager.removePopUp(this);
		}
		
		public function onClick(ev:MouseEvent):void
		{
			close();
		}
		
		private function loadFailed():void
		{
			close();
		}
		protected function loadCompleteHandler():void
		{
			_display.addEventListener(MouseEvent.CLICK,onClick);
			
			
			initGraphics();
		}
		
		private function initGraphics():void
		{
			var currDisplay:DisplayObject =  m_ArrImagesInfo[m_CurrIndex].image;
			_display.addChild(currDisplay);
			currDisplay.x = this.root.width/2 - currDisplay.width/2;
			currDisplay.y = this.root.height/2 - currDisplay.height/2;
			
			const rectBoarder:int = 20
			// create them if not created.
			if(m_ArrImagesInfo.length > 1)
			{
				if(m_RightArrow == null)
				{
					m_RightArrow = makeArrow(false);
					m_RightArrow.addEventListener(MouseEvent.CLICK,onRightClick);
					m_RightArrow.addEventListener(MouseEvent.MOUSE_OVER,onArrowHover);
					m_RightArrow.addEventListener(MouseEvent.MOUSE_OUT,onArrowExit);
					_display.addChild(m_RightArrow);
				}
				if(m_LeftArrow == null)
				{
					m_LeftArrow = makeArrow();
					m_LeftArrow.addEventListener(MouseEvent.CLICK,onLeftClick);
					m_LeftArrow.addEventListener(MouseEvent.MOUSE_OVER,onArrowHover);
					m_LeftArrow.addEventListener(MouseEvent.MOUSE_OUT,onArrowExit);
					_display.addChild(m_LeftArrow);
				}
				// reset the arrow positions.
				m_RightArrow.x = currDisplay.x + currDisplay.width + rectBoarder/4;
				m_RightArrow.y = currDisplay.y + currDisplay.height/2 - m_RightArrow.height;
				m_LeftArrow.x = currDisplay.x - m_LeftArrow.width;
				m_LeftArrow.y = currDisplay.y + currDisplay.height/2 - m_LeftArrow.height;
			}
			
			if(m_Caption == null)
			{
				m_Caption = new TextField();
				m_Caption.defaultTextFormat = new TextFormat("Arial",10,0xFFFFFF);
				m_Caption.autoSize = "center";
				m_Caption.selectable = false;
				m_Caption.mouseEnabled = false;
			}
			m_Caption.text = m_ArrImagesInfo[m_CurrIndex].headline;
			_display.addChild(m_Caption);
			m_Caption.x = this.root.width/2 - currDisplay.width/2;
			m_Caption.y = this.root.height/2 + currDisplay.height/2;
			
			
			// put in image boarder
			_display.graphics.clear();
			// draws the background
			_display.graphics.beginFill(0,0.7);
			_display.graphics.drawRect(0,0,925,665);
			_display.graphics.endFill();
			// draws the boarder around the image at the correct size
			_display.graphics.beginFill(0xCCCCCC,1);
			_display.graphics.drawRoundRect(currDisplay.x - rectBoarder,currDisplay.y - rectBoarder, 
											currDisplay.width + rectBoarder,currDisplay.height + rectBoarder,50);
			_display.graphics.endFill();
			currDisplay.x =  currDisplay.x - rectBoarder/2;
			currDisplay.y =  currDisplay.y - rectBoarder/2;	
		}
		
		private function makeArrow(isLeft:Boolean = true):Sprite
		{
			var s:Sprite = new Sprite();
			var triangleHeight:uint = 50;
			s.graphics.beginFill(0xCCCCCC);
			if(isLeft)
			{
				// top
				s.graphics.moveTo(0,0);
				// bottom
				s.graphics.lineTo(0, triangleHeight);
				// left
				s.graphics.lineTo(-triangleHeight/2, triangleHeight/2);
				// top
				s.graphics.lineTo(0, 0);
			}
			else
			{
				// top
				s.graphics.moveTo(0, 0);
				// bottom
				s.graphics.lineTo(0, triangleHeight);
				// right
				s.graphics.lineTo(triangleHeight/2, triangleHeight/2);
				// top
				s.graphics.lineTo(0, 0);
			}
			s.graphics.endFill();
			
			_display.addChild(s);
			return s;
		}
		
		private function onArrowHover(ev:MouseEvent):void
		{
			var s:Sprite = ev.target as Sprite;
			if(s)
			{
				s.filters = [new GlowFilter(0xFFFFFF,1,6,6,10)];
			}
		}
		private function onArrowExit(ev:MouseEvent):void
		{
			var s:Sprite = ev.target as Sprite;
			if(s)
			{
				s.filters = [];
			}
		}
		private function onLeftClick(ev:MouseEvent):void
		{
			ev.stopImmediatePropagation();
			removeCurrentImage();
			m_CurrIndex = (m_CurrIndex - 1) % m_ArrImagesInfo.length;
			if(m_CurrIndex < 0)
			{
				m_CurrIndex = m_ArrImagesInfo.length - 1;
			}
			
			initGraphics();
		}
		private function onRightClick(ev:MouseEvent):void
		{
			ev.stopImmediatePropagation();
			removeCurrentImage();
			m_CurrIndex = (m_CurrIndex + 1) % m_ArrImagesInfo.length;
			initGraphics();
		}
		
		private function removeCurrentImage():void
		{
			var currDisplay:DisplayObject =  m_ArrImagesInfo[m_CurrIndex].image;
			if(currDisplay.parent == _display)
			{
				_display.removeChild(currDisplay);
			}
		}
		
	}
}