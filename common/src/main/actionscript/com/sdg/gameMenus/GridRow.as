package com.sdg.gameMenus
{
	import flash.display.Sprite;

	public class GridRow extends Sprite
	{
		protected var _fieldArray:Array;
		
		public function GridRow()
		{
			super();
			_fieldArray = new Array();
		}
		
		public function addField(field:GridField):void
		{
			var xPos:Number = 0;
			var numField:int = _fieldArray.length;
			
			if (numField > 0)
			{
				var lastField:GridField = _fieldArray[numField - 1];
				xPos = lastField.x + lastField.width;
			}
			
			field.x = xPos;
			
			addChild(field);
			_fieldArray.push(field);
		}
		
		override public function set height(value:Number):void
		{
			for each(var field:GridField in _fieldArray)
			{
				field.fieldHeight = value;
			}
			
			super.height = value;
		}
	}
}