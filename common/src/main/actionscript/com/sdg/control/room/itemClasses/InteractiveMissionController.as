package com.sdg.control.room.itemClasses
{
	import com.sdg.display.RoomItemSWF;
	import com.sdg.events.RoomItemDisplayEvent;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.model.SdgItem;
	import com.sdg.quest.QuestManager;
	
	import flash.events.Event;
	
	public class InteractiveMissionController extends RoomItemController
	{
		private var _mainMissionId:int;
		private var _missionId:int
		
		public function InteractiveMissionController()
		{
			super();
		}
		
		///////////////////////
		// OVERRIDE FUNCTION
		///////////////////////
		
		override public function initialize(item:SdgItem):void
		{
			// Get Mission Id
			if (item.attributes.missionId)
				_missionId = item.attributes.missionId;
			
			// Continue init if mission is active but not complete
			super.initialize(item);	
		}
		
		override protected function addDisplayListeners():void
		{
			//_display.addEventListener("balloon click",onInteractStart)
			//_display.addEventListener("success", onHatsMissionSuccess);
			super.addDisplayListeners();
		}
		
		override protected function itemResourcesCompleteHandler(event:Event):void
		{
			super.itemResourcesCompleteHandler(event);
			RoomItemSWF(display).addEventListener(RoomItemDisplayEvent.CONTENT, loadCompleteHandler);
		}
		
		protected function loadCompleteHandler(event:Event):void
		{
			if (display == null) return;
			
			var swf:RoomItemSWF = RoomItemSWF(display);
			
			// Determine Visibility
			if (_missionId)
			{
				var status:int = QuestManager.getAchievementStatus(_missionId);
				if (status == 2)
				{
					// set the swf to non-visible
					swf.visible = false;
				}
				else
				{
					var swfListener:Object = Object(swf.content);
					swfListener.addEventListener("mission start",onInteractStart);
					swfListener.addEventListener("mission success",onHatsMissionSuccess);
				}
			}
		}
		
		////////////////////////
		// MISSION LISTENERS
		////////////////////////
		
		private function onInteractStart(e:Event):void
		{
			var swf:Object = Object(RoomItemSWF(display));
			// Check Mission Status
			var questStatus:int = QuestManager.getAchievementStatus(this._missionId);
			// If mission is avialable, play game
			if (questStatus == 1)
			{
				var prop:String = "balloon_6404";
				switch (_missionId)
				{
					case 691:
						swf.content.balloon_6404.startGame();
						break;
					case 692:
						swf.content.balloon_6405.startGame();
						break;
					case 693:
						swf.content.balloon_6406.startGame();
						break;
					case 694:
						swf.content.balloon_6407.startGame();
						break;
					case 695:
						swf.content.balloon_6408.startGame();
						break;
					case 696:
						swf.content.balloon_6409.startGame();
						break;
					case 697:
						swf.content.balloon_6410.startGame();
						break;
					case 698:
						swf.content.balloon_6411.startGame();
						break;
					case 699:
						swf.content.balloon_6412.startGame();
						break;
					case 700:
						swf.content.balloon_6413.startGame();
						break;
					case 701:
						swf.content.balloon_6414.startGame();
						break;
					case 702:
						swf.content.balloon_6415.startGame();
						break;
					case 703:
						swf.content.balloon_6416.startGame();
						break;
					case 704:
						swf.content.balloon_6417.startGame();
						break;
					case 705:
						swf.content.balloon_6418.startGame();
						break;
					case 706:
						swf.content.balloon_6419.startGame();
						break;
					case 707:
						swf.content.balloon_6420.startGame();
						break;
					case 708:
						swf.content.balloon_6421.startGame();
						break;
					case 709:
						swf.content.balloon_6422.startGame();
						break;
					case 710:
						swf.content.balloon_6423.startGame();
						break;
					case 711:
						swf.content.balloon_6424.startGame();
						break;
					case 712:
						swf.content.balloon_6425.startGame();
						break;
					case 713:
						swf.content.balloon_6426.startGame();
						break;
					case 714:
						swf.content.balloon_6427.startGame();
						break;
					case 715:
						swf.content.balloon_6428.startGame();
						break;
					case 716:
						swf.content.balloon_6429.startGame();
						break;
					case 717:
						swf.content.balloon_6430.startGame();
						break;
					case 718:
						swf.content.balloon_6431.startGame();
						break;
					case 719:
						swf.content.balloon_6432.startGame();
						break;
					case 720:
						swf.content.balloon_6433.startGame();
						break;
				}
				
				var swf2:RoomItemSWF = RoomItemSWF(display);
				var swfListener:Object = Object(swf2.content);
				swfListener.addEventListener("mission success",onHatsMissionSuccess);
			}
			// if you don't have the mission yet, then send abstract click handler
			else if (questStatus == 0)
			{
				AbstractItemInteractionHandlers.handleClick(this, "100");
			}
		}

		private function onHatsMissionSuccess(e:Event):void
		{
			// set the swf to non-visible
			var swf:RoomItemSWF = RoomItemSWF(display);
			swf.visible = false;
			
			//	Call Abstract Click Handler - always 100 for interactive missions
			AbstractItemInteractionHandlers.handleClick(this, "100");
			
			// Log Success
			LoggingUtil.sendSignClickLogging(this.item.id)
		}

	}
}