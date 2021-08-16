package com.sdg.view
{
	import com.sdg.events.LoaderQueEvent;
	import com.sdg.model.ILayeredImageItem;
	import com.sdg.net.LoaderQue;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;

	public class LayeredImage extends Sprite
	{
		private static const CLOSE_LOADERS:String = 'close loading que';
		
		protected var _container:Sprite;
		protected var _bytesTotal:uint;
		protected var _bytesLoaded:uint;
		protected var _responseTimeout:uint;
		protected var _urls:Array;
		protected var _layers:Array;
		
		public function LayeredImage()
		{
			super();
			
			_bytesTotal = 0;
			_bytesLoaded = 0;
		}
		
		public function close():void
		{
			// Close loading que.
			dispatchEvent(new Event(CLOSE_LOADERS));
		}
		
		public function loadItemImage(item:ILayeredImageItem):void
		{
			loadUrlArray(item.getLayeredImageUrlArray());
		}
		
		public function loadUrlArray(urls:Array):void
		{
			// Remove the previous image.
			if (_container != null)
			{
				removeChild(_container);
			}
			
			// Reset values.
			_bytesTotal = 0;
			_bytesLoaded = 0;
			_layers = [];
			_urls = urls;
			
			// Create new image container.
			_container = new Sprite();
			addChild(_container);
			
			// Create a loader que.
			// Use to load each image.
			var imageLoaderQue:LoaderQue = new LoaderQue(1, 3000, 2, true);
			imageLoaderQue.addEventListener(LoaderQueEvent.COMPLETE, onLoaderComplete);
			imageLoaderQue.addEventListener(LoaderQueEvent.ERROR, onLoaderError);
			imageLoaderQue.addEventListener(LoaderQueEvent.PROGRESS, onLoaderProgress);
			
			var i:uint = 0;
			var len:uint = _urls.length;
			var requestLen:uint = 0;
			var resolvedRequests:uint = 0;
			var loaderInfoArray:Array = [];
			var bytesTotalArray:Array = [];
			var bytesLoadedArray:Array = [];
			for (i; i < len; i++)
			{
				var url:String = _urls[i] as String;
				if (url == null) continue;
				
				// Create a layer for this image.
				var layer:Sprite = getLayer(i);
				
				// keep track of bytes total/loaded for this loader.
				bytesTotalArray[url] = 1;
				bytesLoadedArray[url] = 0;
				
				// Create request and add it to the loader que.
				var request:URLRequest = new URLRequest(url);
				requestLen++;
				imageLoaderQue.addRequest(request);
			}
			
			// Listen for event to close loading que.
			addEventListener(CLOSE_LOADERS, onCloseLoaders);
			
			
			function onLoaderComplete(e:LoaderQueEvent):void
			{
				// Get reference to loader.
				var loader:Loader = e.loader;
				
				// Get a reference to the url.
				var url:String = loader.contentLoaderInfo.url;
				
				// Increment.
				resolvedRequests++;
				
				// Get the index of the url.
				var index:uint = urls.indexOf(url);
				
				// Set the content of the layer.
				setLayerContent(index, loader.content);
				
				// Check if we are finished loading images.
				checkComplete();
			}
			
			function onLoaderError(e:LoaderQueEvent):void
			{				
				// Increment.
				resolvedRequests++;
				
				// Check if we are finished loading images.
				checkComplete();
			}
			
			function onLoaderProgress(e:LoaderQueEvent):void
			{
				// Get reference to the url.
				var url:String = e.loader.contentLoaderInfo.url;
				
				// Set bytes total/loaded.
				bytesTotalArray[url] = e.bytesTotal;
				bytesLoadedArray[url] = e.bytesLoaded;
				
				// Dispatch a progress event.
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, getBytesLoaded(), getBytesTotal()));
			}
			
			function onCloseLoaders(e:Event):void
			{
				// Remove loader que listeners.
				imageLoaderQue.removeEventListener(LoaderQueEvent.COMPLETE, onLoaderComplete);
				imageLoaderQue.removeEventListener(LoaderQueEvent.ERROR, onLoaderError);
				imageLoaderQue.removeEventListener(LoaderQueEvent.PROGRESS, onLoaderProgress);
				removeEventListener(CLOSE_LOADERS, onCloseLoaders);
				
				// Stop loading.
				imageLoaderQue.clear(true);
			}
			
			function checkComplete():void
			{
				if (resolvedRequests >= requestLen)
				{
					// We are finished loading images.
					dispatchEvent(new Event(Event.COMPLETE));
					
					// Remove loader que listeners.
					imageLoaderQue.removeEventListener(LoaderQueEvent.COMPLETE, onLoaderComplete);
					imageLoaderQue.removeEventListener(LoaderQueEvent.ERROR, onLoaderError);
					imageLoaderQue.removeEventListener(LoaderQueEvent.PROGRESS, onLoaderProgress);
					removeEventListener(CLOSE_LOADERS, onCloseLoaders);
				}
			}
			
			function getBytesTotal():uint
			{
				var i:uint = 0;
				var len:uint = bytesTotalArray.length;
				var total:uint = 0;
				for (i; i < len; i++)
				{
					total += bytesTotalArray[i] as uint;
				}
				
				return total;
			}
			
			function getBytesLoaded():uint
			{
				var i:uint = 0;
				var len:uint = bytesLoadedArray.length;
				var total:uint = 0;
				for (i; i < len; i++)
				{
					total += bytesLoadedArray[i] as uint;
				}
				
				return total;
			}
		}
		
		public function mergeUrlArray(urls:Array):void
		{
			// Go through each url,
			// Any that are different from the current urls,
			// Load and replace the image layer.
			var i:uint = 0;
			var len:uint = Math.max(urls.length, _urls.length);
			var loaderInfoArray:Array = [];
			var requestLen:uint = 0;
			var resolvedRequests:uint = 0;
			var loadedImages:Array = [];
			var layersToClear:Array = [];
			for (i; i < len; i++)
			{
				// Make sure there is a new url at this index.
				var newUrl:String = urls[i] as String;
				if (newUrl == null)
				{
					// If there is not a new url at this index,
					// Add the index to a que of layers to be cleared at a later time.
					layersToClear.push(i);
					continue;
				}
				
				// Check against current url.
				var currentUrl:String = _urls[i] as String;
				if (newUrl == null || currentUrl == newUrl) continue;
				
				var request:URLRequest = new URLRequest(newUrl);
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				
				// Keep track of the loader infos.
				loaderInfoArray[i] = loader.contentLoaderInfo;
				
				// Load the url.
				requestLen++;
				loader.load(request);
			}
			
			function onLoadComplete(e:Event):void
			{
				// Get reference to loader info.
				var loaderInfo:LoaderInfo = e.target as LoaderInfo;
				
				// Remove event listeners.
				loaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
				loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				
				// Increment.
				resolvedRequests++;
				
				// Get the index of the loader info.
				var index:uint = loaderInfoArray.indexOf(loaderInfo);
				
				// Keep track of the loaded content.
				loadedImages[index] = loaderInfo.content;
				
				// Check if we are finished loading images.
				checkComplete();
			}
			
			function onLoadError(e:IOErrorEvent):void
			{
				// Get reference to loader info.
				var loaderInfo:LoaderInfo = e.target as LoaderInfo;
				
				// Remove event listeners.
				loaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
				loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				
				// Increment.
				resolvedRequests++;
				
				// Check if we are finished loading images.
				checkComplete();
			}
			
			function checkComplete():void
			{
				if (resolvedRequests >= requestLen)
				{
					// All new images are loaded.
					// Now swap them in.
					_urls = urls;
					var i:uint = 0;
					var len:uint = loadedImages.length;
					for (i; i < len; i++)
					{
						// Get reference to loaded image.
						var image:DisplayObject = loadedImages[i] as DisplayObject;
						if (image == null) continue;
						
						// Set the content of the layer.
						setLayerContent(i, image);
					}
					
					// Clear layers that should be cleared.
					i = 0;
					len = layersToClear.length;
					for (i; i < len; i++)
					{
						clearLayer(layersToClear[i]);
					}
				}
			}
		}
		
		protected function getLayer(index:uint):Sprite
		{
			// Return the layer at provided index.
			// If it does not exist, create it.
			var layer:Sprite = _layers[index] as Sprite;
			if (layer == null)
			{
				layer = new Sprite();
				_layers[index] = layer;
				_container.addChild(layer);
			}
			
			return layer;
		}
		
		protected function setLayerContent(layerIndex:uint, display:DisplayObject):void
		{
			// Get reference to layer.
			var layer:Sprite = getLayer(layerIndex);
			
			// Replace the content of the layer.
			if (layer.numChildren > 0) layer.removeChildAt(0);
			layer.addChild(display);
		}
		
		protected function clearLayer(layerIndex:uint):void
		{
			// Get reference to layer.
			var layer:Sprite = getLayer(layerIndex);
			
			if (layer.numChildren > 0) layer.removeChildAt(0);
		}
		
	}
}