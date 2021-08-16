package com.sdg.components.dialog
{
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.managers.PopUpManager;

	public class InteractiveBgObjectDialog extends Canvas implements ISdgDialog
	{
		private static const DIALOG_URL_PREFIX:String = Environment.getAssetUrl()+"/test/gameSwf/gameId/80/gameFile/";
		
		private var _itemId:String = "";
		private var _display:DisplayObject;
		
		public function InteractiveBgObjectDialog()
		{
			super();
			
			this.x = 0;
			this.y = 0;
		}
		
		public function init(params:Object):void
		{
			if (params)
			{
				_itemId = params.itemId;
			}
			else
			{
				this.close();
			}
			
			_display = new QuickLoader(DIALOG_URL_PREFIX+_itemId+"_dialog.swf", loadCompleteHandler,null,3);
		}
		
		
		protected function loadCompleteHandler():void
		{
			//_display = DisplayObject(_resource.content);
			_display.addEventListener(Event.CLOSE,onClick);
			this.rawChildren.addChild(_display);
		}
		
		
		protected function onClick(e:Event):void
		{
			this.close();
		}
		
		public function close():void
		{
			// Remove Listener
			_display.removeEventListener(Event.CLOSE,onClick);
			
			try
			{
				Object(_display).unloadSound();
			}
			catch(e:Error) {}
			
			PopUpManager.removePopUp(this);
		}
		
	}
}