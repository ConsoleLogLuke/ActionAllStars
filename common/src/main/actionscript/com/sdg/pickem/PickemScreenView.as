package com.sdg.pickem
{
	import com.boostworthy.animation.easing.Transitions;
	import com.boostworthy.animation.management.AnimationManager;
	import com.boostworthy.animation.rendering.RenderMethod;
	import com.boostworthy.events.AnimationEvent;
	import com.sdg.display.SplitTogetherTitleBar;
	import com.sdg.display.WhiteFlash;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;

	public class PickemScreenView extends Sprite implements IPickemScreenView
	{
		private var _width:Number;
		private var _height:Number;
		private var _questionText:String;
		private var _answer1Text:String;
		private var _answer2Text:String;
		private var _answer1Image:DisplayObject;
		private var _answer2Image:DisplayObject;
		private var _roomAnswer1Picks:Number;
		private var _roomAnswer2Picks:Number;
		private var _worldAnswer1Picks:Number;
		private var _worldAnswer2Picks:Number;
		private var _countdownTime:int;
		private var _viewState:String;
		private var _outerMargin:Number;
		private var _answerArea:Rectangle;
		private var _countdownWidth:Number;
		private var _spacing:Number;
		private var _answerImageFilters:Array;
		private var _screenMask:Sprite;
		private var _maskedContent:Sprite;
		private var _answerBackingFilters:Array;
		private var _answer1Position:Number;
		private var _answer2Position:Number;
		private var _roomResultBreakdown:Number;
		private var _worldResultBreakdown:Number;
		private var _resultLabel:String;
		private var _answer1Width:Number;
		private var _answer2Width:Number;
		private var _initialAnswerRender:Boolean;
		private var _flashLayer:Sprite;
		private var _answerImageLayer1:Sprite;
		private var _answerImageLayer2:Sprite;
		private var _resultFieldFilters:Array;
		private var _answerColor1:uint;
		private var _answerColor2:uint;
		private var _darkScreen:Sprite;
		private var _textLayer:Sprite;
		private var _answerGelLayer1:Sprite;
		private var _answerGelLayer2:Sprite;
		private var _answerBackingMask1:Sprite;
		private var _answerBackingMask2:Sprite;
		private var _questionAreaHeight:Number;
		private var _resultDescriptionBeenShown:Boolean;
		private var _backgroundLoopChannel:SoundChannel;
		private var _backgroundLoopSound:Sound;
		
		private var _questionTextField:TextField;
		private var _countdownField:TextField;
		private var _answer1Field:TextField;
		private var _answer2Field:TextField;
		private var _answer1Backing:Sprite;
		private var _answer2Backing:Sprite;
		private var _resultField1:TextField;
		private var _resultField2:TextField;
		private var _resultTypeField:TextField;
		private var _offHoursField:TextField;
		private var _resultDescriptionField:TextField;
		
		private var _pickemModel:PickemModel;
		
		public function PickemScreenView(pickemModel:PickemModel)
		{
			super();
			
			// Set default values.
			_pickemModel = pickemModel;
			_outerMargin = 20;
			_spacing = 20;
			_width = 0;
			_height = 0;
			_answerArea = new Rectangle(0, 0, _width, _height);
			_countdownWidth = 100;
			_answerImageFilters = [new GlowFilter(0xffffff, 1, 3, 3, 8, 2), new DropShadowFilter(4, 45, 0, 0.6, 12, 12)];
			_answerBackingFilters = [new GlowFilter(0xffffff, 1, 10, 10, 10)];
			_answer1Position = 0;
			_answer2Position = 0;
			_worldResultBreakdown = -1;
			_initialAnswerRender = false;
			_resultFieldFilters = [new BevelFilter(2, 45, 0xffffff, 1, 0, 1, 4, 4, 1, 1, 'inner', true)];
			_answerColor1 = 0xE9252D;
			_answerColor2 = 0x1D51D7;
			_questionAreaHeight = 60;
			_resultDescriptionBeenShown = false;
			
			// Create screen mask.
			_screenMask = new Sprite();
			addChild(_screenMask);
			
			// Create a Sprite that will contain all content that we want to be masked by the screen area.
			_maskedContent = new Sprite();
			_maskedContent.mask = _screenMask;
			addChild(_maskedContent);
			
			// Create the text layer.
			_textLayer = new Sprite();
			_maskedContent.addChild(_textLayer);
			
			// Create visual elements.
			_questionTextField = new TextField();
			_questionTextField.defaultTextFormat = new TextFormat('EuroStyle', 24, 0xffffff, true);
			_questionTextField.embedFonts = true;
			_questionTextField.autoSize = TextFieldAutoSize.LEFT;
			_questionTextField.selectable = false;
			_questionTextField.mouseEnabled = false;
			_textLayer.addChild(_questionTextField);
			
			_resultDescriptionField = new TextField();
			_resultDescriptionField.defaultTextFormat = new TextFormat('EuroStyle', 18, 0xffffff, true);
			_resultDescriptionField.embedFonts = true;
			_resultDescriptionField.autoSize = TextFieldAutoSize.LEFT;
			_resultDescriptionField.selectable = false;
			
			_countdownField = new TextField();
			_countdownField.defaultTextFormat = new TextFormat('EuroStyle', 36, 0xffffff, true);
			_countdownField.embedFonts = true;
			_countdownField.autoSize = TextFieldAutoSize.LEFT;
			_countdownField.selectable = false;
			_countdownField.mouseEnabled = false;
			_textLayer.addChild(_countdownField);
			
			_resultTypeField = new TextField();
			_resultTypeField.defaultTextFormat = new TextFormat('EuroStyle', 14, 0xffffff, true, false, false, null, null, TextFormatAlign.CENTER);
			_resultTypeField.embedFonts = true;
			_resultTypeField.autoSize = TextFieldAutoSize.CENTER;
			_resultTypeField.multiline = true;
			_resultTypeField.width = _countdownWidth;
			_resultTypeField.selectable = false;
			_resultTypeField.mouseEnabled = false;
			_textLayer.addChild(_resultTypeField);
			
			_answer1Backing = new Sprite();
			_answer1Backing.filters = _answerBackingFilters;
			_maskedContent.addChild(_answer1Backing);
			
			_answer2Backing = new Sprite();
			_answer2Backing.filters = _answerBackingFilters;
			_maskedContent.addChild(_answer2Backing);
			
			_resultField1 =  new TextField();
			_resultField1.defaultTextFormat = new TextFormat('EuroStyle', 48, 0xffcccc);
			_resultField1.embedFonts = true;
			_resultField1.autoSize = TextFieldAutoSize.CENTER;
			_resultField1.selectable = false;
			_resultField1.mouseEnabled = false;
			_resultField1.filters = _resultFieldFilters;
			_maskedContent.addChild(_resultField1);
			
			_resultField2 =  new TextField();
			_resultField2.defaultTextFormat = new TextFormat('EuroStyle', 48, 0xccccff);
			_resultField2.embedFonts = true;
			_resultField2.autoSize = TextFieldAutoSize.CENTER;
			_resultField2.selectable = false;
			_resultField2.mouseEnabled = false;
			_resultField2.filters = _resultFieldFilters;
			_maskedContent.addChild(_resultField2);
			
			// Create answer backing mask layers.
			_answerBackingMask1 = new Sprite();
			_maskedContent.addChild(_answerBackingMask1);
			_answerBackingMask2 = new Sprite();
			_maskedContent.addChild(_answerBackingMask2);
			
			// Create individual layers for the answer images.
			_answerImageLayer1 = new Sprite();
			_answerImageLayer1.mask = _answerBackingMask1;
			_maskedContent.addChild(_answerImageLayer1);
			_answerImageLayer2 = new Sprite();
			_answerImageLayer2.mask = _answerBackingMask2;
			_maskedContent.addChild(_answerImageLayer2);
			
			// Create gel layers for answers.
			_answerGelLayer1 = new Sprite();
			_maskedContent.addChild(_answerGelLayer1);
			_answerGelLayer2 = new Sprite();
			_maskedContent.addChild(_answerGelLayer2);
			
			// Create answer fields.
			_answer1Field = new TextField();
			_answer1Field.defaultTextFormat = new TextFormat('EuroStyle', 28, 0xffffff);
			_answer1Field.embedFonts = true;
			_answer1Field.autoSize = TextFieldAutoSize.LEFT;
			_answer1Field.filters = [new DropShadowFilter(3)];
			_answer1Field.selectable = false;
			_answer1Field.mouseEnabled = false;
			_maskedContent.addChild(_answer1Field);
			
			_answer2Field = new TextField();
			_answer2Field.defaultTextFormat = new TextFormat('EuroStyle', 28, 0xffffff);
			_answer2Field.embedFonts = true;
			_answer2Field.autoSize = TextFieldAutoSize.LEFT;
			_answer2Field.filters = _answer1Field.filters;
			_answer2Field.selectable = false;
			_answer2Field.mouseEnabled = false;
			_maskedContent.addChild(_answer2Field);
			
			// Make a display layer for white flashes.
			_flashLayer = new Sprite();
			_maskedContent.addChild(_flashLayer);
			
			// Create a dark screen.
			_darkScreen = new Sprite();
			_darkScreen.graphics.beginFill(0);
			_darkScreen.graphics.drawRect(0, 0, 100, 100);
			_darkScreen.alpha = 0;
			_darkScreen.visible = false;
			_flashLayer.addChild(_darkScreen);
			
			// Create an OFF HOURS message field.
			_offHoursField = new TextField();
			_offHoursField.defaultTextFormat = new TextFormat('EuroStyle', 36, 0xffffff, true);
			_offHoursField.embedFonts = true;
			_offHoursField.autoSize = TextFieldAutoSize.CENTER;
			_offHoursField.selectable = false;
			_offHoursField.mouseEnabled = false;
			addChild(_offHoursField);
			
			render();
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		public function destroy():void
		{
			if (_backgroundLoopChannel != null) _backgroundLoopChannel.stop();
		}
		
		private function render():void
		{
			renderMask();
			
			renderQuestionText();
			
			renderCountdown();
			
			renderAnswer1();
			
			renderAnswer2();
			
			renderResults();
			
			renderOffHoursText();
		}
		
		private function renderMask():void
		{
			_screenMask.graphics.clear();
			_screenMask.graphics.beginFill(0xffffff);
			_screenMask.graphics.drawRect(0, 0, _width, _height);
			
			_darkScreen.width = _width;
			_darkScreen.height = _height;
		}
		
		private function renderCountdown():void
		{
			_countdownField.visible = (_viewState == PickemViewState.POLL_STATE) ? true : false;
			_countdownField.x = (_width / 2) - (_countdownField.width / 2);
			_countdownField.y = _answerArea.y + _answerArea.height / 2 - _countdownField.height / 2;
			
			_resultTypeField.visible = (_countdownField.visible == false && _worldResultBreakdown < 0) ? true : false;
			_resultTypeField.x = (_width / 2) - (_resultTypeField.width / 2);
			_resultTypeField.y = _answerArea.y + _answerArea.height / 2 - _resultTypeField.height / 2;
		}
		
		private function renderQuestionText():void
		{
			//_questionTextField.width = _width - (_outerMargin * 2);
			_questionTextField.x = _width / 2 - _questionTextField.width / 2;
			_questionTextField.y = _outerMargin + _questionAreaHeight / 2 - _questionTextField.height / 2;
			
			_answerArea = new Rectangle(0, _questionAreaHeight + _outerMargin + _spacing, _width, _height - _questionAreaHeight - _outerMargin - _spacing);
		}
		
		private function renderAnswer1():void
		{
			var backHeight:Number = _answerArea.height - _spacing - _outerMargin;
			var backWidth:Number = _answer1Width;
			var xOffset:Number = - (1 - _answer1Position) * backWidth;
			
			// Show/Hide answer backing depending on state.
			// Always show unless the state is "off hours".
			_answer1Backing.visible = (_viewState != PickemViewState.OFF_HOURS) ? true : false;
			
			// Draw the answer backing.
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(backWidth, backHeight, Math.PI / 2);
			_answer1Backing.graphics.clear();
			_answer1Backing.graphics.beginFill(_answerColor1);
			drawBackingShape(_answer1Backing);
			
			_answerGelLayer1.graphics.clear();
			_answerGelLayer1.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xffffff, 0x333333, 0], [0.3, 0.1, 0.1, 0.3], [0, 127, 128, 255], gradMatrix);
			drawBackingShape(_answerGelLayer1);
			
			_answerBackingMask1.graphics.clear();
			_answerBackingMask1.graphics.beginFill(0xffffff);
			drawBackingShape(_answerBackingMask1);
			
			// Position answer backing.
			_answer1Backing.x = _answerGelLayer1.x = _answerBackingMask1.x = xOffset;
			_answer1Backing.y = _answerGelLayer1.y = _answerBackingMask1.y = _answerArea.y + _spacing;
			
			// Position answer text field.
			_answer1Field.x = _answer1Backing.x + _spacing;
			_answer1Field.y = _answer1Backing.y + _spacing;
			
			// Position result fields.
			_resultField1.x = _answer1Backing.x + _spacing;
			_resultField1.y = _answer1Backing.y + _answer1Backing.height - _resultField1.height - _spacing;
			
			if (_answer1Image != null)
			{
				// Scale the answer image.
				var size:Number = backHeight;
				var scale:Number = Math.min(size / _answer1Image.width, size / _answer1Image.height);
				_answer1Image.width *= scale;
				_answer1Image.height *= scale;
				
				// Position the image.
				_answer1Image.x = _answer1Backing.x + _answer1Backing.width - _answer1Image.width - _spacing;
				_answer1Image.y = _answer1Backing.y + _spacing;
				
				// The images inexplicably show up lower than they should.
				// Make a hard coded adjustment.
				_answer1Image.y -= 10;
			}
			
			function drawBackingShape(sprite:Sprite):void
			{
				sprite.graphics.moveTo(0, 0);
				sprite.graphics.lineTo(backWidth - backHeight / 2, 0);
				sprite.graphics.curveTo(backWidth, 0, backWidth, backHeight / 2);
				sprite.graphics.curveTo(backWidth, backHeight, backWidth - backHeight / 2, backHeight);
				sprite.graphics.lineTo(0, backHeight);
				sprite.graphics.lineTo(0, 0);
			}
		}
		
		private function renderAnswer2():void
		{
			var backHeight:Number = _answerArea.height - _spacing - _outerMargin;
			var backWidth:Number = _answer2Width;
			var xOffset:Number = (1 - _answer1Position) * backWidth;
			
			// Show/Hide answer backing depending on state.
			// Always show unless the state is "off hours".
			_answer2Backing.visible = (_viewState != PickemViewState.OFF_HOURS) ? true : false;
			
			// Draw answer backing.
			var gradMatrix:Matrix = new Matrix();
			gradMatrix.createGradientBox(backWidth, backHeight, Math.PI / 2);
			_answer2Backing.graphics.clear();
			_answer2Backing.graphics.beginFill(_answerColor2);
			drawBackingShape(_answer2Backing);
			
			_answerGelLayer2.graphics.clear();
			_answerGelLayer2.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xffffff, 0x333333, 0], [0.3, 0.1, 0.1, 0.3], [0, 127, 128, 255], gradMatrix);
			drawBackingShape(_answerGelLayer2);
			
			_answerBackingMask2.graphics.clear();
			_answerBackingMask2.graphics.beginFill(0xffffff);
			drawBackingShape(_answerBackingMask2);
			
			// Position answer backing.
			_answer2Backing.x = _answerGelLayer2.x = _answerBackingMask2.x = Math.ceil(_answerArea.right - backWidth + xOffset);
			_answer2Backing.y = _answerGelLayer2.y = _answerBackingMask2.y = _answerArea.y + _spacing;
			
			// Position answer text field.
			_answer2Field.x = _answer2Backing.x + _answer2Backing.width - _answer2Field.width - _spacing;
			_answer2Field.y = _answer2Backing.y + _spacing;
			
			// Position result fields.
			_resultField2.x = _answer2Backing.x + _answer2Backing.width - _resultField2.width - _spacing;
			_resultField2.y = _answer2Backing.y + _answer2Backing.height - _resultField2.height - _spacing;
			
			if (_answer2Image != null)
			{
				// Scale the answer image.
				var size:Number = backHeight;
				var scale:Number = Math.min(size / _answer2Image.width, size / _answer2Image.height);
				_answer2Image.width *= scale;
				_answer2Image.height *= scale;
				
				// Position the image.
				_answer2Image.x = _answer2Backing.x + _spacing;
				_answer2Image.y = _answer2Backing.y + _spacing;
				
				// The images inexplicably show up lower than they should.
				// Make a hard coded adjustment.
				_answer2Image.y -= 10;
			}
			
			function drawBackingShape(sprite:Sprite):void
			{
				sprite.graphics.moveTo(backWidth, 0);
				sprite.graphics.lineTo(backHeight / 2, 0);
				sprite.graphics.curveTo(0, 0, 0, backHeight / 2);
				sprite.graphics.curveTo(0, backHeight, backHeight / 2, backHeight);
				sprite.graphics.lineTo(backWidth, backHeight);
				sprite.graphics.lineTo(backWidth, 0);
			}
		}
		
		private function renderResults():void
		{
			// Determine if results should be visible.
			setWorldResultText();
			_resultField1.visible = (_viewState == PickemViewState.WORLD_RESULT_STATE || _worldResultBreakdown >= 0) ? true : false;
			_resultField2.visible = _resultField1.visible;
		}
		
		private function renderOffHoursText():void
		{
			// Position text field.
			_offHoursField.x = _width / 2 - _offHoursField.width / 2;
			_offHoursField.y = _height / 2 - _offHoursField.height / 2;
			
			_offHoursField.visible = (_viewState == PickemViewState.OFF_HOURS) ? true : false;
		}
		
		private function setRoomResultText():void
		{
			var answer1Count:int = Math.round(_roomResultBreakdown * 100);
			var answer2Count:int = 100 - answer1Count;
			_resultField1.text = answer1Count + '%';
			_resultField2.text = answer2Count + '%';
		}
		
		private function setWorldResultText():void
		{
			var answer1Count:int = Math.round(_worldResultBreakdown * 100);
			var answer2Count:int = 100 - answer1Count;
			_resultField1.text = answer1Count + '%';
			_resultField2.text = answer2Count + '%';
		}
		
		private function toggleAnswer1OnTop(onTop:Boolean):void
		{
			// If true.
			// Render answer 1 on top of answer 2.
			var container:Sprite = _maskedContent;
			if (onTop == true)
			{
				container.addChild(_answer1Backing);
				container.addChild(_resultField1);
				container.addChild(_answerImageLayer1);
				container.addChild(_answerGelLayer1);
				container.addChild(_answer1Field);
				container.addChild(_flashLayer);
			}
			else
			{
				container.addChild(_answer2Backing);
				container.addChild(_resultField2);
				container.addChild(_answerImageLayer2);
				container.addChild(_answerGelLayer2);
				container.addChild(_answer2Field);
				container.addChild(_flashLayer);
			}
		}
		
		private function transitionTextField(textField:TextField, value:String, duration:Number = 200, scale:Number = 3):void
		{
			// Get a bitmap copy of the current text.
			var textArea:Rectangle = textField.getBounds(_maskedContent);
			var bd:BitmapData = new BitmapData(textArea.width, textArea.height, true, 0x00ff00);
			bd.draw(textField);
			var bitmap:Bitmap = new Bitmap(bd, 'auto', true);
			
			// Create a container for the bitmap that we will animate.
			var container:Sprite = new Sprite();
			container.addChild(bitmap);
			bitmap.x = - bitmap.width / 2;
			bitmap.y = - bitmap.height / 2;
			container.x = textArea.x + textArea.width / 2;
			container.y = textArea.y + textArea.height / 2;
			_maskedContent.addChild(container);
			
			// Change the value of the text field and create a bitmap copy of that.
			textField.text = value;
			render();
			textArea = textField.getBounds(_maskedContent);
			bd = new BitmapData(textArea.width, textArea.height, true, 0x00ff00);
			bd.draw(textField);
			bitmap = new Bitmap(bd, 'auto', true);
			
			// Create a container to contain the new text copy.
			var newTextContainer:Sprite = new Sprite();
			newTextContainer.addChild(bitmap);
			bitmap.scaleX /= scale;
			bitmap.scaleY /= scale;
			bitmap.x = - bitmap.width / 2;
			bitmap.y = - bitmap.height / 2;
			newTextContainer.x = textArea.x + textArea.width / 2;
			newTextContainer.y = textArea.y + textArea.height / 2;
			// Hide the new text for now.
			newTextContainer.visible = false;
			newTextContainer.alpha = 0;
			_maskedContent.addChild(newTextContainer);
			
			// Hide the text field.
			textField.visible = false;
			
			// Animate the container.
			var animationManager:AnimationManager = _pickemModel.animationManager;
			animationManager.addEventListener(AnimationEvent.FINISH, onAnimationFinish);
			animationManager.property(container, 'scaleX', scale, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			animationManager.property(container, 'scaleY', scale, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			animationManager.property(container, 'alpha', 0, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			function onAnimationFinish(e:AnimationEvent):void
			{
				// If the bitmap has finished animating.
				// Remove the old text bitmap.
				// Animate in the new text.
				if (e.animTarget == container && e.animProperty == 'scaleX')
				{
					_maskedContent.removeChild(container);
					
					newTextContainer.visible = true;
					animationManager.property(newTextContainer, 'scaleX', scale, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
					animationManager.property(newTextContainer, 'scaleY', scale, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
					animationManager.property(newTextContainer, 'alpha', 1, duration, Transitions.CUBIC_OUT, RenderMethod.TIMER);
				}
				else if (e.animTarget == newTextContainer && e.animProperty == 'scaleX')
				{
					// The new text is done animating.
					// Remove the event listener.
					// Remove the new text container and show the text field.
					animationManager.removeEventListener(AnimationEvent.FINISH, onAnimationFinish);
					_maskedContent.removeChild(newTextContainer);
					textField.visible = true;
				}
			}
		}
		
		private function animateAnswerWidth():void
		{
			// Animate answer widths.
			var w1:Number;
			var w2:Number;
			if (_worldResultBreakdown < 0)
			{
				// Determine proper answer widths.
				w1 = (_width - _countdownWidth) / 2;
				w2 = w1;
			}
			else if (_worldResultBreakdown == 0.50)
			{
				// If the world result breakdown is 50/50;
				w1 = (_width - 20) / 2;
				w2 = w1;
			}
			else
			{
				// Determine proper answer widths.
				var minWidth:Number = 120;
				var backHeight:Number = _answerArea.height - _spacing - _outerMargin;
				w1 = minWidth + (width - minWidth * 2) * _worldResultBreakdown;
				w2 = minWidth + (_width - minWidth * 2) * (1 - _worldResultBreakdown);
				if (w1 < w2)
				{
					// Render answer 2 on top of 1.
					w1 = _width / 2 + backHeight;
					toggleAnswer1OnTop(false);
				}
				else
				{
					// Render answer 1 on top of 2.
					w2 = _width / 2 + backHeight;
					toggleAnswer1OnTop(true);
				}
			}
			
			_pickemModel.animationManager.property(this, 'answer1Width', w1, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			_pickemModel.animationManager.property(this, 'answer2Width', w2, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
		}
		
		private function flashScreen():void
		{
			// Create a white flash.
			var whiteFlash:WhiteFlash = new WhiteFlash(_width, _height);
			whiteFlash.blendMode = BlendMode.ADD;
			_flashLayer.addChild(whiteFlash);
			
			// Create local var for animation manager.
			var animationManager:AnimationManager = _pickemModel.animationManager;
			
			animationManager.addEventListener(AnimationEvent.FINISH, onAnimationFinish);
			animationManager.property(whiteFlash, 'intensity', 1, 200, Transitions.CUBIC_IN, RenderMethod.TIMER);
			
			function onAnimationFinish(e:AnimationEvent):void
			{
				if (e.animTarget == whiteFlash && e.animProperty == 'intensity')
				{
					if (whiteFlash.intensity == 1)
					{
						// Animate back to 0.
						animationManager.property(whiteFlash, 'intensity', 0, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
					}
					else if (whiteFlash.intensity == 0)
					{
						// Remove the listener.
						animationManager.removeEventListener(AnimationEvent.FINISH, onAnimationFinish);
						
						// Remove display object.
						_flashLayer.removeChild(whiteFlash);
					}
				}
			}
		}
		
		private function showDarkScreen(animateDuration:Number, stillDuration:Number, stillAlpha:Number):void
		{
			// Comment this...
			
			
			// Create local var for animation manager.
			var animationManager:AnimationManager = _pickemModel.animationManager;
			animationManager.addEventListener(AnimationEvent.FINISH, onAnimationFinish);
			_darkScreen.visible = true;
			animationManager.alpha(_darkScreen, stillAlpha, animateDuration, Transitions.CUBIC_IN, RenderMethod.TIMER);
			
			var fallback:Timer = new Timer(animateDuration + stillDuration + 100);
			fallback.addEventListener(TimerEvent.TIMER, onFallback);
			fallback.start();
			
			function onAnimationFinish(e:AnimationEvent):void
			{
				if (e.animTarget == _darkScreen && e.animProperty == 'alpha')
				{
					if (_darkScreen.alpha == stillAlpha)
					{
						// Animation show is done.
						
						// Use a timer to control when to hide the dark screen.
						var tmr:Timer = new Timer(stillDuration);
						tmr.addEventListener(TimerEvent.TIMER, onTimer);
						tmr.start();
						
						function onTimer(e:TimerEvent):void
						{
							killFallback();
							
							// Kill timer.
							tmr.addEventListener(TimerEvent.TIMER, onTimer);
							tmr.reset();
							
							// Hide the dark screen.
							animationManager.alpha(_darkScreen, 0, animateDuration, Transitions.CUBIC_IN, RenderMethod.TIMER);
						}
					}
					else if (_darkScreen.alpha == 0)
					{
						// Animation hide is done.
						
						// Remove animation manager listener.
						animationManager.removeEventListener(AnimationEvent.FINISH, onAnimationFinish);
						
						_darkScreen.visible = false;
					}
					
				}
			}
			
			function onFallback(e:TimerEvent):void
			{
				killFallback();
				
				// Hide the dark screen.
				animationManager.alpha(_darkScreen, 0, animateDuration, Transitions.CUBIC_IN, RenderMethod.TIMER);
			}
			
			function killFallback():void
			{
				fallback.removeEventListener(TimerEvent.TIMER, onFallback);
				fallback.reset();
			}
		}
		
		private function voteRegisteredAnimation():void
		{
			// Create split title bar.
			var titleBar:SplitTogetherTitleBar = new SplitTogetherTitleBar('Picks Registered', new TextFormat('EuroStyle', 32, 0xffffff, true), 0x00235A, _pickemModel.animationManager);
			titleBar.filters = [new GlowFilter(0xffffff, 0.6, 42, 42, 2)];
			_flashLayer.addChild(titleBar);
			titleBar.addEventListener(Event.COMPLETE, onTitleComplete);
			titleBar.animateIn(_width / 2, _height / 2, _width / 2, 200, 3000);
			showDarkScreen(200, 3000, 0.7);
			flashScreen();
			
			function onTitleComplete(e:Event):void
			{
				// Remove listener.
				titleBar.removeEventListener(Event.COMPLETE, onTitleComplete);
				
				// Remove display object.
				_flashLayer.removeChild(titleBar);
			}
		}
		
		private function showResultDescription(text:String, color:uint, fromLeftSide:Boolean):void
		{
			trace('PickemScreenView: Showing result description.');
			_resultDescriptionBeenShown = true;
			// Apply text value and set format.
			_resultDescriptionField.text = text;
			var format:TextFormat = _resultDescriptionField.getTextFormat();
			format.color = color;
			_resultDescriptionField.setTextFormat(format);
			// Position the text field off screen.
			_resultDescriptionField.x = (fromLeftSide == true) ? -_resultDescriptionField.width : _width;
			_resultDescriptionField.y = _questionTextField.y + _questionTextField.height;
			_textLayer.addChild(_resultDescriptionField);
			
			// Animate in.
			// Create local var for animation manager.
			var animationManager:AnimationManager = _pickemModel.animationManager;
			var destX:Number = _width / 2 - _resultDescriptionField.width / 2;
			animationManager.addEventListener(AnimationEvent.FINISH, onAnimationFinish);
			animationManager.move(_resultDescriptionField, destX, _resultDescriptionField.y, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			function onAnimationFinish(e:AnimationEvent):void
			{
				if (e.animTarget == _resultDescriptionField)
				{
					if (_resultDescriptionField.x == destX)
					{
						// Animate in is finished.
						
						// Remove event listener.
						animationManager.removeEventListener(AnimationEvent.FINISH, onAnimationFinish);
					}
				}
			}
		}
		
		private function hideResultDescription():void
		{
			trace('PickemScreenView: Hiding result description.');
			// Animate out.
			// Create local var for animation manager.
			var animationManager:AnimationManager = _pickemModel.animationManager;
			var destX:Number = -_resultDescriptionField.width;
			animationManager.addEventListener(AnimationEvent.FINISH, onAnimationFinish);
			animationManager.move(_resultDescriptionField, destX, _resultDescriptionField.y, 1000, Transitions.CUBIC_OUT, RenderMethod.TIMER);
			
			function onAnimationFinish(e:AnimationEvent):void
			{
				if (e.animTarget == _resultDescriptionField)
				{
					if (_resultDescriptionField.x == destX)
					{
						// Animate in is finished.
						
						// Remove event listener.
						animationManager.removeEventListener(AnimationEvent.FINISH, onAnimationFinish);
						
						// Remove display object;
						if (_textLayer.contains(_resultDescriptionField)) _textLayer.removeChild(_resultDescriptionField);
					}
				}
			}
		}
		
		public function voteRegistered():void
		{
			voteRegisteredAnimation();
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get questionText():String
		{
			return _questionText;
		}
		public function set questionText(value:String):void
		{
			if (value == _questionText) return;
			_questionText = value;
			transitionTextField(_questionTextField, _questionText, 1000);
		}
		
		public function set answer1Text(value:String):void
		{
			if (value == _answer1Text) return;
			_answer1Text = value;
			_answer1Field.text = _answer1Text;
			renderAnswer1();
		}
		
		public function set answer2Text(value:String):void
		{
			if (value == _answer2Text) return;
			_answer2Text = value;
			_answer2Field.text = _answer2Text;
			renderAnswer2();
		}
		
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			if (value == _width) return;
			_width = value;
			
			if (_initialAnswerRender == false)
			{
				animateAnswerWidth();
				_initialAnswerRender = true;
			}
			
			render();
		}
		
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			if (value == _height) return;
			_height = value;
			render();
		}
		
		public function get answer1Image():DisplayObject
		{
			return _answer1Image;
		}
		public function set answer1Image(value:DisplayObject):void
		{
			if (value == _answer1Image) return;
			
			// If there is currently an answer image, remove it.
			if (_answer1Image != null && _answerImageLayer1.contains(_answer1Image)) _answerImageLayer1.removeChild(_answer1Image);
			
			// Set value.
			_answer1Image = value;
			
			// Apply filters.
			_answer1Image.filters = _answerImageFilters;
			
			// Add the new image to the display.
			_answerImageLayer1.addChild(_answer1Image);
			
			renderAnswer1();
		}
		
		public function get answer2Image():DisplayObject
		{
			return _answer2Image;
		}
		public function set answer2Image(value:DisplayObject):void
		{
			if (value == _answer2Image) return;
			
			// If there is currently an answer image, remove it.
			if (_answer2Image != null && _answerImageLayer2.contains(_answer2Image)) _answerImageLayer2.removeChild(_answer2Image);
			
			// Set value.
			_answer2Image = value;
			
			// Apply filters.
			_answer2Image.filters = _answerImageFilters;
			
			// Add the new image to the display.
			_answerImageLayer2.addChild(_answer2Image);
			
			renderAnswer2();
		}
		
		public function get countdownTime():int
		{
			return _countdownTime;
		}
		public function set countdownTime(value:int):void
		{
			if (value == _countdownTime) return;
			_countdownTime = value;
			
			// If the value is less than 5 and we are in the poll state.
			// Animate the countdown field.
			if (_countdownTime < 5 && _viewState == PickemViewState.POLL_STATE)
			{
				transitionTextField(_countdownField, _countdownTime.toString(), 200, 4);
			}
			else
			{
				_countdownField.text = _countdownTime.toString();
				render();
			}
		}
		
		public function set resultLabel(value:String):void
		{
			if (value == _resultLabel) return;
			_resultLabel = value;
			_resultTypeField.text = _resultLabel;
			//transitionTextField(_resultTypeField, _resultLabel, 2000);
		}
		
		public function get roomAnswer1Picks():Number
		{
			return _roomAnswer1Picks;
		}
		public function set roomAnswer1Picks(value:Number):void
		{
			if (value == _roomAnswer1Picks) return;
			_roomAnswer1Picks = value;
			render();
		}
		
		public function get roomAnswer2Picks():Number
		{
			return _roomAnswer2Picks;
		}
		public function set roomAnswer2Picks(value:Number):void
		{
			if (value == _roomAnswer2Picks) return;
			_roomAnswer2Picks = value;
			render();
		}
		
		public function get worldAnswer1Picks():Number
		{
			return _worldAnswer1Picks;
		}
		public function set worldAnswer1Picks(value:Number):void
		{
			if (value == _worldAnswer1Picks) return;
			_worldAnswer1Picks = value;
			render();
		}
		
		public function get worldAnswer2Picks():Number
		{
			return _worldAnswer2Picks;
		}
		public function set worldAnswer2Picks(value:Number):void
		{
			if (value == _worldAnswer2Picks) return;
			_worldAnswer2Picks = value;
			render();
		}
		
		public function get roomResultBreakdown():Number
		{
			// 0.5 means 50% Answer 1, 50% Answer 2
			// 0.2 means 20% Answer 1, 80% Answer 2
			// -1 means we don't have results.
			
			return _roomResultBreakdown;
		}
		public function set roomResultBreakdown(value:Number):void
		{
			if (value == _roomResultBreakdown) return;
			_roomResultBreakdown = value;
			render();
		}
		
		public function get worldResultBreakdown():Number
		{
			// 0.5 means 50% Answer 1, 50% Answer 2
			// 0.2 means 20% Answer 1, 80% Answer 2
			// -1 means we don't have results.
			
			return _worldResultBreakdown;
		}
		public function set worldResultBreakdown(value:Number):void
		{
			if (value == _worldResultBreakdown) return;
			_worldResultBreakdown = value;
			render();
			
			if (_worldResultBreakdown >= 0 && _resultDescriptionBeenShown == false)
			{
				var answer1IsDominant:Boolean = (_worldResultBreakdown < 0.5) ? false : true;
				showResultDescription('World Results', (answer1IsDominant) ? _answerColor1 : _answerColor2, answer1IsDominant);
			}
			
			animateAnswerWidth();
		}
		
		public function get viewState():String
		{
			return _viewState;
		}
		public function set viewState(value:String):void
		{
			// If not a recognized value, do nothing.
			if (value == _viewState) return;
			switch (value)
			{
				case PickemViewState.POLL_STATE :
					setValue();
					worldResultBreakdown = -1;
					hideResultDescription();
					_resultDescriptionBeenShown = false;
					break;
				case PickemViewState.RESULT_AGGREGATION_STATE :
					setValue();
					resultLabel = 'Getting\nResults';
					break;
				case PickemViewState.ROOM_RESULT_STATE :
					setValue();
					resultLabel = 'Room\nResults';
					break;
				case PickemViewState.WORLD_RESULT_STATE :
					setValue();
					resultLabel = 'Current\nResults';
					break;
				case PickemViewState.OFF_HOURS :
					setValue();
					break;
				case PickemViewState.IN_QUE_TO_START :
					setValue();
					break;
				case PickemViewState.ERROR :
					setValue();
					break;
			}
			
			function setValue():void
			{
				_viewState = value;
				render();
			}
		}
		
		public function get answer1Position():Number
		{
			return _answer1Position;
		}
		public function set answer1Position(value:Number):void
		{
			// Number from 0 to 1.
			// Represents how much of the answer and its backing are shown.
			// Fully hidden is 0.
			// Fully visible is 1.
			
			// Make sure there is a difference before we do anything.
			if (value == _answer1Position) return;
			
			// Set value.
			_answer1Position = value;
			
			// Render answer 1.
			renderAnswer1();
		}
		
		public function get answer2Position():Number
		{
			return _answer2Position;
		}
		public function set answer2Position(value:Number):void
		{
			// Number from 0 to 1.
			// Represents how much of the answer and its backing are shown.
			// Fully hidden is 0.
			// Fully visible is 1.
			
			// Make sure there is a difference before we do anything.
			if (value == _answer2Position) return;
			
			// Set value.
			_answer2Position = value;
			
			// Render answer 2.
			renderAnswer2();
		}
		
		public function get answer1Width():Number
		{
			return _answer1Width;
		}
		public function set answer1Width(value:Number):void
		{
			if (value == _answer1Width) return;
			_answer1Width = value;
			render();
		}
		
		public function get answer2Width():Number
		{
			return _answer2Width;
		}
		public function set answer2Width(value:Number):void
		{
			if (value == _answer2Width) return;
			_answer2Width = value;
			render();
		}
		
		public function get answerHeight():Number
		{
			return _answerArea.height - _spacing - _outerMargin;
		}
		
		public function set answerColor1(value:uint):void
		{
			if (value == _answerColor1) return;
			_answerColor1 = value;
			renderAnswer1();
		}
		
		public function set answerColor2(value:uint):void
		{
			if (value == _answerColor2) return;
			_answerColor2 = value;
			renderAnswer2();
		}
		
		public function set backgroundLoopSound(value:Sound):void
		{
			if (_backgroundLoopSound != null) return;
			_backgroundLoopSound = value;
			
			// Start looping the sound.
			var transform:SoundTransform = new SoundTransform(0.2);
			_backgroundLoopChannel = _backgroundLoopSound.play(0, 0, transform);
			_backgroundLoopChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			
			function onSoundComplete(e:Event):void
			{
				// Play the sound again.
				_backgroundLoopChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
				_backgroundLoopChannel = _backgroundLoopSound.play(0, 0, transform);
				_backgroundLoopChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			}
		}
		
		public function get countdownAlpha():Number
		{
			return _countdownField.alpha;
		}
		public function set countdownAlpha(value:Number):void
		{
			_countdownField.alpha = value;
		}
		
		public function set offHoursMessage(value:String):void
		{
			if (value == _offHoursField.text) return;
			_offHoursField.text = value;
			render();
		}
		
	}
}