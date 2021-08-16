package com.sdg.components.dialog
{
	import com.sdg.model.Avatar;
	import com.sdg.model.ModelLocator;
	import com.sdg.net.Environment;
	import com.sdg.ui.RoundCornerCloseButton;
	import com.sdg.utils.Constants;
	
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.core.Application;
	import mx.managers.PopUpManager;
	
	public class TransactionDialog extends Canvas implements ISdgDialog
	{
		private var _optionsWindow:Image;
		public function TransactionDialog()
		{
			super();
			this.width = 470;
			this.height = 604;
			this.setStyle("backgroundImage", "assets/swfs/store/transactionBG.swf");
			//trace(this.width + " " + this.height);
			_optionsWindow = new Image();
			_optionsWindow.source = "assets/swfs/store/SkuSelection.swf";
			_optionsWindow.addEventListener(Event.INIT, onInit);
			this.addChild(_optionsWindow);
			
			var closeBtn:RoundCornerCloseButton = new RoundCornerCloseButton('Close Dialog');
			closeBtn.x = this.width - closeBtn.width - 15;
			closeBtn.y = 45;
			closeBtn.buttonMode = true;
			closeBtn.addEventListener(MouseEvent.CLICK, onCloseClick);
			this.rawChildren.addChild(closeBtn);
		}
		
		private function onCloseClick(event:MouseEvent):void
		{
			close();
		}
		
		private function onInit(event:Event):void
		{
			this.removeEventListener(Event.INIT, onInit);
			_optionsWindow.content.addEventListener("buyTokens", onBuyTokens);
		}
		
		private function onBuyTokens(event:Event):void
		{
			var transactionEvent:Object = Object(event);
			renderIFrame(transactionEvent.sku, transactionEvent.paymentMethod);
			close();
		}
		
		public function init(params:Object):void
		{
		}
		
		public function close():void
		{
			PopUpManager.removePopUp(this);
		}
		
		public function renderIFrame(sku:int, paymentType:uint):void
		{
			var userAvatar:Avatar = ModelLocator.getInstance().avatar;
			var userId:uint = userAvatar.userId;
			
			//Static URLs
			var creditcardURL:String = "/premium/co/micro?";
			var paypalURL:String = "/premium/paypal/setmicropaypal?";
			
			var jURL:String;
			
			if (paymentType == Constants.CREDIT_CARD)
			{
				jURL = creditcardURL;
			}
			else if (paymentType == Constants.PAYPAL)
			{
				jURL = paypalURL;
			}
			
			jURL += "userId=" + userId + "&productId=" + sku
			
			if (ExternalInterface.available)
			{
				ExternalInterface.call("showCreditForm", jURL);
				
				 // Send the stage to normal display state.
                Application.application.stage.displayState = StageDisplayState.NORMAL;
			}
		}
	}
}
