package com.sdg.ui
{
	import com.sdg.display.AlignType;
	import com.sdg.display.Container;
	import com.sdg.display.Stack;
	import com.sdg.pickem.IPickemDataProvider;
	import com.sdg.pickem.InGamePickBox;
	import com.sdg.pickem.PickCardBacking;
	import com.sdg.pickem.PickDetailsBubble;
	import com.sdg.pickem.PickemData;
	import com.sdg.trivia.Question;
	import com.sdg.trivia.TriviaAnswer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class UIPickemInGameScorecard extends Container
	{
		private var _pickBoxStack:Stack;
		private var _pickBoxes:Array;
		private var _pickemDataProvider:IPickemDataProvider;
		private var _destroyed:Boolean;
		private var _questionIndex:int;
		
		public function UIPickemInGameScorecard(pickemDataProvider:IPickemDataProvider)
		{
			super();
			
			_pickemDataProvider = pickemDataProvider;
			_destroyed = false;
			_pickBoxes = new Array();
			_questionIndex = -1;
			
			// Use standard Action AllStars panel backing.
			backing = new PickCardBacking();
			_backing.lineThickness = 4;
			
			// Create a pick box stack.
			_pickBoxStack = new Stack(AlignType.VERTICAL, 4);
			_pickBoxStack.equalizeSize = true;
			
			// Create default pick boxes.
			var i:int = 0;
			var len:int = 5;
			var pickBox:InGamePickBox;
			var number:TextField;
			var bitData:BitmapData;
			var bitmap:Bitmap;
			var scale:Number;
			var boxImage:Sprite;
			var imageSize:Number = 37;
			for (i; i < len; i++)
			{
				pickBox = new InGamePickBox();
				boxImage = new Sprite();
				boxImage.graphics.beginFill(0x00ff00, 0);
				boxImage.graphics.drawRect(0, 0, imageSize, imageSize);
				number = new TextField();
				number.defaultTextFormat = new TextFormat('EuroStyle', 16, 0xffffff);
				number.autoSize = TextFieldAutoSize.LEFT;
				number.text = Number(i + 1).toString();
				number.mouseEnabled = false;
				number.embedFonts = true;
				boxImage.addChild(number);
				number.x = imageSize / 2 - number.width / 2;
				number.y = imageSize / 2 - number.height / 2;
				pickBox.image = boxImage;
				pickBox.imageFilters = [];
				addPickBox(pickBox);
			}
			
			// Set padding.
			padding = 10;
			
			// Set content as the stack.
			content = _pickBoxStack;
		}
		
		////////////////////
		// CLASS METHODS
		////////////////////
		
		public function destroy():void
		{
			if (_destroyed == true) return;
			clearPicks();
			_destroyed = true;
		}
		
		public function addPickBox(pickBox:InGamePickBox):void
		{
			// Add it to the stack.
			_pickBoxStack.addContainer(pickBox);
			_pickBoxes.push(pickBox);
			
			// Add pick box event listeners.
			addPickBoxListeners(pickBox);
		}
		
		public function addPickBoxAt(pickBox:InGamePickBox, index:int):void
		{
			// Add it to the stack.
			_pickBoxStack.addContainerAt(pickBox, index);
			_pickBoxes[index] = pickBox;
			
			// If the pick box at this index should be the qued pick box, style it.
			if (index == _questionIndex)
			{
				styleQuedPickBox(pickBox);
			}
			
			// Add pick box event listeners.
			addPickBoxListeners(pickBox);
		}
		
		public function clearPicks():void
		{
			var i:int = 0;
			var len:int = _pickBoxes.length;
			for (i; i < len; i++)
			{
				var pickBox:InGamePickBox = _pickBoxes[i] as InGamePickBox;
				if (pickBox != null)
				{
					_pickBoxStack.removeContainer(pickBox);
					
					// Remove pick box event listeners.
					removePickBoxListeners(pickBox);
				}
			}
			
			_pickBoxes = new Array();
			
			_pickBoxStack = new Stack(AlignType.VERTICAL, 4);
			_pickBoxStack.equalizeSize = true;
			
			// Set content as the stack.
			content = _pickBoxStack;
		}
		
		private function addPickBoxListeners(pickBox:InGamePickBox):void
		{
			// Listen for mouse events on the pick box.
			pickBox.addEventListener(MouseEvent.MOUSE_OVER, onPickBoxMouseOver);
			
			// Make butonMode true.
			pickBox.buttonMode = true;
		}
		
		private function removePickBoxListeners(pickBox:InGamePickBox):void
		{
			// Remove event listeners.
			pickBox.removeEventListener(MouseEvent.MOUSE_OVER, onPickBoxMouseOver);
		}
		
		private function styleQuedPickBox(pickBox:InGamePickBox):void
		{
			pickBox.backing.lineColor = 0xff0000;
			pickBox.filters = [new GlowFilter(0xff0000, 1, 18, 18, 2)];
		}
		
		private function styleUnquedPickBox(pickBox:InGamePickBox):void
		{
			pickBox.backing.lineColor = 0x969696;
			pickBox.filters = [];
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function set questionIndex(value:int):void
		{
			if (value == _questionIndex) return;
			
			// Make sure new value is between -1 and 4.
			if (value < -1 || value > 4) return;
			
			// If current value is 0 or greater.
			var box:InGamePickBox;
			if (_questionIndex > -1)
			{
				// Set styling of pick box.
				box = _pickBoxes[_questionIndex] as InGamePickBox;
				if (box != null)
				{
					styleUnquedPickBox(box);
				}
			}
			
			// Set value.
			_questionIndex = value;
			
			// Set styling of new box.
			box = _pickBoxes[_questionIndex] as InGamePickBox;
			if (box == null) return;
			styleQuedPickBox(box);
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onPickBoxMouseOver(e:MouseEvent):void
		{
			// Determine pick box object.
			var pickBox:InGamePickBox = e.currentTarget as InGamePickBox;
			if (pickBox == null) return;
			
			// Determine pickem question.
			var index:int = _pickBoxes.indexOf(pickBox);
			var pickemData:PickemData = _pickemDataProvider.pickemData;
			if (pickemData == null) return;
			var question:Question = pickemData.questions.getAt(index);
			if (question == null) return;
			var pickText:String = question.text;
			var answer1:TriviaAnswer = question.answers[0] as TriviaAnswer;
			var answer2:TriviaAnswer = question.answers[1] as TriviaAnswer;
			if (answer1 != null && answer2 != null)
			{
				pickText += '\n' + answer1.text + ' or ' + answer2.text;
			}
			
			// Listen for mouse out.
			pickBox.addEventListener(MouseEvent.MOUSE_OUT, onPickBoxMouseOut);
			
			// Get pickbox coordinates.
			var boxRect:Rectangle = pickBox.getBounds(this);
			
			// Create a pic details bubble.
			var detailsBubble:PickDetailsBubble = new PickDetailsBubble(140);
			detailsBubble.questionText = pickText;
			detailsBubble.x = boxRect.x - detailsBubble.width;
			detailsBubble.y = boxRect.y + boxRect.height / 2 - detailsBubble.height / 2;
			_addChild(detailsBubble);
			
			function onPickBoxMouseOut(e:MouseEvent):void
			{
				// Remove  mouse out listener.
				pickBox.removeEventListener(MouseEvent.MOUSE_OUT, onPickBoxMouseOut);
				
				_removeChild(detailsBubble);
			}
		}
		
	}
}