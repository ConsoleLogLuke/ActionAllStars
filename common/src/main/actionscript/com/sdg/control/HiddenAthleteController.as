package com.sdg.control
{
	import com.sdg.components.dialog.GiftedCardDialog;
	import com.sdg.components.dialog.ISdgDialog;
	import com.sdg.model.ModelLocator;
	import com.sdg.net.Environment;
	import com.sdg.utils.MainUtil;
	import com.sdg.view.IRoomView;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.managers.PopUpManager;
	
	public class HiddenAthleteController extends CairngormEventController implements IDynamicController
	{
		private var _roomContainer:IRoomView;
		private var _background:Object;
		private var _hiddenAthlete:MovieClip;
		private var _usrHasCard:Boolean;
		private var _usrAvatarID:uint;
		private var _avatarStatNameID:int;
		private var _cardDefinitionID:int;
		private var _playerName:String;
		private var _dontHaveCardMessage:String;
		
		private const _haveCardMessage:String = 'Oops, this card is already in your album.';
		private const _dontHaveCardTitle:String = 'Congratulations!';
		private const _haveCardTitle:String = 'You found him again!';
		
		public function HiddenAthleteController(roomContainer:IRoomView, data:Object)
		{
			super();
			
			_roomContainer = roomContainer;
			_background = data.background;
			_hiddenAthlete = data.hiddenAthlete;
			_usrAvatarID = ModelLocator.getInstance().user.avatarId;
			_avatarStatNameID = 8;
			_cardDefinitionID = (data.cardID) ? data.cardID : 2;
			_playerName = (data.playerName) ? data.playerName : 'Hidden Athlete';
			_dontHaveCardMessage = (data.customMessage) ? data.customMessage : 'Nice work! The limited-edition ' + _playerName + ' 2009 NBA All-Star card has been added to your Card Album.';
			
			// Listen for mouse clicks on the hidden athlete.
			_hiddenAthlete.addEventListener(MouseEvent.CLICK, _athleteMouseClick);
			// The mouse should turn to a finger on mouse over.
			_hiddenAthlete.buttonMode = true;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function init():void
		{
			
		}
		
		public function destroy():void
		{
			// Remove event listeners.
			_hiddenAthlete.removeEventListener(MouseEvent.CLICK, _athleteMouseClick);
		}
		
		private function _giveUserCard():void
		{
			var urlReq:URLRequest = new URLRequest(Environment.getApplicationUrl() + '/test/saveCard?avatarId=' + _usrAvatarID + '&avatarStatNameId=' + _avatarStatNameID + '&statValue=' + _cardDefinitionID);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, saveCardQueryComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, saveCardIOError);
			urlLoader.load(urlReq);
			
			trace('Saving player trading card.');
			
			function saveCardQueryComplete(e:Event):void
			{
				// Remove listeners.
				urlLoader.removeEventListener(Event.COMPLETE, saveCardQueryComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, saveCardIOError);
				
				var data:String = urlLoader.data;
				var xml:XML = new XML(data);
				var status:String = xml.@status;
				if (status == '0')
				{
					// The card was not saved for the user.
				}
				else if (status == '1')
				{
					// The card was successfully saved for the user.
					_showNewCardDialog();
				}
				else
				{
					// Unknown response.
					status = undefined;
				}
				
				trace('Save card response: ' + status);
			}
			
			function saveCardIOError(e:IOErrorEvent):void
			{
				// Remove listeners.
				urlLoader.removeEventListener(Event.COMPLETE, saveCardQueryComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, saveCardIOError);
				
				// Handle an IO Error.
				trace('HiddenAthleteController: Unable to save trading card (' + _cardDefinitionID + ') for user (' + _usrAvatarID + ').');
			}
		}
		
		private function _showNewCardDialog():void
		{
			// Show a gifted card dialog.
			var params:Object = new Object();
			params.alreadyHasCard = _usrHasCard;
			params.cardID = _cardDefinitionID;
			params.playerName = _playerName;
			params.messageText = (_usrHasCard == true) ? _haveCardMessage : _dontHaveCardMessage;
			params.titleText = (_usrHasCard == true) ? _haveCardTitle : _dontHaveCardTitle;
			MainUtil.showDialog(GiftedCardDialog, params, true);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function _athleteMouseClick(e:MouseEvent):void
		{
			trace('Clicked hidden athlete.');
			
			// determine whether or not this user avatar already has a trading card for this athlete
			///test/queryCard?avatarId=<avatarId>&avatarStatNameId=<AvatarStatNameId>&statValue=<TradingCardDefinitionId>
			var urlReq:URLRequest = new URLRequest(Environment.getApplicationUrl() + '/test/queryCard?avatarId=' + _usrAvatarID + '&avatarStatNameId=' + _avatarStatNameID + '&statValue=' + _cardDefinitionID);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, usrHasCardQuryComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, usrHasCardIOError);
			urlLoader.load(urlReq);
			
			trace('Checking if avatar has this player trading card.');
			
			function usrHasCardQuryComplete(e:Event):void
			{
				// Remove listeners from the loader object.
				urlLoader.removeEventListener(Event.COMPLETE, usrHasCardQuryComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, usrHasCardIOError);
				
				var data:String = urlLoader.data;
				var xml:XML = new XML(data);
				var status:String = xml.@status;
				if (status == '0')
				{
					// User does not have card.
					_usrHasCard = false;
					_giveUserCard();
				}
				else if (status == '1')
				{
					// User already has the card.
					_usrHasCard = true;
					_showNewCardDialog();
				}
				else
				{
					// Unknown response.
					status = undefined;
				}
				
				trace('If avatar has player card response: ' + status);
			}
			
			function usrHasCardIOError(e:IOErrorEvent):void
			{
				// Remove listeners from the loader object.
				urlLoader.removeEventListener(Event.COMPLETE, usrHasCardQuryComplete);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, usrHasCardIOError);
				
				// Handle an IO Error while determining if the user has a particular trading card.
				trace('HiddenAthleteController: Unable to determine if user (' + _usrAvatarID + ') has trading card (' + _cardDefinitionID + ').');
			}
		}
		
	}
}