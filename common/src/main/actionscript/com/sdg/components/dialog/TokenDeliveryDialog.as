package com.sdg.components.dialog
{
	import com.sdg.model.ModelLocator;
	import com.sdg.store.transaction.TokenDelivery;
	import com.sdg.ui.RoundCornerCloseButton;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import mx.containers.Canvas;
	import mx.managers.PopUpManager;
	
	import com.sdg.net.Environment;
	
	public class TokenDeliveryDialog extends Canvas implements ISdgDialog
	{
		private var _tokenDelivery:TokenDelivery;
		
		public function TokenDeliveryDialog()
		{
			super();
			this.width = 470;
			this.height = 604;
			var background:Loader = new Loader();
			background.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadedComplete);
			background.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadedComplete);
			background.load(new URLRequest(Environment.getAssetUrl()+ "/assets/swfs/store/transactionBG.swf"));
			
			_tokenDelivery = new TokenDelivery(width, height);
			_tokenDelivery.avatarName = ModelLocator.getInstance().avatar.name;
			_tokenDelivery.visible = false;
			this.rawChildren.addChild(_tokenDelivery);
			
			var closeBtn:RoundCornerCloseButton = new RoundCornerCloseButton();
			closeBtn.x = this.width - closeBtn.width - 15;
			closeBtn.y = 45;
			closeBtn.buttonMode = true;
			closeBtn.addEventListener(MouseEvent.CLICK, onCloseClick);
			closeBtn.visible = false;
			this.rawChildren.addChild(closeBtn);
			
			function onLoadedComplete(event:Event):void
			{
				background.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadedComplete);
				background.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadedComplete);
				var content:DisplayObject = background.content;
				rawChildren.addChild(content);
				rawChildren.setChildIndex(content, 0);
				_tokenDelivery.visible = true;
				closeBtn.visible = true;
			}
		}
		
		private function onCloseClick(event:MouseEvent):void
		{
			close();
		}
		
		public function init(params:Object):void
		{
			//_tokenDelivery.tokenValue = params.tokens;
			_tokenDelivery.setMessages(params.message, params.tokens, params.closingMessage);
			//_tokenDelivery.message = params.message;
			//_tokenDelivery.closingMessage = params.closingMessage;
		}
		
		public function close():void
		{
			PopUpManager.removePopUp(this);
		}
	}
}