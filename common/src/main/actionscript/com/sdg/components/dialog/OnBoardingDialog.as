package com.sdg.components.dialog
{
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.GameAssetId;
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.managers.PopUpManager;

	public class OnBoardingDialog extends Canvas implements ISdgDialog
	{
		protected var _display:DisplayObject;
		
		public function OnBoardingDialog()
		{
			super();
			
			this.x = 0;
			this.y = 0;
		}
		
		public function init(params:Object):void
		{
			var url:String = AssetUtil.GetGameAssetUrl(GameAssetId.WORLD, 'onboarding.swf');
			_display = new QuickLoader(url, loadCompleteHandler,null,3);
		}
		
		protected function loadCompleteHandler():void
		{
			// Log Start
			LoggingUtil.sendClickLogging(LoggingUtil.ONBOARDING_START);
			
			_display.addEventListener(Event.CLOSE,onClick);
			this.rawChildren.addChild(_display);
		}
		
		protected function onClick(e:Event):void
		{
			// Log Closing
			LoggingUtil.sendClickLogging(LoggingUtil.ONBOARDING_END);
			
			this.close();
		}
		
		public function close():void
		{
			// Remove Listener
			_display.removeEventListener(Event.CLOSE,onClick);
			
			//Forward the close event to anything listening
			this.dispatchEvent(new Event(Event.CLOSE));
			
			// Tell Room Manager to show World Map
			//RoomManager.getInstance().dispatchEvent(new RoomManagerEvent(RoomManagerEvent.REQUEST_FOR_WORLD_MAP));

			PopUpManager.removePopUp(this);
		}
		
	}
}