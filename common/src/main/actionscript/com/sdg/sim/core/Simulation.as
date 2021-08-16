﻿package com.sdg.sim.core{		import com.sdg.collections.QuickList;	import com.sdg.collections.QuickMap;	import com.sdg.events.SimEvent;	import com.sdg.sim.dynamics.IIntegrator;		import flash.events.EventDispatcher;		public class Simulation extends EventDispatcher implements ISimulation	{		protected var integrators:QuickList = new QuickList();		protected var invalidMembers:QuickList = new QuickList();		protected var members:QuickList = new QuickList();				public function Simulation()		{		}				public function addMember(entity:SimEntity):void		{			var simulation:ISimulation = entity.getSimulation();			if (simulation) simulation.removeMember(entity);						members.push(entity);			invalidMembers.push(entity);						entity.setSimulation(this);		}				public function addAllMembers(simulation:Simulation):void		{			var members:Array = simulation.members;			var i:int = members.length;						while (--i > -1)				addMember(members[i]);		}				public function containsMember(entity:SimEntity):Boolean		{			return entity.getSimulation() == this;		}				public function invalidateMember(entity:SimEntity):void		{			invalidMembers.push(entity);		}				public function removeMember(entity:SimEntity):void		{			if (entity.getSimulation() == this)			{				members.removeValue(entity);				entity.setSimulation(null);			}		}				public function removeAllMembers():void		{			var i:int = members.length;						while (--i > -1)				members[i].setSimulation(null);						invalidMembers.length = 0;			members.length = 0;		}				public function addIntegrator(integrator:IIntegrator):void		{			if (!integrators.contains(integrator))			{				integrators.push(integrator);			}		}				public function removeIntegrator(integrator:IIntegrator):void		{			integrators.removeValue(integrator);		}				public function update(dt:Number, iterations:int):void		{			var numIntegrators:int = integrators.length;			var i:int;						while (--iterations > -1)			{				i = numIntegrators;								while (--i > -1)				{					integrators[i].step(dt);				}			}						i = invalidMembers.length;						if (i > 0)			{				while (--i > -1)				{					invalidMembers[i].validateNow();				}				invalidMembers.length = 0;			}		}	}}