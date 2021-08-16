package com.sdg.control.room.itemClasses
{	
	import com.adobe.utils.StringUtil;
	import com.sdg.display.RoomItemSprite;
	import com.sdg.events.SimEvent;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.SdgItem;
	import com.sdg.net.Environment;
	import com.sdg.net.QuickLoader;
	import com.sdg.sim.core.SimEntity;
	import com.sdg.utils.Constants;
	import com.sdg.utils.ObjectUtil;
	import com.sdg.view.chat.ChatBubbleAnimated;
	import com.sdg.view.emote.EmoteAnimated;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	public class Character extends RoomItemController
	{
		public static const WALK_START:String = 'walk start';
		public static const ANIMATION_START:String = 'anim start';
		public static const DEFAULT_PATH_COMPLETE_ANIM:String = 'rest';
		
		private static var _chatBubbleFills:Array;
		private static var _chatBubbleStrokes:Array;
		
		protected var _walkSpeedMultiplier:Number = 1;
		protected var _pathCompleteAnim:String;
		
		private var _horizontalScreenWalkDirection:int;
		private var _verticalScreenWalkDirection:int;
		private var _lastUsedChatBubbleColorIndex:uint;
		private var _lastWalkCoordinate:Point;
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		override public function initialize(item:SdgItem):void
		{
			super.initialize(item);
			
			// This is the animation that will be triggered when the character finishes a walk path.
			// Default to rest.
			_pathCompleteAnim = DEFAULT_PATH_COMPLETE_ANIM;
			
			if (entity != null)
			{
				entity.setNumOrientations(8);
				entity.solidity = 2;
				entity.addEventListener(SimEvent.MOTION_DISABLED, motionDisabledHandler);
			}
			
			setActionListener("animate", animateActionHandler);
			setActionListener("chat", chatActionHandler);
			setActionListener("walk", walkActionHandler);
			setActionListener("stopwalking", stopWalkingActionHandler);
			setActionListener("showOverheadMessage", showOverheadMessageHandler);
			setActionListener("showDualOverheadMessage", showDualOverheadMessageHandler);
			setActionListener("showBurstOverhead", showBurstOverheadHandler);
			setActionListener("showSublevelUp", showSublevelUpHandler);
		}
		
		override public function destroy():void
		{
			removeActionListener("animate");
			removeActionListener("chat");
			removeActionListener("walk");
			removeActionListener("stopwalking");
			removeActionListener("showOverheadMessage");
			removeActionListener("showDualOverheadMessage");
			removeActionListener("showBurstOverhead");
			removeActionListener("showSublevelUp");
			
			// Remove entity listeners.
			if (entity != null) entity.removeEventListener(SimEvent.MOTION_DISABLED, motionDisabledHandler);
				
			super.destroy();
		}
		
		public function showOverheadMessage(message:String, strokeColor:uint = 0x003399):void
		{
			commitAction("showOverheadMessage", {message:message, strokeColor:strokeColor});
		}
		
		public function stopWalking():void
		{
			commitAction("stopwalking", null);
		}
		
		public function animate(animationName:String):void
		
		{
			// Here, we used to check entity.motionEnabled and make sure it was false before proceeding with the animation.
			// I assume this was to make sure that the character was not already moving, before commiting an animation.
			// I want to have alternative animations (opposed to walking) playing while the character is moving across the room.
			commitAction("animate", { animationName:animationName });
		}
		
		public function chat(text:String):void
		{
			commitAction("chat", { text:text });
		}
		
		public function emote(emoteName:String, failOverEmote:String = null, useBubble:Boolean = true, width:Number = 35, height:Number = 36, applyFiters:Boolean = true, paramsToSwf:Object = null, makePersistentBoolean:Boolean = false):void
		{
			var params:Object = new Object();
			
			params.text = '/emote ' + emoteName;
			params.useBubble = useBubble;
			params.width = width;
			params.height = height;
			params.applyFilters = applyFiters;
			params.makePersistent = (makePersistentBoolean == true) ? 1 : 0;
			
			if (failOverEmote != null) 
				params.text += ' ' + failOverEmote;
				
			// params for the emote swf?
			if (paramsToSwf)
				params.paramsToSwf = ObjectUtil.toXMLString(paramsToSwf, "paramsToSwf");
				
			commitAction('chat', params);
		}
		
		public function walk(x:int, y:int):void
		{
			if (entity.findPath(x, y))
			{
				_lastWalkCoordinate = new Point(x, y);
				commitAction("walk", { x:x, y:y, walkSpeed:Constants.DEFAULT_WALK_SPEED * _walkSpeedMultiplier }, { x:x, y:y });
			}
		}
		
		public function showOverheadAsset(asset:DisplayObject, duration:int, centerOnLeft:Boolean = true, space:Number = 0):void
		{
			var imgRect:Rectangle = display.getImageRect();
			asset.x = (centerOnLeft) ? imgRect.x + imgRect.width / 2 - asset.width / 2 : imgRect.x + imgRect.width / 2;
			asset.y = imgRect.y - asset.y - space;
			display.addChild(asset);
			
			var timer:Timer = new Timer(duration);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			
			function onTimer(e:TimerEvent):void
			{
				// Hide asset.
				timer.removeEventListener(TimerEvent.TIMER, onTimer);
				timer.reset();
				timer = null;
				
				if (display) display.removeChild(asset);
				asset = null;
			}
		}
		
		////////////////////
		// PROTECTED FUNCTIONS
		////////////////////
		
		override protected function entityValidatedHandler(event:SimEvent):void
		{
			var flags:int = entity.stateFlags;
			
			// If the character is facing straight up or straight down OR directly left/right, determine a proper orientation
			// based on the instance vars "_horizontalScreenWalkDirection" and "_verticalScreenWalkDirection".
			// This will force up/down/left/right orientations into one of the 4 directions used for "optimized sprite sheets". (0, 90, 180, 270)
			var orientation:int = _entity.orientation;
			switch (orientation)
			{
				case (315):
					// If orientation is straight DOWN, relative to the screen.
					orientation = (_horizontalScreenWalkDirection < 0) ? 270 : 0;
					break;
				case (135):
					// If orientation is straight UP, relative to the screen.
					orientation = (_horizontalScreenWalkDirection < 0) ? 180 : 90;
					break;
				case (225):
					// If orientation is sdirectly LEFT, relative to the screen.
					orientation = (_verticalScreenWalkDirection < 0) ? 180 : 270;
					break;
				case (45):
					// If orientation is sdirectly RIGHT, relative to the screen.
					orientation = (_verticalScreenWalkDirection < 0) ? 90 : 0;
					break;
			}
			
			if (flags & SimEntity.ROTATED_FLAG)
			{
				_item.orientation = orientation;
				_display.orientation = orientation;
			}
			
			if (flags & SimEntity.MOVED_FLAG)
			{
				_item.x = _entity.col;
				_item.y = _entity.row;
			}
		}
		
		////////////////////
		// PRIVATE FUNCTIONS
		////////////////////
		
		private function handleEncodedEmote(params:Object):void
		{
			// Split the string into an array.
			var text:String = params.text;
			var strs:Array = text.split(" ");
			var len:int = strs.length;
			if (len < 2) return;
			
			// Validate some params about the type of emote to show.
			var defaultSize:Number = 35;
			var useBubble:Boolean = (params.useBubble != null && params.useBubble == false) ? false : true;
			var applyFilters:Boolean = (params.applyFilters != null && params.applyFilters == false) ? false : true;
			var makePersistent:Boolean = (params.makePersistent != null && params.makePersistent == 1) ? true : false;
			var width:Number = (params.width) ? params.width : defaultSize;
			var height:Number = (params.height) ? params.height : defaultSize;
	
			// Show emoticon using name.
			var emoteName:String = strs[1];
			if (StringUtil.beginsWith(emoteName, "http")) emoteName = emoteName.replace(Environment.DOMAIN_REGEX, Environment.getApplicationUrl());
			var failOverEmote:String = (len > 2) ? strs[2] : '';
			if (StringUtil.beginsWith(failOverEmote, "http")) failOverEmote = failOverEmote.replace(Environment.DOMAIN_REGEX, Environment.getApplicationUrl());
			var paramsToSwf:Object = XMLList(params.paramsToSwf).children().length() == 0 ? null : XML(params.paramsToSwf.paramsToSwf);
			
			// Load the emote display.
			trace('Loading emote: ' + emoteName);
			var emoteDisplay:QuickLoader = new QuickLoader(emoteName, onEmoteLoaded, onEmoteNotLoaded);
			var emote:EmoteAnimated;
			
			function onEmoteNotLoaded():void
			{
				trace('Failed to load emote: ' + emoteName);
				emoteDisplay = null;
			}
			
			function onEmoteLoaded():void
			{
				if(display != null)
				{
					trace('Emote loaded: ' + emoteName);
					// Create an animated emote, using the loaded emote display.
					emote = new EmoteAnimated(emoteDisplay, 60, 60, 6000);
					// Listen for when the emote finishes, so we can remove it.
					emote.addEventListener(EmoteAnimated.HIDE_FINISH, onEmoteHideFinish);
					emote.mouseChildren = emote.mouseEnabled = false;
					var disRect:Rectangle = display.getImageRect();
					emote.x = disRect.x + disRect.width / 2 - 3;
					emote.y = disRect.y - 5;
					display.addChild(emote);
					
					try
					{
						if (paramsToSwf)
						{
							var swfObj:Object = emoteDisplay.content;
							swfObj.params = paramsToSwf;
						}
					
					}
					catch(e:Error)
					{
						trace(e.getStackTrace());
					}
				}
				emoteDisplay = null;
			}
			
			function onEmoteHideFinish(e:Event):void
			{
				// Remove the emote and clean it up.
				emote.removeEventListener(EmoteAnimated.HIDE_FINISH, onEmoteHideFinish);
				if(display != null)
				{
					display.removeChild(emote);
				}
				emote.destroy();
				emote = null;
			}
		}
		
		private static function setupChatBubbleColors():void
		{
			// We only want this to happen once.
			if (_chatBubbleFills) return;
			
			// Define set of chat bubble colors.
			_chatBubbleFills = [];
			_chatBubbleFills.push(0xFF5B5B); // Red
			_chatBubbleFills.push(0xBD70F2); // Purple
			_chatBubbleFills.push(0x89FF85); // Green
			_chatBubbleFills.push(0x43EFFF); // Cyan
			_chatBubbleFills.push(0xFFE638); // Yellow
			_chatBubbleFills.push(0xFF8033); // Orange
			_chatBubbleStrokes = [];
			_chatBubbleStrokes.push(0x4D0000); // Red
			_chatBubbleStrokes.push(0x2E0740); // Purple
			_chatBubbleStrokes.push(0x1C410E); // Green
			_chatBubbleStrokes.push(0x00282F); // Cyan
			_chatBubbleStrokes.push(0x2F2400); // Yellow
			_chatBubbleStrokes.push(0x340F00); // Orange
		}
		
		private function getRandomChatBubbleColors(canUseSameConsecutive:Boolean = true):Array
		{
			// If "canUseSameConsecutive" is false, this function will make sure it does not return the same color set twice.
			
			// Make sure colors have been defined.
			setupChatBubbleColors();
			
			// Get random color set.
			var newIndex:int = _lastUsedChatBubbleColorIndex;
			do
			{
				newIndex = Math.round(Math.random() * (_chatBubbleFills.length - 1));
			}
			while (newIndex == _lastUsedChatBubbleColorIndex && !canUseSameConsecutive);
			
			var fill:uint = _chatBubbleFills[newIndex];
			var stroke:uint = _chatBubbleStrokes[newIndex];
			_lastUsedChatBubbleColorIndex = newIndex;
			
			return [fill, stroke];
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get behaviorRunning():Boolean
		{
			return entity.behaviorRunning;
		}
		
		public function set walkSpeedMultiplier(value:Number):void
		{
			_walkSpeedMultiplier = value;
		}
		
		public function get walkSpeedMultiplier():Number
		{
			return _walkSpeedMultiplier;
		}
		
		public function get pathCompleteAnimation():String
		{
			return _pathCompleteAnim;
		}
		public function set pathCompleteAnimation(value:String):void
		{
			_pathCompleteAnim = value;
		}
		
		public function get lastWalkCoordinate():Point
		{
			return _lastWalkCoordinate;
		}
		
		////////////////////
		// ACTION HANDLERS
		////////////////////
		
		protected function animateActionHandler(params:Object):void
		{
			// don't run if an animations is already running ('rest' and 'idle' animations are not considered animations here)
			// I'm trying to trigger alternative animations while the character is walking.
			// So I added "walk" to the list of animations that are not considered for denying a new animation.
			var characterDisplay:RoomItemSprite = display as RoomItemSprite;
			if (characterDisplay == null) return;
			if (characterDisplay.currentAnimation != null && 
				!StringUtil.beginsWith(characterDisplay.currentAnimation, "idle") && 
				!StringUtil.beginsWith(characterDisplay.currentAnimation, "rest") &&
			    !StringUtil.beginsWith(characterDisplay.currentAnimation, "walk"))
				return;
			
			// Here, we used to check entity.motionEnabled and make sure it was false before proceeding with the animation.
			// I assume this was to make sure that the character was not already moving, before commiting an animation.
			// I want to have alternative animations (opposed to walking) playing while the character is moving across the room.
			//display.orientation = 315;
			display.playAnimation(params.animationName);
			
			dispatchEvent(new Event(ANIMATION_START));
		}
		
		protected function chatActionHandler(params:Object):void
		{
			// is this avatar being ignored?
			var avatarController:AvatarController = this as AvatarController;
			if (avatarController != null && ModelLocator.getInstance().ignoredAvatars[avatarController.avatar.avatarId])
				return;

			var text:String = params.text;
			var chatBubble:ChatBubbleAnimated;
			
			// Define chat bubble colors.
			
			
			// Check if the chat action was an encoded emote.
			if (StringUtil.beginsWith(text, "/emote "))
			{
				// Handle an encoded emote.
				handleEncodedEmote(params);
			}
			else
			{
				// Show chat message.
				// Choose a random color.
				var randomColorSet:Array = getRandomChatBubbleColors(false);
				var fill:uint = randomColorSet[0];
				var stroke:uint = randomColorSet[1];
				chatBubble = new ChatBubbleAnimated(text, stroke, fill);
				// Listen for when the chat bubble finsihes, so we can remove it.
				chatBubble.addEventListener(ChatBubbleAnimated.HIDE_FINISH, onChatBubbleFinish);
				var rect:Rectangle = display.getImageRect();
				chatBubble.x = rect.x + rect.width / 2;
				chatBubble.y = rect.y - 5;
				display.addChild(chatBubble);
				chatBubble.show();
			}
			
			function onChatBubbleFinish(e:Event):void
			{
				// Remove the chat bubble and clean it up.
				chatBubble.removeEventListener(ChatBubbleAnimated.HIDE_FINISH, onChatBubbleFinish);
				if(display != null)
				{
					display.removeChild(chatBubble);
				}
				chatBubble.destroy();
				chatBubble = null;
			}
		}
		
		protected function walkActionHandler(params:Object):void
		{
			// Set walk speed.
			var walkSpeed:Number = params.walkSpeed;
			if (walkSpeed <= 0)
				walkSpeed = Constants.DEFAULT_WALK_SPEED;
			
			// Determine the horizontal and vertical direction that the character will be walking in.
			// Use it's current position and the destination to determine this.
			var destinationX:int = params.x;
			var destinationY:int = params.y;
			var currentX:int = _entity.x;
			var currentY:int = _entity.y;
			var xDis:int = destinationX - currentX;
			var yDis:int = destinationY - currentY;
			var horizontalScreenDir:int = xDis - yDis;
			var verticalScreenDir:int = xDis + yDis;
			_horizontalScreenWalkDirection = horizontalScreenDir;
			_verticalScreenWalkDirection = verticalScreenDir;
			
			// Have character entity follow path and if that is successful, play the walk animation.
			if (entity.followPath(destinationX, destinationY, walkSpeed))
			{
				display.playAnimation("walk");
				dispatchEvent(new Event(WALK_START));
			}
		}
		
		protected function stopWalkingActionHandler(params:Object):void
		{
			if (behaviorRunning)
				entity.stop();
		}
		
		protected function showSublevelUpHandler(params:Object):void
		{
			RoomItemSprite(display).showSublevelUp(params.newLevel);
		}
		
		protected function showBurstOverheadHandler(params:Object):void
		{
			var rewardsString:String = params.rewardsString;
			var rewardsArray:Array = rewardsString.split("~");
			RoomItemSprite(display).showBurstOverhead(rewardsArray);
		}
		
		protected function showOverheadMessageHandler(params:Object):void
		{
			// Show overhead message.
			RoomItemSprite(display).showOverheadMessage(params.message, params.strokeColor, params.sfxId);
		}
		
		protected function showDualOverheadMessageHandler(params:Object):void
		{
			// Show overhead message.
			RoomItemSprite(display).showDualOverheadMessage(params.message1, params.message2, params.strokeColor1, params.strokeColor2, params.sfxId1, params.sfxId2);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		protected function motionDisabledHandler(event:SimEvent):void
		{
			if (_pathCompleteAnim) display.playAnimation(_pathCompleteAnim);
		}
	}
}