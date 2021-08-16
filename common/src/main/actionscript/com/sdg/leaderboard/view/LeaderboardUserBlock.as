package com.sdg.leaderboard.view
{
	import com.sdg.events.UserTitleBlockEvent;
	import com.sdg.model.IInitable;
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;
	import com.sdg.view.UserTitleBlock;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class LeaderboardUserBlock extends UserTitleBlock implements IInitable
	{
		protected var _pointField:TextField;
		protected var _turfBtn:Sprite;
		
		protected var _points:int;
		
		public function LeaderboardUserBlock(id:uint, name:String, level:uint, points:int, teamId:uint, teamName:String, color1:uint, color2:uint, width:Number=247, height:Number=54, autoInit:Boolean=true)
		{
			_points = points;
			
			_pointField = new TextField();
			_pointField.defaultTextFormat = new TextFormat('EuroStyle', 13, 0xf0cd1e, true);
			_pointField.autoSize = TextFieldAutoSize.LEFT;
			_pointField.selectable = false;
			_pointField.mouseEnabled = false;
			_pointField.embedFonts = true;
			_pointField.text = _points.toString();
			_pointField.filters = [_dropShadow];
			
			_turfBtn = new Sprite();
			_turfBtn.filters = [_dropShadow];
			_turfBtn.buttonMode = true;
			
			super(id, name, level, teamId, teamName, color1, color2, width, height, autoInit);
			
			addChild(_turfBtn);
			addChild(_pointField);
		}
		
		////////////////////
		// PUBLIC METHODS
		////////////////////
		
		override public function init():void
		{
			super.init();
			
			_turfBtn.addEventListener(MouseEvent.CLICK, onTurfClick);
			var btnLoader:QuickLoader = new QuickLoader(AssetUtil.GetGameAssetUrl(74, 'homeTurfButton.swf'), render);
			_turfBtn.addChild(btnLoader);
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			_turfBtn.removeEventListener(MouseEvent.CLICK, onTurfClick);
		}
		
		////////////////////
		// PROTECTED METHODS
		////////////////////
		
		override protected function render():void
		{
			super.render();
			
			_pointField.x = _nameField.x;
			_pointField.y = _nameField.y + _nameField.height;
			
			var btnScale:Number = (_height - 24) / _turfBtn.height;
			_turfBtn.width *= btnScale;
			_turfBtn.height *= btnScale;
			_turfBtn.x = _width - _turfBtn.width - 20;
			_turfBtn.y = _height / 2 - _turfBtn.height / 2;
		}
		
		////////////////////
		// GET/SET METHODS
		////////////////////
		
		public function get useTurfButton():Boolean
		{
			return _turfBtn.visible;
		}
		public function set useTurfButton(value:Boolean):void
		{
			_turfBtn.visible = value;
		}
		
		public function get points():int
		{
			return _points;
		}
		public function set points(value:int):void
		{
			_points = value;
			_pointField.text = _points.toString();
		}
		
		public function get usePoints():Boolean
		{
			return _pointField.visible;
		}
		public function set usePoints(value:Boolean):void
		{
			_pointField.visible = value;
		}
		
		override public function set embedFonts(value:Boolean):void
		{
			super.embedFonts = value;
			
			_pointField.embedFonts = value;
		}
		
		override public function set font(value:String):void
		{
			super.font = value;
			
			_pointField.setTextFormat(new TextFormat(value, 13, 0xf0cd1e, true));
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onTurfClick(e:MouseEvent):void
		{
			dispatchEvent(new UserTitleBlockEvent(UserTitleBlockEvent.TURF_BUTTON_CLICK, _id, _name, _teamId, true));
		}
		
	}
}