package singletons 
{
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author matt
	 */
	public class Assets 
	{
		
		private static var instance:Assets;
		
		private var reported:Vector.<String> = new Vector.<String>();
		
		public function Assets() 
		{
			
		}
		
		public static function getInstance() : Assets
		{
			if ( instance == null )
			instance = new Assets();
			
			return instance;
		}
		
		public function formatName( name:String ) : String
		{
			var plop:String = name;
			plop = plop.replace( "/", "_" );
			plop = plop.replace( ".gif", "" );
			plop = plop.replace( ".GIF", "" );
			plop = plop.replace( ".png", "" );
			plop = plop.replace( ".jpg", "" );
			
			if ( plop.indexOf( ".swf" ) != -1 )
				return plop.replace( ".swf", "" );
			
			if ( ApplicationDomain.currentDomain.hasDefinition( plop ) )
				return plop;
					
			if ( reported.indexOf( plop ) == -1 && plop != "" )
			{
				trace( "asset not in library: " + plop );
				reported.push( plop );
			}
				
			return name;
		}
		
	}

}