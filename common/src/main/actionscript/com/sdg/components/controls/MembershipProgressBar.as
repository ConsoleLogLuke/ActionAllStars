package com.sdg.components.controls
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;

	import mx.events.*;
	import mx.preloaders.*;
	import com.sdg.components.controls.DownloadProgressBar;
	import com.sdg.net.Environment;

	public class MembershipProgressBar extends DownloadProgressBar
	{
		override public function initialize():void
		{
			dpbImageControl = new flash.display.Loader();
			dpbImageControl.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_completeHandler);
			dpbImageControl.load(new URLRequest(Environment.getApplicationUrl() + 'swfs/membershipPreloader.swf'));

			// scaling
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_BORDER;
		}
	}
}
