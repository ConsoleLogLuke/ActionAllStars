package it.gotoandplay.smartfoxserver.data
{
	public class User
	{
		private var id:int
		private var name:String
		private var variables:Array
		private var isSpec:Boolean
		private var isMod:Boolean
		private var pId:int
		
		public function User(id:int, name:String)
		{
			this.id = id
			this.name = name
			this.variables = []
			this.isSpec = false
			this.isMod = false
		}
		
		public function getId():int
		{
			return this.id
		}
		
		public function getName():String
		{
			return this.name
		}
		
		public function getVariable(varName:String):Object
		{
			return this.variables[varName]
		}
		
		public function getVariables():Array
		{
			return this.variables
		}
		
		public function clearVariables():void
		{
			this.variables = []
		}
		
		public function setIsSpectator(b:Boolean):void
		{
			this.isSpec = b
		}
		
		public function isSpectator():Boolean
		{
			return this.isSpec
		}
		
		public function setModerator(b:Boolean):void
		{
			this.isMod = b
		}
		
		public function isModerator():Boolean
		{
			return this.isMod
		}
		
		public function getPlayerId():int
		{
			return this.pId
		}
		
		public function setPlayerId(pid:int):void
		{
			this.pId = pid
		}
		
		public function setVariables(vars:Array):void
		{
			this.variables = vars
		}
		
	}
}