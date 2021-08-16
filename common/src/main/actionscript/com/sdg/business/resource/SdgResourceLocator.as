package com.sdg.business.resource
{
	import com.sdg.factory.AnimationSetFactory;
	import com.sdg.factory.SimpleXMLObjectFactory;
	import com.sdg.model.BadgeRewardMessage;
	import com.sdg.model.ItemViewMetrics;
	import com.sdg.model.LevelMessage;
	import com.sdg.model.ModelLocator;
	import com.sdg.model.SdgItemClassId;
	import com.sdg.model.SpriteTemplate;
	import com.sdg.net.Environment;
	import com.sdg.utils.Constants;
	
	import flash.display.Bitmap;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	public class SdgResourceLocator
	{
		protected var rscLocator:RemoteResourceLocator = new RemoteResourceLocator();
		
		private static var _instance:SdgResourceLocator;
		
		public static function getInstance():SdgResourceLocator
		{
			if (_instance == null) _instance = new SdgResourceLocator();
			return _instance;
		}
		
		public function SdgResourceLocator()
		{
			if (_instance)
				throw new Error("SdgResourceLocator is a singleton class. Use 'getInstance()' to access the instance.");

			rscLocator.setResourceFactory("animationSet", SdgServiceResource, 1000, new AnimationSetFactory(), true);
			rscLocator.setResourceFactory("itemViewMetrics", SdgServiceResource, 1000, new SimpleXMLObjectFactory(ItemViewMetrics, "itemViewMetrics"), true);
			rscLocator.setResourceFactory("spriteTemplate", SdgServiceResource, 1000, new SimpleXMLObjectFactory(SpriteTemplate, "spriteTemplate"), true);
			rscLocator.setResourceFactory("levelMessaging", SdgServiceResource, 1000, new SimpleXMLObjectFactory(LevelMessage,"levelMessage"), true);
			rscLocator.setResourceFactory("badgeMessaging", SdgServiceResource, 1000, new SimpleXMLObjectFactory(BadgeRewardMessage,"badgeMessage"), true);
			if(Constants.SWF_SPRITES_ENABLED){
				rscLocator.setResourceFactory("static/spriteswf", LoaderResource, 250000);
				rscLocator.setResourceFactory("static/spriteswf", AvatarLoaderResource, 75000);
			}else{
				rscLocator.setResourceFactory("static/spritesheet", LoaderResource, 250000);
				rscLocator.setResourceFactory("static/spritesheet", AvatarLoaderResource, 75000);
			}
			rscLocator.setResourceFactory("doodadspritesheet", LoaderResource, 50000);
			rscLocator.setResourceFactory("swfDoodad", createChildDomainLoaderResource, 50000);
			rscLocator.setResourceFactory("swfDoodad/layer", createChildDomainLoaderResource, 50000);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Requests
		//
		//--------------------------------------------------------------------------
		
		public function getAnimationSet(animationSetId:uint):IRemoteResource
		{
			return getServiceResource("animationSet", { animationSetId: animationSetId });
		}
		
		public function getItemViewMetrics(itemViewMetricsId:uint):IRemoteResource
		{
			return getServiceResource("itemViewMetrics", { itemViewMetricsId:itemViewMetricsId });
		}
		
		public function getSpriteTemplate(spriteTemplateId:uint):IRemoteResource
		{
			return getServiceResource("spriteTemplate", { spriteTemplateId:spriteTemplateId });
		}
		
		public function getLevelMessage(levelId:uint):IRemoteResource
		{
			return getServiceResource("levelMessaging", { levelId:levelId });
		}
		
		public function getBadgeRewardMessage(rewardId:uint):IRemoteResource
		{
			return getServiceResource("badgeMessaging", { rewardId:rewardId });
		}
		
		public function getSpriteSheet(itemClassId:uint, id:uint, animationSetId:uint, spriteTemplateId:uint, layer:uint, version:String = null):IRemoteResource
		{
			switch (itemClassId)
			{
				case SdgItemClassId.INVENTORY_ITEM :
					return getDoodadSpriteSheet(id, animationSetId, spriteTemplateId, layer, version);
					break;
				case SdgItemClassId.AVATAR :
					return getAvatarSpriteSheet(id, animationSetId, spriteTemplateId, layer, version);
					break;
				case SdgItemClassId.APPAREL_ITEM :
					return getAvatarSpriteSheetLayer(id, spriteTemplateId, layer, 101);
					break;
			}
			
			return null;
		}
		
		public function getAvatarSpriteSheet(avatarId:uint, animationSetId:uint, spriteTemplateId:uint, layer:uint, version:String = null):IRemoteResource
		{
			var params:Object = { avatarId:avatarId, animationSetId:animationSetId, layerId:500 };
			if (version != null) params.version = version;
			
			var resources:RemoteResourceMap = new RemoteResourceMap();
			resources.contentFactory = new SpriteSheetFactory();
			resources.setResource("spriteTemplate", getSpriteTemplate(spriteTemplateId));
			resources.setResource("spriteBitmap", getAssetResource("avatarspritesheet", params));
			
			return resources;
		}
		
		public function getAvatarSpriteSheetLayer(itemId:uint, spriteTemplateId:uint, layerId:uint, contextId:uint = 101):IRemoteResource
		{
			var params:Object = { itemId:itemId, layerId:layerId, contextId:contextId };
			var resources:RemoteResourceMap = new RemoteResourceMap();
			resources.contentFactory = new SpriteSheetFactory();
			resources.setResource("spriteTemplate", getSpriteTemplate(spriteTemplateId));

			// look for the bitmap in the cache
			var cacheKey:String = itemId + "/" + layerId + "/" + contextId;
			var bitmap:Bitmap = ModelLocator.getInstance().expandedSpriteSheetBitmapsPerm[cacheKey] as Bitmap;
			if (bitmap == null)
			{
				bitmap = ModelLocator.getInstance().expandedSpriteSheetBitmaps[cacheKey] as Bitmap;
				if (bitmap != null)
					trace("Got expanded bitmap from non-perm cache for " + cacheKey); 
			}
			else
				trace("Got expanded bitmap from perm cache for " + cacheKey); 
			
			// use the cached bitmap or start loading it if it wasn't found
			if (bitmap != null)
				SpriteSheetFactory(resources.contentFactory).setData(bitmap);
			else{
				if(Constants.SWF_SPRITES_ENABLED){
					resources.setResource("spriteBitmap", getAssetResource("static/spriteswf", params));
				}else{
					resources.setResource("spriteBitmap", getAssetResource("static/spritesheet", params));
				}
			}
			// set the layer id for this spritesheet 
			if (layerId == Constants.LAYER_SHOES_UPPER)
				layerId = Constants.SPRITESHEET_PRIORITY_SHOES_UPPER;
			else if (layerId == Constants.LAYER_SHOES_LOWER)
				layerId = Constants.SPRITESHEET_PRIORITY_SHOES_LOWER;
			else if (layerId == Constants.LAYER_PANTS)
				layerId = Constants.SPRITESHEET_PRIORITY_PANTS;
				
			SpriteSheetFactory(resources.contentFactory).layerId = layerId;
			
			return resources;
		}
		
		public function getDoodadSpriteSheet(itemId:uint, animationSetId:uint, spriteTemplateId:uint, layer:uint, version:String = null):IRemoteResource
		{
			var params:Object = { itemId:itemId, animationSetId:animationSetId, layerId:500 };
			if (version != null) params.version = version;
			
			var resources:RemoteResourceMap = new RemoteResourceMap();
			resources.contentFactory = new SpriteSheetFactory();
			resources.setResource("spriteTemplate", getSpriteTemplate(spriteTemplateId));
			resources.setResource("spriteBitmap", getAssetResource("doodadspritesheet", params));
			
			return resources;
		}
		
		public function getDoodadSWF(itemId:uint):IRemoteResource
		{
			return getAssetResource("swfDoodad", { itemId:itemId });
		}
		
		public function getDoodadSWF_1(itemId:uint):IRemoteResource
		{
			return getAssetResource("swfDoodad/layer", { itemId:itemId, layerId:1 });
		}
		
		// Used only briefly, but should be used more going forward
		public function getDoodadSWF_Layer(itemId:uint,layerId:uint):IRemoteResource
		{
			return getAssetResource("swfDoodad/layer", { itemId:itemId, layerId:layerId });
		}
		
		//--------------------------------------------------------------------------
		//
		//  General retrieval methods
		//
		//--------------------------------------------------------------------------
		
		protected function getAssetResource(type:String, params:Object = null):IRemoteResource
		{
			return rscLocator.getResource(type, Environment.getAssetUrl() + "/test/" + type, params);
		}
		
		protected function getServiceResource(type:String, params:Object = null):IRemoteResource
		{
			return rscLocator.getResource(type, type, params);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Resource factory methods
		//
		//--------------------------------------------------------------------------
		
		public function createChildDomainLoaderResource(info:ResourceInfo):IRemoteResource
		{
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
			
			var resource:LoaderResource = new LoaderResource(info);
			resource.loaderContext = loaderContext;
			return resource;
		}
	}
}

import com.sdg.business.resource.*;
import com.sdg.display.SpriteSheet;
import com.sdg.factory.IContentFactory;
import com.sdg.model.SpriteTemplate;
import com.sdg.utils.Constants;

import flash.display.*;

class SpriteSheetFactory implements IContentFactory
{
	protected var resources:RemoteResourceMap;
	private var _bitmap:Bitmap;
	private var _layerId:uint = 0;
	
	public function setData(data:Object):void
	{
		var bitmap:Bitmap = data as Bitmap;
		if (bitmap != null)
			_bitmap = bitmap;
		else	
			resources = RemoteResourceMap(data);
	}
	
	public function set layerId(value:uint):void
	{
		_layerId = value;
	}
	
	public function createInstance():Object
	{
		var template:SpriteTemplate = resources.getContent("spriteTemplate") as SpriteTemplate;
		var bitmap:Bitmap = _bitmap != null ? _bitmap : resources.getContent("spriteBitmap") as Bitmap;	
		
	    if (bitmap) return new SpriteSheet(template.spriteWidth, template.spriteHeight, bitmap.bitmapData, _layerId);
		
		return null;
	}
}