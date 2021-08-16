package com.sdg.factory
{
	import com.sdg.model.Buddy;
	import com.sdg.model.PartyBuddy;
	
	public class BuddyFactory
	{
		/**
		 * Builds an array of buddy objects from the provided XML
		 */ 
		public static function buildBuddyList(buddiesXml:XML):Object
		{
			var buddies:Object = new Object();
			for each (var buddyXml:XML in buddiesXml.buddy)
				buddies[buddyXml.buddyAvatarId] = buildBuddy(buddyXml);
			
			return buddies;
		}
		
		public static function buildPartyList(buddiesXml:XML):Object
		{
			var buddies:Object = new Object();
			for each (var buddyXml:XML in buddiesXml.buddy)
				buddies[buddyXml.buddyAvatarId] = buildPartyBuddy(buddyXml);
			
			return buddies;
		}
		
		/**
		 * Builds a buddy object from the provided XML
		 */
		public static function buildBuddy(buddyXml:XML):Buddy
		{
			var buddy:Buddy = new Buddy();
			updateBuddy(buddyXml, buddy);
			
			return buddy;
		}
		
		public static function buildPartyBuddy(buddyXml:XML):PartyBuddy
		{
			var buddy:PartyBuddy = new PartyBuddy();
			updatePartyBuddy(buddyXml, buddy);
			
			return buddy;
		}
		
		public static function updateBuddy(buddyXml:XML, buddy:Buddy):void
		{
			buddy.avatarId = buddyXml.buddyAvatarId;
			buddy.name = buddyXml.buddyName;
			buddy.presence = buddyXml.hasOwnProperty("pr") ? buddyXml.pr : 2;
			buddy.roomId = buddyXml.rm;
			buddy.roomName = buddyXml.ld;
			buddy.status = buddyXml.statusId;
			buddy.level = buddyXml.bl;
			buddy.gender = buddyXml.g;
			buddy.partyMode = buddyXml.p;
			buddy.teamId = buddyXml.buddyTeamId;
			buddy.teamName = buddyXml.buddyTeamName;
			buddy.teamColor1 = uint("0x" + buddyXml.buddyTeamColor1);
			buddy.teamColor2 = uint("0x" + buddyXml.buddyTeamColor2);
			buddy.teamColor3 = uint("0x" + buddyXml.buddyTeamColor3);
			buddy.teamColor4 = uint("0x" + buddyXml.buddyTeamColor4);
		}
		
		public static function updatePartyBuddy(buddyXml:XML, buddy:PartyBuddy):void
		{
			updateBuddy(buddyXml, buddy);
			
			buddy.numGuest = buddyXml.na;
			buddy.partyName = buddyXml.pn;
		}
	}
}