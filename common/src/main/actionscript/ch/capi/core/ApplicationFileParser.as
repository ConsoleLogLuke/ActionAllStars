package ch.capi.core 
{
	import ch.capi.errors.ParseError;
	import ch.capi.core.ApplicationFile;
	import ch.capi.net.LoadableFileFactory;
	import ch.capi.net.ILoadableFile;
	import ch.capi.net.LoadableFileType;
	
	import flash.xml.XMLNode;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	/**
	 * Parser of <code>ApplicationFile</code> objects.
	 * 
	 * @see		ch.capi.core.ApplicationFile		ApplicationFile
	 * @see		ch.capi.core.ApplicationMassLoader	ApplicationMassLoader	 * @author 	Cedric Tabin - thecaptain
	 * @version	1.0	 */	public class ApplicationFileParser 
	{
		//---------//
		//Constants//
		//---------//
		
		/**
		 * Defines the 'name' attribute value.
		 */
		private static const ATTRIBUTE_NAME_VALUE:String = "name";
		
		/**
		 * Defines the 'global' attribute value.
		 */
		private static const ATTRIBUTE_GLOBAL_VALUE:String = "global";
		
		/**
		 * Defines the 'url' attribute value.
		 */
		private static const ATTRIBUTE_URL_VALUE:String = "url";
		
		/**
		 * Defines the 'type' attribute value.
		 */
		private static const ATTRIBUTE_TYPE_VALUE:String = "type";
		
		/**
		 * Defines the 'data' attribute value.
		 */
		private static const ATTRIBUTE_DATA_VALUE:String = "data";
		
		/**
		 * Defines the 'virtualBytesTotal' attribute value.
		 */
		private static const ATTRIBUTE_VIRTUALBYTESTOTAL_VALUE:String = "virtualBytesTotal";
		
		/**
		 * Defines the 'useCache' attribute value.
		 */
		private static const ATTRIBUTE_USECACHE_VALUE:String = "useCache";
		
		/**
		 * Defines the 'netState' attribute value.
		 */
		private static const ATTRIBUTE_NETSTATE_VALUE:String = "netState";
		
		//---------//
		//Variables//
		//---------//
		private var _loadableFileFactory:LoadableFileFactory;
		
		//-----------------//
		//Getters & Setters//
		//-----------------//
		
		/**
		 * Defines the <code>LoadableFileFactory</code> to use to create the <code>ILoadableFile</code> objects.
		 */
		public function get loadableFileFactory():LoadableFileFactory { return _loadableFileFactory; }
		public function set loadableFileFactory(value:LoadableFileFactory):void
		{
			if (value == null) throw new ArgumentError("value is not defined"); 
			_loadableFileFactory = value;
		}
		
		//-----------//
		//Constructor//
		//-----------//
		
		/**
		 * Creates a new <code>ApplicationFileParser</code> object.
		 * 
		 * @param	loadableFileFactory		The <code>LoadableFileFactory</code>.
		 */
		public function ApplicationFileParser(loadableFileFactory:LoadableFileFactory=null):void
		{
			_loadableFileFactory = (loadableFileFactory==null) ? new LoadableFileFactory() : loadableFileFactory;
		}
		
		//--------------//
		//Public methods//
		//--------------//
		
		/**
		 * Parse the specified <code>XMLNode</code>.
		 * 
		 * @param	node	The <code>XMLNode</code> to parse.
		 * @param	ch.capi.errors.ParseError	If the node is invalid.
		 */
		public function parse(node:XMLNode):void
		{
			if(node.childNodes.length != 2) throw new ParseError("checkLength", "Invalid node count : "+node.childNodes.length, node);
			parseFiles(node.childNodes[0]);
			parseDependencies(node.childNodes[1]);
		}
		
		//-----------------//
		//Protected methods//
		//-----------------//
		
		/**
		 * Creates a <code>ApplicationFile</code> from the <code>XMLNode</code>.
		 * 
		 * @param	node		The <code>XMLNode</code> to parse.
		 * @return	The created <code>ApplicationFile</code>.
		 */
		protected function createApplicationFile(node:XMLNode):ApplicationFile
		{
			var n:String = node.attributes[ATTRIBUTE_NAME_VALUE];
			if (n == null || n.length == 0) throw new ParseError("checkName", "Attribute '"+ATTRIBUTE_NAME_VALUE+"' is not defined", node);
		
			var a:ApplicationFile = new ApplicationFile(n);
			
			var u:String = node.attributes[ATTRIBUTE_URL_VALUE];
			var t:String = node.attributes[ATTRIBUTE_TYPE_VALUE];
			if (u != null && u.length > 0)
			{
				var lf:ILoadableFile = createLoadableFile(u, t);
				a.loadableFile = lf;
				
				//attach the properties to the ILoadableFile
				for(var prop:String in node.attributes)
				{
					var dt:String = node.attributes[prop];
					lf.properties.put(prop, dt);
					
					//if this is the 'data' property, then attribute it to the data of the URLRequest object
					if (prop == ATTRIBUTE_DATA_VALUE)
					{
						try
						{
							var rv:URLVariables = new URLVariables(dt);
							lf.urlRequest.data = rv;
						}
						catch(e:Error)
						{
							lf.urlRequest.data = dt;
						}
					}
				}
				
				//initialization
				initializeLoadableFile(lf);
			}
			
			var g:String = node.attributes[ATTRIBUTE_GLOBAL_VALUE];
			a.global = (g == true.toString());
			
			return a;
		}
		
		/**
		 * Creates a <code>ILoadableFile</code> object.
		 * 
		 * @param	url		The url.
		 * @param	type	The type issued from the <code>LoadableFileFactory</code> constants.
		 * @return	The <code>ILoadableFile</code> created.
		 */
		protected function createLoadableFile(url:String, type:String=null):ILoadableFile
		{
			var lf:LoadableFileFactory = _loadableFileFactory;
			if (type == null) return lf.create(url);
			
			var ur:URLRequest = new URLRequest(url);
			switch (type)
			{
				case LoadableFileType.BINARY:
				case LoadableFileType.TEXT:
				case LoadableFileType.VARIABLES:
					return lf.createURLLoaderFile(ur, type);
					
				case LoadableFileType.SWF:
					return lf.createLoaderFile(ur);
					
				case LoadableFileType.SOUND:
					return lf.createSoundFile(ur);
					
				case LoadableFileType.STREAM:
					return lf.createURLStreamFile(ur);
			}
			
			//the type is unkown, we create a loadable file by default
			return lf.create(url);
		}
		
		/**
		 * Initialize the <code>ILoadableFile</code>. This method initialize the <code>virtualBytesTotal</code>,
		 * <code>useCache</code> and <code>netState</code> values if they are defined into the <code>properties</code>
		 * map of the <code>ILoadableFile</code>.
		 * 
		 * @param	file	The <code>ILoadableFile</code> to initialize.
		 */
		protected function initializeLoadableFile(file:ILoadableFile):void
		{
			var p:* = file.properties.getValue(ATTRIBUTE_VIRTUALBYTESTOTAL_VALUE);
			if (p != null && !isNaN(p)) file.virtualBytesTotal = parseInt(p);
			
			var c:* = file.properties.getValue(ATTRIBUTE_USECACHE_VALUE);
			if (c != null) file.useCache = (c==false.toString());
			
			var n:* = file.properties.getValue(ATTRIBUTE_NETSTATE_VALUE);
			if (n != null) file.netState = n;
		}
		
		//---------------//
		//Private methods//
		//---------------//
		
		/**
		 * @private
		 */
		private function parseFiles(node:XMLNode):void
		{
			var n:Array = node.childNodes;
			for each(var cn:XMLNode in n)
			{
				createApplicationFile(cn);
			}
		}
		
		/**
		 * @private
		 */
		private function parseDependencies(node:XMLNode):void
		{
			var n:Array = node.childNodes;
			for each(var cn:XMLNode in n)
			{
				var app:ApplicationFile = getApplicationFile(cn);
				parseFileDependency(app, cn);
			}
		}
		
		/**
		 * @private
		 */
		private function parseFileDependency(file:ApplicationFile, node:XMLNode):void
		{
			var n:Array = node.childNodes;
			for each(var cn:XMLNode in n)
			{
				var app:ApplicationFile = getApplicationFile(cn);
				file.addDependency(app);
			}
		}
		
		/**
		 * @private
		 */
		private function getApplicationFile(node:XMLNode):ApplicationFile
		{
			var name:String = node.attributes[ATTRIBUTE_NAME_VALUE];
			if (name == null || name.length == 0) throw new ParseError("checkName", "Attribute '"+ATTRIBUTE_NAME_VALUE+"' not defined", node);
			
			var app:ApplicationFile = ApplicationFile.getFile(name);
			if (app == null) throw new TypeError("The file named '"+name+"' does not exist");
			
			return app;
		}	}}