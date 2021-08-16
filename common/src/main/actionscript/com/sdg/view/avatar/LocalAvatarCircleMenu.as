package com.sdg.view.avatar
{
	import com.sdg.events.room.item.RoomItemCircleMenuEvent;
	import com.sdg.model.Emote;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.button.ButtonDefinition;
	import com.sdg.view.room.RoomItemCircleMenu;
	
	import flash.display.Sprite;

	public class LocalAvatarCircleMenu extends RoomItemCircleMenu
	{
		public function LocalAvatarCircleMenu(defaultLabel:String = 'You', isAvatarMvp:Boolean = false, emoteList:Array = null, canInspect:Boolean = true, canShop:Boolean = true, canPrintInvite:Boolean = true)
		{
			super(defaultLabel);
			
			// Get list of all emotes from model locator.
			var emoteList:Array = ModelLocator.getInstance().emoteList;
			
			// Create child emote button definitions.
			var emoteChildren:Array = [];
			var i:int = 0;
			var len:int = (emoteList) ? emoteList.length : 0;
			for (i; i < len; i++)
			{
				var emote:Emote = emoteList[i];
				var eventParams:Object = new Object();
				eventParams.emoteName = emote.emoteName;
				eventParams.emoteUrl = emote.emoteIconUrl;
				var button:Sprite = RoomItemCircleMenu.getEmoteIcon(emote.emoteId) as Sprite;
				if (!button) continue;
				var def:ButtonDefinition = new ButtonDefinition(button, RoomItemCircleMenuEvent.CLICK_EMOTE, emote.emoteName, null, eventParams);
				emoteChildren.push(def);
			}
			
			if (canInspect) addButton(new ButtonDefinition(new CircleIconInspect(), RoomItemCircleMenuEvent.CLICK_INSPECT, 'Check Out', null, null));
			addButton(new ButtonDefinition(new CircleIconEmote(), RoomItemCircleMenuEvent.CLICK_EMOTE, 'Mood', emoteChildren, null));
			addButton(new ButtonDefinition(new CircleIconVisit(), RoomItemCircleMenuEvent.CLICK_HOME, 'Home Turf', null, null));
			if (canShop) addButton(new ButtonDefinition(new CircleIconShop(), RoomItemCircleMenuEvent.CLICK_SHOP, 'Shop', null, null));
			if (canPrintInvite) addButton(new ButtonDefinition(new CircleIconPrint(), RoomItemCircleMenuEvent.CLICK_PRINT, 'Print Invite', null, null));
			if (!isAvatarMvp) addButton(new ButtonDefinition(new CircleIconMVP(), RoomItemCircleMenuEvent.CLICK_MVP, 'Upgrade MVP', null, null));
		}
		
	}
}