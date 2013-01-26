package singletons 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author matt
	 */
	public class Texts
	{

		private static var instance:Texts;
		
		private var texts:Dictionary;
		private var lang:String;
		
		public function Texts() 
		{
			
		}
		
		public function init( texts:XML, lang:String ) : void
		{
			this.lang = lang;
			this.texts = new Dictionary();
			trace( texts );
		}
		
		public function getText( key:String ) : String
		{
			return texts[key];
		}
		
		public static function getInstance() : Texts
		{
			if ( instance == null )
				instance = new Texts();
			return instance;
		}
		
	}

}