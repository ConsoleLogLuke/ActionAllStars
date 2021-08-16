package com.sdg.view.pda.interfaces
{
	public interface IPDAButton extends IPDAButtonBase
	{
		function set labelText(value:String):void;
		function get labelText():String;
		function get params():Object;
		function set params(value:Object):void;
		function set selected(value:Boolean):void;
		function get selected():Boolean;
		function set toggleOn(value:Boolean):void;
		function get toggleOn():Boolean;
	}
}
