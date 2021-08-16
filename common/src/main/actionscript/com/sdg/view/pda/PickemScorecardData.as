package com.sdg.view.pda
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class PickemScorecardData
	{
		public var pickemPicks:ArrayCollection = new ArrayCollection();
		public var status:String;
		public var numCorrect:int;
		
		public function PickemScorecardData()
		{
		}
		
		public function addPick(pick:Object):void
		{
			pickemPicks.addItem(pick);
		}
	}
}