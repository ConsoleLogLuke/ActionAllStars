package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.components.controls.SdgAlertChrome;
	import com.sdg.events.PickemScorecardEvent;
	import com.sdg.utils.ErrorCodeUtil;
	
	import mx.rpc.IResponder;
	
	public class PickemScorecardCommand implements ICommand, IResponder
	{
		private var _event:PickemScorecardEvent;
		
		public function execute(event:CairngormEvent):void
		{
			_event = event as PickemScorecardEvent;
			new SdgServiceDelegate(this).getPickem(_event.avatarId);
		}
		
		public function result(data:Object):void
		{
//			trace(data);
//			
//		data = 
//			<SDGResponse status="1">
//				<questions status="unplayed" resultNew="false"/>
//			</SDGResponse>
//			<SDGResponse status="1">
//				<questions status="resolved" resultNew="true">
//					<question id="495" text="Who will win tomorrow between Boston and Cleveland?" eventId="151" roomId="131">
//						<answer selected="0" answerCount="46" teamid="12" correct="1" answerId="1993">Boston</answer>
//						<answer selected="1" answerCount="54" teamid="13" correct="0" answerId="1994">Cleveland</answer>
//					</question>
//					<question id="496" text="Who will win tomorrow between Cinncinati and Colorado?" eventId="151" roomId="131">
//						<answer selected="0" answerCount="0" teamid="14" correct="0" answerId="1995">Cinncinati</answer>
//						<answer selected="1" answerCount="1" teamid="15" correct="1" answerId="1996">Colorado</answer>
//					</question>
//					<question id="497" text="Who will win tomorrow's NBA game between the Cavaliers and Bobcats?" eventId="151" roomId="131">
//						<answer selected="0" answerCount="0" teamid="37" correct="0" answerId="1997">Cavaliers</answer>
//						<answer selected="1" answerCount="1" teamid="38" correct="1" answerId="1998">Bobcats</answer>
//					</question>
//					<question id="498" text="Who will win tomorrow's NBA game between the Celtics and Hawks?" eventId="151" roomId="131">
//						<answer selected="1" answerCount="1" teamid="46" correct="1" answerId="1999">Boston Celtics</answer>
//						<answer selected="0" answerCount="0" teamid="36" correct="1" answerId="2000">Atlanta Hawks</answer>
//					</question>
//					<question id="499" text="Who will score more points in tonight's NBA game, LeBron James or Kobe Bryant?" eventId="151" roomId="131">
//						<answer selected="1" answerCount="1" correct="0" playerid="4" answerId="2001">Jermaine ONeal</answer>
//						<answer selected="0" answerCount="0" correct="1" playerid="88" answerId="2002">LeBron James</answer>
//					</question>
//				</questions>
//			</SDGResponse>
			CairngormEventDispatcher.getInstance().dispatchEvent(new PickemScorecardEvent(_event.avatarId, PickemScorecardEvent.SCORECARD_RECEIVED, data));
		}
		
		public function fault(info:Object):void
		{
			var myClass:Class = Object(this).constructor;
			var status:int = int(info.@status);
			
			SdgAlertChrome.show("Sorry, we were unable to complete your request.", "Time Out!", null, null, 
									true, true, 430, 200, ErrorCodeUtil.constructCode(myClass,status.toString()));
			//SdgAlertChrome.show("Error getting pickem scorecard.", "Time Out!", null, null, 
									//true, true, false, 430, 200, ErrorCodeUtil.constructCode(myClass,status.toString()));
		}
	}
}
