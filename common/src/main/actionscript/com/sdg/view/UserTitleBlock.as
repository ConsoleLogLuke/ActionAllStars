package com.sdg.view
{
	import com.good.goodui.FluidView;
	import com.sdg.model.IIdObject;
	import com.sdg.model.IInitable;
	
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class UserTitleBlock extends FluidView implements IIdObject, IInitable
	{
		protected static var _dropShadow:DropShadowFilter = new DropShadowFilter(2, 45, 0, 0.6);
		protected var _id:uint;
		protected var _name:String;
		protected var _level:uint;
		protected var _teamId:uint;
		protected var _teamName:String;
		protected var _color1:uint;
		protected var _color2:uint;
		protected var _margin:Number;
		protected var _isInit:Boolean;
		
		protected var _back:UserTitleBackground;
		protected var _icon:TeamIcon;
		protected var _nameField:TextField;
		
		public function UserTitleBlock(id:uint, name:String, level:uint, teamId:uint, teamName:String, color1:uint, color2:uint, width:Number = 247, height:Number = 54, autoInit:Boolean = true)
		{
			_id = id;
			_name = name;
			_level = level;
			_teamId = teamId;
			_teamName = teamName;
			_color1 = color1;
			_color2 = color2;
			_margin = 5;
			_isInit = false;
			
			_back = new UserTitleBackground(width, height, _level, _color1, _color2, autoInit);
			_back.mouseEnabled = false;
			_back.mouseChildren = false;
			
			_icon = new TeamIcon(height - _margin * 2, _height - _margin * 2, _teamId, _color1, _color2, autoInit);
			_icon.filters = [_dropShadow];
			
			_nameField = new TextField();
			_nameField.defaultTextFormat = new TextFormat('EuroStyle', 16, 0xffffff, true);
			_nameField.autoSize = TextFieldAutoSize.LEFT;
			_nameField.selectable = false;
			_nameField.mouseEnabled = false;
			_nameField.filters = [_dropShadow];
			_nameField.embedFonts = true;
			_nameField.text = _name;
			
			addChild(_back);
			addChild(_icon);
			addChild(_nameField);
			
			super(width, height);
			
			render();
		}
		
		public function init():void
		{
			// Make sure we only init once.
			if (_isInit == true) return;
			_isInit = true;
			
			_back.init();
			_icon.init();
		}
		
		public function destroy():void
		{
			// Remove displays.
			removeChild(_back);
			removeChild(_icon);
			removeChild(_nameField);
			
			// Destroy children.
			_back.destroy();
			_icon.destroy();
			
			// Destroy references to help garbage collection.
			_back = null;
			_icon = null;
			_nameField = null;
		}
		
		public function setParams(id:uint, name:String, level:uint, teamId:uint, teamName:String, color1:uint, color2:uint):void
		{
			_id = id;
			_name = name;
			_level = level;
			_teamId = teamId;
			_teamName = teamName;
			_color1 = color1;
			_color2 = color2;
			
			_nameField.text = name;
			
			_back.setParams(level, color1, color2);
			
			_icon.setParams(teamId, color1, color2);
		}
		
		override protected function render():void
		{
			super.render();
			
			_back.width = _width;
			_back.height = _height;
			
			var iH:Number = _height - _margin * 2;
			_icon.x = _margin;
			_icon.y = _margin;
			_icon.width = iH;
			_icon.height = iH;
			
			_nameField.x = _icon.x + _icon.width + _margin;
			_nameField.y = _margin;
		}
		
		public function get id():uint
		{
			return _id;
		}
		
		override public function get name():String
		{
			return _name;
		}
		
		public function get embedFonts():Boolean
		{
			return _nameField.embedFonts;
		}
		public function set embedFonts(value:Boolean):void
		{
			_nameField.embedFonts = value;
		}
		
		public function get font():String
		{
			return _nameField.defaultTextFormat.font;
		}
		public function set font(value:String):void
		{
			_nameField.setTextFormat(new TextFormat(value, 16, 0xffffff, true));
		}
		
	}
}