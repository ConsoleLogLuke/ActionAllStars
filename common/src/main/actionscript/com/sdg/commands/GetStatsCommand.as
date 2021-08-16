package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.GetStatsEvent;
	import com.sdg.model.ModelLocator;
	
	import mx.rpc.IResponder;
	
	public class GetStatsCommand implements ICommand, IResponder
	{
		private var _event:GetStatsEvent;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as GetStatsEvent;
			new SdgServiceDelegate(this).getGameStats(ModelLocator.getInstance().avatar.avatarId, _event.gameId, _event.timeCheck);
		}
		
		public function result(data:Object):void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(
				new GetStatsEvent(GetStatsEvent.STATS_RECEIVED, _event.gameId, data.stats, _event.timeCheck, data.@gameOn == 1));
		}
		
		public function fault(info:Object):void
		{
			CairngormEventDispatcher.getInstance().dispatchEvent(new GetStatsEvent(GetStatsEvent.GET_STATS_ERROR, _event.gameId));
		}
	}
}