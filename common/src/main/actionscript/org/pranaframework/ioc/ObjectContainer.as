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
 package org.pranaframework.ioc {
	
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	
	import org.pranaframework.collections.IMap;
	import org.pranaframework.collections.Map;
	import org.pranaframework.errors.ClassNotFoundError;
	import org.pranaframework.ioc.factory.IFactoryObject;
	import org.pranaframework.ioc.factory.IInitializingObject;
	import org.pranaframework.ioc.factory.IObjectFactory;
	import org.pranaframework.ioc.factory.MethodInvokingObject;
	import org.pranaframework.ioc.factory.ObjectFactory;
	import org.pranaframework.ioc.factory.config.IObjectPostProcessor;
	import org.pranaframework.ioc.factory.config.LoggingTargetFactoryObject;
	import org.pranaframework.ioc.factory.config.ObjectContainerAwarePostProcessor;
	import org.pranaframework.utils.Assert;
	import org.pranaframework.utils.ClassUtils;
	
	/**
	 * Manages object definitions and creates new objects based on those
	 * definitions.
	 * 
	 * @author Christophe Herreman
	 * @author Damir Murat
	 */
	public class ObjectContainer {
		
		// static code block to force compilation of certain classes
		{
			MethodInvokingObject,
			LoggingTargetFactoryObject
		}
		
		private var _objectDefinitions:IMap;
		private var _objectCache:IMap;
		private var _objectPostProcessors:Array;
		
		/**
		 * Constructs a new <code>ObjectContainer</code>.
		 */
		public function ObjectContainer() {
			_objectDefinitions = new Map();
			_objectCache = new Map();
			_objectPostProcessors = [new ObjectContainerAwarePostProcessor(this)];
		}
		
		public function get objectDefinitions():IMap {
			return _objectDefinitions;
		}
		public function set objectDefinitions(value:IMap):void {
			_objectDefinitions = value;
		}
		
		/**
		 * Removes an object from the internal container cache.
		 * 
		 * @param name the id/name of the object to remove
		 * @return the removed object
		 */
		public function clearObjectFromInternalCache(name:String):Object {
			return _objectCache.remove(name);
		}
		
		/**
		 * 
		 */
		public function getObject(name:String, constructorArguments:Array = null):* {
			var result:*;
			var objectDefinition:IObjectDefinition = objectDefinitions[name];
			
			// we don't have an object definition for the given name
			if (!objectDefinition)
				throw new ObjectDefinitionNotFoundError("An object definition for '" + name + "' was not found.");
			
			// dmurat: constructor parameters are only allowed for lazy instantiating objects (at least for now)
			if (constructorArguments != null && !objectDefinition.isLazyInit) {
				throw new Error(
					"An object definition for '" + name + "' is not lazy. Constructor arguments can only be supplied for " +
					"lazy instantiating objects.");
			}
			
			// if this is a singleton, try to get it from the cache
			// else, create a new object and return it
			if (objectDefinition.isSingleton) {
				result = _objectCache[name]; // look up the object in the cache
			}
			
			// create a new object if none was found in cache
			if (!result) {
				try {
					var clazz:Class = ClassUtils.forName(objectDefinition.className);
					var factory:IObjectFactory = new ObjectFactory();
					
					if (constructorArguments != null) {
						objectDefinition.constructorArguments = constructorArguments;
					}
					
					if (objectDefinition.factoryMethod == null) {
						result = factory.createObject(clazz, objectDefinition.constructorArguments);
					}else {
						result = factory.createObjectThroughFactoryMethod(clazz, objectDefinition.factoryMethod);
					}
					
					// set properties on the newly created object
					for (var property:* in objectDefinition.properties) {
						try {
							result[property] = objectDefinition.properties[property];
							// TODO throws TypeError when calling property with wrong type
							//trace("result[property]: " + property + " = " + objectDefinition.properties[property]);
						}
						catch(typeError:TypeError) {
							trace(typeError.message);
							trace("Error for property '" + property + "' on object '" + name + "' with class '" + objectDefinition.className + "'");
							throw typeError;
						}
						catch(referenceError:ReferenceError) { // trying to assign read-only property
							if (result[property] is IList) {
								if (objectDefinition.properties[property]) {
									for (var c:IViewCursor = objectDefinition.properties[property].createCursor(); !c.afterLast; c.moveNext()) {
										result[property].addItem(c.current);
									}
								}
								
							}
						}
						catch(e:Error) {
							trace("ObjectContainer error: " + e.message);
							throw e;
						}
					}
					
					doPostProcessingBeforeInitialization(result, name);
					
					if (result is IInitializingObject) {
						IInitializingObject(result).afterPropertiesSet();
					}
					
					if (objectDefinition.initMethod != null) {
						result[objectDefinition.initMethod]();
					}
					
					doPostProcessingAfterInitialization(result, name);
					
					if (result is IFactoryObject) {
						result = IFactoryObject(result).getObject();
					}
					
					// cache the object if its definition is a singleton
					if (objectDefinition.isSingleton)
						_objectCache[name] = result;
				}
				catch(e:ClassNotFoundError) {
					// TODO throw ObjectContainerError
					throw e;
				}
			}
			
			return result;
		}
		
		/**
		 * Adds an object postprocessor to this container.
		 * 
		 * @param objectPostProcessor the object postprocessor to add
		 */
		public function addObjectPostProcessor(objectPostProcessor:IObjectPostProcessor):void {
			Assert.notNull(objectPostProcessor, "The 'objectPostProcessor' must not be null");
			_objectPostProcessors.push(objectPostProcessor);
		}
		
		private function doPostProcessingBeforeInitialization(object:*, name:String):void {
			for (var i:int = 0; i<_objectPostProcessors.length; i++) {
				var o:IObjectPostProcessor = _objectPostProcessors[i];
				o.postProcessBeforeInitialization(object, name);
			}
		}
		
		private function doPostProcessingAfterInitialization(object:*, name:String):void {
			for (var i:int = 0; i<_objectPostProcessors.length; i++) {
				var o:IObjectPostProcessor = _objectPostProcessors[i];
				o.postProcessAfterInitialization(object, name);
			}
		}
		
	}
}