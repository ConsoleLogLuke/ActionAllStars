////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package com.sdg.components.skins
{
	import flash.display.GradientType;
	
	import mx.core.EdgeMetrics;
	import mx.core.mx_internal;
	import mx.skins.halo.PanelSkin;
	
	use namespace mx_internal;
	
	public class TitlePanelSkin extends PanelSkin
	{
		override mx_internal function drawBackground(w:Number, h:Number):void
	    {
	    	if (!h) return;
	    	
			var bm:EdgeMetrics = getBackgroundColorMetrics();
			
			// fill
			drawRoundRect(
	        	bm.left, bm.top, w - (bm.left + bm.right), h - (bm.top + bm.bottom), radius, 
	        	backgroundColor,  getStyle('backgroundAlpha'));
			
			// highlight
			var alphas:Object = getStyle('highlightAlphas');
			
			if (alphas is Array)
			{
				var gMax:uint = 255;
				var g1:uint = gMax * 6 / h; 
				var g2:uint = gMax * 50 / h;
				
				drawRoundRect(
		        	bm.left, bm.top, w - (bm.left + bm.right), h - (bm.top + bm.bottom), radius, 
		        	[0xffffff, 0xffffff, 0xffffff, 0xffffff],  alphas,
		    		verticalGradientMatrix(0, 0, w, h), GradientType.LINEAR, [g1, g2, gMax - g2, gMax]);
			}
	    }
	}
}