package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.ChallengesEvent;
	import com.sdg.model.ModelLocator;
	import com.sdg.components.dialog.helpers.ChallengeDialogHelper;
	
	import mx.rpc.IResponder;

	public class ChallengesCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		public function execute(event:CairngormEvent):void
		{
			var ev:ChallengesEvent = event as ChallengesEvent;
			
			// get the challenges from the server
			new SdgServiceDelegate(this).getChallenges(ev.gameId, ModelLocator.getInstance().avatar.avatarId);
		}
		
		public function result(data:Object):void
		{
			ChallengeDialogHelper.showDialog(data);
			//new ChallengeUtil(data);
			//_challengeUtil.generateXML(params.data);
			//MainUtil.showDialog(OverlayDialog, {challenge:true, data:data}, false, false);
			//MainUtil.showDialog(ChallengeDialog, data);
		}
	}
}