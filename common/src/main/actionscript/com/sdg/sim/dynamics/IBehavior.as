package com.sdg.sim.dynamics
{
	import flash.events.IEventDispatcher;
	
	public interface IBehavior extends IIntegrator, IEventDispatcher
	{
		function get isComplete():Boolean;
	}
}