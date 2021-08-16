package com.sdg.display.gamelaunch
{
	import com.sdg.control.room.RoomManager;
	import com.sdg.core.IProgressInfo;
	import com.sdg.display.IRoomItemDisplay;
	import com.sdg.display.RoomItemDisplayBase;
	import com.sdg.game.counter.GamePlayCounter;
	import com.sdg.model.MembershipStatus;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.SdgItem;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	public class GameLaunchPointDisplay extends RoomItemDisplayBase implements IRoomItemDisplay
	{
		private var _icon:DisplayObject;
		
		public function GameLaunchPointDisplay(item:SdgItem)
		{
			super(item);
			
			// Get game id.
			var gameId:int = int(item.attributes['gameId']);
			// Determine if there is a "levelRequirement" attribute.
			// This implies an MVP only game.
			var levelRequirement:int = int(item.attributes['levelRequirement']);
			// This makes a game free to play as many times as you want
			var noLimit:Boolean = false;
			// Game Icon Exceptions
			noLimit = !RoomManager.isGameWithGamePlayLimit(gameId);
			// Determine if local avatar is MVP.
			var isMvp:Boolean = ModelLocator.getInstance().avatar.membershipStatus == MembershipStatus.PREMIUM;
			// Determine how many times the local avatar has played this game today.
			var gamePlayCount:int = GamePlayCounter.getPlayCount(gameId);
			
			var hitRectBounds:String = String(item.attributes['hitBoxSize']);
			
			// Show a specific play icon based scenario.
			if (noLimit)
			{
				// this game can be played as much as possible
				_icon = new GameLaunchNormal();
			}
			else if (levelRequirement > 0)
			{
				// Any level requirement at all, implies that the game is MVP only.
				_icon = new GameLaunchMVP();
			}
			else if (isMvp && gamePlayCount < 1)
			{
				// The user is MVP and has not played this game today.
				_icon = new GameLaunchBonus();
			}
			else if (isMvp)
			{
				// The user is MVP but has already played this game today.
				_icon = new GameLaunchNormal();
			}
			else if (gamePlayCount < GamePlayCounter.MAX_FREE_PLAYS_PER_DAY)
			{
				// This user is NOT MVP but has played less than the alloted amount today.
				_icon = new GameLaunchNormal();
			}
			else
			{
				// The user is NOT MVP and has played as much as they are allowed today.
				_icon = new GameLaunchLimited();
			}
			
			// increases the hit space of the icon
			if(hitRectBounds != null)
			{
				var bounds:Array = hitRectBounds.split("|");
				if(bounds.length >= 4)
				{
					var sBounds:Sprite = new Sprite();
					this.useHandCursor = true;
					this.buttonMode = true;
					sBounds.graphics.beginFill(0,0);
					sBounds.graphics.drawRect(bounds[0],bounds[1],bounds[2],bounds[3]);
					sBounds.graphics.endFill();
					addChild(sBounds);
				}
				else
				{
					trace("Bounds should be x,y,width,height");
				}
			}
			
			// Add icon to display.
			addChild(_icon);
		}
		
		////////////////////
		// PUBLIC FUNCTIONS
		////////////////////
		
		override public function destroy():void
		{
			// Remove icon from display.
			if (_icon) removeChild(_icon);
			_icon = null;
			
			super.destroy();
		}
		
		public function getImageRect(update:Boolean = false):Rectangle
		{
			return getRect(this);
		}
		
		public function playAnimation(name:String):void
		{
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get orientation():uint
		{
			return 0;
		}
		public function set orientation(value:uint):void
		{
			
		}
		
		public function get progressInfo():IProgressInfo
		{
			return null;
		}
		
		public function get content():DisplayObject
		{
			return this;
		}
		
		public function set floorMarker(value:DisplayObject):void
		{
			
		}
		
	}
}