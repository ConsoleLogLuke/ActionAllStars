package com.sdg.sim.entity
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public interface IMapOccupant extends IBody, IEventDispatcher
	{
		function get solidity():Number;
		function set solidity(value:Number):void;
		
		function validateOccupancy(x:Number = NaN, y:Number = NaN):Boolean
	}
}