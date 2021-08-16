package com.sdg.animation.sequence
{
	public interface ISequenceCursor
	{
		function get currentIndex():int;
		
		function checkIndex(index:int):Boolean;
		
		function seekKeyframe(index:int):SequenceFrame;
	}
}