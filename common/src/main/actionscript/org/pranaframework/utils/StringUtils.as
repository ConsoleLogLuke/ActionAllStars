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
 package org.pranaframework.utils {
	
	/**
	 * Contains utility methods for working with strings.
	 * 
	 * @author Christophe Herreman
	 */
	public class StringUtils {
		
		/**
		 * Adds/inserts a new string at a certain position in the source string.
		 */
		public static function addAt(string:String, value:*, position:int):String {
			if (position > string.length) {
				position = string.length;
			}
			var firstPart:String = string.substring(0, position);
			var secondPart:String = string.substring(position, string.length);
			return (firstPart + value + secondPart);
		}
		
		/**
		 * Replaces a part of the text between 2 positions.
		 */
		public static function replaceAt(string:String, value:*, beginIndex:int, endIndex:int):String {
			beginIndex = Math.max(beginIndex, 0)
			endIndex = Math.min(endIndex, string.length);
			var firstPart:String = string.substr(0, beginIndex);
			var secondPart:String = string.substr(endIndex, string.length);
			return (firstPart + value + secondPart);
		}
		
		/**
		 * Removes a part of the text between 2 positions.
		 */
		public static function removeAt(string:String, beginIndex:int, endIndex:int):String {
			return StringUtils.replaceAt(string, "", beginIndex, endIndex);
		}
		
		/**
		 * Fixes double newlines in a text.
		 */
		public static function fixNewlines(string:String):String {
			return string.replace(/\r\n/gm, "\n");
		}
		
	}
}