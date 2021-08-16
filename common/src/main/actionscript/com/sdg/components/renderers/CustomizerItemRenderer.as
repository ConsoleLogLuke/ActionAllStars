package com.sdg.components.renderers
{
	import flash.filters.GlowFilter;
	
	public class CustomizerItemRenderer extends TileItemRenderer
	{
		public function CustomizerItemRenderer()
		{
			super();
			this.backAlpha = .3;
			this.selectedBorderThickness = 2;
			this.defaultBorderThickness = 1;
			//this.iconFilters = [new GlowFilter(0xffffff, .8, 10, 10)];
			this.sizeOffset = 4;
			this.greyedBorderColor = 0x444444;
			this.greyedColor = 0x444444;
		}
	}
}