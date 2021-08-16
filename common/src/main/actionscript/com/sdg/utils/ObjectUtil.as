package com.sdg.utils
{
	import flash.utils.*;
	
	public class ObjectUtil
	{
		private static const PRIMITIVE_TYPES:Object = { number:true, string:true, boolean:true };
		
		public static function getClass(object:Object):Class
		{
			return getDefinitionByName(getQualifiedClassName(object)) as Class;
		}
		
		public static function getClassName(object:Object, fullPath:Boolean = false):String
		{
		    var className:String = getQualifiedClassName(object);
		    
			if (fullPath)
		    	return className;
		   	else
				return className.slice(className.lastIndexOf(':') + 1);
		}
		
		public static function classOf(object:Object, classRef:Class):Boolean
		{
			if (!(object is Class)) return object is classRef;
			
			while (object != null)
			{
				if (object == classRef) return true;
					
				var superName:String = getQualifiedSuperclassName(object);
				object = (superName == null) ? null : getDefinitionByName(superName);
			}
			
			return false;
		}
		
		public static function toSimpleString(value:Object):String
	    {
			return (PRIMITIVE_TYPES[typeof(value)] || value is Date || value is Array) ? value.toString() : "";
	    }
		
		/**
		 * Convert an object to a simple XML formatted string.
		 */
		public static function toXMLString(object:Object, topNodeName:String = null, propNames:Array = null):String
		{
			var xmlStr:String = "";
			var valueStr:String;
			var name:String;
			
			if (propNames)
			{
				for each (name in propNames)
				{
					if (object.hasOwnProperty(name))
					{
						valueStr = toSimpleString(object[name]);
						if (valueStr != "") xmlStr += "<" + name + ">" + valueStr + "</" + name + ">";
					}
				}
			}
			else
			{
				for (name in object)
				{
					valueStr = toSimpleString(object[name]);
					if (valueStr != "") xmlStr += "<" + name + ">" + valueStr + "</" + name + ">";
				}
			}
			
			if (topNodeName == null) topNodeName = ObjectUtil.getClassName(object);
			
			return "<" + topNodeName + ">" + xmlStr + "</" + topNodeName + ">";
		}
		
		/**
		 * Convert a list to a simple XMLList formatted string.
		 */
		public static function toXMLListString(list:Object, itemNodeName:String = null, itemPropNames:Array = null):String
		{
			var xmlStr:String = "";
			
			for each (var item:Object in list)
			{
				if (item != null) xmlStr += toXMLString(item, itemNodeName, itemPropNames);
			}
			
			return xmlStr;
		}
	
		public static function mapXMLNodeValues(target:Object, xml:Object):*
		{
			var nodes:XMLList = (xml is XML) ? xml.children() : xml as XMLList;
			
			for each (var node:XML in nodes)
			{
				var name:String = node.name();
				if (target.hasOwnProperty(name)) target[name] = node.valueOf();
			}
			
			return target;
		}
		
		public static function enumToArray(object:Object):Array
		{
			var array:Array = [];
			
			for each (var prop:* in object)
				array.push(prop);
			
			return array;
		}
		
		public static function inspect(object:Object):String
		{
			var result:String = "";
			for (var s:String in object) {
				result += "key: " + s + " value: " + object[s] + " type: " + typeof(object[s]) + "\n";
			}
			return result;
		}
	}
}