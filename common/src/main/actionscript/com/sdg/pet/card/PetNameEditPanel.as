package com.sdg.pet.card
{
	import com.sdg.ui.TextFieldPanelWithArrow;
	import com.sdg.view.FluidView;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class PetNameEditPanel extends FluidView
	{
		private var _back:Sprite;
		private var _nameField:TextFieldPanelWithArrow;
		private var _nameField2:TextFieldPanelWithArrow;
		private var _delegate:IPetNameEditDelegate;
		private var _statusField:TextField;
		
		public function PetNameEditPanel(width:Number, height:Number, firstName:String, secondName:String, defaultStatusMessage:String = 'Loading pet names...')
		{
			_back = new Sprite();
			
			_nameField = new TextFieldPanelWithArrow(_width - 20, 32);
			_nameField.value = firstName;
			_nameField.arrowRotation = 90;
			
			_nameField2 = new TextFieldPanelWithArrow(_width - 20, 32);
			_nameField2.value = secondName;
			_nameField2.arrowRotation = 90;
			
			_statusField = new TextField();
			_statusField.defaultTextFormat = new TextFormat('EuroStyle', 14, 0xffffff, true, null, null, null, null, TextFormatAlign.CENTER);
			_statusField.selectable = false;
			_statusField.mouseEnabled = false;
			_statusField.embedFonts = true;
			_statusField.text = defaultStatusMessage;
			_statusField.visible = false;
			
			super(width, height);
			
			// Add interaction listeners.
			_nameField.addEventListener(MouseEvent.MOUSE_DOWN, onNameMouseDown);
			_nameField2.addEventListener(MouseEvent.MOUSE_DOWN, onNameMouseDown2);
			
			render();
			
			// Add displays.
			addChild(_back);
			addChild(_nameField);
			addChild(_nameField2);
			addChild(_statusField);
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		public function destroy():void
		{
			// Remove listeners.
			_nameField.removeEventListener(MouseEvent.MOUSE_DOWN, onNameMouseDown);
			_nameField2.removeEventListener(MouseEvent.MOUSE_DOWN, onNameMouseDown2);
			
			// Remove references.
			_delegate = null;
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(_width, _height, Math.PI / 2);
			_back.graphics.clear();
			_back.graphics.beginGradientFill(GradientType.LINEAR, [0x202020, 0x404040, 0x404040, 0x202020], [1, 1, 1, 1], [1, 60, 195, 255], gradMatrix);
			_back.graphics.drawRect(0, 0, _width, _height);
			
			var space:Number = 20;
			var totalH:Number = _nameField.height + space + _nameField2.height;
			
			_nameField.width = _width - 20;
			_nameField.x = 10;
			_nameField.y = _height / 2 - totalH / 2;
			
			_nameField2.width = _width - 20;
			_nameField2.x = 10;
			_nameField2.y = _nameField.y + _nameField.height + space;
			
			_statusField.width = width - 20;
			_statusField.height = height - 20;
			_statusField.x = 10;
			_statusField.y = 10;
		}
		
		////////////////////
		// GET/SET FUNCTIONS
		////////////////////
		
		public function get delegate():IPetNameEditDelegate
		{
			return _delegate;
		}
		public function set delegate(value:IPetNameEditDelegate):void
		{
			_delegate = value;
		}
		
		public function get firstName():String
		{
			return _nameField.value;
		}
		public function set firstName(value:String):void
		{
			_nameField.value = value;
		}
		
		public function get secondName():String
		{
			return _nameField2.value;
		}
		public function set secondName(value:String):void
		{
			_nameField2.value = value;
		}
		
		public function get showStatusMessage():Boolean
		{
			return _statusField.visible;
		}
		public function set showStatusMessage(value:Boolean):void
		{
			_statusField.visible = value;
		}
		
		public function get statusMessage():String
		{
			return _statusField.text;
		}
		public function set statusMessage(value:String):void
		{
			_statusField.text = value;
		}
		
		public function get showFields():Boolean
		{
			return (_nameField.visible && _nameField2.visible);
		}
		public function set showFields(value:Boolean):void
		{
			_nameField.visible = _nameField2.visible = value;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onNameMouseDown(e:MouseEvent):void
		{
			if (_delegate) _delegate.onFirstNameEditStart();
		}
		
		private function onNameMouseDown2(e:MouseEvent):void
		{
			if (_delegate) _delegate.onSecondNameEditStart()
		}
		
	}
}