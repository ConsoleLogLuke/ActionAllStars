package com.sdg.components.controls
{
	import mx.containers.Panel;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	import flash.display.Sprite;
	
	import com.sdg.utils.MainUtil;
	
	public class PopUpPanel extends SimpleTitlePanel
	{
		/**
		 * Constructor.
		 */
		public function PopUpPanel()
		{
		}
		
		public function show(closeHandler:Function = null, parent:Sprite = null,
							 modal:Boolean = true, center:Boolean = true):void
		{
			if (closeHandler != null)
				addEventListener(CloseEvent.CLOSE, closeHandler);
			
			visible = true;
			if (modal)
			{
				MainUtil.showModalDialog(null, null, this);
			}
			else
			{	
				PopUpManager.addPopUp(this, parent ? parent : Sprite(Application.application), modal);
				if (center) 
					PopUpManager.centerPopUp(this);
			}	
		}

		public function close(closeDetail:int = -1):void
		{
			var event:CloseEvent = new CloseEvent(CloseEvent.CLOSE, false, true, closeDetail);
			
			dispatchEvent(event);

			if (!event.isDefaultPrevented())
			{
				visible = false;
				PopUpManager.removePopUp(this);
			}
		}
	}
}