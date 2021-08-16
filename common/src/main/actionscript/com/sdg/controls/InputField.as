package com.sdg.controls
{
	import com.sdg.view.utils.LayoutUtils;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	public class InputField extends Sprite
	{
		
		protected var _useLabel:Boolean;
		protected var _label:TextField;
		protected var _field:TextField;
		
		public function InputField(width:Number = 80, height:Number = 18)
		{
			super();
			
			_useLabel = true;
			
			_label = new TextField();
			_label.defaultTextFormat = new TextFormat('Arial', 12, 0);
			_label.text = 'Label';
			addChild(_label);
			
			_field = new TextField();
			_field.type = TextFieldType.INPUT;
			_field.defaultTextFormat = new TextFormat('Arial', 12, 0);
			_field.background = _field.border = true;
			_field.backgroundColor = 0xffffff;
			_field.borderColor = 0;
			addChild(_field);
			
			_draw();
		}
		
		protected function _draw():void
		{
			// do some layout work
			LayoutUtils.StackDown([_label, _field], 0, 0);
		}
		
	}
}