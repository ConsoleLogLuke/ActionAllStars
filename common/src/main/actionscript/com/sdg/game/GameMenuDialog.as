package com.sdg.game
{
	import com.sdg.components.dialog.ISdgDialog;
	import com.sdg.game.controllers.IGameMenuController;
	import com.sdg.game.controllers.UnityNBAController;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	public class GameMenuDialog extends UIComponent implements ISdgDialog
	{
		private var _controller:IGameMenuController;
		
		public function GameMenuDialog()
		{
			super();
			this.width = 925;
			this.height = 665;
		}
		
		public function init(params:Object):void
		{
			_controller = new UnityNBAController();
			var view:DisplayObject = _controller.view as DisplayObject;
			addChild(view);
			
			_controller.addEventListener(Event.CLOSE, onClose, false, 0, true);
		}
		
		private function onClose(event:Event):void
		{
			_controller.removeEventListener(Event.CLOSE, onClose);
			close();
		}
		
		public function close():void
		{
			PopUpManager.removePopUp(this);
		}
	}
}