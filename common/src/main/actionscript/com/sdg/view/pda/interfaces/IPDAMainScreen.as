package com.sdg.view.pda.interfaces
{
	import com.sdg.control.PDAController;
	
	import mx.core.IUIComponent;
	
	public interface IPDAMainScreen extends IUIComponent
	{		
		function set controller(value:PDAController):void;
		function set mainPanel(value:IPDAMainPanel):void;
		function get mainPanel():IPDAMainPanel;
		function set mouseChildren(value:Boolean):void;
	}
}
