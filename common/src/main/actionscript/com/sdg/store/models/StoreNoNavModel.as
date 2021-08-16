package com.sdg.store.models
{
	import com.sdg.store.StoreModel;
	import com.sdg.store.controllers.PetStoreController;
	import com.sdg.store.view.PetStoreHomeView;
	
	/**
	 * 
	 * Used for the pet store, or theoretically for anything that doesn't show the right Nav.
	 * 
	 * Currently this class still creates the otehr models even though they are not shown
	 * because the controller references them. Idealy if we keep using this I'll create
	 * a "NullModel" for the ListModel and other things.
	 * 
	 * So one day before launch it was decided that it was important (for unknown reasons)
	 * that we put in a limit of one pet. 
	 * 
	 * It has been made clear to me no matter what the risks to the code, it's
	 * no my fault if something bad happens.
	 * 
	 * Since the store is being rewritten in a month anyways, it seems logical.
	 * 
	 * 
	 * @author molly.jameson
	 */
	public class StoreNoNavModel extends StoreModel
	{
		public function StoreNoNavModel(storeId:uint)
		{
			super(storeId);
			
			this.HOME_VIEW_CLASS = PetStoreHomeView;
			this.STORE_CONTROLLER = PetStoreController;
		}
		
		public override function init():void
		{
			super.init();
			
			_navModel.view.visible = false;
			
			//TODO: on homeview
		}
		
	}
}