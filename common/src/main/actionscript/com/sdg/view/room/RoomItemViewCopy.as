package com.sdg.view.room
{
	import com.sdg.control.room.RoomManager;
	import com.sdg.control.room.itemClasses.IRoomItemController;
	import com.sdg.view.FluidView;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class RoomItemViewCopy extends FluidView
	{
		protected var _bitmap:Bitmap;
		
		private var _roomItemController:IRoomItemController;
		private var _bitmapData:BitmapData;
		private var _roomView:DisplayObject;
		private var _itemScale:Number;
		private var _drawWithRoom:Boolean;
		private var _margin:Number;
		
		public function RoomItemViewCopy(width:Number, height:Number, roomItemController:IRoomItemController, drawWithRoom:Boolean = true, itemScale:Number = 1, margin:Number = 0)
		{
			_roomItemController = roomItemController;
			_roomView = DisplayObject(RoomManager.getInstance().roomContext.roomView);
			_itemScale = itemScale;
			_drawWithRoom = drawWithRoom;
			_margin = margin;
			
			_bitmapData = new BitmapData(width + _margin * 2, height + _margin * 2, true, 0x00ff00);
			
			_bitmap = new Bitmap(_bitmapData);
			_bitmap.x = -_margin;
			_bitmap.y = -_margin;
			
			super(width, height);
			
			// We will re-draw the image on enter frame.
			_roomView.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			addChild(_bitmap);
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function destroy():void
		{
			// Remove the enter frame listener to stop re-drawing the image.
			_roomView.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			// Remove displays.
			removeChild(_bitmap);
			
			// Clean bitmap data.
			_bitmapData.dispose();
			
			// Remove references.
			_roomItemController = null;
			_bitmap = null;
			_bitmapData = null;
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			// Recreate bitmap data at new size.
			newBitmapData();
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function draw():void
		{
			// Re-draw the copy of the room item.
			if (!_roomItemController.display || !_roomItemController.display.content) return;
			var itemDisplay:DisplayObject = _roomItemController.display.content;
			var scale:Number = _itemScale;
			var source:IBitmapDrawable;
			var imgRect:Rectangle = _roomItemController.display.getImageRect();
			var offX:Number;
			var offY:Number;
			// Determine if we should draw the room item with the room environment included.
			if (_drawWithRoom)
			{
				// Draw the item with the background environment.
				source = _roomView;
				offX = (-_roomItemController.display.x - imgRect.x - imgRect.width / 2) * scale + _margin + _width / 2;
				offY = (-_roomItemController.display.y - imgRect.y - imgRect.height / 2) * scale + _margin + _height / 2;
			}
			else
			{
				// Draw the item without the background environment.
				source = itemDisplay;
				offX = (-imgRect.x - imgRect.width / 2) * scale + _margin + _width / 2;
				offY = (-imgRect.y - imgRect.height / 2) * scale + _margin + _height / 2;
				
				// Create new bitmap data.
				newBitmapData();
			}
			
			_bitmapData.draw(source, new Matrix(scale, 0, 0, scale, offX, offY), null, null, null, (_itemScale != 1));
		}
		
		private function newBitmapData():void
		{
			// Recreate bitmap data.
			_bitmapData = new BitmapData(_width + _margin * 2, _height + _margin * 2, true, 0x00ff00);
			_bitmap.bitmapData = _bitmapData;
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public function get itemScale():Number
		{
			return _itemScale;
		}
		public function set itemScale(value:Number):void
		{
			_itemScale = value;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onEnterFrame(e:Event):void
		{
			draw();
		}
		
	}
}