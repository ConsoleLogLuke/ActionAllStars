package com.sdg.store.preview
{
	import com.sdg.mvc.IView;
	
	import flash.display.DisplayObject;
	
	public interface IStoreAvatarPreviewView extends IView
	{
		function init(width:Number, height:Number):void;
		function animateTokens(newTokenValue:uint, duration:Number = 4000):void;
		function animateXp(amount:uint, duration:Number = 4000):void;
		function animateTokensAndXp(tokenAmount:uint, tokenDuration:Number, xpAmount:uint, xpDuration:Number):void
		
		function set avatarName(value:String):void;
		function set avatarImage(value:DisplayObject):void;
		function set avatarImageLoadProgress(value:Number):void;
		function set tokens(value:int):void;
		function set background(value:DisplayObject):void;
		function set level(value:int):void
		function set subLevel(value:int):void
		function set levelName(value:String):void;
		function set turfValue(value:int):void;
	}
}