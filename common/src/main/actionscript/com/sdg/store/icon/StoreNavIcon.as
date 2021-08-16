package com.sdg.store.icon
{
	import com.sdg.mvc.ViewBase;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;

	public class StoreNavIcon extends ViewBase implements IStoreNavIcon
	{
		protected var _image:DisplayObject;
		protected var _clickArea:Sprite;
		protected var _imageContainer:Sprite;
		protected var _id:int;
		protected var _thumbnailURL:String;
		
		//Variables for Scaling
		protected var _widthMemory:Number;
		protected var _heightMemory:Number;
		protected var _iconName:String;
		
		public function StoreNavIcon(id:int=-1,name:String="")
		{
			super();
			
			_id = id;
			_iconName = name;
			_imageContainer = new Sprite();
			
			addChild(_imageContainer);
			
			//addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
		}
		
		override public function init(width:Number, height:Number):void
		{
			super.init(width,height);
			render();
		}
		
		override public function destroy():void
		{
			super.destroy();
		}
		
		override public function render():void
		{
			super.render();
			
			//if (_image == null) return;
		}
		
		public function get image():DisplayObject
		{
			return _image;
		}
		public function set image(value:DisplayObject):void
		{
			if (_image != null)
			{
				_imageContainer.removeChild(_image);
				_imageContainer.removeChild(_clickArea);
			}
			
			// Set the new one.
			_image = value;
			
			// Add Glow Filter
			//_image.filters = [new GlowFilter(0xFFFFFF,1,2,2,10,1)];
			
			_imageContainer.addChild(_image);
			
			// Add a Clickable Box to image
			_clickArea = new Sprite();
			//_imageContainer.width = 56;
			//_imageContainer.height = 56;
			_clickArea.graphics.beginFill(0x00ff00,0);
			_clickArea.graphics.drawRect(0,0,56,56);
			_imageContainer.addChild(_clickArea);
			
			render();
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function get iconName():String{
			return _iconName;
		}
		
		public function get imageContainer():Sprite
		{
			return _imageContainer;
		}
		
		//protected function enlargeImage(e:MouseEvent):void
		//{
			//_imageContainer.width = this.width;
			//_imageContainer.height = this.height;
			
			//Remember Original Size
			//_widthMemory = this.width;
			//_heightMemory = this.height;
			
		//	trace("+++++++++MOUSE OVER!!!!: "+this.id);
			
		//	this._image.width *= 1.25;
		//	this._image.height *= 1.25;
		//}
		
		//protected function shrinkImage(e:MouseEvent):void
		//{
		//	this._image.width *= .8;
		//	this._image.height *= .8;
		//}
		
		/////////////////////////////
		// STATIC UTILITY FUNCTIONS
		/////////////////////////////
		
		//public static function calculateWidth(parentWidth:uint):uint
		//{
		//	return parentWidth / 20;
		//}
		
		//public static function calculateHeight(parentHeight:uint):uint
		//{
		//	return parentHeight / 25;
		//}
		
	}
}