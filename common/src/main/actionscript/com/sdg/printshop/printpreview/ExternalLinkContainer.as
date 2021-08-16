package com.sdg.printshop.printpreview
{
	import com.sdg.components.controls.store.StoreNavBar;
	import com.sdg.display.LineStyle;
	import com.sdg.graphics.GradientStyle;
	import com.sdg.graphics.RoundRectStyle;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.utils.Constants;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextFormat;

	public class ExternalLinkContainer extends Sprite
	{
		//private const WIDTH:uint = 350;
		//private const HEIGHT:uint = 550;
		
		private var _preview:Sprite;
		private var _printButton:StoreNavBar;
		private var _linkUrl:String;
		private var _logId:int;
		private var _buttonX:uint;
		private var _buttonY:uint;
		
		public function ExternalLinkContainer(url:String,logId:int,buttonX:uint,buttonY:uint)
		{
			super();
			
			_linkUrl = url;
			_logId = logId;
			_buttonX = buttonX;
			_buttonY = buttonY;
			
			generatePrintButton();
		}
		
		private function generatePrintButton():void
		{
			//create button
			_printButton = new StoreNavBar(170, 28, "VIEW");
			_printButton.roundRectStyle = new RoundRectStyle(10, 10);
			_printButton.labelFormat = new TextFormat('EuroStyle', 20, 0x9D330B, true);
			_printButton.buttonMode = true;
			_printButton.addEventListener(MouseEvent.MOUSE_OVER, onButtonMouseOver);
			_printButton.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
			
			_printButton.labelX = _printButton.width/2 - _printButton.labelWidth/2;
			setDefaultButton(_printButton);
			
			//locate button
			this.addChild(_printButton);
			_printButton.x = _buttonX;
			_printButton.y = _buttonY;
			
			//add listener
			_printButton.addEventListener(MouseEvent.CLICK,onViewClick);
			
			function onButtonMouseOver(event:MouseEvent):void
			{
				setMouseOverButton(event.currentTarget);
			}
				
			function onButtonMouseOut(event:MouseEvent):void
			{
				setDefaultButton(event.currentTarget);
			}
			
			function setDefaultButton(button:StoreNavBar):void
			{
				button.labelColor = 0x9D330B;
				button.borderStyle = new LineStyle(0x913300, 1, 1);
				
				var gradientBoxMatrix:Matrix = new Matrix();
				gradientBoxMatrix.createGradientBox(button.width, button.height, Math.PI/2, 0, 0);
				button.gradient = new GradientStyle(GradientType.LINEAR, [0xF7D85B, 0xD88616], [1, 1], [0, 255], gradientBoxMatrix);
			}
				
			function setMouseOverButton(button:StoreNavBar):void
			{
				button.labelColor = 0xffcc33;
				button.borderStyle = new LineStyle(0xff9900, 1, 1);
				
				var gradientBoxMatrix:Matrix = new Matrix();
				gradientBoxMatrix.createGradientBox(button.width, button.height, Math.PI/2, 0, 0);
				button.gradient = new GradientStyle(GradientType.LINEAR, [0xd18500, 0xa54c0a], [1, 1], [0, 255], gradientBoxMatrix);
			}
		}
		
		// Informs the server that a print job was attempted - first time nets a badge
		private function giveFirstPrintJobBadge():void
		{
			var uiTaggedMsg:String = "<uiEvent><uiId>" + Constants.UI_EVENT_PRINT_SHOP_PRINT_EVENT + "</uiId></uiEvent>";
			SocketClient.getInstance().sendPluginMessage("avatar_handler", "uiEvent", { uiEvent:uiTaggedMsg });
		}
		
		private function onViewClick(e:MouseEvent):void
		{
			this.giveFirstPrintJobBadge();
			LoggingUtil.sendClickLogging(_logId);
			
			var req:URLRequest = new URLRequest(_linkUrl);
			try
			{
				navigateToURL(req);
			}
			catch (e:Error)
			{}
		}
		
	}
}