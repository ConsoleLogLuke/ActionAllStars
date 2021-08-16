package com.sdg.model
{
	import com.sdg.utils.PreviewUtil;
	
	[Bindable]
	public class InventoryItem extends SdgItem implements IPreviewItem, ILayeredImageItem
	{
		public var inventoryItemId:uint;
		public var roomId:uint;
		
		public var turfValue:int;
		public var themeId:int;
		public var layoutId:int;
		
		private var _previewUrl:String;
		private var _previewUrlAlt:String;
		private var _itemValueType:uint;
		private var _isGreyedOut:Boolean = false;
		
		// custom attributes
		private var _walkSpeedPercent:int;
		private var _cooldownSeconds:int;
		private var _effectDurationSeconds:int;
		private var _charges:int;
		private var _levelRequirement:int;
		private var _itemSetId:int;
		private var _abstractClickHandlerIds:Array;
		
		public static const PREMIUM:uint = 3;
		public static const DEFAULT:uint = 1;
		public static const FREE:uint = 2;
		public static const FREE_NOW:uint = 0;
		
		/**
		 * Constructor.
		 */
		public function InventoryItem()
		{
			// Default values.
			
			// Static means the item is created from the database and has a static existance.
			// Oppose to room items created dynamically during gameplay.
			_isStatic = true;
			
			// This will array will contain string Ids that represnt functions
			// to be called when this iventory item is clicked.
			_abstractClickHandlerIds = [];
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function getLayeredImageUrlArray():Array
		{
			return [previewUrl];
		}
		
		public function getLayerId():int
        {
        	return PreviewUtil.getLayerId(itemTypeId);
        }
        
        public static function getTypeNameById(id:uint):String
        {
        	return PreviewUtil.getTypeNameById(id);
        }
        
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get abstractClickHandlerIds():Array
		{
			return _abstractClickHandlerIds;
		}
		public function set abstractClickHandlerIds(value:Array):void
		{
			_abstractClickHandlerIds = value;
		}
		
		override public function get id():uint
		{
			return inventoryItemId;
		}
		
		override public function get itemTypeId():int
		{
			return _itemTypeId;
		}
		override public function set itemTypeId(value:int):void
		{
			_itemTypeId = value;
		}
		
		public function get previewUrl():String
		{
			return _previewUrl;
		}
		
		public function set previewUrl(value:String):void
		{
			_previewUrl = value;
		}
		
		public function get previewUrlAlt():String
		{
			return _previewUrlAlt;
		}
		
		public function set previewUrlAlt(value:String):void
		{
			_previewUrlAlt = value;
		}
		
		public function get itemValueType():uint
		{
			return _itemValueType;
		}
		
		public function set itemValueType(value:uint):void
		{
			_itemValueType = value;
		}
		
		public function get isGreyedOut():Boolean
		{
			return _isGreyedOut;
		}
		
		public function set isGreyedOut(value:Boolean):void
		{
			_isGreyedOut = value;
		}
		
		/**
		 * The walkSpeedPercent of this store item
		 */
		public function get walkSpeedPercent():int
		{
			return _walkSpeedPercent;
		}
		
		public function set walkSpeedPercent(value:int):void
		{
			_walkSpeedPercent = value;
		}

		/**
		 * The cooldownSeconds of this store item
		 */
		public function get cooldownSeconds():int
		{
			return _cooldownSeconds;
		}

		public function set cooldownSeconds(value:int):void
		{
			_cooldownSeconds = value;
		}

		/**
		 * The _effectDurationSeconds of this store item
		 */
		public function get effectDurationSeconds():int
		{
			return _effectDurationSeconds;
		}

		public function set effectDurationSeconds(value:int):void
		{
			_effectDurationSeconds = value;
		}

		/**
		 * The usage charges of this store item
		 */
		public function get charges():int
		{
			return _charges;
		}

		public function set charges(value:int):void
		{
			_charges = value;
		}

		/**
		 * The levelRequirement of this store item
		 */
		public function get levelRequirement():int
		{
			return _levelRequirement;
		}
		
		public function set levelRequirement(value:int):void
		{
			_levelRequirement = value;
		}

		/**
		 * The usage charges of this store item
		 */
		public function get itemSetId():int
		{
			return _itemSetId;
		}

		public function set itemSetId(value:int):void
		{
			_itemSetId = value;
		}
		
		public function get hasCustomAttributes():Boolean
		{
			if (walkSpeedPercent || itemSetId)
				return true;
				
			return false;	
		}
		
		public function get isUseItem():Boolean
		{
			// if there is an effect that lasts for a limited time, it's a use item
			return hasCustomAttributes && effectDurationSeconds;
		}
		
		override public function get propListString():String
		{
			var superPropString:String = super.propListString;
			var propString:String = 	'itemId: ' + itemId + '\n' +
										'inventoryItemId: ' + inventoryItemId + '\n' +
										'itemTypeId: ' + itemTypeId + '\n' +
										'previewUrl: ' + previewUrl + '\n';
			
			propString = superPropString + propString;
										
			return propString;
		}
		
		override public function get className():String
		{
			return 'InventoryItem';
		}
	}
}