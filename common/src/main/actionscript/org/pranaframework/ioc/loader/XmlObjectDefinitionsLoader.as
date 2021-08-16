/**
 * Copyright (c) 2007, the original author(s)
 * 
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *     * Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the Prana Framework nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 package org.pranaframework.ioc.loader {
 	
 	import flash.net.URLLoader;
 	import flash.events.Event;
 	import org.pranaframework.ioc.parser.XmlObjectDefinitionsParser;
 	import org.pranaframework.ioc.ObjectContainer;
 	import flash.net.URLRequest;
 	import flash.events.EventDispatcher;
 	
	/**
	 *
	 */
	public class XmlObjectDefinitionsLoader extends EventDispatcher implements IObjectDefinitionsLoader {	
		
		//private var _url:String;
		private var _container:ObjectContainer;
		private var _loader:URLLoader;
		private var _parser:XmlObjectDefinitionsParser;
		
		/**
		 * 
		 */
		public function XmlObjectDefinitionsLoader(container:ObjectContainer = null) {
			if (container == null)
				container = new ObjectContainer();
			this.container = container;
			_parser = new XmlObjectDefinitionsParser(container);
		}
		
		public function addListener(listener:IObjectDefinitionsLoaderListener):void {
			addEventListener(ObjectDefinitionsLoaderEvent.COMPLETE, listener.onObjectDefinitionsLoaderListenerComplete);
		}
		
		public function removeListener(listener:IObjectDefinitionsLoaderListener):void {
			removeEventListener(ObjectDefinitionsLoaderEvent.COMPLETE, listener.onObjectDefinitionsLoaderListenerComplete);
		}
		
		public function load(url:String):void {
			var request:URLRequest = new URLRequest(url);
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onLoaderComplete);
			_loader.load(request);
		}
		
		//public function get url():String { return _url; }
		//public function set url(value:String):void { _url = value; }
		
		public function get container():ObjectContainer { return _container; }
		public function set container(value:ObjectContainer):void { _container = value; }
		
		/**
		 * 
		 */
		private function onLoaderComplete(event:Event):void {
			this.container = _parser.parse(XML(_loader.data));
			dispatchEvent(new ObjectDefinitionsLoaderEvent(ObjectDefinitionsLoaderEvent.COMPLETE));
		}
	}
}