package com.good.goodui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;

	public class GoodDialogControl extends FluidView
	{
		protected var _dialogQue:Array;
		protected var _modalQue:Array;
		protected var _container:Sprite;
		protected var _isModal:Boolean;
		protected var _dialogShadow:DropShadowFilter;
		protected var _currentDialog:DisplayObject;
		
		public function GoodDialogControl(width:Number, height:Number)
		{
			_dialogShadow = new DropShadowFilter(4, 45, 0, 0.6, 16, 16);
			_dialogQue = [];
			_modalQue = [];
			_container = new Sprite();
			_isModal = false;
			
			addChild(_container);
			
			super(width, height);
		}
		
		public function addDialog(dialog:DisplayObject, isModal:Boolean = false):void
		{
			var index:uint = _dialogQue.push(dialog) - 1;
			_modalQue[index] = isModal;
			updateQue();
		}
		
		public function removeDialog(dialog:DisplayObject):void
		{
			// Determine index of the dialog in the que.
			var index:int = _dialogQue.indexOf(dialog);
			if (index < 0) return;
			
			// Set to null.
			_dialogQue[index] = null;
			_modalQue[index] = null;
			
			// If it's the current dialog, remove it from display.
			if (dialog == _currentDialog)
			{
				_container.removeChild(dialog);
				_currentDialog = null;
				_isModal = false;
				
				// Render modal.
				renderModal();
			}
			
			// Update que.
			updateQue();
		}
		
		override protected function render():void
		{
			super.render();
			
			// If there is a current dialog, render it.
			if (_currentDialog != null) renderDialog(_currentDialog);
			
			renderModal();
		}
		
		protected function updateQue():void
		{
			// If there is a current dialog, do nothing.
			if (_currentDialog != null) return;
			
			// If there is not a current dialog, check for the next dialog in the que.
			var i:uint = 0;
			var len:uint = _dialogQue.length;
			for (i; i < len; i++)
			{
				if (_dialogQue[i] != null)
				{
					// Set modal.
					_isModal = _modalQue[i];
					
					// Found what should be the current dialog.
					setCurrentDialog(_dialogQue[i]);
					
					return;
				}
			}
		}
		
		protected function renderDialog(dialog:DisplayObject):void
		{
			dialog.x = _width / 2 - dialog.width / 2;
			dialog.y  = _height / 2 - dialog.height / 2;
		}
		
		protected function setCurrentDialog(dialog:DisplayObject):void
		{
			// Make sure there isn't a current dialog.
			if (_currentDialog != null) return;
			
			// Set the current dialog.
			_currentDialog = dialog;
			_currentDialog.filters = [_dialogShadow];
			_container.addChild(_currentDialog);
			
			// Render the dialog.
			renderDialog(_currentDialog);
			
			// Render modal.
			renderModal();
		}
		
		protected function renderModal():void
		{
			_container.graphics.clear();
			
			if (_isModal == true)
			{
				_container.graphics.beginFill(0, 0.7);
				_container.graphics.drawRect(0, 0, _width, _height);
			}
		}
		
	}
}