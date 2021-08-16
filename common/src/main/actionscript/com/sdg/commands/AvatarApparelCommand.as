package com.sdg.commands
{
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.control.CairngormEventDispatcher;
	import com.sdg.business.SdgServiceDelegate;
	import com.sdg.events.AvatarApparelEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.InventoryItem;
	import com.sdg.net.Environment;
	import com.sdg.utils.ObjectUtil;
	import com.sdg.utils.PreviewUtil;
	
	import mx.rpc.IResponder;
	
	public class AvatarApparelCommand extends AbstractResponderCommand implements ICommand, IResponder
	{
		private var _avatar:Avatar;	
		
		public function execute(event:CairngormEvent):void
		{
			var ev:AvatarApparelEvent = event as AvatarApparelEvent;
			_avatar = ev.avatar;
			new SdgServiceDelegate(this).getAvatarApparel(_avatar.avatarId);
		}
		
		public function result(data:Object):void
		{
			for each (var item:XML in data.items.children())
			{
				var a:InventoryItem = new InventoryItem();
				
				a.inventoryItemId = item.Id;
				a.name = item.n;
				a.thumbnailUrl = Environment.getApplicationUrl() + item.tUrl;
				a.previewUrl = Environment.getApplicationUrl() + item.pUrl;
				a.itemTypeId = item.itId;
				a.itemId = item.iId;
				a.itemValueType = item.dif;
				a.animationSetIds = ObjectUtil.enumToArray(item.asId);
				
				// custom attributes
				a.walkSpeedPercent = item.walkSpeedPercent.length() ? item.walkSpeedPercent : 0;
				a.effectDurationSeconds = item.effectDurationSecond.length() ? item.effectDurationSecond : 0;
				a.cooldownSeconds = item.cooldownSeconds.length() ? item.cooldownSeconds : 0;
				a.charges = item.charges.length() ? item.charges : -1;
				a.levelRequirement = item.levelRequirement.length() ? item.levelRequirement : 0;
				a.itemSetId = item.itemSetId.length() ? item.itemSetId : 0;
				
				// if this is a hair item, the the hat-hair previewUrl
				if (a.itemTypeId == PreviewUtil.HAIR)					
					a.previewUrlAlt = Environment.getApplicationUrl() + item.previewUrl_9010;
					
				_avatar.setApparel(a);
			}
			
			// dispatch a "listCompleted" event			
			CairngormEventDispatcher.getInstance().dispatchEvent(
				new AvatarApparelEvent(_avatar, AvatarApparelEvent.AVATAR_APPAREL_COMPLETED));
		}
	}
}