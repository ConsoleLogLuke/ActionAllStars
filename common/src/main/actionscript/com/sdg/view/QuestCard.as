package com.sdg.view
{
	import com.sdg.events.QuestCardEvent;
	import com.sdg.model.Achievement;
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class QuestCard extends FluidView
	{
		protected var _quest:Achievement;
		protected var _card:Sprite;
		protected var _back:Sprite;
		protected var _txt:TextField;
		protected var _cardComplete:Boolean;
		protected var _loadedCard:EventDispatcher;
		protected var _loadIndicator:SpinningLoadingIndicator;
		
		protected var _isInit:Boolean;
		
		public function QuestCard(quest:Achievement, width:Number = 925, height:Number = 665)
		{
			_isInit = false;
			_quest = quest;
			
			_card = new Sprite();
			
			_back = new Sprite();
			
			_txt = new TextField();
			_txt.defaultTextFormat = new TextFormat('Arial', 12, 0xffffff, true);
			_txt.autoSize = TextFieldAutoSize.LEFT;
			_txt.selectable = false;
			_txt.text = "Loading";
			
			_loadIndicator = new SpinningLoadingIndicator();
			var indScale:Number = (20 / _loadIndicator.width);
			_loadIndicator.width *= indScale;
			_loadIndicator.height *= indScale;
			
			super(width, height);
			
			render();
			
			addChild(_back);
			addChild(_txt);
			addChild(_loadIndicator);
			addChild(_card);
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		public function init():void
		{
			// Make sure we only init once.
			if (_isInit == true) return;
			_isInit = true;
			
			// Load card image.
			var imgCmp:Boolean = false;
			var imgUrl:String = AssetUtil.GetQuestCardAsset(_quest.id);
			var img:Sprite = new QuickLoader(imgUrl, onImageComplete, onImageComplete, 2);
			
			// Load card asset.
			var cardMaxTry:uint = 3;
			var cardTries:uint = 1;
			var cardObj:Object;
			var card:DisplayObject;
			var url:String = AssetUtil.GetGameAssetUrl(75, 'quest_card.swf');
			var cardReq:URLRequest = new URLRequest(url);
			var cardLoader:Loader = new Loader();
			cardLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCardComplete);
			cardLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onCardError);
			cardLoader.load(cardReq);
			
			function onCardComplete(e:Event):void
			{
				// Remove listeners.
				cardLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCardComplete);
				cardLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onCardError);
				
				// Get abstarct reference.
				card = cardLoader.content;
				cardObj = Object(card);
				
				checkComplete();
			}
			
			function onCardError(e:Event):void
			{
				if (cardTries < cardMaxTry)
				{
					// Try again.
					cardTries++;
					cardLoader.load(cardReq);
				}
				else
				{
					// Remove listeners.
					cardLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCardComplete);
					cardLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onCardError);
				}
			}
			
			function onImageComplete():void
			{
				imgCmp = true;
				
				checkComplete();
			}
			
			function checkComplete():void
			{
				// Check if the card and image are loaded.
				if (cardObj != null && imgCmp)
				{
					trace('QUEST CARD COMPLETE. ' + cardTries.toString() + ' TRIES.');
					
					// Set params on the card.
					cardObj.description = _quest.description;
					cardObj.image = img;
					
					// Add card listeners.
					card.addEventListener('accept quest', onAcceptQuest);
					
					// Add to display.
					_card.addChild(card);
					
					// Set flag.
					_loadedCard = card;
					_cardComplete = true;
					
					// Hide the text and load indicator.
					_loadIndicator.visible = false;
					_txt.visible = false;
					
					render();
					
					// Dispatch complete.
					dispatchEvent(new Event(Event.COMPLETE));
				}
			}
		}
		
		public function destroy():void
		{
			// Handle cleanup.
			if (_cardComplete == true) _loadedCard.removeEventListener('accept quest', onAcceptQuest);
			
			removeChild(_back);
			removeChild(_txt);
			removeChild(_card);
			
			_back = null;
			_txt = null;
			_card = null;
			_loadedCard = null;
			
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			_back.graphics.clear();
			_back.graphics.beginFill(0x000000, 0.8);
			_back.graphics.drawRect(0, 0, _width, _height);
			
			_txt.x = _width / 2 - _txt.width / 2;
			_txt.y = _height / 2 - _txt.height / 2;
			
			_card.x = _width / 2 - _card.width / 2;
			_card.y = _height / 2 - _card.height / 2;
			
			_loadIndicator.x = _txt.x + _txt.width + 10;
			_loadIndicator.y = _height / 2 - _loadIndicator.height / 2;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onAcceptQuest(e:Event):void
		{
			// Dispatch quest card event.
			var event:QuestCardEvent = new QuestCardEvent(QuestCardEvent.OK, _quest);
			dispatchEvent(event);
		}
		
	}
}