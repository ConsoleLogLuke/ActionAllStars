package com.sdg.store.skin
{
	import com.sdg.net.Environment;
	import com.sdg.store.StoreConstants;
	
	public class FirstStoreSkin implements IStoreSkin
	{
		protected var _assetPath:String;
		protected var _storeId:int = -1;
		
		public function FirstStoreSkin()
		{
			var gameId:String = '70';
			_assetPath = Environment.getAssetUrl() + '/test/gameSwf/gameId/' + gameId + '/gameFile/';
		}

		public function get avatarPreviewBackgroundUrl():String
		{
			return _assetPath + 'avatarPreview_panel.swf';
		}
		
		public function get itemListBackgroundUrl():String
		{
			return _assetPath + 'midPanelBacking.swf';
		}
		
		public function get itemListWindowBackgroundUrl():String
		{
			return _assetPath + 'itemWindowBackground.swf';
		}
		
		public function get magnifyingGlassUrl():String
		{
			return _assetPath + 'magnifyingGlass.swf';
		}
		
		public function get addTokensButtonUrl():String
		{
			return _assetPath + 'btn_addTokens.swf';
		}
		
		public function get navBorderTopUrl():String
		{
			switch (_storeId)
			{
				case (StoreConstants.STORE_ID_MLB) :
					return _assetPath + 'navTop_MLB.swf';
				case (StoreConstants.STORE_ID_NBA) :
					return _assetPath + 'navTop_NBA.swf';
				case (StoreConstants.STORE_ID_NFL) :
					return _assetPath + 'navTop_NFL.swf';
				case (StoreConstants.STORE_ID_VERTVILLAGE) :
					return _assetPath + 'navTop_AAS.swf';
				case (StoreConstants.STORE_ID_RIVERWALK) :
					return _assetPath + 'navTop_AAS.swf';
				default :
					return _assetPath + 'navTop_AAS.swf';
			}
		}
		
		public function get navBorderMiddleUrl():String
		{
			return _assetPath + 'navMiddle_NBA.swf';
		}
		
		public function get navBorderBottomUrl():String
		{
			return _assetPath + 'navBottom_NBA.swf';
		}
		
		public function set storeId(value:int):void
		{
			_storeId = value;
		}
		
	}
}