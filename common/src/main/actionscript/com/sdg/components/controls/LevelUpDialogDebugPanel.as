package com.sdg.components.controls
{
	import com.sdg.components.controls.store.StoreNavBar;
	import com.sdg.display.LineStyle;
	import com.sdg.events.GameResultEvent;
	import com.sdg.graphics.GradientStyle;
	import com.sdg.graphics.RoundRectStyle;
	import com.sdg.manager.BadgeManager;
	import com.sdg.manager.LevelManager;
	import com.sdg.model.ModelLocator;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	public class LevelUpDialogDebugPanel extends Sprite
	{
		protected var _background:Sprite;
		protected var _name:TextField;
		protected var _secondName:TextField;
		protected var _typeField:TextField;
		protected var _indexField:TextField;
		protected var _button:StoreNavBar;
		
		protected var _levelField:TextField;
		protected var _button2:StoreNavBar;
		
		protected var _typeBacking:Sprite;
		protected var _indexBacking:Sprite;
		protected var _levelBacking:Sprite;
		
		protected var _height:uint;
		protected var _width:uint;
		protected var _cornerSize:uint;
		
		public function LevelUpDialogDebugPanel()
		{
			super();
			
 			_height = 40;
			_width = 175;
			_cornerSize = 5;
			
			_background = new Sprite();
			addChild(_background);
			
			_typeBacking = new Sprite();
			addChild(_typeBacking);
			
			_indexBacking = new Sprite();
			addChild(_indexBacking);
			
			_levelBacking = new Sprite();
			addChild(_levelBacking);
			
			_name = new TextField();
			_name.defaultTextFormat = new TextFormat('EuroStyle', 10, 0xffffff, true);
			_name.text = 'DIALOG DEBUG';
			_name.autoSize = TextFieldAutoSize.LEFT;
			_name.embedFonts = true;
			_name.selectable = false;
			addChild(_name);
			
			_secondName = new TextField();
			_secondName.defaultTextFormat = new TextFormat('EuroStyle', 10, 0xffffff, true);
			_secondName.text = 'LEVELER';
			_secondName.autoSize = TextFieldAutoSize.LEFT;
			_secondName.embedFonts = true;
			_secondName.selectable = false;
			addChild(_secondName);			
			
			_typeField = new TextField();
			_typeField.defaultTextFormat = new TextFormat('EuroStyle', 10, 0x000000, true);
			_typeField.type = TextFieldType.INPUT;
			_typeField.autoSize = TextFieldAutoSize.LEFT;
			_typeField.embedFonts = true;
			_typeField.selectable = true;
			_typeField.width = 20;
			addChild(_typeField);
			
			_indexField = new TextField();
			_indexField.defaultTextFormat = new TextFormat('EuroStyle', 10, 0x00000, true);
			_indexField.type = TextFieldType.INPUT;
			_indexField.autoSize = TextFieldAutoSize.LEFT;
			_indexField.embedFonts = true;
			_indexField.selectable = true;
			_indexField.width = 20;
			addChild(_indexField);
			
			_button = new StoreNavBar(25, 18, "X");
			_button.labelFormat = new TextFormat('EuroStyle', 10, 0x913300, true, false);
			_button.roundRectStyle = new RoundRectStyle(0,0);
			_button.borderStyle = new LineStyle(0x000000, 1, 1);
			var gradientBoxMatrix:Matrix = new Matrix();
			gradientBoxMatrix.createGradientBox(_button.width,_button.height, Math.PI/2, 0, 0);
			_button.gradient = new GradientStyle(GradientType.LINEAR, [0xf8db5c, 0xd28602], [1, 1], [0, 255], gradientBoxMatrix);
			_button.labelX = _button.width/2 - _button.labelWidth/2;
			addChild(_button);
			_button.addEventListener(MouseEvent.CLICK,onButtonClick);
			
			_levelField = new TextField();
			_levelField.defaultTextFormat = new TextFormat('EuroStyle', 10, 0x000000, true);
			_levelField.type = TextFieldType.INPUT;
			_levelField.autoSize = TextFieldAutoSize.LEFT;
			_levelField.embedFonts = true;
			_levelField.selectable = true;
			_levelField.width = 20;
			addChild(_levelField);
			
			_button2 = new StoreNavBar(25, 18, "X");
			_button2.labelFormat = new TextFormat('EuroStyle', 10, 0x913300, true, false);
			_button2.roundRectStyle = new RoundRectStyle(0,0);
			_button2.borderStyle = new LineStyle(0x000000, 1, 1);
			var gradientBoxMatrix2:Matrix = new Matrix();
			gradientBoxMatrix2.createGradientBox(_button2.width,_button2.height, Math.PI/2, 0, 0);
			_button2.gradient = new GradientStyle(GradientType.LINEAR, [0xf8db5c, 0xd28602], [1, 1], [0, 255], gradientBoxMatrix);
			_button2.labelX = _button2.width/2 - _button2.labelWidth/2;
			addChild(_button2);
			_button2.addEventListener(MouseEvent.CLICK,onButtonTwoClick);
			
			render();
		}
		
		protected function render():void
		{
			// Draw backing.
			_background.graphics.clear();
			_background.graphics.beginFill(0x25231d, 0.9);
			_background.graphics.drawRoundRect(0,0, _width, _height, _cornerSize, _cornerSize);
			
			_typeBacking.graphics.clear();
			_typeBacking.graphics.beginFill(0xffffff, 1.0);
			_typeBacking.graphics.drawRect(0,0,20,13);
			
			_indexBacking.graphics.clear();
			_indexBacking.graphics.beginFill(0xffffff, 1.0);
			_indexBacking.graphics.drawRect(0,0,20,13);
			
			_levelBacking.graphics.clear();
			_levelBacking.graphics.beginFill(0xffffff, 1.0);
			_levelBacking.graphics.drawRect(0,0,20,13);
			
			_name.x = 2;
			_name.y = 2;
			
			_typeBacking.x = 90;
			_typeBacking.y = 3;
			_typeField.x = 90;
			_typeField.y = 2
			
			_indexBacking.x = 120;
			_indexBacking.y = 3;
			_indexField.x = 120;
			_indexField.y = 2;			
			
			_button.x = 145;
			_button.y = 1;
			
			_secondName.x = 2;
			_secondName.y = 22;
			
			_levelBacking.x = 90;
			_levelBacking.y = 22;
			_levelField.x = 90;
			_levelField.y = 22;		
			
			_button2.x = 145;
			_button2.y = 21;
		}
		
		protected function onButtonClick(e:Event):void
		{
			trace("TYPE: "+_typeField.text);
			trace("INDEX: "+_indexField.text);
			if (_typeField.text == "b")
			{
				BadgeManager.badgeAwardTester(parseInt(_indexField.text));
			}
			else if (_typeField.text == "l")
			{
				LevelManager.awardLevel(parseInt(_indexField.text));
			}
		}
		
		protected function onButtonTwoClick(e:Event):void
		{
			var avatarId:uint = ModelLocator.getInstance().avatar.id;
			
			// BUILD XML
			var result:XML = <SdgRequest></SdgRequest>;
			result.appendChild("<gameId>105</gameId>");
			result.appendChild("<avatarId>"+avatarId+"</avatarId>");
			result.appendChild("<score>5</score>");
			result.appendChild("<startDate>5</startDate>");
			result.appendChild("<startTime>5</startTime>");
			result.appendChild("<endDate>5</endDate>");
			result.appendChild("<endTime>5</endTime>");
			result.appendChild("<submissionDate>5</submissionDate>");
			result.appendChild("<submissionTime>5</submissionTime>");
			var attributes:XML = <attributes></attributes>;
			attributes.appendChild("<points>5</points>");
			result.appendChild(attributes);	
			
			//dispatchEvent(new GameResultEvent(result));
		}
		
	}
}