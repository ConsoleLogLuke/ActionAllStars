package com.sdg.printshop.printpreview
{
	import com.sdg.components.controls.store.StoreNavBar;
	import com.sdg.display.LineStyle;
	import com.sdg.graphics.GradientStyle;
	import com.sdg.graphics.RoundRectStyle;
	import com.sdg.logging.LoggingUtil;
	import com.sdg.net.socket.SocketClient;
	import com.sdg.printshop.PrintShopEvent;
	import com.sdg.printshop.printitem.IPrintItem;
	import com.sdg.printshop.printitem.PrintItemMapping;
	import com.sdg.utils.Constants;
	import com.sdg.utils.PrintUtil;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextFormat;

	public class PrintPreviewContainer extends Sprite
	{
		private const WIDTH:uint = 350;
		private const HEIGHT:uint = 550;
		
		//private var _printItem:MyCardFrontPrintItem;
		private var _printItem:IPrintItem;
		private var _preview:Sprite;
		private var _page:Sprite;
		private var _printButton:StoreNavBar;
		private var _itemId:uint;
		private var _buttonX:uint;
		private var _buttonY:uint;
		
		public function PrintPreviewContainer(itemId:uint,buttonX:uint,buttonY:uint)
		{
			super();
			
			_itemId = itemId;
			_buttonX = buttonX;
			_buttonY = buttonY;
			
			var tempClass:Class = PrintItemMapping.getItemFromItemId(_itemId.toString());
			_printItem = new tempClass() as IPrintItem;
			_printItem.addEventListener(PrintShopEvent.PREVIEW_COMPLETE,onPreviewComplete);
			_printItem.addEventListener(PrintShopEvent.PAGE_COMPLETE,onPageComplete);
			
			generatePrintButton();
		}
		
		private function generatePrintButton():void
		{
			//create button
			_printButton = new StoreNavBar(170, 28, "PRINT");
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
			_printButton.addEventListener(MouseEvent.CLICK,onPrintClick);
			
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
		
		private function onPreviewComplete(e:PrintShopEvent):void
		{
			_preview = _printItem.getPrintPreview();
			this.addChild(_preview);
			_preview.x = 0;
			_preview.y = 0;
		}
		
		private function onPageComplete(e:PrintShopEvent):void
		{
			_page = _printItem.getPrintPage();
		}
		
		/*
		private function generatePrintPreview():void
		{
			_preview = MyCardFrontPrintItem.getPrintPreview();
			//_preview = MyCardBackPrintItem.getPrintPreview();
			//_preview = FoldableMyCardPrintItem.getPrintPreview();
			
			_preview.addEventListener(Event.COMPLETE,onPreviewComplete)
			
			generatePrintButton();
			
			function onPreviewComplete(e:Event):void
			{
				this.addChild(_preview);
				_preview.x = 0;
				_preview.y = 0;
			}
		}
		*/
		
		private function onPrintClick(e:MouseEvent):void
		{
			this.giveFirstPrintJobBadge();
			LoggingUtil.sendClickLogging(_printItem.getLoggingId());
			
			if (_page)
				PrintUtil.print(_page);
		}
		
	}
}