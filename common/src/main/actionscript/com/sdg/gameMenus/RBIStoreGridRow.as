package com.sdg.gameMenus
{
	import com.sdg.buttonstyle.ButtonSyle;
	import com.sdg.buttonstyle.IButtonStyle;
	import com.sdg.controls.BasicButton;
	import com.sdg.display.BoxStyle;
	import com.sdg.display.GradientFillStyle;
	import com.sdg.events.GameItemPurchaseEvent;
	import com.sdg.util.AssetUtil;
	
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	public class RBIStoreGridRow extends GreyedOutGridRow
	{
		protected var _buyButton:BasicButton;
		protected var _storeItem:RBITeamItem;
		
		public function RBIStoreGridRow(storeItem:RBITeamItem,
										teamIconWidth:Number,
										teamNameWidth:Number,
										recordWidth:Number,
										offensiveWidth:Number,
										pitchingWidth:Number,
										tokensWidth:Number,
										buyWidth:Number)
		{
			super("OWNED");
			
			_storeItem = storeItem;
			addConstantField(new LoaderGridField(teamIconWidth, 52, AssetUtil.GetTeamLogoUrl(_storeItem.teamId)));
			addConstantField(new TextGridField(teamNameWidth, 52, _storeItem.name.toString(), 16, false, 15));
			
			addField(new TextGridField(recordWidth, 52, _storeItem.wins + " - " + _storeItem.losses));
			addField(new GridField(offensiveWidth, 52, new RankStars(_storeItem.offensiveRank, 14, 12, 5, 0xDC911F)));
			addField(new GridField(pitchingWidth, 52, new RankStars(_storeItem.pitchingRank, 14, 12, 5, 0xDC911F)));
			addField(new TextGridField(tokensWidth, 52, _storeItem.tokens.toString()));
			
			var offStyle:BoxStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0xf8db5c, 0xd28602], [1, 1], [1, 255], Math.PI / 2), 0x913300, 1, 1, 8);
			var overStyle:BoxStyle = new BoxStyle(new GradientFillStyle(GradientType.LINEAR, [0xd18500, 0xa54c0a], [1, 1], [1, 255], Math.PI / 2), 0x913300, 1, 1, 8);
			var bStyle:IButtonStyle = new ButtonSyle(offStyle, overStyle, overStyle);
			
			_buyButton = new BasicButton('BUY', 60, 20, bStyle);
			_buyButton.labelFormat = new TextFormat('EuroStyle', 15, 0x913300, true);
			_buyButton.embedFonts = true;
			_buyButton.addEventListener(MouseEvent.CLICK, onBuyClick);
			addField(new GridField(buyWidth, 52, _buyButton));
			
			_storeItem.addEventListener("ownedChanged", onOwnedChanged);
			
			greyedOut = _storeItem.owned;
		}
		
		protected function onOwnedChanged(event:Event):void
		{
			greyedOut = _storeItem.owned;
		}
		
		protected function onBuyClick(event:MouseEvent):void
		{
			trace(_storeItem.name);
			dispatchEvent(new GameItemPurchaseEvent(_storeItem, true));
		}
		
		public function destroy():void
		{
			_buyButton.removeEventListener(MouseEvent.CLICK, onBuyClick);
			_storeItem.removeEventListener("ownedChanged", onOwnedChanged);
		}
	}
}