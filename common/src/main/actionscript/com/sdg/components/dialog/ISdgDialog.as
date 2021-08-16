package com.sdg.components.dialog
{
	import mx.core.IUIComponent;
	
	public interface ISdgDialog extends IUIComponent
	{
		function init(params:Object):void;
		function close():void;
	}
}