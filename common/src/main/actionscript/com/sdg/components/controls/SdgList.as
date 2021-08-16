package com.sdg.components.controls
{
	import mx.controls.List;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.IStateClient;
	
	public class SdgList extends List
	{
		public function SdgList()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			listContent.removeChild(selectionLayer);
		}
		
		override protected function drawItem(item:IListItemRenderer,
											selected:Boolean = false, highlighted:Boolean = false,
											caret:Boolean = false, transition:Boolean = false):void
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