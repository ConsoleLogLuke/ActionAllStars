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
 package org.pranaframework.ioc.parser.preprocessors {
	
	import org.pranaframework.ioc.parser.IXmlObjectDefinitionsPreprocessor;
	import org.pranaframework.ioc.util.SpringConstants;
	import org.pranaframework.ioc.util.Constants;
	
	/**
	 * Preprocesses an xml context and replaces all Spring specific names with
	 * their Prana equivalent.This enables you to load in a Spring compliant
	 * context and parse it with Prana.
	 * 
	 * @author Christophe Herreman
	 */
	public class SpringNamesPreprocessor implements IXmlObjectDefinitionsPreprocessor {
		
		/**
		 * Creates a new <code>SpringNamesPreprocessor</code>
		 */
		public function SpringNamesPreprocessor() {
		}
		
		/**
		 * @inheritDoc
		 */
		public function preprocess(xml:XML):XML {
			xml = convertBeansDefinition(xml);
			xml = convertBeanDefinitions(xml);
			xml = convertBeanReferences(xml);
			return xml;
		}
		
		/**
		 * 
		 */
		private function convertBeansDefinition(xml:XML):XML {
			if (SpringConstants.BEANS == xml.name().localName) {
				xml.setName(Constants.OBJECTS);
			}
			return xml;
		}
		
		private function convertBeanDefinitions(xml:XML):XML {
			var beans:XMLList = xml..bean;
			for each(var beanNode:XML in beans) {
				beanNode.setName(Constants.OBJECT);
			}
			return xml;
		}
		
		private function convertBeanReferences(xml:XML):XML {
			var nodes:XMLList = xml..ref.(attribute(SpringConstants.BEAN) != undefined);
			for each (var node:XML in nodes) {
				node.text()[0] = node.@bean;
				delete node.@bean;
			}
			return xml;
		}
		
	}
}