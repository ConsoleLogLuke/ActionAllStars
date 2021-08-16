package com.sdg.view.room
{
	import com.sdg.events.room.item.RoomItemCircleMenuEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.button.ButtonDefinition;
	
	public class PetCircleMenu extends RoomItemCircleMenu
	{
		public static const CLICK_ACTION:String = 'pet click action';
		
		public function PetCircleMenu(menuLabel:String, isCurrentLeashedPet:Boolean, isFollowingOwner:Boolean, canFeed:Boolean, canPlay:Boolean, canLeash:Boolean, canStay:Boolean, defaultRadius:Number = 45)
		{
			super(menuLabel, defaultRadius);
			
			// Check out.
			addButton(new ButtonDefinition(new CircleIconInspect(), RoomItemCircleMenuEvent.CLICK_INSPECT, 'Check Out', null, null));
			// Feed.
			if (canFeed) addButton(new ButtonDefinition(new CircleIconPetsFeed(), RoomItemCircleMenuEvent.CLICK_FEED_PET, 'Feed', null, null));
			// Play.
			if (canPlay) addButton(new ButtonDefinition(new CircleIconPetsPlay(), RoomItemCircleMenuEvent.CLICK_PLAY_PET, 'Play', null, null));
			// Stay/Follow
			if (canStay) addButton(new ButtonDefinition(isFollowingOwner ? new CircleIconPetsStay() : new CircleIconPetsHeel(), RoomItemCircleMenuEvent.CLICK_STAY_PET, isFollowingOwner ? 'Stay' : 'Heel', null, null));
			
			var leashActionLabel:String = (isCurrentLeashedPet) ? 'Unleash' : 'Leash';
			var buttonParams4:Object = {action:'leash', clickLogId:LoggingUtil.PET_MENU_LEASH};
			if (canLeash) addButton(new ButtonDefinition(new CircleIconPetsLeash(), CLICK_ACTION, leashActionLabel, null, buttonParams4));
		}
		
	}
}