package com.sdg.components.dialog.helpers
{
	import com.sdg.components.dialog.SaveYourGameDialog;
	import com.sdg.control.room.RoomManager;
	
	import flash.display.StageDisplayState;
	
	public class ChallengeDialogHelper
	{
		import flash.events.Event;
		import com.sdg.model.ModelLocator;
		import mx.core.Application;
		import com.sdg.components.dialog.OverlayDialog2;
		import com.sdg.events.SdgSwfEvent;
		import com.sdg.utils.MainUtil;
		import com.sdg.net.Environment;
		
		private var _overlayDialog:OverlayDialog2;
		public static var _instance:ChallengeDialogHelper;
		
		private static const LEVEL_MAP:Object =
		{
			1:"Amateur",
			2:"Rookie",
			3:"Pro",
			4:"Veteran",
			5:"AllStar"
		};
		
		public function ChallengeDialogHelper(params:Object)
		{
			// paramsXML
			var paramsXml:XML = params as XML;
			if (!paramsXml)
				return;

			generateXML(paramsXml);
		}
		
		private function onClose(event:Event):void
		{
			cleanUp();
		}
		
		private function cleanUp():void
		{
			_overlayDialog.removeEventListener(SdgSwfEvent.SDG_SWF_EVENT, onSdgSwfEvent);
			_overlayDialog.addEventListener(Event.CLOSE, onClose);
			_instance = null;
		}
		
		private function onSdgSwfEvent(ev:SdgSwfEvent):void
		{
			if (ModelLocator.getInstance().avatar.membershipStatus == 3)
			{
				//MainUtil.showDialog(MonthFreeUpsellDialog, {showPremiumHeader:false, messaging:"This feature is only available if you register."});
				MainUtil.showDialog(SaveYourGameDialog);
				return;
			}
			else
			{
				if (ev.data.eventType == "playGame")
				{
					RoomManager.getInstance().loadGame(ev.data.gameId, ev.data.achievementId);
				}
				else if (ev.data.eventType == "playNormal")
				{
					RoomManager.getInstance().loadGame(ev.data.gameId);
				}
			}
			//else if (ev.data.eventType == "goPremium")
			//	MainUtil.navigateToMonthFreePage(1)
			cleanUp();
			_overlayDialog.close();
		}
		
		private function generateXML(paramsXml:XML):void
		{
			var xmlData:XML = <data></data>;
			
			var avatarXml:XML = <avatar></avatar>;
			avatarXml.appendChild("<membershipStatus>" + ModelLocator.getInstance().avatar.membershipStatus + "</membershipStatus>");
			xmlData.appendChild(avatarXml);
			
			var gameXml:XML = <game></game>;
			gameXml.appendChild("<gameId>" + paramsXml.achievements.@gameId + "</gameId>");
			gameXml.appendChild("<logo>" + Environment.getAssetUrl() + paramsXml.achievements.@gameLogoUrl + "</logo>");
			gameXml.appendChild("<screenshot>" + Environment.getAssetUrl() + paramsXml.achievements.@gameScreenshotUrl + "</screenshot>");
			xmlData.appendChild(gameXml);
			
			for each(var challengeXml:XML in paramsXml.achievements.achievement)
			{
				var achievementRequirementValue:int = parseInt(challengeXml.achievementRequirementValue);
				
				var achievementXml:XML = <achievement></achievement>;
				achievementXml.appendChild("<level>" + LEVEL_MAP[achievementRequirementValue] + "</level>");
				achievementXml.appendChild("<achievementId>" + challengeXml.achievementId + "</achievementId>");
				achievementXml.appendChild("<description><![CDATA[" + challengeXml.description + "]]></description>");
				achievementXml.appendChild("<state>" + (achievementRequirementValue > ModelLocator.getInstance().avatar.level ? 2 : challengeXml.completed != "0" ? 1 : 0) + "</state>");
				
				var teamXml:XML = <team></team>;
				teamXml.appendChild("<logo>" + Environment.getAssetUrl() + challengeXml.teamLogoSmall + "</logo>");
				teamXml.appendChild("<biglogo>" + Environment.getAssetUrl() + challengeXml.teamLogoLarge + "</biglogo>");
				achievementXml.appendChild(teamXml);
				
				var playerXml:XML = <player></player>;
				playerXml.appendChild("<image>" + Environment.getAssetUrl() + challengeXml.playerImage + "</image>");
				achievementXml.appendChild(playerXml);
				
				xmlData.appendChild(achievementXml);
			}
			
			trace(xmlData);
			
			// create the params for OverlayDialog
			var params:Object = new Object();
			params.xml = xmlData;
			params.swfPath = "assets/swfs/challengeDialog.swf";
			
			// show the dialog
			_overlayDialog = OverlayDialog2(MainUtil.showDialog(OverlayDialog2, params, false, false));
			_overlayDialog.addEventListener(SdgSwfEvent.SDG_SWF_EVENT, onSdgSwfEvent);
			_overlayDialog.addEventListener(Event.CLOSE, onClose);
		}
		
		public static function showDialog(params:Object):void
		{
			if (_instance) return;
			_instance = new ChallengeDialogHelper(params);
		}
	}
}
