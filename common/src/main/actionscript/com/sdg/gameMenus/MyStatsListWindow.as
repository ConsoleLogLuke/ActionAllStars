package com.sdg.gameMenus
{
	import com.sdg.model.DisplayObjectCollection;
	import com.sdg.view.ItemListWindow;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class MyStatsListWindow extends GameTable
	{
		protected var _listWindow:ItemListWindow;
		protected const CATEGORY_WIDTH:Number = 570;
		protected const VALUE_WIDTH:Number = 260;
		protected const CATEGORY_INDENT:Number = 30;
		
		public function MyStatsListWindow(width:Number = 858, height:Number = 311, borderHeight:Number = 37, borderThickness:Number = 4)
		{
			super(width, height, borderHeight, borderThickness);
			
			_listWindow = new ItemListWindow(_width - 2 * borderThickness, _height - 2 * borderThickness - borderHeight, 1, 100, 0);
			_listWindow.widthHeightRatio = 25;
			_listWindow.x = _width/2 - _listWindow.width/2;
			_listWindow.y = borderThickness + borderHeight;
			addChild(_listWindow);
			
			var categoryTitle:TextField = new TextField();
			categoryTitle.defaultTextFormat = new TextFormat('EuroStyle', 18, 0x132B50, true);
			categoryTitle.embedFonts = true;
			categoryTitle.autoSize = TextFieldAutoSize.LEFT;
			categoryTitle.selectable = false;
			categoryTitle.mouseEnabled = false;
			categoryTitle.text = "CATEGORY";
			var categoryColumnWidth:Number = (CATEGORY_WIDTH/(CATEGORY_WIDTH + VALUE_WIDTH)) * (_header.width - 20);
			categoryTitle.x = (categoryColumnWidth/CATEGORY_WIDTH) * CATEGORY_INDENT;
			categoryTitle.y = _header.height/2 - categoryTitle.height/2;
			_header.addChild(categoryTitle);
			
			var valueTitle:TextField = new TextField();
			valueTitle.defaultTextFormat = new TextFormat('EuroStyle', 18, 0x132B50, true);
			valueTitle.embedFonts = true;
			valueTitle.autoSize = TextFieldAutoSize.LEFT;
			valueTitle.selectable = false;
			valueTitle.mouseEnabled = false;
			valueTitle.text = "CURRENT VALUES";
			var valueColumnWidth:Number = (VALUE_WIDTH/(CATEGORY_WIDTH + VALUE_WIDTH)) * (_header.width - 20);
			valueTitle.x = categoryColumnWidth + valueColumnWidth/2 - valueTitle.width/2;
			valueTitle.y = _header.height/2 - valueTitle.height/2;
			_header.addChild(valueTitle);
		}
		
		public function set stats(value:Array):void
		{
			var statsCollection:DisplayObjectCollection = new DisplayObjectCollection();
			
			for each (var pair:Object in value)
			{
				var values:Array = pair.value.split(";");
				var row:GridRow = new GridRow();
				row.addField(new TextGridField(CATEGORY_WIDTH, 33, pair.category, 16, false, CATEGORY_INDENT));
				if (values.length == 1)
					row.addField(new TextGridField(VALUE_WIDTH, 33, values[0]));
				else if (values.length == 2)
					row.addField(new TeamGridField(VALUE_WIDTH, 33, values[0], values[1]));
				
				statsCollection.push(row);
			}
			
			_listWindow.items = statsCollection;
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