package com.sdg.geom
{
	import com.sdg.geom.Path;
	import com.sdg.geom.PathCursor;

	public class PathEditor extends PathCursor
	{
		public function PathEditor(path:Path)
		{
			super(path);
		}

		public function insert(segType:int, coords:Array):void
		{
			var numCoords:int = Path.SEG_COORDS[segType]; // Non-SDG - get SEG_COORDS from Path

			if (numCoords > 0)
			{
				_path.types.splice(_segIndex, 0, segType);
				_path.coords.splice.apply(this, [_coordIndex, 0].concat(coords.slice(0, numCoords)));
			}
		}

		public function remove(coords:Array):void // Non-SDG - return void instead of int
		{
			var type:int = currentSegment(coords); // Non-SDG - current to currentSegment
			var numCoords:int = Path.SEG_COORDS[ _path.types[_segIndex] ]; // Non-SDG - get SEG_COORDS from Path

			if (numCoords > 0)
			{
				_path.types.splice(_segIndex, 1);
				_path.coords.splice(_coordIndex, numCoords);
			}
		}
	}
}
