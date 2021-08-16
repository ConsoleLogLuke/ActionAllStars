package com.sdg.game.views
{
	import com.sdg.game.events.UnityNBAEvent;
	import com.sdg.game.models.IGameMenuModel;
	import com.sdg.game.models.IUnityNBAModel;
	
	import flash.display.Sprite;
	
	public class SubMenuViewBase extends Sprite implements ISubMenuView
	{
		protected var _model:IUnityNBAModel;
		protected var _headerText:String;
		protected var _isModelDirty:Boolean;
		protected var _isShown:Boolean;
		
		public function SubMenuViewBase()
		{
			super();
		}
		
		public function get headerText():String
		{
			return _headerText;
		}
		
		public function close():void
		{
			if (_model != null)
			{
				removePersistentListeners();
				removeIsShownListeners();
			}
		}
		
		public function show(model:IGameMenuModel):void
		{
			this.model = model;
			
			if (_isShown == false)
			{
				if (_model != null)
				{
					addIsShownListeners();
				}
			}
			
			_isShown = true;
			
			refresh();
		}
		
		public function hide():void
		{
			if (_isShown == true)
			{
				removeIsShownListeners();
			}
			
			_isShown = false;
		}
		
		protected function addPersistentListeners():void
		{
		}
		
		protected function removePersistentListeners():void
		{
		}
		
		protected function addIsShownListeners():void
		{
			_model.addEventListener(UnityNBAEvent.DATA_CHANGE, onDataChange, false, 0, true);
		}
		
		protected function removeIsShownListeners():void
		{
			_model.removeEventListener(UnityNBAEvent.DATA_CHANGE, onDataChange);
		}
		
		protected function onDataChange(event:UnityNBAEvent):void
		{
		}
		
		protected function refresh():void
		{
			_isModelDirty = false;
		}
		
		protected function set model(value:IGameMenuModel):void
		{
			if (value == _model) return;
			
			_isModelDirty = true;
			
			if (_model != null)
			{
				removePersistentListeners();
				removeIsShownListeners();
			}
			
			_model = value as IUnityNBAModel;
			
			if (_model != null)
			{
				addPersistentListeners();
				
				if (_isShown)
				{
					addIsShownListeners();
				}
			}
		}
	}
}
