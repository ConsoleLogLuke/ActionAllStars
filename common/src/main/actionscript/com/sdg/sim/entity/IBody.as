package com.sdg.sim.entity
{
	import com.sdg.geom.AABB;

	public interface IBody extends IParticle
	{
		function getAABB():AABB;
		
		function getLocalAABB(ox:Number = 0, oy:Number = 0):AABB;
	}
}