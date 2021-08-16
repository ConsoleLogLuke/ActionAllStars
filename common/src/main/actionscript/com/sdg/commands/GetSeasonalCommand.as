package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.GetSeasonalEvent;
	
	import mx.rpc.IResponder;
		
	public class GetSeasonalCommand implements ICommand, IResponder
	{
		private var _avatarId:int;
		
		public function execute(event:CairngormEvent):void
		{
			var ev:GetSeasonalEvent = event as GetSeasonalEvent;
			_avatarId = ev.avatarId;
			new SdgServiceDelegate(this).getSeasonal(ev.avatarId);
		}
		
		public function result(data:Object):void
		{
			var xml:XML = XML(data);
			trace(xml);
			
			// dispatch a "listCompleted" event			
			CairngormEventDispatcher.getInstance().dispatchEvent(
				new GetSeasonalEvent(_avatarId, GetSeasonalEvent.GET_SEASONAL_COMPLETED, xml));
		}
		
		public function fault(info:Object):void
		{
			trace("GetSeasonalCommand failed for avatarId " + _avatarId);
			
			// dispatch a "listCompleted" event			
			CairngormEventDispatcher.getInstance().dispatchEvent(
				new GetSeasonalEvent(_avatarId, GetSeasonalEvent.GET_SEASONAL_COMPLETED, null));
		}
	}
}