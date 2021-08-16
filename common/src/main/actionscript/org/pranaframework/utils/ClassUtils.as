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
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.ObjectUtil;
	
	import org.pranaframework.errors.ClassNotFoundError;
	
	/**
	 * Provides utilities for working with <code>Class</code> objects.
	 * 
	 * @author Christophe Herreman
	 */
	public class ClassUtils {
		
		/**
		 * Returns a <code>Class</code> object that corresponds with the given
		 * instance. If no correspoding class was found, a
		 * <code>ClassNotFoundError</code> will be thrown.
		 * 
		 * @param instance the instance from which to return the class
		 * @return the <code>Class</code> that corresponds with the given instance
		 * @see org.pranaframework.errors.ClassNotFoundError
		 */
		public static function forInstance(instance:*):Class {
			// TODO this does not work with primitive types
			// solution: wrap getClassInfo in Prana ObjectUtils and add checks?
			var classInfo:Object = ObjectUtil.getClassInfo(instance);
			return forName(classInfo.name);
		}
		
		/**
		 * Returns a <code>Class</code> object that corresponds with the given
		 * name. If no correspoding class was found, a
		 * <code>ClassNotFoundError</code> will be thrown.
		 * 
		 * @param name the name from which to return the class
		 * @return the <code>Class</code> that corresponds with the given name
		 * @see org.pranaframework.errors.ClassNotFoundError
		 */
		public static function forName(name:String):Class {
			var result:Class;
			try {
				result = getDefinitionByName(name) as Class;
			}
			catch(e:ReferenceError) {
				throw new ClassNotFoundError("A class with the name '" + name + "' could not be found.");
			}
			return result;
		}
		
		/**
		 * Returns whether the passed in Class object is a subclass of the
		 * passed in parent Class.
		 */
		public static function isSubclassOf(clazz:Class, parentClass:Class):Boolean {
			Assert.notNull(clazz, "The clazz argument must no be null");
			Assert.notNull(parentClass, "The parentClass argument must not be null");
			var classDescription:XML = describeType(clazz) as XML;
			var parentName:String = getQualifiedClassName(parentClass);
			return (classDescription.factory.extendsClass.(@type == parentName).length() != 0);
		}
		
		/**
		 * Returns the class that the passed in clazz extends. If no parent class
		 * was found, in case of Object, null is returned.
		 * @param clazz the class to get the parent class from
		 * @returns the parent class or null if no parent class was found
		 */
		public static function getParentClass(clazz:Class):Class {
			Assert.notNull(clazz, "The clazz argument must no be null");
			var result:Class;
			var classDescription:XML = describeType(clazz) as XML;
			var parentClasses:XMLList = classDescription.factory.extendsClass;
			if (parentClasses.length() > 0)
				result = ClassUtils.forName(parentClasses[0].@type);
			return result;
		}
		
		/**
		 * Returns whether the passed in <code>Class</code> object implements
		 * the given interface.
		 * 
		 * @param clazz the class to check for an implemented interface
		 * @param interfaze the interface that the clazz argument should implement
		 * @return true if the clazz object implements the given interface; false if not
		 */
		public static function isImplementationOf(clazz:Class, interfaze:Class):Boolean {
			var result:Boolean;
			if (clazz == null) {
				result = false;
			}
			else {
				var classDescription:XML = describeType(clazz) as XML;
				result = (classDescription.factory.implementsInterface.(@type == getQualifiedClassName(interfaze)).length() != 0);
			}
			return result;
		}
		
		/**
		 * Creates an instance of the given class and passes the arguments to
		 * the constructor.
		 * 
		 * TODO find a generic solution for this. Currently we support constructors
		 * with a maximum of 10 arguments.
		 * 
		 * @param clazz the class from which an instance will be created
		 * @param args the arguments that need to be passed to the constructor
		 */
		public static function newInstance(clazz:Class, args:Array = null):* {
			var result:*;
			var a:Array = (args == null) ? [] : args;
			
			switch (a.length) {
				case 1:
					result = new clazz(a[0]);
					break;
				case 2:
					result = new clazz(a[0], a[1]);
					break;
				case 3:
					result = new clazz(a[0], a[1], a[2]);
					break;
				case 4:
					result = new clazz(a[0], a[1], a[2], a[3]);
					break;
				case 5:
					result = new clazz(a[0], a[1], a[2], a[3], a[4]);
					break;
				case 6:
					result = new clazz(a[0], a[1], a[2], a[3], a[4], a[5]);
					break;
				case 7:
					result = new clazz(a[0], a[1], a[2], a[3], a[4], a[5], a[6]);
					break;
				case 8:
					result = new clazz(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]);
					break;
				case 9:
					result = new clazz(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8]);
					break;
				case 10:
					result = new clazz(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9]);
					break;
				default:
					result = new clazz();	
			}
			
			return result;
		}
		
	}
}