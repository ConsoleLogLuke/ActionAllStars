package org.pranaframework.utils{
	
	import mx.utils.StringUtil;
	
	/**
	 * @author Kristof Neirynck
	 * @since 2008-01-23
	 * 
	 * Contains utility methods for working with html.
	 */
	public class HtmlUtils{
		/** string used for newline (&lt;BR&gt; or \n work best) */
		public static const BR:String = "<BR>"; 
		/** string used for tab (&lt;TAB&gt; or \t work best) */
		public static const TAB:String = "<TAB>"; 
		
		/**
		 * parseTables<br>
		 * Parses tables with the Parse class and outputs String fit for use as htmlText.<br>
		 * No support for nested tables.<br>
		 * Ignores errors thrown by Parse.<br>
		 * 
		 * @param html String with &lt;table&gt; notation
		 * @return String with &lt;TEXTFORMAT&gt; notation
		 */
		public static function parseTables(html:String):String{
			var result:String;
			var parsedHtml:Parse;
			try{
				result = "";
				parsedHtml = new Parse(html, null);
			}catch(error:Error){
				//an error occured, ignore it and return the input
				trace(error.message);
				result = html;
				parsedHtml = null;
			}
			for(var table:Parse = parsedHtml; table != null; table = table.more){
				result += table.leader;
				result += "<TEXTFORMAT TABSTOPS=\"";
				var tabPosition:int = 0;
				for(var td:Parse = table.parts.parts; td != null; td = td.more){
					tabPosition += td.width;
					result += tabPosition;
					if(td.more != null){
						result += ",";
					}
				}
				result += "\">";
				
				for(var tr:Parse = table.parts; tr != null; tr = tr.more){
					for(var td2:Parse = tr.parts; td2 != null; td2 = td2.more){
						result += td2.body;
						if(td2.more != null){
							result += TAB;
						}
					}
					if(tr.more != null){
						result += BR;
					}
				}
				result += "</TEXTFORMAT>";
				if(table.more== null){
					result += table.trailer;
				}
			}
			return result;
		}
		
		/**
		 * Unformat, unescape and trim a String.
		 */
		public static function parseText(s:String):String {
	        return StringUtil.trim(HtmlUtils.unescape(HtmlUtils.unformat(s)));
	    }
	    
	    /**
	     * Removes all html tags from a string
	     */
	    public static function unformat(s:String):String {
	        var i:int=0, j:int;
	        while ((i=s.indexOf('<',i))>=0) {
	            if ((j=s.indexOf('>',i+1))>0) {
	                s = s.substring(0,i) + s.substring(j+1);
	            } else break;
	        }
	        return s;
	    }
		
		/**
		 * Unescape all entities in a string.
		 */
	    public static function unescape(s:String):String {
	        var i:int=-1, j:int;
	        while ((i=s.indexOf('&',i+1))>=0) {
	            if ((j=s.indexOf(';',i+1))>0) {
	                var from:String = s.substring(i+1, j).toLowerCase();
	                var to:String = null;
	                if ((to=replacement(from)) != null) {
	                    s = s.substring(0,i) + to + s.substring(j+1);
	                }
	            }
	        }
	        return s;
	    }
	    
		/**
		 * Unescape an entity.
		 */
	    public static function replacement(from:String):String {
	    	var result:String = null;
	    	switch(from){
	    		case "lt": result = "<"; break;
	    		case "gt": result = ">"; break;
	    		case "amp": result = "&"; break;
	    		case "nbsp": result = " "; break;
	    		default: result = null; 
	    	}
	    	return result;
	    }
	    
	}
}
