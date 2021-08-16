package com.sdg.npc
{
	import com.sdg.control.room.itemClasses.Character;
	import com.sdg.events.RoomItemDisplayEvent;
	import com.sdg.events.SocketRoomEvent;
	import com.sdg.model.Achievement;
	import com.sdg.model.AvatarAchievementCollection;
	import com.sdg.model.QuestProvider;
	import com.sdg.model.QuestProviderCollection;
	import com.sdg.model.SdgItem;
	import com.sdg.model.UserActionTypes;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.quest.QuestManager;
	import com.sdg.utils.Constants;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	public class NPCController extends Character
	{
		private var _isDestroy:Boolean;
		
		public function NPCController()
		{
			super();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		override public function initialize(item:SdgItem):void
		{
			super.initialize(item);
		}
		
		override public function destroy():void
		{
			// Make sure we only destroy once.
			if (_isDestroy == true) return;
			_isDestroy = true;
			
			super.destroy();
		}
		
		////////////////////
		// EVENT HANDLERS 
		////////////////////
		
		
	}
}