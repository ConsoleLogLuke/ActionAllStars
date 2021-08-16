package com.sdg.components.controls
{
	import com.sdg.components.dialog.InteractiveBgObjectDialog;
	import com.sdg.components.dialog.InteractiveDialog;
	import com.sdg.control.room.RoomManager;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.net.Environment;
	import com.sdg.store.transaction.FreeItemAtom;
	import com.sdg.utils.MainUtil;
	
	import flash.utils.getDefinitionByName;

	
	public class InteractiveBgObjectHandler
	{
		private static var bgObjectStatus:Object = new Object();
		private static var bgObjectFunction:Object = {BoardHIT:clickChalkBoard,
														SnowmanHIT:clickSnowman,
														AllstarHit:clickAllstar,
														AllstarHit2:clickAllstar2,
														ChuteHIT:clickChute,
														StadiumHIT:clickStadium,
														ScopeHIT:clickTelescope,
														SkateHIT:clickSkate,
														EggHIT:clickEgg};
		
		public static function processInteract(bgItemId:String,data:Object = null):void
		{
			// Check status on bgItemId
			if (bgObjectStatus[bgItemId])
			{
				return;	
			}
			
			// Lock bgItemId
			bgObjectStatus[bgItemId] = true;
			
			// Look Up Related Function
			var func:Function = bgObjectFunction[bgItemId] as Function;
			
			
			if (func == null && data == null) return;
			
			// Execute Function
			if(func != null)
			{
				func();
			
				// Unlock bgItemId
				bgObjectStatus[bgItemId] = false;
			}
			else if(data != null)
			{
				if(data["showDialog"] != null)	
				{
					showDialogWithName(data["showDialog"],data["params"]);
					bgObjectStatus[bgItemId] = false;
				}
			}
		}
		
		//Allows us to show more than just an Interactive Dialog.
		// If it exists
		public static function showDialogWithName(dialogName:String,params:Object):void
		{
			try
			{
			 var ClassReference:Class = getDefinitionByName(dialogName) as Class;
			 
			 if(ClassReference != null)
			 {
			 	MainUtil.showDialog(ClassReference,params);
			 }
			}
			catch(e:Error)
			{
				trace("Class not found: " + e.getStackTrace());
			}
		}


		////////////////////////////////
		// GENERAL FUNCTIONS
		////////////////////////////////
		
		private static function showDialog(id:String):void
		{
			MainUtil.showDialog(InteractiveBgObjectDialog,{itemId:id},false,false);
		}
		
		private static function showInteractiveDialog(urlIn:String,idIn:String):void
		{
			MainUtil.showDialog(InteractiveDialog,{url:urlIn,id:idIn},false,false);
		}
		
		////////////////////////////////
		// OBJECT SPECIFIC FUNCTIONS
		////////////////////////////////
		
		// TEMPLATE
		//private static function clickLocker1():void
		//{
		//	var gift:FreeItemAtom = new FreeItemAtom(6047,6047,true);
		//	
		//	showDialog("HitLocker1"); 
		//}
		
		private static function clickChalkBoard():void
		{
			showInteractiveDialog(Environment.getAssetUrl()+"/test/gameSwf/gameId/80/gameFile/BoardHIT_dialog.swf","BoardHIT");
		}
		
		private static function clickSnowman():void
		{
			var roomId:String = RoomManager.getInstance().currentRoomId;
			if (roomId == "public_101")
			{
				LoggingUtil.sendClickLogging(LoggingUtil.SNOWMAN_SIGN_RIVERWALK);
			}
			else if (roomId == "public_107")
			{
				LoggingUtil.sendClickLogging(LoggingUtil.SNOWMAN_SIGN_BALLERS_HALL);
			}
			
			showInteractiveDialog(Environment.getAssetUrl()+"/test/gameSwf/gameId/80/gameFile/Snowman_dialog.swf","SnowmanHIT");
		}
		
		private static function clickAllstar():void
		{
			LoggingUtil.sendClickLogging(LoggingUtil.ALLSTAR_SIGN_RIVERWALK);
			showInteractiveDialog(Environment.getAssetUrl()+"/test/gameSwf/gameId/80/gameFile/AllstarHIT_dialog.swf","101");
		}
		
		private static function clickAllstar2():void
		{
			LoggingUtil.sendClickLogging(LoggingUtil.ALLSTAR_SIGN_THE_PEAK);
			showInteractiveDialog(Environment.getAssetUrl()+"/test/gameSwf/gameId/80/gameFile/AllstarHIT_dialog.swf","102");
		}
		
		private static function clickChute():void
		{
			LoggingUtil.sendClickLogging(LoggingUtil.CHUTE_PROMOTION);
			showInteractiveDialog(Environment.getAssetUrl()+"/test/gameSwf/gameId/80/gameFile/ChuteHIT_dialog.swf","103");
		}
		
		private static function clickStadium():void
		{
			LoggingUtil.sendClickLogging(LoggingUtil.STADIUM_PROMOTION);
			showInteractiveDialog(Environment.getAssetUrl()+"/test/gameSwf/gameId/80/gameFile/StadiumHIT_dialog.swf","104");
		}
		
		private static function clickTelescope():void
		{
			LoggingUtil.sendClickLogging(LoggingUtil.TELESCOPE_PROMOTION);
			showInteractiveDialog(Environment.getAssetUrl()+"/test/gameSwf/gameId/80/gameFile/ScopeHIT_dialog.swf","105");
		}
		
		private static function clickSkate():void
		{
			LoggingUtil.sendClickLogging(LoggingUtil.SKATE_PROMOTION);
			showInteractiveDialog(Environment.getAssetUrl()+"/test/gameSwf/gameId/80/gameFile/SkateHIT_dialog.swf","106");
		}
		
		private static function clickEgg():void
		{
			LoggingUtil.sendClickLogging(LoggingUtil.SAM_SHOP_EGG_PROMOTION);
			var gift:FreeItemAtom = new FreeItemAtom(6622,6622,true);
			showInteractiveDialog(Environment.getAssetUrl()+"/test/gameSwf/gameId/80/gameFile/EggHIT_dialog.swf","107");
		}
		
	}
}