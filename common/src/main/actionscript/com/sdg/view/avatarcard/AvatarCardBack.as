package com.sdg.view.avatarcard
{
	import com.good.goodgraphics.GoodRect;
	import com.good.goodui.FluidView;
	import com.sdg.events.AvatarApparelEvent;
	import com.sdg.model.Avatar;
	import com.sdg.model.AvatarLevel;
	import com.sdg.model.Level;
	import com.sdg.net.QuickLoader;
	import com.sdg.util.AssetUtil;
	import com.sdg.utils.BitmapUtil;
	import com.sdg.utils.DateUtil;
	import com.sdg.view.TeamIconEmboss;
	import com.sdg.view.TurfValueEmboss;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class AvatarCardBack extends FluidView
	{
		public static const FLIP_CLICK:String = 'flip click';
		
		protected var _back:Sprite;
		protected var _flipBtn:Sprite;
		protected var _avatar:Avatar;
		protected var _headShot:AvatarCardHeadShot;
		protected var _nameField:TextField;
		protected var _dropShadow:DropShadowFilter;
		protected var _draftedField:TextField;
		protected var _mvp:Sprite;
		protected var _levelMeter:Sprite;
		protected var _pointMeter:Sprite;
		protected var _teamBlock:Sprite;
		protected var _turfBlock:TurfValueEmboss;
		protected var _levelNameField:TextField;
		protected var _subLevelField:TextField;
		protected var _levelBack:Sprite;
		
		public function AvatarCardBack(avatar:Avatar, width:Number, height:Number)
		{
			_avatar = avatar;
			_dropShadow = new DropShadowFilter(1, 45, 0, 0.7, 4, 4);
			
			_back = new Sprite();
			
			_flipBtn = new Sprite();
			_flipBtn.buttonMode = true;
			
			_headShot = new AvatarCardHeadShot(_avatar, width / 3);
			
			_nameField = new TextField();
			_nameField.defaultTextFormat = new TextFormat('EuroStyle', 18, 0xffffff, true);
			_nameField.embedFonts = true;
			_nameField.selectable = false;
			_nameField.autoSize = TextFieldAutoSize.LEFT;
			_nameField.text = _avatar.name;
			_nameField.filters = [_dropShadow];
			
			_draftedField = new TextField();
			_draftedField.defaultTextFormat = new TextFormat('EuroStyle', 10, 0xffffff, true, false, null, null, null, TextFormatAlign.CENTER);
			_draftedField.embedFonts = true;
			_draftedField.selectable = false;
			_draftedField.autoSize = TextFieldAutoSize.CENTER;
			_draftedField.text = 'Drafted On\n00-00-0000';
			_draftedField.filters = [_dropShadow];
			
			_levelNameField = new TextField();
			_levelNameField.defaultTextFormat = new TextFormat('EuroStyle', 10, 0xffffff, true);
			_levelNameField.embedFonts = true;
			_levelNameField.selectable = false;
			_levelNameField.autoSize = TextFieldAutoSize.LEFT;
			_levelNameField.text = 'Amateur';
			_levelNameField.filters = [_dropShadow];
			
			_subLevelField = new TextField();
			_subLevelField.defaultTextFormat = new TextFormat('EuroStyle', 10, 0xffffff, true);
			_subLevelField.embedFonts = true;
			_subLevelField.selectable = false;
			_subLevelField.autoSize = TextFieldAutoSize.LEFT;
			_subLevelField.text = '1';
			_subLevelField.filters = [_dropShadow];
			
			_mvp = new Sprite();
			
			_levelMeter = new Sprite();
			
			_pointMeter = new Sprite();
			
			_teamBlock = new Sprite();
			
			_turfBlock = new TurfValueEmboss(100, 100, _avatar.level, _avatar.homeTurfValue, false);
			
			_levelBack = new GoodRect(10, 10, 6, Level.GetLevelColor(_avatar.level));
			
			super(width, height);
		}
		
		public function init():void
		{
			var backgroundUrl:String = AssetUtil.GetGameAssetUrl(99, 'avatar_card_back_' + _avatar.level.toString() + '.swf');
			var back:Sprite = new QuickLoader(backgroundUrl, render, null, 2);
			_back.addChild(back);
			
			var flipBtnUrl:String = AssetUtil.GetGameAssetUrl(99, 'card_flip_button.swf');
			var flipBtn:Sprite = new QuickLoader(flipBtnUrl, render, null, 2);
			flipBtn.mouseChildren = false;
			_flipBtn.addChild(flipBtn);
			_flipBtn.addEventListener(MouseEvent.CLICK, onFlipClick);
			
			var levMtrUrl:String = AssetUtil.GetGameAssetUrl(99, 'avatar_card_level_meter.swf');
			var levMtrReq:URLRequest = new URLRequest(levMtrUrl);
			var levMtrLoader:Loader = new Loader();
			levMtrLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLevelMeterComplete);
			levMtrLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLevelMeterError);
			levMtrLoader.load(levMtrReq);
			
			var ptMtrUrl:String = AssetUtil.GetGameAssetUrl(99, 'avatar_card_point_meter.swf');
			var ptMtrReq:URLRequest = new URLRequest(ptMtrUrl);
			var ptMtrLoader:Loader = new Loader();
			ptMtrLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onPointMeterComplete);
			ptMtrLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onPointMeterError);
			ptMtrLoader.load(ptMtrReq);
			
			var mvpStarUrl:String = AssetUtil.GetGameAssetUrl(99, 'mvp_star.swf');
			var star:Sprite = new QuickLoader(mvpStarUrl, render, null, 2);
			_mvp.visible = (_avatar.membershipStatus == 2); // If avatar is premium.
			_mvp.addChild(star);
			
			_headShot.addEventListener(Event.COMPLETE, onHeadShotComplete);
			_headShot.init();
			
			_teamBlock = new TeamIconEmboss(100, 100, _avatar.favoriteTeamId, true);
			
			_turfBlock.init();
			
			_draftedField.text = 'Drafted On\n' + DateUtil.DateToCommonString(_avatar.joinDate);
			
			_levelNameField.text = AvatarLevel.getLevelName(_avatar.level);
			
			_subLevelField.text = _avatar.subLevel.toString();
			
			addChild(_back);
			addChild(_mvp);
			addChild(_turfBlock);
			addChild(_teamBlock);
			addChild(_pointMeter);
			addChild(_levelMeter);
			addChild(_levelBack);
			addChild(_headShot);
			addChild(_levelNameField);
			addChild(_subLevelField);
			addChild(_draftedField);
			addChild(_nameField);
			addChild(_flipBtn);
			
			// Add event listeners.
			_avatar.addEventListener(AvatarApparelEvent.AVATAR_APPAREL_CHANGED, onAvatarApparelChanged);
			
			function onHeadShotComplete(e:Event):void
			{
				// Remove event listener.
				_headShot.removeEventListener(Event.COMPLETE, onHeadShotComplete);
				
				// Dispatch complete event.
				dispatchEvent(new Event(Event.COMPLETE));
			}
			
			function onLevelMeterError(e:Event):void
			{
				// Remove listeners.
				e.currentTarget.removeEventListener(Event.COMPLETE, onLevelMeterComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onLevelMeterError);
			}
			
			function onLevelMeterComplete(e:Event):void
			{
				// Remove listeners.
				e.currentTarget.removeEventListener(Event.COMPLETE, onLevelMeterComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onLevelMeterError);
				
				var levMtr:DisplayObject = levMtrLoader.content;
				_levelMeter.addChild(levMtr);
				
				MovieClip(levMtr).gotoAndStop(_avatar.subLevel);
				
				render();
			}
			
			function onPointMeterError(e:Event):void
			{
				// Remove listeners.
				e.currentTarget.removeEventListener(Event.COMPLETE, onPointMeterComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onPointMeterError);
			}
			
			function onPointMeterComplete(e:Event):void
			{
				// Remove listeners.
				e.currentTarget.removeEventListener(Event.COMPLETE, onPointMeterComplete);
				e.currentTarget.removeEventListener(IOErrorEvent.IO_ERROR, onPointMeterError);
				
				var ptMtr:DisplayObject = ptMtrLoader.content;
				_pointMeter.addChild(ptMtr);
				
				// Pass params.
				Object(ptMtr).start(_avatar.xpGamer, _avatar.xpGuru, _avatar.xpCollector, 0, 0, 0);
				
				render();
			}
		}
		
		public function destroy():void
		{
			// Remove event listeners.
			_avatar.removeEventListener(AvatarApparelEvent.AVATAR_APPAREL_CHANGED, onAvatarApparelChanged);
		}
		
		override protected function render():void
		{
			super.render();
			
			_back.width = _width;
			_back.height = _height;
			
			_flipBtn.x = _width - _flipBtn.width;
			_flipBtn.y = _height - _flipBtn.height;
			
			_headShot.x = _width / 2 - _headShot.width / 2;
			_headShot.y = _height * 0.1;
			
			_nameField.x = _width / 2 - _nameField.width / 2;
			_nameField.y = 10;
			
			_draftedField.x = _headShot.x + _headShot.width + (_width / 3 / 2) - _draftedField.width / 2;
			_draftedField.y = _headShot.y;
			
			var mvpScale:Number = ((_width / 3) * 0.8) / _mvp.width;
			_mvp.width *= mvpScale;
			_mvp.height *= mvpScale;
			_mvp.x = (_width / 3) * 0.1;
			_mvp.y = _mvp.x;
			
			var margin:Number = _width * 0.05;
			var levMtrScale:Number = (_width - margin * 2) / _levelMeter.width;
			_levelMeter.width *= levMtrScale;
			_levelMeter.height *= levMtrScale;
			_levelMeter.x = margin;
			_levelMeter.y = _headShot.y + _headShot.height + margin;
			
			var ptMtrScale:Number = (_width - margin * 2) / _pointMeter.width;
			_pointMeter.width *= ptMtrScale;
			_pointMeter.height *= ptMtrScale;
			_pointMeter.x = margin;
			_pointMeter.y = _levelMeter.y + _levelMeter.height + margin;
			
			_teamBlock.width = (_height - (_pointMeter.y + _pointMeter.height)) * 0.6;
			_teamBlock.height = _teamBlock.width;
			_teamBlock.x = margin * 2;
			_teamBlock.y = _pointMeter.y + _pointMeter.height + margin;
			
			_turfBlock.width = _teamBlock.width;
			_turfBlock.height = _teamBlock.height;
			_turfBlock.x = _width - _turfBlock.width - margin * 2;
			_turfBlock.y = _teamBlock.y;
			
			_levelNameField.x = _headShot.x - _levelNameField.width + 4;
			_levelNameField.y = _headShot.y + _headShot.height - _levelNameField.height - (_headShot.height * 0.1);
			
			_levelBack.width = (_headShot.x + (_headShot.width / 2) - _levelNameField.x + 4) * 2;
			_levelBack.height = _levelNameField.height;
			_levelBack.x = _width / 2 - _levelBack.width / 2;
			_levelBack.y = _levelNameField.y;
			
			_subLevelField.x = _levelBack.x + _levelBack.width - _subLevelField.width - 4;
			_subLevelField.y = _levelNameField.y;
		}
		
		public function getScaledBitmap(scale:Number,smooth:Boolean=false):Bitmap
		{	
			var cardMap:Bitmap = BitmapUtil.spriteToBitmap(this,smooth);
			cardMap.scaleX *= scale;
			cardMap.scaleY *= scale;
			
			return cardMap;
		}
		
		////////////////////
		// EVENT HANDLERS
		////////////////////
		
		private function onFlipClick(e:MouseEvent):void
		{
			dispatchEvent(new Event(FLIP_CLICK, true));
		}
		
		private function onAvatarApparelChanged(e:AvatarApparelEvent):void
		{
			
		}
		
	}
}