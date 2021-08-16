package com.sdg.messageBoard
{
	import com.sdg.components.dialog.ISdgDialog;
	import com.sdg.messageBoard.controllers.MessageBoardController;
	import com.sdg.messageBoard.events.MessageBoardEvent;
	
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	public class AddMessageDialog extends UIComponent implements ISdgDialog
	{
		private var _controller:MessageBoardController;
		
		public function AddMessageDialog()
		{
			super();
			this.width = 800;
			this.height = 570;
		}
		
		public function init(params:Object):void
		{
			_controller = params as MessageBoardController;
			addChild(_controller.addMessageView);
		}
		
		public function close():void
		{
			PopUpManager.removePopUp(this);
		}
	}
}