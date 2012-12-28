package objects.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Matt
	 */
	public class EndGameEvent extends Event 
	{
		
		public static const PRINCESS_DEAD:String = 'princessdead';
		public static const KNIGHT_DEAD:String = 'knightdead';
		public static const WIN:String = 'win';
		public static const RELOAD:String = 'reload';
		public static const EXIT:String = 'exit';
		
		public function EndGameEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new EndGameEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("EndGameEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}