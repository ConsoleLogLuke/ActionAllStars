package com.sdg.commands
{
 	import mx.rpc.IResponder; 
 	import com.adobe.cairngorm.commands.ICommand;
 	import com.adobe.cairngorm.control.CairngormEvent;
 	import com.sdg.business.SdgServiceDelegate;
 	import com.sdg.events.TutorialResetEvent;
 		
 	public class TutorialResetCommand extends AbstractResponderCommand implements ICommand, IResponder
 	{
 		public function execute(event:CairngormEvent):void
 		{
 			var ev:TutorialResetEvent= event as TutorialResetEvent;
 			new SdgServiceDelegate(this).sendTutorialReset(ev.avatarId, ev.value );
 		}
 		
 		public function result(data:Object):void
 		{
 			trace("sendTutorialReset response: " + XML(data));
 		}
 	}
}
