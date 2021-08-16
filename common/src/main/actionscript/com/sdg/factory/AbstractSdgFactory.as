package com.sdg.factory
{
	import flash.utils.getDefinitionByName;
	
	public class AbstractSdgFactory
	{
		protected var defaultClass:Class;
		protected var subclassRoot:String;
		
		public function AbstractSdgFactory(defaultClass:Class = null, subclassRoot:String = "")
		{
			this.defaultClass = defaultClass;
			this.subclassRoot = subclassRoot;
		}
		
		public function getClass(className:String):Class
		{
			var classRef:Class;
			
			try
			{
				var root:String = subclassRoot.length ? subclassRoot + '.' : "";
				classRef = getDefinitionByName(root + className) as Class;
			}
			catch (e:Error)
			{
				classRef = defaultClass;
			}
			
			if (!classRef) throw new Error("Class not found for 'className' [" + className + "].");
			return classRef;
		}
	}
}