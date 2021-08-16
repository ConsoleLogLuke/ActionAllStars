package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.components.controls.ProgressAlertChrome;
	import com.sdg.components.controls.SdgAlert;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.PrivateRoomEditEvent;
	import com.sdg.events.RoomManagerEvent;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Room;
	
	import mx.events.CloseEvent;
	import mx.rpc.IResponder;
	
	public class PrivateRoomEditCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		private var room:Room;
		private var roomManager:RoomManager = RoomManager.getInstance();
		private var continueEditing:Boolean;
		private var progressAlert:ProgressAlertChrome;
		
		private static var leaveRoomHandler:Function;
		
		public function execute(event:CairngormEvent):void
		{
			var ev:PrivateRoomEditEvent = PrivateRoomEditEvent(event);
			
			room = roomManager.currentRoom;
			
			if (room == null) return;
			
			// Abort if room is not owned by system avatar.
			if (room.ownerId != ModelLocator.getInstance().user.avatarId)
			{
				trace("PrivateRoomEditCommand: Room is not owned by system avatar.");
				return;
			}
			
			// Execute the task specified by the event type.
			switch (ev.type)
			{
				case PrivateRoomEditEvent.EDIT_PRIVATE_ROOM:
					executeEdit();
					break;
				
				case PrivateRoomEditEvent.REVERT_PRIVATE_ROOM:
					executeRevert();
					break;
				
				case PrivateRoomEditEvent.SAVE_PRIVATE_ROOM:
					executeSave();
					break;
				
				case PrivateRoomEditEvent.UPDATE_PRIVATE_ROOM:
					executeUpdate();
					break;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Edit
		//
		//--------------------------------------------------------------------------
		
		private function executeEdit():void
		{
			if (!room.editMode)
			{
				room.editMode = true;
				roomManager.socketEnabled = false;
				roomManager.preventRoomChange(PrivateRoomEditCommand);
				roomManager.addEventListener(RoomManagerEvent.ENTER_ROOM_INIT, leaveRoomHandler);
				PrivateRoomEditCommand.leaveRoomHandler = leaveRoomHandler;
			}
		}
		
		private function stopEditing():void
		{
			if (PrivateRoomEditCommand.leaveRoomHandler != null) 
			{
				roomManager.removeEventListener(RoomManagerEvent.ENTER_ROOM_INIT, PrivateRoomEditCommand.leaveRoomHandler);
				PrivateRoomEditCommand.leaveRoomHandler = null;
			}
			
			roomManager.allowRoomChange(PrivateRoomEditCommand);
			roomManager.socketEnabled = true;
			room.editMode = false;
		}
		
		private function leaveRoomHandler(event:RoomManagerEvent):void
		{
			executeSave();
//			var alert:SdgAlert = SdgAlert.show("Do you want to save your room changes?", "Before You Leave", 
//											   SdgAlert.CANCEL | SdgAlert.NO | SdgAlert.YES, SdgAlert.YES, 
//											   leaveRoomAlertHandler);
//			
//			alert.setButtonLabels(SdgAlert.CANCEL, "Keep Editing", SdgAlert.NO, "Don't Save", SdgAlert.YES, "Save");
//			alert.setStyle("buttonMinWidth", "90");
		}
		
		private function leaveRoomAlertHandler(event:CloseEvent):void
		{
			switch (event.detail)
			{
				// Don't save and leave room.
				case SdgAlert.NO:
					stopEditing();
					break;
				
				// Save and leave room.
				case SdgAlert.YES:
					executeSave();
					break;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Revert
		//
		//--------------------------------------------------------------------------
		
		private function executeRevert():void
		{
			if (room.editMode)
			{
				var alert:SdgAlert = SdgAlert.show("Are you sure you want to cancel your changes?", "Are You Sure?",
												   SdgAlert.YES | SdgAlert.CANCEL, SdgAlert.CANCEL, 
												   revertAlertHandler);

				alert.setButtonLabels(SdgAlert.YES, "Cancel Changes", SdgAlert.CANCEL, "Keep Editing");
			}
		}
		
		private function revertAlertHandler(event:CloseEvent):void
		{
			if (event.detail == SdgAlert.YES)
			{
				// Revert room to previous state.
				stopEditing();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Save
		//
		//--------------------------------------------------------------------------
		
		private function executeSave():void
		{
			progressAlert = ProgressAlertChrome.show("Saving Room...", room.name, null, null, true);
			continueEditing = false;
			saveRoom();
		}
		
		private function executeUpdate():void
		{
			continueEditing = true;
			saveRoom();
		}
		
		private function saveRoom():void
		{
			if (room.editMode)
				new SdgServiceDelegate(this).savePrivateRoom(room.id, room.ownerId, room.getValidItems());
		}
		
		public function result(data:Object):void
		{
			roomManager.sendRoomUpdate();
			if (!continueEditing)
				stopEditing();
			
			if (progressAlert)
			{
				progressAlert.close();
				progressAlert = null;
			}
		}
	}
}