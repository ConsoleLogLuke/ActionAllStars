package com.sdg.model
{
	public class QuestProviderCollection extends ObjectCollection
	{
		public function QuestProviderCollection()
		{
			super();
		}
		
		////////////////////
		// STATIC METHODS
		////////////////////
		
		public static function ParseMultipleQuestProviderXML(xml:XMLList):QuestProviderCollection
		{
			var i:int = 0;
			var questProviderXML:XML;
			var questProvider:QuestProvider;
			var collection:QuestProviderCollection = new QuestProviderCollection();
			while (xml.questProvider[i] != null)
			{
				questProviderXML = xml.questProvider[i];
				questProvider = QuestProvider.ParseQuestProviderXML(questProviderXML);
				if (questProvider != null) collection.push(questProvider);
				i++;
			}
			
			return collection;
		}
		
		////////////////////
		// INSTANCE METHODS
		////////////////////
		
		/**
		 * Returns the item at the specified index.
		 */
		public function getAt(index:int):QuestProvider
		{	
			return _data[index];
		}
		
		/**
		 * Returns the index of the specified item.
		 */
		public function indexOf(value:QuestProvider):int
		{
			return _data.indexOf(value);
		}
	
		/**
		 * Returns whether the value exists.
		 */
		public function contains(value:QuestProvider):Boolean
		{
			return _data.indexOf(value) > -1;
		}
		
		/**
		 * Adds item to the end of the collection.
		 */
		public function push(value:QuestProvider):uint
		{
			return _data.push(value);
		}
		
		/**
		 * Returns the item with specified id.
		 */
		public function getFromId(id:int):QuestProvider
		{	
			var i:int = 0;
			var len:int = _data.length;
			var questProvider:QuestProvider;
			for (i; i < len; i++)
			{
				questProvider = _data[i] as QuestProvider;
				if (questProvider.id == id) return questProvider;
			}
			
			// If we get here, we couldn't find a match.
			return null;
		}
		
	}
}