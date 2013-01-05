package singletons 
{
	/**
	 * ...
	 * @author matt
	 */
	public class XmlGameData 
	{
		
		private static var instance:XmlGameData;
		
		public var cinematics:XML;
		public var texts:XML;
		public var lang:String;
		
		public function XmlGameData() 
		{
			
		}
		
		public static function getInstance() : XmlGameData
		{
			if ( instance == null )
			instance = new XmlGameData();
			return instance;
		}
		
	}

}