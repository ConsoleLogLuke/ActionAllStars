package com.sdg.components.controls
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.BlurFilter;

	public class TransitionBitmap extends Bitmap
	{
		private var _blurValue:Number;
		
		public function TransitionBitmap(bitmapData:BitmapData=null, pixelSnapping:String='auto', smoothing:Boolean=false)
		{
			super(bitmapData, pixelSnapping, smoothing);
		}
		
		public function get blurValue():Number
		{
			return _blurValue;
		}
		
		public function set blurValue(value:Number):void
		{
//			var filtersArray:Array = new Array();
//			for (var i:int = 0; i < this.filters.length; i++)
//			{
//				if (this.filters[i] != _blurFilter)
//					filtersArray.push(this.filters[i]);
//			}
//			
//			_blurFilter = new BlurFilter(value, value);
//			
//			filtersArray.push(_blurFilter);

			_blurValue = value;
			this.filters = [new BlurFilter(_blurValue, _blurValue)];
		}
	}
}