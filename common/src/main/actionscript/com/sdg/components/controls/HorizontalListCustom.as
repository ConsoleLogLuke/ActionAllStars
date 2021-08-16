package com.sdg.components.controls
{
	import mx.controls.HorizontalList;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.IStateClient;

	public class HorizontalListCustom extends HorizontalList
	{
		public function HorizontalListCustom()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			listContent.removeChild(selectionLayer);
		}
		
		override protected function drawItem(
							item:IListItemRenderer, selected:Boolean = false,
							highlighted:Boolean = false, caret:Boolean = false,
							transition:Boolean = false):void
		{
			super.drawItem(item, selected, highlighted, caret, transition);
			
			if (item)
			{
				if (item is IStateClient)
				{
					IStateClient(item).currentState = selected ? "selected" : highlighted ? "highlighted" : null;
				}
			}
		}
	}
}