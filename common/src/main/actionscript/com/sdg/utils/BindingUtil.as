package com.sdg.utils
{
	import mx.binding.utils.ChangeWatcher;

	public class BindingUtil
	{
    	public static function bindProperty(site:Object, prop:String, host:Object, chain:Object,
											commitOnly:Boolean = false, assignNow:Boolean = true):ChangeWatcher
	    {
	        var w:ChangeWatcher =
	            ChangeWatcher.watch(host, chain, null, commitOnly);
        
	        if (w != null)
	        {
	            var assign:Function = function(event:*):void
	            {
	                site[prop] = w.getValue();
	            };
	            w.setHandler(assign);
	            if (assignNow) assign(null);
	        }
        
	        return w;
	    }
	
	    public static function bindSetter(setter:Function, host:Object, chain:Object, commitOnly:Boolean = false, 
	                                      assignNow:Boolean = true, valueArgument:Boolean = true):ChangeWatcher
	    {
	        var w:ChangeWatcher =
	            ChangeWatcher.watch(host, chain, null, commitOnly);
        
	        if (w != null)
	        {
	            var invoke:Function;
	
				if (valueArgument) 
					invoke = function(event:*):void { setter(w.getValue()); };
				else
					invoke = function(event:*):void { setter(); };
	            
	            w.setHandler(invoke);
	            if (assignNow) invoke(null);
	        }
        
	        return w;
	    }
	}
}
