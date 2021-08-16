package com.sdg.control.room.itemClasses
{
	import com.sdg.events.SimEvent;
	import com.sdg.geom.GeomUtil;
	import com.sdg.sim.entity.TileMapEntity;
	import com.sdg.utils.MathUtil;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.events.PropertyChangeEvent;
	
	[Bindable]
	public class RoomEntity extends TileMapEntity
	{
		protected var orientationStep:uint = 90;
		protected var rotationStep:Number = .6366197723675814;
		
		private var _orientation:uint;
		
		public function RoomEntity(width:Number = 1, height:Number = 1, solidity:Number = 10000)
		{
			super(width, height, solidity);
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function nextOrientation():void
		{
			orientation = MathUtil.wrap(orientation - orientationStep, 360);
			snapToGrid();
		}
		
		public function setNumOrientations(num:uint):void
		{
			orientationStep = (num == 0) ? 0 : Math.round(360 / num);
			rotationStep = GeomUtil._180_OVER_PI / orientationStep;
		}
		
		override protected function validate():void
		{
			super.validate();
			
			if (sdata.flags & ROTATED_FLAG)
			{
				_orientation = MathUtil.wrap(Math.round(-rotation * rotationStep) * orientationStep, 360);
			}
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get orientation():uint
		{
			return _orientation;
		}
		
		public function set orientation(value:uint):void
		{
			_orientation = value;
			rotation = _orientation * -GeomUtil.PI_OVER_180;
		}
		
	}
}