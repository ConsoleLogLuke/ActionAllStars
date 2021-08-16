package com.sdg.store.skin
{
	public interface IStoreSkin
	{
		function get avatarPreviewBackgroundUrl():String;
		function get itemListBackgroundUrl():String;
		function get itemListWindowBackgroundUrl():String;
		function get magnifyingGlassUrl():String;
		function get addTokensButtonUrl():String;
		function get navBorderTopUrl():String;
		function get navBorderMiddleUrl():String;
		function get navBorderBottomUrl():String;
		function set storeId(value:int):void;
	}
}