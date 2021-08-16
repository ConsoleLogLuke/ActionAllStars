package com.sdg.components.controls
{
	import com.sdg.components.events.TurfVoteEvent;
	import com.sdg.graphics.customShapes.SlantedStarShape;
	
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	public class VoteStars extends Sprite
	{
		// Location Constants
		private static var STARS_WIDTH:uint = 85;
		private static var WIDTH:uint = 160;
		private static var HEIGHT:uint = 15;
		// Object Positions
		private static var STAR_POSITION_1:Point = new Point(2,1);
		private static var STAR_POSITION_2:Point = new Point(17,1);
		private static var STAR_POSITION_3:Point = new Point(34,1);
		private static var STAR_POSITION_4:Point = new Point(51,1);
		private static var STAR_POSITION_5:Point = new Point(68,1);
		private static var DOT_OFFSET_1:Point = new Point(6,5);
		private static var DOT_OFFSET_2:Point = new Point(6,5);
		private static var DOT_OFFSET_3:Point = new Point(6,5);
		private static var DOT_OFFSET_4:Point = new Point(6,5);
		private static var DOT_OFFSET_5:Point = new Point(6,5);
		private static var DOT_POSITION_1:Point = new Point(8,6);
		private static var DOT_POSITION_2:Point = new Point(25,6);
		private static var DOT_POSITION_3:Point = new Point(42,6);
		private static var DOT_POSITION_4:Point = new Point(59,6);
		private static var DOT_POSITION_5:Point = new Point(76,6);
		//Mouse_Over Borders
		private static var TRANSITION_1_2:uint = 16;
		private static var TRANSITION_2_3:uint = 33;	
		private static var TRANSITION_3_4:uint = 50;
		private static var TRANSITION_4_5:uint = 67;
		
		// Star Colors
		private static var ACTIVE_COLOR:uint = 0xffcc00;
		private static var PASSIVE_COLOR:uint = 0xfb3000;
		
		// Class State
		//protected var _activeState:Boolean; // Is the object currently manipulated by a mouse-over
		protected var _votedTallied:Boolean = false; // Has the current avatar voted on the current turf today?
		protected var _vote:uint = 0;
		protected var _currentAverage:Number = 3; // Voting Average; Defaults to three
		//protected var _active:; // Are the Stars Active Or Passive (2 Possible Colors)
		
		// Objects
		protected var _mouseOverCatch:Sprite;
		protected var _firstPosition:Sprite;
		protected var _secondPosition:Sprite;
		protected var _thirdPosition:Sprite;
		protected var _fourthPosition:Sprite;
		protected var _fifthPosition:Sprite;
		protected var _textDescription:TextField;
//		protected var _firstHalfPosition:Sprite;
//		protected var _secondHalfPosition:Sprite;
//		protected var _thirdHalfPosition:Sprite;
//		protected var _fourthHalfPosition:Sprite;
//		protected var _fifthHalfPosition:Sprite;
		//protected var _firstWhiteDot:Sprite = new Sprite();
		//protected var _secondWhiteDot:Sprite = new Sprite();
		//protected var _thirdWhiteDot:Sprite = new Sprite();
		//protected var _fourthWhiteDot:Sprite = new Sprite();
		//protected var _fifthWhiteDot:Sprite = new Sprite();
		//protected var _firstGrayStar:DisplayObject;
		//protected var _secondGrayStar:DisplayObject;
		//protected var _thirdGrayStar:DisplayObject;
		//protected var _fourthGrayStar:DisplayObject;
		//protected var _fifthGrayStar:DisplayObject;
		//protected var _secondGrayOutline:DisplayObject;
		//protected var _thirdGrayOutline:DisplayObject;
		//protected var _fourthGrayOutline:DisplayObject;
		//protected var _fifthGrayOutline:DisplayObject;
		
		//protected var loader1:Loader;
		protected var _lagTimer:Timer;
		
		protected var starShape:SlantedStarShape = new SlantedStarShape(13,10);
		
		public function VoteStars()
		{
			super();
			
			_lagTimer = new Timer(2000,1);
			
			this.graphics.beginFill(0x000000,0);
			this.graphics.drawRect(0,0,WIDTH,HEIGHT);
			
			// Add Display Sprites
			_firstPosition = new Sprite();
			addChild(_firstPosition);
			_secondPosition = new Sprite();
			addChild(_secondPosition);
			_thirdPosition = new Sprite();
			addChild(_thirdPosition);
			_fourthPosition = new Sprite();
			addChild(_fourthPosition);
			_fifthPosition = new Sprite();
			addChild(_fifthPosition);
			
			// Position Display Sprites
			_firstPosition.x = STAR_POSITION_1.x;
			_firstPosition.y = STAR_POSITION_1.y;
			_secondPosition.x = STAR_POSITION_2.x;
			_secondPosition.y = STAR_POSITION_2.y;
			_thirdPosition.x = STAR_POSITION_3.x;
			_thirdPosition.y = STAR_POSITION_3.y;
			_fourthPosition.x = STAR_POSITION_4.x;
			_fourthPosition.y = STAR_POSITION_4.y;
			_fifthPosition.x = STAR_POSITION_5.x;
			_fifthPosition.y = STAR_POSITION_5.y;
			
			// Add Stars Description Text
			_textDescription = new TextField();
			_textDescription.defaultTextFormat = new TextFormat('EuroStyle', 10, 0xffffff, true);
			_textDescription.text = this.getDefaultDescription();
			_textDescription.autoSize = TextFieldAutoSize.LEFT;
			_textDescription.embedFonts = true;
			_textDescription.selectable = false;
			_textDescription.x = 86;
			_textDescription.y = 0;
			addChild(_textDescription);
			
			// Add MouseOver Catch Item
			_mouseOverCatch = new Sprite();
			addChild(_mouseOverCatch);
			_mouseOverCatch.x = 0;
			_mouseOverCatch.y = 0;
			_mouseOverCatch.graphics.beginFill(0x000000,0);
			_mouseOverCatch.graphics.drawRect(0,0,STARS_WIDTH,HEIGHT);
			
			//this.render();
			// Initialize Stars to Default Amount
			this.setStars("passive",determineWholeStars(_currentAverage),determineHalfStars(_currentAverage));	
			
			// Listeners
			_mouseOverCatch.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			_mouseOverCatch.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			_mouseOverCatch.addEventListener(MouseEvent.CLICK,onStarClick);
		}
		
		public function reset():void
		{
			_currentAverage = 3;
			_votedTallied = false;
	 		_vote = 0;
		}
		
		// This is the only interface to set the stars displayed
		public function setStars(type:String,wholeStars:uint,halfStars:Boolean = false):void
		{
			this.erasePositions();
			
			if (type == "active")
			{
				drawActiveStars(wholeStars);
			}
			else
			{
				drawPassiveStars(wholeStars,halfStars);
			}

		}
		
		public function updateStarsDescription(text:String = null):void
		{
			if (text)
			{
				_textDescription.text = text;
			}
			else
			{
				_textDescription.text = this.getDefaultDescription();
			}
		}
		
		public function setAverage(average:Number):void
		{
			this._currentAverage = average;
			
			this.setStars("passive",determineWholeStars(_currentAverage),determineHalfStars(_currentAverage));	
		}
		
		public function setVote(stars:uint):void
		{
			this._vote = stars;
			this._votedTallied = true;
			//this.setStars("active",stars);
		}
		
		// LISTENERS
		
		private function onSwfInit(e:Event,container:DisplayObject):void
		{
			e.currentTarget.removeEventListener(Event.COMPLETE, arguments.callee);
			e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			try
			{
				var loaderInfo:LoaderInfo = e.currentTarget as LoaderInfo;
				//var loader:Loader = loaderInfo.loader;
				//container = DisplayObject(loader.content);
				//_firstGoldStar = DisplayObject(loader1.content);
				container = DisplayObject(loaderInfo.content);
				addChild(container);
				//loader.visible= true;
			}
			catch(e:Error)
			{
				trace("Turf Ratings GUI Error: " + e.message);
			}
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			// Deal with the error
			trace("ioErrorHandler: " + event.text);
			event.currentTarget.removeEventListener(Event.INIT, arguments.callee);
			event.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
		
		private function onRollOver(e:MouseEvent):void
		{
			// Shut off timer if it is on
			this.cancelTimer();
			
			//On rollover, a listener is activated that watches the movement of the cursor and controls the starts displayed
			//listener only turned on if person has not voted yet - If they have, their vote is shown again
			if (_votedTallied == false)
			{
				_mouseOverCatch.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
				
				// Get the ball rolling by calling onMouseMove manually
				this.onMouseMove(e);
			}
			else
			{
				this.setStars("active",_vote);
			}
		}

		private function onRollOut(e:MouseEvent):void
		{
			// Turn off listener
			_mouseOverCatch.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			
			// If the user has voted, start a timer showing the vote
			//     If not, go immediatelty back to the average
			if (_votedTallied)
			{
				// start the timer, turn on the listener
				_lagTimer.addEventListener(TimerEvent.TIMER,switchToAverage);
				_lagTimer.start();
			}
			else
			{
				// Return to Average Stars
				this.setStars("passive",determineWholeStars(_currentAverage),determineHalfStars(_currentAverage));
				this.updateStarsDescription();
			}
		}
		
		// Called when the lagTimer ends
		private function switchToAverage(e:TimerEvent):void
		{
			_lagTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,switchToAverage);
			this.removeEventListener(MouseEvent.ROLL_OVER,cancelTimer);
			this.setStars("passive",determineWholeStars(_currentAverage),determineHalfStars(_currentAverage));
			this.updateStarsDescription();
		}
		
		private function cancelTimer():void
		{
			_lagTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,switchToAverage);
			_lagTimer.stop();
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			// Figure Out Where I Am And how many stars I should be showing
			var stars:uint = this.getStarPosition(e.localX);
			this.setStars("active",stars);
			this.updateStarsDescription(this.convertStarsToLabel(stars));
		}
		
		private function onStarClick(e:MouseEvent):void
		{
			var starVote:uint = this.getStarPosition(e.localX);
			this._vote = starVote;
			
			// Turn off listener
			_mouseOverCatch.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			//_mouseOverCatch.removeEventListener(MouseEvent.CLICK,onStarClick);

			// Throw Event of a Vote
			dispatchEvent(new TurfVoteEvent(TurfVoteEvent.VOTE, true, false,starVote));
			
			// Rerender the stars
			_votedTallied = true;
		}

		// DRAWING FUNCTIONS
		
		// Removes all stars / dots
		public function erasePositions():void
		{
			_firstPosition.graphics.clear();
			_secondPosition.graphics.clear();
			_thirdPosition.graphics.clear();
			_fourthPosition.graphics.clear();
			_fifthPosition.graphics.clear();
			
//			try {
//				this.removeChild(_firstPosition);
//
//				this.removeChild(_secondPosition);
//
//				this.removeChild(_thirdPosition);
//
//				this.removeChild(_fourthPosition);
//				
//				this.removeChild(_fifthPosition);
//			} catch (e:ArgumentError) 
//			{
//				// Call the Safe Version
//				erasePositionsSafe();
//			}
		}
		
		public function erasePositionsSafe():void
		{
			if (this.contains(_firstPosition))
				this.removeChild(_firstPosition);
				
			if (this.contains(_secondPosition))
				this.removeChild(_secondPosition);
				
			if (this.contains(_thirdPosition))
				this.removeChild(_thirdPosition);
				
			if (this.contains(_fourthPosition))
				this.removeChild(_fourthPosition);
				
			if (this.contains(_fifthPosition))
				this.removeChild(_fifthPosition);
		}
		
		// Adds [num] of mouseover stars and 5 - num white dots
		public function drawActiveStars(num:uint):void
		{
			if (num > 0)
			{
				_firstPosition.graphics.lineStyle(1,0xffcc00,1);
				_firstPosition.graphics.beginFill(0xffcc00,1)
				starShape.draw(_firstPosition.graphics);
			}
			else
			{
				if (_votedTallied == false)
				{
					_firstPosition.graphics.beginFill(0xffffff,1);
					_firstPosition.graphics.drawCircle(DOT_OFFSET_1.x,DOT_OFFSET_1.y,2);
				}
			}
			
			if (num > 1)
			{
				_secondPosition.graphics.lineStyle(1,0xffcc00,1);
				_secondPosition.graphics.beginFill(0xffcc00,1)
				starShape.draw(_secondPosition.graphics);
			}
			else
			{
				if (_votedTallied == false)
				{
					_secondPosition.graphics.beginFill(0xffffff,1);
					_secondPosition.graphics.drawCircle(DOT_OFFSET_2.x,DOT_OFFSET_2.y,2);
				}
			}

			if (num > 2)
			{
				_thirdPosition.graphics.lineStyle(1,0xffcc00,1);
				_thirdPosition.graphics.beginFill(0xffcc00,1)
				starShape.draw(_thirdPosition.graphics);
			}
			else
			{
				if (_votedTallied == false)
				{
					_thirdPosition.graphics.beginFill(0xffffff,1);
					_thirdPosition.graphics.drawCircle(DOT_OFFSET_3.x,DOT_OFFSET_3.y,2);
				}
			}
			
			if (num > 3)
			{
				_fourthPosition.graphics.lineStyle(1,0xffcc00,1);
				_fourthPosition.graphics.beginFill(0xffcc00,1)
				starShape.draw(_fourthPosition.graphics);
			}
			else
			{
				if (_votedTallied == false)
				{
					_fourthPosition.graphics.beginFill(0xffffff,1);
					_fourthPosition.graphics.drawCircle(DOT_OFFSET_4.x,DOT_OFFSET_4.y,2);
				}
			}
			
			if (num > 4)
			{
				_fifthPosition.graphics.lineStyle(1,0xffcc00,1);
				_fifthPosition.graphics.beginFill(0xffcc00,1)
				starShape.draw(_fifthPosition.graphics);
			}
			else
			{
				if (_votedTallied == false)
				{
					_fifthPosition.graphics.beginFill(0xffffff,1);
					_fifthPosition.graphics.drawCircle(DOT_OFFSET_5.x,DOT_OFFSET_5.y,2);
				}
			}
		}
		
		// Adds [num] opf filled passive stars and [5-num] star outlines
		public function drawPassiveStars(num:uint,addHalfStar:Boolean):void
		{
			var halfStarNotUsed:Boolean = true;
			
			if (num > 0)
			{
				_firstPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
				_firstPosition.graphics.beginFill(PASSIVE_COLOR,1)
				starShape.draw(_firstPosition.graphics);
			}
			else
			{
				if (addHalfStar && halfStarNotUsed)
				{
					_firstPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
					_firstPosition.graphics.beginFill(PASSIVE_COLOR,1)
					starShape.drawLeftHalf(_firstPosition.graphics);
					_firstPosition.graphics.endFill();
					starShape.drawRightHalf(_firstPosition.graphics);
					
					halfStarNotUsed = false;
				}
				else
				{
					_firstPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
					starShape.draw(_firstPosition.graphics);
				}
			}
			
			if (num > 1)
			{
				_secondPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
				_secondPosition.graphics.beginFill(PASSIVE_COLOR,1)
				starShape.draw(_secondPosition.graphics);
			}
			else
			{
				if (addHalfStar && halfStarNotUsed)
				{
					_secondPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
					_secondPosition.graphics.beginFill(PASSIVE_COLOR,1)
					starShape.drawLeftHalf(_secondPosition.graphics);
					_secondPosition.graphics.endFill();
					starShape.drawRightHalf(_secondPosition.graphics);
					
					halfStarNotUsed = false;
				}
				else
				{
					_secondPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
					starShape.draw(_secondPosition.graphics);
				}
			}

			if (num > 2)
			{
				_thirdPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
				_thirdPosition.graphics.beginFill(PASSIVE_COLOR,1)
				starShape.draw(_thirdPosition.graphics);
			}
			else
			{
				if (addHalfStar && halfStarNotUsed)
				{
					_thirdPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
					_thirdPosition.graphics.beginFill(PASSIVE_COLOR,1)
					starShape.drawLeftHalf(_thirdPosition.graphics);
					_thirdPosition.graphics.endFill();
					starShape.drawRightHalf(_thirdPosition.graphics);
					
					halfStarNotUsed = false;
				}
				else
				{
					_thirdPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
					starShape.draw(_thirdPosition.graphics);
				}
			}
			
			if (num > 3)
			{
				_fourthPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
				_fourthPosition.graphics.beginFill(PASSIVE_COLOR,1)
				starShape.draw(_fourthPosition.graphics);
			}
			else
			{
				if (addHalfStar && halfStarNotUsed)
				{
					_fourthPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
					_fourthPosition.graphics.beginFill(PASSIVE_COLOR,1);
					starShape.drawLeftHalf(_fourthPosition.graphics);
					_fourthPosition.graphics.endFill();
					starShape.drawRightHalf(_fourthPosition.graphics);
					
					halfStarNotUsed = false;
				}
				else
				{
					_fourthPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
					starShape.draw(_fourthPosition.graphics);
				}
			}
			
			if (num > 4)
			{
				_fifthPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
				_fifthPosition.graphics.beginFill(PASSIVE_COLOR,1)
				starShape.draw(_fifthPosition.graphics);
			}
			else
			{
				if (addHalfStar && halfStarNotUsed)
				{
					_fifthPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
					_fifthPosition.graphics.beginFill(PASSIVE_COLOR,1)
					starShape.drawLeftHalf(_fifthPosition.graphics);
					_fifthPosition.graphics.endFill();
					starShape.drawRightHalf(_fifthPosition.graphics);
					
					halfStarNotUsed = false;
				}
				else
				{
					_fifthPosition.graphics.lineStyle(1,PASSIVE_COLOR,1);
					starShape.draw(_fifthPosition.graphics);
				}
			}
		}
		
		// Returns: Number of stars to display given mouse position
		private function getStarPosition(xCoord:uint):uint
		{
			if (xCoord > TRANSITION_4_5)
			{
				return 5;
			}
			else if (xCoord > TRANSITION_3_4)
			{
				return 4;	
			}
			else if (xCoord > TRANSITION_2_3)
			{
				return 3;
			}
			else if (xCoord > TRANSITION_1_2)
			{
				return 2;
			}
			else
			{
				return 1;	
			}
		}
		
		// UTILITY FUNCTIONS
		private function determineWholeStars(average:Number):uint
		{
			// EDGE Cases
			if (average > 5)
			{
				return 5;
			}
			else if (average < 0)
			{
				return 0;
			}
			
			// Likely Cases
			var roundedAverage:int = Math.round(average);
			if (roundedAverage > average)
			{
				return roundedAverage - 1;
			}
			else
			{
				return roundedAverage;	
			}
		}
		
		private function determineHalfStars(average:Number):Boolean
		{
			//var averageCeiling:int = Math.ceil(average);
			var roundedAverage:int = Math.round(average);
			if (roundedAverage > average)
			{
				return true;
			}
			else
			{
				return false;	
			}
		}
		
		private function convertStarsToLabel(stars:uint):String
		{
			switch (stars)
			{
				case 1:
					return "Needs Work!";
				case 2:
					return "Decent!";
				case 3:
					return "Pretty Good!";
				case 4:
					return "Nice!";
				case 5:
					return "Love It!";
				default:
					return "Pretty Good!";
			}
		}
		
		private function getDefaultDescription():String
		{
			if (_votedTallied)
			{
				return "Thanks!";
			}
			else
			{
				return "Rate Turf";
			}
		}
		
	}
}