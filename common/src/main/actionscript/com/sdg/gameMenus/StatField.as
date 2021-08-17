package com.sdg.gameMenus
{
	import com.sdg.model.DisplayObjectCollection;
	import com.sdg.view.ItemListWindow;

	import flash.display.Sprite;

	public class StatField extends Sprite
	{
		protected var _width:Number;
		protected var _height:Number;
		protected var _listWindow:ItemListWindow;

		public function StatField(width:Number = 850, height:Number = 300) // Non-SDG - fix the constructor name
		{
			super();
			_width = width;
			_height = height;

			this.graphics.beginFill(0xfff000);
			this.graphics.drawRect(0, 0, _width, _height);

			_listWindow = new ItemListWindow(_width, _height, 1, 100, 0);
			_listWindow.widthHeightRatio = 23;
			addChild(_listWindow);

			var items:DisplayObjectCollection = new DisplayObjectCollection();

			for (var i:int = 0; i< 10; i++)
			{
				var box:Sprite = new Sprite();
				box.graphics.beginFill(0x333333 * i);
				box.graphics.drawRect(0, 0, 100, 10);
				items.push(box);
			}

			_listWindow.items = items;

			//_listWindow.addEventListener(GridItemEvent.INTO_VISIBILITY, onItemIntoVisibility);
		}

		override public function get width():Number
		{
			return _width;
		}

		override public function get height():Number
		{
			return _height;
		}
	}
}
