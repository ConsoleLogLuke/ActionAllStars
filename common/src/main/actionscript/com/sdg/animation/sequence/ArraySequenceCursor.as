package com.sdg.animation.sequence
{
	public class ArraySequenceCursor implements ISequenceCursor
	{
		private var index:int = 0;
		private var keyframe:SequenceFrame;
		private var sequence:Array;
		
		public function get currentIndex():int
		{
			return index;
		}
		
		public function ArraySequenceCursor(sequence:Array):void
		{
			this.sequence = sequence;
			this.keyframe = sequence[0];
		}
		
		public function checkIndex(index:int):Boolean
		{
			return index < sequence.length && index > -1;
		}
		
		public function seekKeyframe(index:int):SequenceFrame
		{
			if (sequence[index])
			{
				keyframe = sequence[index];
			}
			else if (index - index != 1)
			{
				for (var i:int = index; i > -1; i--)
				{
					if (sequence[i])
					{
						keyframe = sequence[i];
						break;
					}
				}
			}
			
			this.index = index;
			return keyframe;
		}
	}
}