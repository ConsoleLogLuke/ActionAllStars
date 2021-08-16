package com.sdg.model
{
	import mx.collections.ArrayCollection;
	
	import com.sdg.model.ModelLocator;
	
	/**
	 * Represents a catory for store items or other store categories.  
	 */
	public class StoreCategory
	{
		private var _name:String; 
		private var _id:int;
		private var _subCategoryCount:int;
		private var _storeId:int;
		private var _thumbnailUrl:String;
		private var _parent:StoreCategory;
		private var _storeData:Store;
				
		/**
		 *  Creates a new StoreCategory
		 */
		public function StoreCategory(
			name:String, 
			id:int,
			storeId:int, 
			subCategoryCount:int,
			thumbnailUrl:String,
			parentId:int)
		{
			_name = name;
			_id = id;
			_storeId = storeId;
			_subCategoryCount = subCategoryCount;
			_thumbnailUrl = thumbnailUrl;
			_parent = parent;
			
			// get the store
			_storeData = ModelLocator.getInstance().stores[storeId];
		}
		
		// properties
		
		/**
		 * The name of this category
		 */
		public function get name():String
		{
			return _name;
		}

		/**
		 * The id of this category
		 */
		public function get id():int
		{
			return _id;
		}

		/**
		 * The id of this category's store
		 */
		public function get storeId():int
		{
			return _storeId;
		}
		
		/**
		 * The id of this category's store
		 */
		public function get subCategoryCount():int
		{
			return _subCategoryCount;
		}
		
		/**
		 * the url for the thumnail image for this category
		 */
		public function get thumbnailUrl():String
		{
			return _thumbnailUrl;
		}
		
		/**
		 * The parent catogory or null if there is no parent
		 */
		public function get parent():StoreCategory
		{
			return _parent;
		}

        /**
        * The child categories of this category
        */
		public function get childCategories():ArrayCollection
		{
			return _storeData.getCategoriesByParentId(this.id);
		}
		
        /**
        * The store items in this category
        */
		public function get items():ArrayCollection
		{
			return _storeData.getItemsByCategoryId(this.id);
		}
	}
}