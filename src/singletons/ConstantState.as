package singletons 
{
	/**
	 * ...
	 * @author ...
	 */
	public class ConstantState 
	{

		private static var instance:ConstantState;
		
		public var runningCinematic:Boolean = false;
		public var fightTing:Boolean = false;
		
		public function ConstantState() 
		{
			
		}
		
		public static function getInstance() : ConstantState
		{
			if ( instance == null )
				instance = new ConstantState();
				
			return instance;
		}
		
	}

}