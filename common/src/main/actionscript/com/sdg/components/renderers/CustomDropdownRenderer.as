package com.sdg.components.renderers
{
	import mx.controls.listClasses.ListItemRenderer;

	public class CustomDropdownRenderer extends ListItemRenderer
	{
		private var _enabled:Boolean;
		
		public function CustomDropdownRenderer()
		{
			super();
		}
		
		override public function set data(value:Object):void
		{
			if (value != null && value.enabled == false)
			{
				_enabled = false;
			}
			else
			{
				_enabled = true;
			}
			
			super.data = value;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (_enabled)
			{
				setStyle("color", 0x743447);
			}
			else
			{
				setStyle("color", 0x888888);
			}
		}
	}
}