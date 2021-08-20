package com.sdg.display
{
	import com.sdg.components.controls.BurstIcon;
	import com.sdg.control.room.RoomManager;
	import com.sdg.events.RoomManagerEvent;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.Reward;
	import com.sdg.model.SdgItem;
	import com.sdg.net.Environment;
	import com.sdg.net.RemoteSoundBank;
	import com.sdg.utils.Constants;
	import com.sdg.utils.MathUtil;

	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Timer;

	public class RewardEffect extends EventDispatcher
	{
		//private static const CURRENCY_EFFECT_URL:String = "swfs/rewardEffect.swf";
		//private static const POINTS_EFFECT_URL:String = "swfs/rewardEffect.swf";
		private static const LEVEL_EFFECT_URLS:Object =
		{
			1:"swfs/amateurEffect.swf",
			2:"swfs/rookieEffect.swf",
			3:"swfs/proEffect.swf",
			4:"swfs/veteranEffect.swf",
			5:"swfs/allstarEffect.swf"
		}

		private var _awaitingResponse:int;
		private var _rewardItem:SdgItem;
		private var _burstArray:Array;
		private var _burstTimer:Timer;
		private var _remoteSoundBank:RemoteSoundBank;
		private var _rewardDisplay:Sprite;

		public function RewardEffect(rewards:Array, rewardItem:SdgItem)
		{
			_remoteSoundBank = new RemoteSoundBank();
			_rewardItem = rewardItem;

			var sublevelEffectArray:Array = new Array();
			var levelEffectArray:Array = new Array();
			var burstEffectArray:Array = new Array();

			var rewardTypeId:int;
			var reward:Reward;
			for each (reward in rewards)
			{
				// Show a type of reqrd effect based on the type of reward.
				rewardTypeId = reward.rewardTypeId;
				if (rewardTypeId == Reward.LEVEL_UP)
					levelEffectArray.push(reward);
				else if (rewardTypeId == Reward.SUBLEVEL_UP)
					sublevelEffectArray.push(reward);
				else if (rewardTypeId == Reward.CURRENCY || rewardTypeId == Reward.EXPERIENCE)
					burstEffectArray.push(reward);
			}

			showLevelEffect(levelEffectArray);
			showSublevelEffect(sublevelEffectArray);
			showBurstEffect(burstEffectArray);
		}

		private function checkFinish():void
		{
			if (_awaitingResponse == 0)
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}

		private function removeFromAwaiting():void
		{
			_awaitingResponse--;

			checkFinish();
		}

		private function addBurst(burst:BurstIcon):void
		{
			if (_burstArray == null) _burstArray = new Array();

			//var renderLayer:RenderLayer = RoomManager.getInstance().roomContext.roomView.getRenderLayer(RoomLayerType.FOREGROUND);
			var avatarSprite:IRoomItemDisplay = RoomManager.getInstance().userController.display;
			burst.x = avatarSprite.x + MathUtil.random(-40, 150);
			burst.y = avatarSprite.y + MathUtil.random(100, 130);
			burst.addEventListener(MouseEvent.CLICK, onBurstClick);

			_burstArray.push(burst);
			_awaitingResponse++;
			//renderLayer.addItem(new RenderObject(new RenderData(child)));
			RoomManager.getInstance().roomContext.roomView.uiLayer.addChild(burst);
		}

		private function onBurstClick(event:MouseEvent):void
		{
			collectBurst(event.currentTarget as BurstIcon);
		}

		private function collectBurst(burst:BurstIcon):void
		{
			burst.removeEventListener(MouseEvent.CLICK, onBurstClick);
			_remoteSoundBank.playSound(Environment.getAssetUrl() + Constants.SFX_URL + 103);
			burst.collect();
			var value:int = burst.value;

			if (burst.burstType == Reward.CURRENCY)
			{
				//avatar.currencyToShow += burst.value;
				var ticker:Timer = new Timer(.1, value);
				ticker.addEventListener(TimerEvent.TIMER, onTicker);
				ticker.addEventListener(TimerEvent.TIMER_COMPLETE, onTickerComplete);
				ticker.start();
			}
			else if (burst.burstType == Reward.EXPERIENCE)
			{
				ModelLocator.getInstance().avatar.pointsToShow += burst.value;
				removeFromAwaiting();
			}

			burst.addEventListener(Event.COMPLETE, onBurstComplete);
		}

		private function onTicker(event:TimerEvent):void
		{
			ModelLocator.getInstance().avatar.currencyToShow++;
		}

		private function onTickerComplete(event:TimerEvent):void
		{
			var ticker:Timer = event.currentTarget as Timer;
			ticker.stop();
			ticker.removeEventListener(TimerEvent.TIMER, onTicker);
			ticker.removeEventListener(TimerEvent.TIMER_COMPLETE, onTickerComplete);
			removeFromAwaiting();
		}

		private function onBurstComplete(event:Event):void
		{
			var burst:BurstIcon = event.currentTarget as BurstIcon;
			burst.removeEventListener(Event.COMPLETE, onBurstComplete);
			RoomManager.getInstance().roomContext.roomView.uiLayer.removeChild(burst);

			var i:int;
			for (i = _burstArray.length - 1; i >= 0; i--)
			{
				if (_burstArray[i] == burst)
				{
					_burstArray.splice(i, 1);
				}
			}

			if (_burstArray.length == 0)
			{
				_burstTimer.stop();
				_burstTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			}
		}

		private function onTimerComplete(event:TimerEvent):void
		{
			removeBurst();
		}

		private function removeBurst():void
		{
			var burst:BurstIcon;
			for each (burst in _burstArray)
			{
				collectBurst(burst);
			}
		}

		private function onEnterRoomStart(event:RoomManagerEvent):void
		{
			RoomManager.getInstance().removeEventListener(RoomManagerEvent.ENTER_ROOM_START, onEnterRoomStart);
			removeBurst();
		}

		private function showBurstEffect(rewards:Array):void
		{
			if (rewards.length == 0) return;

			var rewardsString:String;
			var reward:Reward;

			_burstTimer = new Timer(15000, 1);
			_burstTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			RoomManager.getInstance().addEventListener(RoomManagerEvent.ENTER_ROOM_START, onEnterRoomStart, false, 0, true);

			for each (reward in rewards)
			{
				var className:Class;
				if (reward.rewardTypeId == Reward.CURRENCY)
					className = BurstToken;
				else if (reward.rewardTypeId == Reward.EXPERIENCE)
					className = BurstPoint;

				if (className != null)
				{
					var rewardValue:int = reward.rewardValue;
					var numBurst:int = int(String(rewardValue).charAt(0));
					var iconValue:int = Math.floor(rewardValue / numBurst);
					var j:int;

					for (j = 0; j < numBurst; j++)
					{
						if (j == numBurst - 1)
							iconValue += rewardValue % numBurst;

						var burstIcon:BurstIcon = new BurstIcon(className, iconValue);
						addBurst(burstIcon);
					}
				}

				if (rewardsString == null)
					rewardsString = "";
				else
					rewardsString += "~";

				rewardsString += reward.rewardTypeId + "," + reward.rewardValue;
			}

			RoomManager.getInstance().sendItemAction(_rewardItem, "showBurstOverhead", {rewardsString:rewardsString});
			_burstTimer.start();
		}

		private function showSublevelEffect(rewards:Array):void
		{
			var reward:Reward;

			for each (reward in rewards)
			{
				RoomManager.getInstance().sendItemAction(_rewardItem, "showSublevelUp", {newLevel:reward.rewardValueTotal});
			}
		}

		private function showLevelEffect(rewards:Array):void
		{
			var reward:Reward;

			for each (reward in rewards)
			{
				loadEffect(LEVEL_EFFECT_URLS[reward.rewardValueTotal]);
			}
		}

		private function loadEffect(url:String):void
		{
			if (_rewardDisplay == null) _rewardDisplay = new Sprite();

			var loader:Loader = new Loader();
			var contentLoaderInfo:LoaderInfo = loader.contentLoaderInfo;
			contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);

			var context:LoaderContext = new LoaderContext(false, new ApplicationDomain());

			loader.load(new URLRequest(url), context);

			_awaitingResponse++;
		}

		private	function loadCompleteHandler(event:Event):void
		{
			var contentLoaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			contentLoaderInfo.removeEventListener(Event.COMPLETE, loadCompleteHandler);

			var display:DisplayObject = contentLoaderInfo.content;
			_rewardDisplay.addChild(display);
			display.addEventListener(Event.COMPLETE, effectCompleteHandler);
		}

		private function effectCompleteHandler(event:Event):void
		{
			var display:DisplayObject = event.currentTarget as DisplayObject;
			display.removeEventListener(Event.COMPLETE, effectCompleteHandler);

			var loaderInfo:LoaderInfo = display.loaderInfo;
			removeFromAwaiting();
		}

		public function get rewardDisplay():DisplayObject
		{
			return _rewardDisplay;
		}

		public function get hasPendingEffect():Boolean
		{
			return _awaitingResponse > 0;
		}
	}
}
