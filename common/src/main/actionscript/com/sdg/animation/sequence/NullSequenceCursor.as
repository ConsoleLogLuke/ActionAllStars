package com.sdg.animation.sequence
{
	public class NullSequenceCursor implements ISequenceCursor
	{
		public function NullSequenceCursor()
		{
		}
	
		public function get currentIndex():int
		{
			return 0;
		}
	
		public function checkIndex(index:int):Boolean
		{
			return false;
		}
	
		public function seekKeyframe(index:int):SequenceFrame
		{
			return null;
		}
	}
}