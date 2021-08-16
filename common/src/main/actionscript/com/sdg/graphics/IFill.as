package com.sdg.graphics
{
	public interface IFill
	{
		function Draw():void;
		function GetDuplicate():IFill;
		
		function set Color(newValue:uint):void;
		function get Color():uint;
		
		function set Width(newValue:Number):void;
		function get Width():Number;
		
		function set Height(newValue:Number):void;
		function get Height():Number;
		
		function set Alpha(value:Number):void;
		function get Alpha():Number;
		
	}
}