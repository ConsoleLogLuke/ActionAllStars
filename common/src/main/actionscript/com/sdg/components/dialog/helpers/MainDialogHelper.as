package com.sdg.components.dialog.helpers
{
	public class MainDialogHelper
	{
		import com.sdg.components.dialog.OverlayDialog;
		import com.sdg.control.room.RoomManager;
		import com.sdg.net.Environment;
		import com.sdg.utils.MainUtil;
		import com.sdg.model.Avatar;
		import com.sdg.model.ModelLocator;
		
		private var _avatar:Avatar = ModelLocator.getInstance().avatar;
		
		public function MainDialogHelper(params:Object)
		{
			var txtPath:String;
			var swfPath:String;
			var _showSkip:int = 0;
			
			if( params != null )
			{
				_showSkip = params.showSkip;
			}
			
			if (params == null)
			{
				// this is a room tutorial	
				txtPath  = RoomManager.getInstance().currentbgHelpTextUrl;
				swfPath  = RoomManager.getInstance().currentbgSwfUrl;
			
			}
			else if (params.worldmap == true)		
			{
				// this is the world map tutorial new world map tut has no text
				txtPath = Environment.getAssetUrl() + "/test/static/tutorial/bgHelpText?backgroundId=100";
				swfPath = Environment.getAssetUrl() + "/test/static/tutorial/bgSwf?backgroundId=100";
			}
			else if (params.dialogId != null)
			{
				// this is a dialog tutorial
				txtPath = Environment.getAssetUrl() + "/test/static/tutorial/dialogHelpText?dialogId=" + params.dialogId;
				swfPath = Environment.getAssetUrl() + "/test/static/tutorial/dialogSwf?dialogId=" + params.dialogId; 
			}
			else if (params.news == true)
			{
				txtPath = Environment.getAssetUrl() + "/test/asnEdition/get?avatarId=" + _avatar.avatarId;
				swfPath = Environment.getAssetUrl() + "/reg/assets/swfs/asn.swf";
			}
			else
			{
				trace("Unexpected params in MainDialogHelper");
				return;
			}
			
			MainUtil.showDialog(OverlayDialog, {txtPath:txtPath, swfPath:swfPath, showSkip:_showSkip}, false, true);
		}
		
		public static function showDialog(params:Object = null):void
		{
			new MainDialogHelper(params);
		}
	}
}
