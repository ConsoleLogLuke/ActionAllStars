package com.sdg.view.pda
{
	import com.sdg.net.QuickLoader;
	import com.sdg.view.pda.interfaces.IPDAButtonBase;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	
	import mx.core.UIComponent;

	public class PDAButton3 extends UIComponent implements IPDAButtonBase
	{
		private var _mouseOverSound:Sound;
		private var _clickSound:Sound;
		private var _callBack:Function;
		private var _content:DisplayObject;
		
		public function PDAButton3()
		{
			super();
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
			addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}
		
		private function onMouseOver(event:MouseEvent):void
		{
			if (_mouseOverSound)
				_mouseOverSound.play();
		}
		
		private function onClick(event:MouseEvent):void
		{
			if (_clickSound)
				_clickSound.play();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (_content)
			{
				scaleLogo();
			}
		}
		
		private function scaleLogo():void
		{
			var scale:Number = Math.min(width/_content.width, height/_content.height);
			_content.scaleX *= scale;
			_content.scaleY *= scale;
		}
		
		public function set swfUrl(value:String):void
		{
			var loader:QuickLoader = new QuickLoader(value, onComplete);
			
			function onComplete():void
			{
				_content = loader.content;
				addChild(_content);
				scaleLogo();
			}
		}
		
		public function set mouseOverSound(value:Sound):void
		{
			_mouseOverSound = value;
		}
		
		public function set clickSound(value:Sound):void
		{
			_clickSound = value;
		}
		
		public function set callBack(value:Function):void
		{
			_callBack = value;
		}
		
		public function get callBack():Function
		{
			return _callBack;
		}
	}
}