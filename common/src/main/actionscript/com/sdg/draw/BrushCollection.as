package com.sdg.draw
{
	import com.sdg.data.Collection;

	public class BrushCollection extends Collection
	{
		public function BrushCollection()
		{
			super();
		}
		
		public function addItem(itm:Brush):uint
		{
			return innerArray.push(itm);
		}
		
		public function getItem(index:uint):Brush
		{
			return Brush(innerArray[index]);
		}
	}
}