package singletons 
{
	/**
	 * ...
	 * @author Matt
	 */
	public class Levels 
	{
				
		private static var XML_TUTORIAL:XML;
		private static var XML_CORRIDOR:XML;
		private static var XML_THRONE:XML;
		private static var XML_LIFT:XML;
		private static var XML_WALL:XML;
		private static var XML_YARD:XML;
		private static var XML_TEST:XML;
		
		public static const LEVEL_TUTORIAL:String 	= "tutorial";
		public static const LEVEL_CORRIDOR:String 	= "corridor";
		public static const LEVEL_THRONE:String 	= "throne";
		public static const LEVEL_LIFT:String 		= "lift";
		public static const LEVEL_WALL:String 		= "wall";
		public static const LEVEL_YARD:String 		= "yard";
		public static const LEVEL_TEST:String 		= "test";
		
		public static function setLevelXml( lvl:String, xml:XML ) : void
		{ 
			switch( lvl )
			{
				case LEVEL_TUTORIAL:
					XML_TUTORIAL = xml;
					break;
				case LEVEL_CORRIDOR:
					XML_CORRIDOR = xml;
					break;
				case LEVEL_THRONE:
					XML_THRONE = xml;
					break;
				case LEVEL_LIFT:
					XML_LIFT = xml;
					break;
				case LEVEL_WALL:
					XML_WALL = xml;
					break;
				case LEVEL_YARD:
					XML_YARD = xml;
					break;
				case LEVEL_TEST:
					XML_TEST = xml;
					break;
			}
		}
		
		public static function getLevelXml( lvl:String ) : XML
		{ 
			
			var xml:XML;
			
			switch( lvl )
			{
				case LEVEL_TUTORIAL:
					xml = XML_TUTORIAL;
					break;
				case LEVEL_CORRIDOR:
					xml = XML_CORRIDOR;
					break;
				case LEVEL_THRONE:
					xml = XML_THRONE;
					break;
				case LEVEL_LIFT:
					xml = XML_LIFT;
					break;
				case LEVEL_WALL:
					xml = XML_WALL;
					break;
				case LEVEL_YARD:
					xml = XML_YARD;
					break;
				case LEVEL_TEST:
					xml = XML_TEST;
					break;
			}
			
			return xml;
		}
				
	}

}