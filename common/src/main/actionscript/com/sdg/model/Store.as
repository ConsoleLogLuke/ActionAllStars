package com.sdg.model
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class Store
	{
		private var _categories:Object = new Object();
		private var _categoryLists:Object = new Object();
		private var _itemLists:Object = new Object();
		private var _id:int;
		private var _name:String;
		private var _rootCategories:ArrayCollection = new ArrayCollection();
		
		public function Store(name:String, id:int)
		{
			_name = name;
			_id = id;
		}
		
		public function AddCategory(category:StoreCategory):void
		{
			_categories[category.id] = category;
		}
		
		public function getCategoryById(id:uint):StoreCategory
		{
			return _categories[id];
		}
		
		// properties
		
		public function get name():String
		{
			return _name;
		}
		
		public function get id():int
		{
			return _id;
		}

		public function get rootCategories():ArrayCollection
		{
			return _rootCategories;
		}
		
		public function get categories():Object
		{
			return _categories;
		}
		
		// methods
		
		/**
		 * Gets a list of categories by the parent category id. If the list
		 * does not exists and empty list is created
		 */
		public function getCategoriesByParentId(parentId:int):ArrayCollection
		{
			if (_categoryLists[parentId] != null) 
				return _categoryLists[parentId];
				
			_categoryLists[parentId] = new ArrayCollection();
			return _categoryLists[parentId];
		}

		public function getItemsByCategoryId(categoryId:int):ArrayCollection
		{
			if (_itemLists[categoryId] != null) 
				return _itemLists[categoryId];
				
			_itemLists[categoryId] = new ArrayCollection();
			return _itemLists[categoryId];
		}
	}
}