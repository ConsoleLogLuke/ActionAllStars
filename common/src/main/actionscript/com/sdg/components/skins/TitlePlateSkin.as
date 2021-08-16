package com.sdg.components.skins
{
	// Import necessary classes here.
	import mx.skins.RectangularBorder;

	public class TitlePlateSkin extends RectangularBorder 
	{
	
		private var _cornerRadius:uint = 2;
		private var _bgColor:int = 0x5173a7;

	    // Constructor.
	    public function TitlePlateSkin() 
	    {
	    	
	    }
	
	    override protected function updateDisplayList(w:Number, h:Number):void 
	    {
	       super.updateDisplayList(w, h);
	
	       //var cornerRadius:Number = (getStyle("cornerRadius") != null) ?  getStyle("cornerRadius") : _cornerRadius;
	       var backgroundColor:int = (getStyle("backgroundColor") != null) ?  getStyle("backgroundColor") : _bgColor;
	       
	       graphics.clear();
	
	       drawRoundRect(0, 0, w, h, 
	           {tl: _cornerRadius, tr:_cornerRadius, bl: _cornerRadius, br: _cornerRadius}, 
	           backgroundColor,1);
	
	       drawRoundRect(0, 0, w, h/2, 
	           {tl: 0, tr:0, bl: _cornerRadius, br: _cornerRadius}, 
	           0xffffff, .2);
	    }
	}
}