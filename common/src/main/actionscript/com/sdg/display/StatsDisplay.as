package com.sdg.display
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.*;
	import flash.utils.*;

	import mx.containers.*;
	import mx.controls.Text;


/**
 *  The StatsDisplay class defines a dynamic display
 *  that is used to 'rolllup' awards pinball or slot machine style
 *  when a user is awarded points
 *  whenever a bindable property is updated.
 */

    /**
     *  Creates and starts a StatsDisplay instance.
     *
     *  @param container			- containing element ie <mx:VBox
     *  @param plevelName			- string the current level of a user
     *  @param pnumXpPoints 		- user's current displayed score
     *  @param pnumTokens 			- user's current number of tokens
     *  @param pnumxpPointsAward 	- number of points awarded
     *  @param pnumTokensAward 		- number of tokens awarded
     *
     *  @return nothing
     *  if a given award is > 0 the user's display for points and tokens
     *  is incremented and redisplayed ever timer tick along with an appropriate
     *  sound.
     *
     *  At the end of the rollup there is a alpha flash and the display is closed
     *  the main display will be updated to show the updated score on return
     *
	*/

	public class StatsDisplay extends Sprite
	{
			private static const TICK_TIME:uint = 50;					// rollup rate

			[Embed(source="fonts/GIL.TTF", fontFamily="GillSans")]
			private var gillsans:Class;

			private var rankTextField:Text;
			private var xpTextField:Text;
			private var tokensTextField:Text;

			private var numXpPoints:uint;
			private var numTokens:uint;
			private var xpPointsToAward:uint;
			private var tokensToAward:uint;

			private var rollupTimer:Timer;


		public function StatsDisplay( container:Box, plevelName:String,
											pnumXpPoints:int,pnumTokens:int,
											pnumxpPointsAward:int = 1,  pnumTokensAward:int = 1  )
		{
			super();

			numXpPoints = pnumXpPoints;
			numTokens 	= pnumTokens;
			xpPointsToAward = pnumxpPointsAward;
			tokensToAward = pnumTokensAward;

			rankTextField = new Text();
			xpTextField = new Text();
			tokensTextField = new Text();

			container.addChild(rankTextField);
			container.addChild(xpTextField);
			container.addChild(tokensTextField);

			rankTextField.text = "RANK" +  plevelName.toUpperCase(); // make sure upper case
		}

		/**
		 * show display, run timer on ourselves until we get
		 *  a false return from Rolllup telling us we are done
		 *
		 */

		public function start():void
		{
            rollupTimer = new Timer(TICK_TIME, 1000000);	// 100 ms per interval, 10000 intervals  should be enough
            rollupTimer.addEventListener(TimerEvent.TIMER, rollup);
            rollupTimer.start();
		}

		/**
		 * all done, remove listener, shut down timer
		 *
 		 */

		public function stop():void
		{
			rollupTimer.removeEventListener(TimerEvent.TIMER, rollup );
			rollupTimer = null;
		}

		/** rollup
		 * called every timer tick
		 * increments all scores with awards points left to display
		 * when all points racked kill timer
		 *
		 */

		private function rollup(event:TimerEvent):void
		{
		//		trace("tickevent in rollup" + event.target.currentCount);

			if( xpPointsToAward > 0 )
			{
				xpPointsToAward--;
				numXpPoints++;
				xpTextField.text = 'XP: ' + numXpPoints;
			}

			if( tokensToAward > 0 )
			{
				tokensToAward--;
				numTokens++;
				tokensTextField.text = 'TOKENS: ' + numTokens;
			}

			if( (xpPointsToAward) + (tokensToAward) == 0 )
			{
				stop();
			}

		}


	}
}
