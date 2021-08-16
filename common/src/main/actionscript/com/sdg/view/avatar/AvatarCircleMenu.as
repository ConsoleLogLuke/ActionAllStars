package com.sdg.view.avatar
{
	import com.sdg.events.room.item.RoomItemCircleMenuEvent;
	import com.sdg.model.Jab;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.button.ButtonDefinition;
	import com.sdg.view.room.RoomItemCircleMenu;
	
	import flash.display.Sprite;

	public class AvatarCircleMenu extends RoomItemCircleMenu
	{
		public function AvatarCircleMenu(defaultLabel:String = 'Avatar', isFriend:Boolean = false, isIgnored:Boolean = false, jabList:Array = null, isInvitableToGame:Boolean = false, canInspect:Boolean = true, isInvitableToHome:Boolean = true)
		{
			super(defaultLabel);
			
			// Get an array of jabs from model locator.
			var jabList:Array = ModelLocator.getInstance().jabList;
			
			// Create child jab button definitions.
			var jabChildren:Array = [];
			var i:int = 0;
			var len:int = (jabList) ? jabList.length : 0;
			for (i; i < len; i++)
			{
				var jab:Jab = jabList[i];
				// Make sure the gender matches the local user.
				if (ModelLocator.getInstance().avatar.gender != jab.genderId) continue;
				var eventParams:Object = new Object();
				eventParams.jabName = jab.jabName;
				eventParams.jabId = jab.jabId;
				eventParams.jabShowEmote = jab.showEmote;
				var jabBtn:Sprite = RoomItemCircleMenu.getJabIcon(jab.jabId) as Sprite;
				if(jabBtn != null)
				{
					// regular jabs have id's less than 100
					// This is a keating bomb taken from old code. Don't blame me.
					if (jab.jabId < 99)
					{
						var def:ButtonDefinition = new ButtonDefinition(jabBtn, RoomItemCircleMenuEvent.CLICK_JAB, 
																			jab.jabName, null, eventParams);
						jabChildren.push(def);
					}
				}
				else
				{
					trace("Jab " + jab.jabName + " graphic not found");
				}
			}
			
			// Determine if this avatar is ignored.
			if (!isIgnored)
			{
				// The avatar is not ignored so give full range of buttons.
				
				// Determine which type of friend button to use.
				var friendButton:Sprite = (isFriend) ? new CircleIconUnfriend() : new CircleIconFriend();
				var friendLabel:String = (isFriend) ? 'Remove Friend' : 'Add Friend';
				
				// Determine if we should show the game invite button.
				// Currently, concentration is the only game of this type. We'll just use a button that is specific to concentration.
				if (isInvitableToGame) addButton(new ButtonDefinition(new CircleIconJabConcentration(), RoomItemCircleMenuEvent.CLICK_INVITE_TO_GAME, 'Invite to Concentration', null, null));
				
				if (canInspect) addButton(new ButtonDefinition(new CircleIconInspect(), RoomItemCircleMenuEvent.CLICK_INSPECT, 'Check Out', null, null));
				addButton(new ButtonDefinition(friendButton, RoomItemCircleMenuEvent.CLICK_FRIEND, friendLabel, null, null));
				if (isInvitableToHome) addButton(new ButtonDefinition(new CircleIconInvite(), RoomItemCircleMenuEvent.CLICK_INVITE, 'Invite', null, null));
				addButton(new ButtonDefinition(new CircleIconVisit(), RoomItemCircleMenuEvent.CLICK_HOME, 'Visit Turf', null, null));
				addButton(new ButtonDefinition(new CircleIconJab(), RoomItemCircleMenuEvent.CLICK_JAB, 'Jab', jabChildren, null));
				addButton(new ButtonDefinition(new CircleIconIgnore(), RoomItemCircleMenuEvent.CLICK_IGNORE, 'Ignore', null, null));
			}
			else
			{
				// The avatar is ignored so only show the "un-ignore" button.
				addButton(new ButtonDefinition(new CircleIconUnignore(), RoomItemCircleMenuEvent.CLICK_IGNORE, 'Un-Ignore', null, null));
			}
			
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		
		
	}
}