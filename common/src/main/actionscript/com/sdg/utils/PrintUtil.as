package com.sdg.utils
{
	import com.sdg.business.resource.IRemoteResource;
	import com.sdg.business.resource.SdgResourceLocator;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.printing.PrintJob;
	
	public class PrintUtil
	{
		// Set Resize to true if you need the sprite to be scaled to fit the printed page
		public static function print(printItem:Sprite,resize:Boolean=false):void
		{
			var job:PrintJob = new PrintJob();

			if (job.start())
			{
				if (resize)
				{
					// TBD - INCOMPLETE
					
					var pWidth:int = job.pageWidth;
					var pHeight:int = job.pageHeight;
					var sWidth:int = printItem.width;
					var sHeight:int = printItem.height;
					
					var widthRatio:int = pWidth / sWidth;
					var heightRatio:int = pHeight / sHeight;
					
					var lowRatio:int = 1;
					if ( heightRatio > widthRatio )
					{
						lowRatio = widthRatio;
					}
					else
					{
						lowRatio = heightRatio;
					}
					
					// Scale if ratio is less than 1 
					if ( lowRatio < 1 )
					{
						printItem.scaleX *= lowRatio;
						printItem.scaleY *= lowRatio;
					}

					job.addPage(printItem);
				}
				else
				{
					job.addPage(printItem);
				}
			}
			
			job = null;
		}
		
		/*
		public static function printDO(printItem:DisplayObject):void
		{
			var job:PrintJob = new PrintJob();
			new Sprite
			if (job.start())
			{
				//var width:int = job.pageWidth;
				//var height:int = job.pageHeight;
				//trace("Page Height and Width: "+height+" | "+width);
				var page:Sprite = new Sprite();
				page.addChild(printItem);
				job.addPage(page);
			}
			
			job = null;
		}
		*/
		
		/*
		public static function launchPrintPreview(printItem:Sprite):void
		{
			MainUtil.showDialog(PrintPreviewDialog, {subject:printItem},false,false);
		}
		*/
	}
}