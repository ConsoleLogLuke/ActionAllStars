﻿package com.sdg.animation{		import com.sdg.animation.sequence.ISequence;	import com.sdg.display.SpriteSheet;	import com.sdg.model.SdgItem;	import com.sdg.model.SdgItemClassId;		import flash.display.Bitmap;	import flash.display.BitmapData;	import flash.geom.Point;	import flash.geom.Rectangle;	public class AnimationSetResource	{		private var _animationSet:AnimationSet;		private var _spriteSheets:Array;		private var _item:SdgItem;				public function AnimationSetResource(animationSet:AnimationSet, spriteSheets:Array, item:SdgItem, compositeFilters:Array = null)		{			// Any composite filters passed in will be applied to the final composited resource 			// and flattened into a bitmap. See "compositeSpriteSheets"						_animationSet = animationSet;			_spriteSheets = spriteSheets;			_item = item;						// If it's an avatar, composite the resource.			if (item.itemClassId == SdgItemClassId.AVATAR) compositeSpriteSheets();						// Composite filters into the composited sprite sheet.			if (compositeFilters) compositeSpriteSheetFilters(getSpriteSheet(0), compositeFilters);		}				////////////////////		// PUBLIC FUNCTIONS		////////////////////				public function getSequence(name:String):ISequence		{			return _animationSet.getSequence(name);		}				public function getSpriteSheet(index:int):SpriteSheet		{			return _spriteSheets[index];		}				////////////////////		// PRIVATE FUNCTIONS		////////////////////				private function compositeSpriteSheets():void		{			if (_spriteSheets.length == 0)				return;							// Sort the spritesheets by layerId.			_spriteSheets.sortOn("layerId", Array.NUMERIC);						// Use the bottom layer as the base.			// This should be the skin layer.			var mainSprite:SpriteSheet = _spriteSheets[0];							// Composite each sprite sheet together.			// "i" has to start at 1 because we already use the first layer for the base.			var point:Point = new Point(0, 0);			for (var i:int = 1; i < _spriteSheets.length; i++)			{				var spriteSheet:SpriteSheet = _spriteSheets[i] as SpriteSheet;				if (spriteSheet != null)				{					var sourceRect:Rectangle = new Rectangle(0, 0, spriteSheet.source.width, spriteSheet.source.height);					mainSprite.source.copyPixels(spriteSheet.source, sourceRect, point, null, null, true);				}			}						// Create a new sprite sheet array that only contains the composited sprite sheet.			_spriteSheets = [mainSprite];		}				private function compositeSpriteSheetFilters(source:SpriteSheet, compositeFilters:Array):void		{			// Apply filters to the source and compisite them into the bitmap.			if (!source) return;			var mainBitmap:Bitmap = new Bitmap(source.source);			mainBitmap.filters = compositeFilters;			var newBitData:BitmapData = new BitmapData(mainBitmap.width, mainBitmap.height, true, 0x00ff00);			newBitData.draw(mainBitmap);			source.source = newBitData;		}    }}