package objects.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Matt
	 */
	public class KnightEvent extends Event 
	{
		
		public static const KNIGHT_START:String = 'knight_start';
		public static const KNIGHT_REMOVED:String = 'knight_removed';
				
		public function KnightEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new KnightEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("KnightEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}