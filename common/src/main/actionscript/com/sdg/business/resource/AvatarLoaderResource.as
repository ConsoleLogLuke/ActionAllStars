package com.sdg.business.resource
{
	import com.sdg.collections.MruCache;
	import com.sdg.model.ModelLocator;
	import com.sdg.utils.Constants;
	import com.sdg.utils.NetUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	/**
	 * This class gets the spritesheets we use to compose avatars
	 */ 
	public class AvatarLoaderResource extends AbstractResourceLoader implements IResourceLoader
	{
		public var loaderContext:LoaderContext;
		
		protected var _displayLoader:Loader;
		protected var _urlLoader:URLLoader;
		protected var _spriteSheetCache:MruCache = ModelLocator.getInstance().spriteSheetCache;
		protected var _cacheKey:String;
	    protected var _urlDownloadTimer:Timer = new Timer(10000, 1);
	    protected var _bitmapLoadTimer:Timer = new Timer(5000, 1);
	    protected var _templateItemId:int = 0;
	    private var bitmapDataBuffer:BitmapData;

	    public function AvatarLoaderResource()
	    {
	    	_urlDownloadTimer.addEventListener(TimerEvent.TIMER, onUrlDownloadTimerExpired);
	    	_bitmapLoadTimer.addEventListener(TimerEvent.TIMER, onBitmapLoadTimerExpired);
	    }
		
		override public function set info(value:ResourceInfo):void
		{
			super.info = value;
			
			// if we are coloring this item, we'll need the template id
			_templateItemId = getTemplateItemId(info.params.itemId);
			 
			// generate our sprite sheet cache ckey
			if (_templateItemId)
				_cacheKey = _templateItemId + "/" + info.params.layerId  + "/" + info.params.contextId;
			else	
				_cacheKey = info.params.itemId + "/" + info.params.layerId + "/" + info.params.contextId;
		}
		
		protected override function setComplete(content:*):void
		{
			// color the bitmap if we need to
			var bitmap:Bitmap = content as Bitmap;
			if (bitmap)
				bitmap = this.colorBitmap(bitmap);
			
			super.setComplete(bitmap);
		}
		
		override protected function loadContent():void
		{
			// we use the same mouth and eyes sprite sheets for all avatars
			var isMouth:Boolean = info.params.layerId == Constants.LAYER_MOUTH;
			var isEyes:Boolean = info.params.layerId == Constants.LAYER_EYES;
			if (isMouth && ModelLocator.getInstance().mouthSpriteSheet != null)
			{
				setComplete(ModelLocator.getInstance().mouthSpriteSheet);
				return;
			}
			if (isEyes && ModelLocator.getInstance().eyesSpriteSheet != null)
			{
				setComplete(ModelLocator.getInstance().eyesSpriteSheet);
				return;
			}
			
			// first, look in our perm cache (template sprite sheets should be here)
			var bitmap:Bitmap = ModelLocator.getInstance().expandedSpriteSheetBitmapsPerm[_cacheKey] as Bitmap;
			if (bitmap)
			{
				setComplete(bitmap);
				return;
			}
			
			// set up the display loader (loads our bitmap from compressed bytes - i.e. loader.loadbytes())
			// we get these compressed bytes from urlLoader or the cache
			// no cached spritesheet - get it from the server
			_displayLoader = ModelLocator.getInstance().expandingSpriteSheetLoaders[_cacheKey] as Loader;
			if (_displayLoader == null)
			{
				_displayLoader = new Loader();
				//var loaderInfo:LoaderInfo = _displayLoader.contentLoaderInfo;
				//loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				//loaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				//loaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				//loaderInfo.addEventListener(Event.COMPLETE, diplayLoaderComplete);
				
				_displayLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				_displayLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				_displayLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				_displayLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, diplayLoaderComplete);
			}
			else
			{
				// this bitemap already has a loader, listen for it's complete event
				_bitmapLoadTimer.start();
				_displayLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, diplayLoaderComplete);
				return;
			}

			// now get our compressed spritesheet - first look in the cache
			var bytes:ByteArray = _spriteSheetCache.getElement(_cacheKey) as ByteArray;
			if (bytes != null)
			{
				// got it!
				//trace("from cache: loading bitmap bytes for " + _cacheKey);
				_bitmapLoadTimer.start();
				_displayLoader.loadBytes(bytes);
				return;
			}
			else if (_spriteSheetCache.contains(_cacheKey))
			{
				// this was already determined to be missing in errorHandler()
				setComplete(null);
				return;
			}
			
			// no cached spritesheet - get it from the server
			_urlLoader = ModelLocator.getInstance().urlSpriteSheetLoaders[_cacheKey] as URLLoader;
			if (_urlLoader == null)
			{
				// set the the urlRequest
				var urlParams:Object = null;
				if (_templateItemId)
					urlParams = {itemId:_templateItemId, layerId:info.params.layerId, contextId:info.params.contextId};
				else
					urlParams = info.params;
					
				var urlRequest:URLRequest = NetUtil.createURLRequest(info.url, urlParams);
				
				// create the loader	
				_urlLoader = new URLLoader();
				
				// add it to our cache
				ModelLocator.getInstance().urlSpriteSheetLoaders[_cacheKey] = _urlLoader;
				
				// set the download format to binary
				_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				
				// add listeners
				_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				_urlLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				
				// start loading			
				_urlLoader.load(urlRequest);
			}
			
			// add the download complete listener
			_urlDownloadTimer.start();
			_urlLoader.addEventListener(Event.COMPLETE, urlLoaderComplete);
		}
		
		protected function diplayLoaderComplete(event:Event):void
		{
			_displayLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_displayLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_displayLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			_displayLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, diplayLoaderComplete);
			
			_bitmapLoadTimer.removeEventListener(TimerEvent.TIMER, onBitmapLoadTimerExpired);
			
			// stop the timer
			_bitmapLoadTimer.stop();
			
			// remove the loader from the expandingSpriteSheetLoaders collection
			ModelLocator.getInstance().expandingSpriteSheetLoaders[_cacheKey] = null;
			
			// finally got our bitmap 
			var bitmap:Bitmap = null;
			var loaderBitmap:Bitmap;
			if(Constants.SWF_SPRITES_ENABLED){
				//han experiment
				if(_displayLoader.content!=null && _displayLoader.contentLoaderInfo!=null && _displayLoader.contentLoaderInfo.bytesLoaded>0 && _displayLoader.content.width>0 && _displayLoader.content.height>0 && _displayLoader.content.width<=2880 && _displayLoader.content.height<=2880){
					// Create bitmap buffer.
					bitmapDataBuffer = new BitmapData(1440, 1440, true,0x00000000);
					bitmapDataBuffer.draw(_displayLoader.content);
					loaderBitmap = new Bitmap(bitmapDataBuffer);
				}
				_displayLoader.unload();
				
				//end han experiment
			}else{
				loaderBitmap = _displayLoader.content as Bitmap;
			}
			
			if (loaderBitmap != null)
			{
				// Set bitmap as the bitmap that was just loaded.
				bitmap = loaderBitmap;
			}
			
			setComplete(bitmap);
		}
		
		protected function urlLoaderComplete(event:Event):void
		{
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_urlLoader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			_urlLoader.removeEventListener(Event.COMPLETE, urlLoaderComplete);
			
			_urlDownloadTimer.removeEventListener(TimerEvent.TIMER, onUrlDownloadTimerExpired);
			
			// stop the timer
			_urlDownloadTimer.stop();
			
			// remove the loader from the downloadingSpriteSheets collection
			ModelLocator.getInstance().urlSpriteSheetLoaders[_cacheKey] = null;
			
			// get our bytesArray from urlLoader
			if (!_urlLoader.data is ByteArray)
				return;
			
			// do we need to caches this?	
			if (!_spriteSheetCache.contains(_cacheKey))
			{	
				// create a new byte array to cache.
				// note: just caching loader.contentLoaderInfo.bytes will add a reference to 
				//       the loader object and cause a nasty memory leak
				
				var bytes:ByteArray = new ByteArray();
				
				// load our new byte array
				bytes.writeBytes(_urlLoader.data);
				
				// add our new byte array to the cache
				_spriteSheetCache.addElement(_cacheKey, bytes);
			}
				
			// now load the bytes
			_displayLoader.loadBytes(ByteArray(_spriteSheetCache.getElement(_cacheKey)));
		}
		
		protected function errorHandler(event:ErrorEvent):void
		{
			trace("Error on " +  _cacheKey + ": " + event.text);
			_displayLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_displayLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_displayLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			_displayLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, diplayLoaderComplete);
			
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			_urlLoader.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
			_urlLoader.removeEventListener(Event.COMPLETE, urlLoaderComplete);
			
			_urlDownloadTimer.removeEventListener(TimerEvent.TIMER, onUrlDownloadTimerExpired);
	    	_bitmapLoadTimer.removeEventListener(TimerEvent.TIMER, onBitmapLoadTimerExpired);
			
			// stop our timers
			if (_bitmapLoadTimer.running)
				_bitmapLoadTimer.stop();
			if (_urlDownloadTimer.running)
				_urlDownloadTimer.stop();
					
			// set null for this sprite sheet (assume it does not exist)		
			_spriteSheetCache.addElement(_cacheKey, "missing");
			setComplete(null);				
		}
		
		protected function progressHandler(event:ProgressEvent):void
		{
			setProgress(event.bytesLoaded, event.bytesTotal);
		}
		
		protected function onUrlDownloadTimerExpired(event:TimerEvent):void
		{
			trace("\n **UrlLoadTimerExpired for " + _cacheKey + "** \n");
			
		}

		protected function onBitmapLoadTimerExpired(event:TimerEvent):void
		{
			trace("\n **BitmapTimerExpired for " + _cacheKey + "** \n");
		}
		
		protected function getTemplateItemId(itemId:int):int
		{
			// see if we need to use a template spriteSheet that we will color
			var templateItemId:int = 0;
			switch (info.params.itemId)
			{
//				// boy skin
//				case 2643:
//					templateItemId = info.params.layerId == Constants.LAYER_SKIN_SKATEBOARDING ? 4249 : 0;
//					break;						
//				case 2644:
//				case 2645:
//				case 2646:
//					templateItemId = info.params.layerId == Constants.LAYER_SKIN_SKATEBOARDING ? 4249 : 2643;
//					break;
//					
//				// girl skin
//				case 2647:
//					templateItemId = info.params.layerId == Constants.LAYER_SKIN_SKATEBOARDING ? 4249 : 0;
//					break;					
//				case 2648:
//				case 2649:
//				case 2650:
//					templateItemId = info.params.layerId == Constants.LAYER_SKIN_SKATEBOARDING ? 4249 : 2647;
//					break;
					
				case 2644:
				case 2645:
				case 2646:
					templateItemId = 2643;
					break;
					
				// girl skin
				case 2648:
				case 2649:
				case 2650:
					templateItemId = 2647;
					break;
					
				// shorts
				case 3516:
				case 2717:
				case 2718:
				case 2719:
					templateItemId = 2720;
					break;
					
				// shirts
				case 3514:
				case 2685:
				case 2686:
				case 2687:
					templateItemId = 2688;
					break;
					
				// hair 
				case 3465:
				case 3466:
				case 2631:
					templateItemId = 3464;
					break;
				case 3486:
				case 3487:
				case 3488:
					templateItemId = 3485;
					break;
				case 3468:
				case 3469:
				case 3470:
					templateItemId = 3467;
					break;
				case 3483:
				case 2633:
				case 3484:
					templateItemId = 3482;
					break;
				case 3479:
				case 3480:
				case 3481:
					templateItemId = 3478;
					break;
				case 3472:
				case 3473:
				case 3474:
					templateItemId = 3471;
					break;
				case 3490:
				case 3491:
				case 3492:
					templateItemId = 3489;
					break;
				case 3501:
				case 2977:
				case 3502:
					templateItemId = 3500;
					break;
				case 3497:
				case 3498:
				case 3499:
					templateItemId = 3496;
					break;
				case 3504:
				case 3505:
				case 3506:
					templateItemId = 3503;
					break;
				case 3494:
				case 3495:
				case 2634:
					templateItemId = 3493;
					break;
				case 2635:
				case 3508:
				case 3509:
					templateItemId = 3507;
					break;
				case 3511:
				case 3512:
				case 3513:
					templateItemId = 3510;
					break;
				case 2632:
				case 3476:
				case 3477:
					templateItemId = 3475;
					break;
					
				default:
					templateItemId = 0;
					break;
			}
			
			return templateItemId;
		}
		
		protected function colorBitmap(bitmap:Bitmap):Bitmap
		{
			// just return if we are not coloring anything
			if (_templateItemId == 0)
				return bitmap;
				
			// find the RGB multipliers for this item	
			var RedMultiplier:Number = 1;
			var Greenmultiplier:Number = 1;
			var BlueMultiplier:Number = 1;
			switch (info.params.itemId)
			{
				// boy/girl skin 
				case 2644:
				case 2648:
					RedMultiplier = .93;
					Greenmultiplier = .93;
					BlueMultiplier = .93;
					break;
				case 2645:
				case 2649:
					RedMultiplier = .78;
					Greenmultiplier = .78;
					BlueMultiplier = .78;
					break;
				case 2646:
				case 2650:
					RedMultiplier = .60;
					Greenmultiplier = .60;
					BlueMultiplier = .60;
					break;
					
				// shorts/shirts
				case 3514:
					RedMultiplier = .53;
					Greenmultiplier = 1;
					BlueMultiplier = 1;
					break;
				case 3516:
					RedMultiplier = .53;
					Greenmultiplier = .82;
					BlueMultiplier = .93;
					break;
				case 2717:
					RedMultiplier = .2;
					Greenmultiplier = .36;
					BlueMultiplier = .5;
					break;
				case 2685:
					RedMultiplier = .03;
					Greenmultiplier = .48;
					BlueMultiplier = .87;
					break;
				case 2686:
				case 2718:
					RedMultiplier = .52;
					Greenmultiplier = .52;
					BlueMultiplier = .52;
					break;
				case 2687:
				case 2719:
					RedMultiplier = .84;
					Greenmultiplier = .19;
					BlueMultiplier = .19;
					break;
					  
				// red hair
				case 3465:
				case 3476:				 
				case 3486:
				case 3468:
				case 3483:
				case 3479:
				case 3472:
				case 3490:
				case 3501:
				case 3497:
				case 3504:
				case 3494:
				case 2635:
				case 3511:
					RedMultiplier = .82;
					Greenmultiplier = .45;
					BlueMultiplier = .48;
					break;
					
				// brown hair	
				case 3466:
				case 2632:				 
				case 3487:
				case 3469:
				case 2633:
				case 3480:
				case 3473:
				case 3491:
				case 2977:
				case 3498:
				case 3505:
				case 3495:
				case 3508:
				case 3512:
					RedMultiplier = .37;
					Greenmultiplier = .29;
					BlueMultiplier = .19;
					break;
				
				// black hair	  
				case 2631:
				case 3477:				 
				case 3488:
				case 3470:
				case 3484:
				case 3481:
				case 3474:
				case 3492:
				case 3502:
				case 3499:
				case 3506:
				case 2634:
				case 3509:
				case 3513:
					RedMultiplier = .09;
					Greenmultiplier = .10;
					BlueMultiplier = .19;
					break;
					
				// no template spritesheet, just return current bitmap	  
				default:
					return bitmap;
			} 
			
			// now color the template
			trace("coloring item " + info.params.itemId + " from item " + _templateItemId);
			 
			// copy the bitmap
			var bitmapCopy:Bitmap = new Bitmap(bitmap.bitmapData.clone());
			
			// now color the copy
			var ct:ColorTransform = new ColorTransform(RedMultiplier, Greenmultiplier, BlueMultiplier);
			bitmapCopy.bitmapData.colorTransform(bitmapCopy.bitmapData.rect, ct);
			
			// if there is an alpha bitmap for this, copy its green channel into our alpha channel
			var bitmapAlpha:Bitmap = ModelLocator.getInstance().expandedSpriteSheetBitmapsAlpha[_cacheKey] as Bitmap;
			if (bitmapAlpha != null)
				bitmapCopy.bitmapData.copyChannel(bitmapAlpha.bitmapData, bitmapAlpha.bitmapData.rect, new Point(0,0), BitmapDataChannel.GREEN, BitmapDataChannel.ALPHA);
				
			return bitmapCopy;
		}
	}
}