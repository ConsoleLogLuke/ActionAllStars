package com.sdg.model
{
	import com.sdg.utils.PreviewUtil;
	
	/**
	 * An item that can be purchased in the AllStars store
	 */
	public class StoreItem implements IPreviewItem
	{
		private var _id:int;
		private var _name:String;
		private var _description:String;
		private var _price:int;
		private var _typeId:int;
		private var _itemClass:int;
		private var _previewUrl:String;
		private var _previewUrlAlt:String;
		private var _thumbnailUrl:String;
		private var _isGroup:Boolean;
		//private var _isPurchased:Boolean;
		private var _qtyOwned:int;
		private var _childItems:Array;
		private var _parentCategory:StoreCategory;
		private var _homeTurfValue:uint;
		
		// custom attributes
		private var _walkSpeedPercent:int;
		private var _cooldownSeconds:int;
		private var _effectDurationSeconds:int;
		private var _charges:int;
		private var _levelRequirement:int;
		private var _itemSetId:int;
		
		/**
		 * Creates a new StoreItem
		 */				
		public function StoreItem(
			id:int, 
			name:String, 
			description:String, 
			price:int, 
			type:int, 
			itemClass:int,
			isGroup:Boolean,
			qtyOwned:int,
			previewUrl:String,
			thumbnailUrl:String,
			parentCategory:StoreCategory,
			walkSpeedPercent:int,
			cooldownSeconds:int,
			effectDurationSeconds:int,
			charges:int,
			levelRequirement:int,
			itemSetId:int,
			childItems:Array = null,
			homeTurfValue:uint = 0):void
		{
			_id = id;
			_name = name;
			_description = description;
			_price = price;
			_typeId = type;
			_itemClass = itemClass;
			_isGroup = isGroup;
			_qtyOwned = qtyOwned;
			_previewUrl = previewUrl;
			_thumbnailUrl = thumbnailUrl;
			_parentCategory = parentCategory;
			_walkSpeedPercent = walkSpeedPercent;
			_cooldownSeconds = cooldownSeconds;
			_effectDurationSeconds = effectDurationSeconds;
			_charges = charges;
			_levelRequirement = levelRequirement;
			_itemSetId = itemSetId;
			_homeTurfValue = homeTurfValue;
			
			// create the childItems array if this is a collection storeItem
			if (_isGroup && childItems==null)
			{
				_childItems = new Array();
			}
		}
		
		public static function StoreItemFromXML(xml:XML,storeId:int=0):StoreItem
		{
			// Extract attributes.
			var attributes:XMLList = xml.child('item');
			if (attributes == null) return null;
			var id:uint = (attributes.itemId != null) ? attributes.itemId : 0;
			var name:String = (attributes.name != null) ? attributes.name: '';
			var description:String = (attributes.description != null) ? attributes.description : '';
			var price:uint = (attributes.price != null) ? attributes.price : 0;
			var itemTypeId:uint = (attributes.itemTypeId != null) ? attributes.itemTypeId : 0;
			var isGroup:Boolean = (attributes.isGroup == 1) ? true : false;
			var itemClass:uint = (attributes.itemClass != null) ? attributes.itemClass : 0;
			var thumbnailUrl:String = (attributes.thumbnailUrl != null) ? attributes.thumbnailUrl : '';
			var previewUrl:String = (attributes.previewUrl != null) ? attributes.previewUrl : '';
			//var isPurchased:Boolean = false;
			var qtyOwned:int = (attributes.qtyOwned != null) ? attributes.qtyOwned : 0;
			var parentCategory:StoreCategory = null;
			var walkSpeedPercent:int = 1;
			var cooldownSeconds:int = 0;
			var effectDurationSeconds:int = 0;
			var charges:int = 0;
			var levelRequirement:int = (attributes.levelRequirement != null) ? attributes.levelRequirement : 0;
			var itemSetId:int = -1;
	
			var children:Array = new Array();
			if(storeId>0){
				parentCategory=new StoreCategory("", 0, storeId, 0,"",0);
			}			
			if(isGroup){
				var i:uint = 0;
				while (attributes.item[i] != null)
				{
					var childXml:XML = attributes.item[i] as XML;
					children.push(StoreItemFromXML(childXml));
					i++;			
				}
			}
			return new StoreItem(id, name, description, price, itemTypeId, itemClass, isGroup, qtyOwned, previewUrl, thumbnailUrl, parentCategory, walkSpeedPercent, cooldownSeconds, effectDurationSeconds, charges, levelRequirement, itemSetId, children);
		}
		
		// properties
		
		/**
		 * The id of this store item
		 */
		public function get id():int
		{
			return _id;
		}
		public function get itemId():uint
		{
			return _id;
		}

		/**
		 * The name of this store item
		 */
		public function get name():String
		{
			//return _name.charAt(0).toUpperCase() + _name.substring(1).toLowerCase();
			return _name;
		}
	
		/**
		 * The description of this store item
		 */
		public function get description():String
		{
			return _description;
		}
		
		/**
		 * The price of this store item
		 */
		public function get price():int
		{
			return _price;
		}

		/**
		 * The type of this store item
		 */
		public function get itemTypeId():int
		{
			return _typeId;
		}
		
		/**
		 * The class of this store item
		 */
		public function get itemClassId():int
		{
			return _itemClass;
		}
		
		/**
		 * Is the storeItem a collection of child storeItems?
		 */
		public function get isGroup():Boolean
		{
			return _isGroup;
		}
		
		/**
		 * has the item already been purchased by the current user?
		 */
		public function get qtyOwned():int
		{
			return _qtyOwned;
		}
		
		/**
		 * has the item already been purchased by the current user?
		 */
		public function set qtyOwned(value:int):void
		{
			_qtyOwned = value;
		}
		
		/**
		 * The thumbnail url for viewing in the list control)
		 */
		public function get thumbnailUrl():String
		{
			return _thumbnailUrl;
		}
		
		/**
		 * The preview url for viewing on the avatar (if apparal)
		 */
		public function get previewUrl():String
		{
			return _previewUrl;
		}
		
		/**
		 * The alternate preview url for viewing on the avatar (if apparal)
		 */
		public function get previewUrlAlt():String
		{
			return _previewUrlAlt;
		}
		
		/**
		 * The child store items if this is a 'collection' storeItem.
		 * Note that isGroup should be true if there are childItems.
		 */
		public function get childItems():Array
		{
			return _childItems;
		}
		
		/**
		 * The type of this store item
		 */
		public function get parentCategory():StoreCategory
		{
			return _parentCategory;
		}
		
		/**
		 * The walkSpeedPercent of this store item
		 */
		public function get walkSpeedPercent():int
		{
			return _walkSpeedPercent;
		}

		/**
		 * The cooldownSeconds of this store item
		 */
		public function get cooldownSeconds():int
		{
			return _cooldownSeconds;
		}

		/**
		 * The _effectDurationSeconds of this store item
		 */
		public function get effectDurationSeconds():int
		{
			return _effectDurationSeconds;
		}

		/**
		 * The usage charges of this store item
		 */
		public function get charges():int
		{
			return _charges;
		}

		/**
		 * The levelRequirement of this store item
		 */
		public function get levelRequirement():int
		{
			return _levelRequirement;
		}

		/**
		 * The levelRequirement of this store item
		 */
		public function get itemSetId():int
		{
			return _itemSetId;
		}
		
		// methods
		
		/**
		 * Checks to see if this StoreItem has a given ItemTypeId
		 */
		public function hasItemType(typeId:int):Boolean
		{
			if (isGroup)
			{
				for each (var childItem:StoreItem in childItems)
				{
					if (childItem.itemTypeId == typeId)
						return true;					
				}
				
				return false;
			}
			
			return this.itemTypeId == typeId;
		}
		
		public function get hasCustomAttributes():Boolean
		{
			if (walkSpeedPercent || levelRequirement || itemSetId)
				return true;
				
			return false;	
		}
		
		public function get homeTurfValue():uint
		{
			return _homeTurfValue;
		}
	}
}