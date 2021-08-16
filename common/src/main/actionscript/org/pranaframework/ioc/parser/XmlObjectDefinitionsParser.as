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
 package org.pranaframework.ioc.parser {
	
	import flash.utils.Dictionary;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IViewCursor;
	
	import org.pranaframework.collections.Map;
	import org.pranaframework.collections.TypedCollection;
	import org.pranaframework.ioc.IObjectDefinition;
	import org.pranaframework.ioc.ObjectContainer;
	import org.pranaframework.ioc.ObjectDefinition;
	import org.pranaframework.ioc.parser.preprocessors.IdAttributePreprocessor;
	import org.pranaframework.ioc.parser.preprocessors.SpringNamesPreprocessor;
	import org.pranaframework.ioc.parser.preprocessors.TemplatePreprocessor;
	import org.pranaframework.utils.Assert;
	import org.pranaframework.utils.TypeConverter;
	import org.pranaframework.ioc.parser.preprocessors.ScopeAttributePrepocessor;
	import org.pranaframework.ioc.ObjectDefinitionScope;
	import org.pranaframework.ioc.util.Constants;
	
	/**
	 * Xml parser for object definitions.
	 * 
	 * @author Christophe Herreman
	 * @author Damir Murat
	 */
	public class XmlObjectDefinitionsParser {
		
		private static const ID_ATTRIBUTE:String = "id";
		private static const CLASS_ATTRIBUTE:String = "class";
		private static const FACTORY_METHOD_ATTRIBUTE:String = "factory-method";
		private static const INIT_METHOD_ATTRIBUTE:String = "init-method";
    	private static const LAZY_INIT_ATTRIBUTE:String = "lazy-init";
		
		private static const PROPERTY_NODE:String = "property";
		private static const CONSTRUCTOR_ARG:String = "constructor-arg";
		
		private var _container:ObjectContainer;
		private var _xml:XML;
		private var _preprocessors:TypedCollection;
		
		/**
		 * Constructs a new <code>XmlObjectDefinitionsParser</code>.
		 * An optional container can be passed to store the definitions. If no
		 * container is passed then a new one gets created.
		 * 
		 * @param container the container where the definitions will be stored
		 */
		public function XmlObjectDefinitionsParser(container:ObjectContainer = null) {
			if (container == null)
				container = new ObjectContainer();
			this.container = container;
			
			// init
			initPreprocessors();
		}
		
		public function initPreprocessors():void {
			_preprocessors = new TypedCollection(IXmlObjectDefinitionsPreprocessor);
			addPreprocessor(new SpringNamesPreprocessor());
			addPreprocessor(new TemplatePreprocessor());
			addPreprocessor(new IdAttributePreprocessor());
			addPreprocessor(new ScopeAttributePrepocessor());
		}
		
		public function get container():ObjectContainer { return _container; }
		public function set container(value:ObjectContainer):void { _container = value; }
		
		/**
		 * Adds a preprocessor to the parser.
		 */
		public function addPreprocessor(preprocessor:IXmlObjectDefinitionsPreprocessor):void {
			Assert.notNull(preprocessor, "The preprocessor argument must not be null");
			_preprocessors.addItem(preprocessor);
		}
		
		/**
		 * Parses all object definitions and returns the container that contains
		 * the parsed results.
		 * 
		 * @param xml the xml object with the object definitions
		 * @return the container with the parsed object definitions
		 */
		public function parse(xml:XML):ObjectContainer {
			//trace("parse(" + xml.toString() + ")");
			
			_xml = xml; // store the xml locally, we need it in other methods
			_xml = preprocess(_xml);
			
			var objectNodes:XMLList = _xml..object.(attribute(CLASS_ATTRIBUTE) != undefined);
			
			for each(var objectNode:XML in objectNodes) {
				if (container.objectDefinitions[objectNode.@id] == null) {
					parseObjectNode(objectNode);
				}
				else {
					//trace("*** ALREADY PARSED: " + objectNode.@id);
				}
			}

			return container;
		}
		
		private function preprocess(xml:XML):XML {
			for (var c:IViewCursor = _preprocessors.createCursor(); !c.afterLast; c.moveNext()) {
				var preprocessor:IXmlObjectDefinitionsPreprocessor = c.current as IXmlObjectDefinitionsPreprocessor;
				xml = preprocessor.preprocess(xml);
			}
			return xml;
		}
		
		private function parseObjectNode(node:XML):* {
			preProcessObjectNode(node);
			var id:String = node.@id;
			var objectDefinition:IObjectDefinition = parseObjectDefinition(node);
			container.objectDefinitions[id] = objectDefinition;
			// call getObject() so that the generated object will be cached in the container
			if (objectDefinition.isSingleton && !objectDefinition.isLazyInit) {
				if (container.getObject(id) == null) {
					container.getObject(id);
				}
				return container.getObject(id);
			}
			else {
				return null;
			}
		}
		
		/**
		 * 
		 */
		public function preProcessObjectNode(node:XML):void {
			preProcessObjectSubNodes(node, CONSTRUCTOR_ARG);
			preProcessObjectSubNodes(node, PROPERTY_NODE);
		}
		
		private function getObjectNodeByID(id:String):XML {
			//trace("getObjectNodeByID(" + id + ")");
			return _xml..object.(attribute("id") == id)[0];
		}
		

		
		private function convertListToArray(xml:XML):void {
			var listNodes:XMLList = xml..list;
			for each(var listNode:XML in listNodes) {
				listNode.setName("array");
			}
		}
		
		/**
		 * 
		 */
		private function preProcessObjectSubNodes(node:XML, nodeName:String):void {
			for each(var subNode:XML in node[nodeName]) {
				// replace "value" attributes
				/*if (subNode.@value != undefined) {
					subNode.value = new String(subNode.@value);
					delete subNode.@value;
				}*/
				// replace "ref" attributes
				if (subNode.@ref != undefined) {
					subNode.ref = new String(subNode.@ref);
					delete subNode.@ref;
				}
			}
		}
		
		/**
		 * 
		 */
		private function parseObjectDefinition(xml:XML):IObjectDefinition {
			var result:IObjectDefinition = new ObjectDefinition(xml.attribute(CLASS_ATTRIBUTE));
			result.factoryMethod = (xml.attribute(FACTORY_METHOD_ATTRIBUTE) == undefined) ? null : xml.attribute(FACTORY_METHOD_ATTRIBUTE);
			result.initMethod = (xml.attribute(INIT_METHOD_ATTRIBUTE) == undefined) ? null : xml.attribute(INIT_METHOD_ATTRIBUTE);
			result.isLazyInit = (xml.attribute(LAZY_INIT_ATTRIBUTE) == "true") ? true : false;
			result.constructorArguments = parseConstructorArguments(xml);
			result.properties = parseProperties(xml.property, Map);
			result.scope = ObjectDefinitionScope.fromName(xml.attribute(Constants.SCOPE_ATTRIBUTE));
			return result;
		}
		
		/**
		 * 
		 */
		private function parseConstructorArguments(xml:XML):Array {
			var result:Array = new Array();
			for each(var node:XML in xml[CONSTRUCTOR_ARG]) {
				result.push(parseProperty(node));
			}
			return result;
		}
		
		/**
		 * 
		 */
		private function parseProperties(propertyNodes:XMLList, resultType:Class):* {
			var result:* = new resultType();
			for each(var node:XML in propertyNodes) {
				var property:* = parseProperty(node);
				result[node.@name.toString()] = property;
			}
			return result;
		}
		
		/**
		 * 
		 */
		private function parseProperty(node:XML):* {
			//trace("parseProperty(" + node.toXMLString() + ")");
			// convert 'value' attribute to childNode
			if (node.@value != undefined) {
				node.value = new String(node.@value);
				delete node.@value;
			}
			
			if (node.value == undefined) {
				var subNodes:XMLList = node.children();
				var propertyNode:XML = subNodes[0];
				return parsePropertyValue(propertyNode);
			}
			else {
				return parsePropertyValue(node.value[0]);
			}
		}
		
		private function parseDictionary(mapNode:XML):Dictionary {
			var result:Dictionary = new Dictionary();
			for each(var node:XML in mapNode.children()) {
				// convert all "key" attributes to "key" childnodes
				if (node.@key != undefined) {
					node.key = new String(node.@key);
					delete node.@key;
				}
				result[node.key] = parseProperty(node);
			}
			return result;
		}
		
		private function parseArrayCollection(node:XML):ArrayCollection {
			var result:ArrayCollection = new ArrayCollection();
			for each (var n:XML in node.children()) {
				result.addItem(parsePropertyValue(n));
			}
			return result;
		}
		
		/**
		 * 
		 */
		private function parsePropertyValue(node:XML):* {
			var result:*;
			switch (String(node.name()).toLowerCase()) {
				case "object": // inner bean
					result = parseObjectNode(node);
					break;
				case "value":
					result = TypeConverter.execute(node.toString());
					break;
				case "array":
					result = [];
					for each (var child:XML in node.children()) {
						result.push(parsePropertyValue(child));
					}
					break;
				case "object":
					result = parseProperties(node.property, Object);
					break;
				case "ref":
					var nodeName:String = node.toString();
					try {
						result = container.getObject(nodeName);
					}
					catch(e:Error) { // no object definition found
						var xml:XML = getObjectNodeByID(nodeName);
						result = parseObjectNode(xml);
					}
					break;
				case "map":
					result = parseDictionary(node);
					break;
				case "list":
					result = parseArrayCollection(node);
					break;
			}
			return result;
		}
	}
}