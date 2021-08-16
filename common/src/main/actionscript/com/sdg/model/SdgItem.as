package com.sdg.model
{
	import com.sdg.control.room.itemClasses.RoomEntity;
	import com.sdg.display.IRoomItemDisplay;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Bindable]
	public class SdgItem extends EventDispatcher
	{
		public static const DISPLAY_SET:String = 'display has been set';
		
		public var itemId:uint;
		public var attributes:Object = {};
		public var avatarId:uint = 0;
		public var animationSetIds:Array = [];
		public var spriteTemplateId:uint = 0;
		public var layerType:uint = 0;
		public var numLayers:uint = 0;
		public var name:String = '';
		public var thumbnailUrl:String = '';
		public var version:String = '';
		public var x:int = 0;
		public var y:int = 0;
		public var orientation:uint = 0;
		public var updateCount:int = 0;
		public var description:String = '';
		private var _assetType:uint = 0;
		protected var _entity:RoomEntity;
		protected var _display:IRoomItemDisplay;
		protected var _instanceId:int;
		protected var _itemTypeId:uint = 0;
		
		// Static means the item is created from the database and has a static existance.
		// Oppose to room items created dynamically during gameplay.
		protected var _isStatic:Boolean;
		
		public function SdgItem(instanceId:int = 0):void
		{
			// Create default values.
			_entity = new RoomEntity();
			_instanceId = instanceId;
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function destroy():void
		{
			
		}
		
		override public function toString():String
		{
			return 'SdgItem: ' + name + '; id: ' + id + ', itemClassId: ' + itemClassId;
		}
		
		public function print():void
		{
			// Trace out the properties of this item.
			trace(className);
			
			trace(propListString);
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get id():uint
		{
			return itemId;
		}
		
		public function get itemClassId():uint
		{
			return SdgItemUtil.getClassId(this);
		}
		
		public function get instanceId():int
		{
			return _instanceId;
		}
		
		public function get isUserItem():Boolean
		{
			return avatarId == ModelLocator.getInstance().user.avatarId;
		}
		
		public function get assetType():uint
		{
			return _assetType;
		}
		public function set assetType(value:uint):void
		{
			if (value == _assetType) return;
			_assetType = value;
		}
		
		public function get propListString():String
		{
			var propString:String = 	'id: ' + id + '\n' +
										'name: ' + name + '\n' +
										'itemClassId: ' + itemClassId + '\n' +
										'avatarId: ' + avatarId + '\n' +
										'spriteTemplateId: ' + spriteTemplateId + '\n' +
										'animationSetIds: ' + stringAnimSetIds() + '\n' +
										'layerType: ' + layerType + '\n' +
										'numLayers: ' + numLayers + '\n' +
										'thumbnailUrl: ' + thumbnailUrl + '\n' +
										'x: ' + x + '\n' +
										'y: ' + y + '\n' +
										'orientation: ' + orientation + '\n' +
										'assetType: ' + _assetType + '\n';
										
			return propString;
			
			function stringAnimSetIds():String
			{
				var i:int = 0;
				var len:int = animationSetIds.length;
				var string:String = '';
				var animationSetIdNode:XML;
				for (i; i < len; i++)
				{
					animationSetIdNode = animationSetIds[i] as XML;
					if (animationSetIdNode != null)
					{
						if (string.length > 0) string += ', ';
						string += animationSetIdNode.toString();
					}
				}
				
				return string;
			}
		}
		
		public function get className():String
		{
			return 'SdgItem';
		}
		
		public function get isStatic():Boolean
		{
			return _isStatic;
		}
		public function set isStatic(value:Boolean):void
		{
			_isStatic = value;
		}
		
		public function get entity():RoomEntity
		{
			return _entity;
		}
		public function set entity(value:RoomEntity):void
		{
			if (value == _entity) return;
			_entity = value;
		}
		
		public function get display():IRoomItemDisplay
		{
			return _display;
		}
		public function set display(value:IRoomItemDisplay):void
		{
			if (value == _display) return;
			_display = value;
			dispatchEvent(new Event(DISPLAY_SET));
		}
		
		public function get itemTypeId():int
		{
			return _itemTypeId;
		}
		public function set itemTypeId(value:int):void
		{
			_itemTypeId = value;
		}
		
	}
}