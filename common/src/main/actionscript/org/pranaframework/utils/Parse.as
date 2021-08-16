package org.pranaframework.utils{
	
	/**
	 * @author Kristof Neirynck
	 * @since 2008-01-22
	 * @url http://fit.c2.com/wiki.cgi?ParsingTables
	 * 
	 * Helper class for HtmlUtil.<br>
	 * A port from the Fit framework.
	 */
	public class Parse{
		
		/** text before the startTag */
		public var leader:String;
		/** startTag (contains attributes) */
		public var tag:String;
		/** text inside the td (or null if it isn't a td) */
		public var body:String;
		/** endTag */
		public var end:String;
		/** text after the endTag */
		public var trailer:String;
		
		/** nextsibling */
		public var more:Parse;
		/** first child */
		public var parts:Parse;
		
		/** default tagnames [&quot;table&quot;, &quot;tr&quot;, &quot;td&quot;] */
		public static const TAGS:Array = ["table", "tr", "td"];
		
		/**
		 * Parse constructor<br>
		 * Every table, tr and td is a Parse element<br>
		 * 
		 * @param String text input
		 * @param Array tags optional default Parse.TAGS (use null to get default)
		 * @param int level optional default 0
		 * @param int offset optional default 0
		 */
		public function Parse(text:String, tags:Array, level:int = 0, offset:int = 0){
			if(tags == null){tags = Parse.TAGS;}
			var lc:String = text.toLowerCase();
			var startTag:int = lc.indexOf("<"+tags[level]);
			var endTag:int = lc.indexOf(">", startTag) + 1;
			var startEnd:int = lc.indexOf("</"+tags[level], endTag);
			var endEnd:int = lc.indexOf(">", startEnd) + 1;
			var startMore:int = lc.indexOf("<"+tags[level], endEnd);
			
			//trace(startTag + ", " + endTag + ", " + startEnd + ", " + endEnd + ", " + startMore);
			
			if(startTag<0 || endTag<0 || startEnd<0 || endEnd<0){
				throw new Error("Can't find tag: "+tags[level] + " offset: "+offset);
			}
			
			leader  = text.substring(0, startTag);
			tag     = text.substring(startTag, endTag);
			body    = text.substring(endTag, startEnd);
			end     = text.substring(startEnd, endEnd);
			trailer = text.substring(endEnd);
			
			//trace(leader + ", " + tag + ", " + body + ", " + end + ", " + trailer);
			
			if(level + 1 < tags.length){
				parts = new Parse(body, tags, level+1, offset+endTag);
				body = null;
			}
			
			// FIX >= 0 gives stack overflow
			if(startMore > 0){
				more = new Parse(trailer, tags, level, offset+endEnd);
				trailer = null;
			}
		}
		
		/**
		 * @return exactly the same string as the input
		 */
		public function toString():String{
			var result:String = leader + tag;
			if(parts != null){
				result += parts.toString();
			}else{
				result += body.toString();
			}
			result += end;
			if(more != null){
				result += more.toString();
			}else{
				result += trailer;
			}
			return result;
		}
		
		/**
		 * width attribute value or 0 if not found
		 */
		public function get width():int{
			var result:int = parseInt(tag
				.replace(/\s/g, "")
				.replace(/.*width=["']*/i, "")
				.replace(/[^0-9]+.*/, ""));
			if(isNaN(result)){
				result = 0;
			}
			return result;
		}
		
		/**
		 * last element on same depth<br>
		 * td.last returns the last td from the same tr  
		 */
		public function get last():Parse{
			return more == null ? this : more.last;
		}
		
		/**
		 * Count elements on same depth.<br>
		 * Doesn't count those before this one.
		 */
	    public function get size():int {
	        return more==null ? 1 : more.size+1;
	    }
		
		/**
		 * Get first leaf child.
		 */		
	    public function get leaf():Parse {
	        return parts==null ? this : parts.leaf;
	    }
		
		/**
		 * Get sibling or child by index.<br>
		 * 
		 * @param i index
		 * @param j optional index one level deeper
		 * @param k optional index two levels deeper
		 * @return sibling or child
		 */
	    public function at(i:int, j:int = -1, k:int = -1):Parse {
			if(j != -1){
				if(k != -1){
					return at(i).parts.at(j).parts.at(k);
				}else{
					return at(i).parts.at(j);
				}
			}else{
				return i==0 || more==null ? this : more.at(i-1);
			}
	    }
	    
	}
}