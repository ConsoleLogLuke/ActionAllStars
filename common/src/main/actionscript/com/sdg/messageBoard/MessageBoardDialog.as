package com.sdg.messageBoard
{
	import com.sdg.components.dialog.ISdgDialog;
	import com.sdg.messageBoard.controllers.MessageBoardController;
	
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	public class MessageBoardDialog extends UIComponent implements ISdgDialog
	{
		private var _controller:MessageBoardController;
		
		public function MessageBoardDialog()
		{
			super();
			this.width = 925;
			this.height = 665;
		}
		
		public function init(params:Object):void
		{
			_controller = new MessageBoardController();
			addChild(_controller.view);
			
			_controller.addEventListener(Event.CLOSE, onClose, false, 0, true);
		}
		
		private function onClose(event:Event):void
		{
			close();
		}
		
		public function close():void
		{
			_controller.removeEventListener(Event.CLOSE, onClose);
			PopUpManager.removePopUp(this);
		}
	}
}