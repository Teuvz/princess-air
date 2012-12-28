package objects.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Matt
	 */
	public class MenuEvent extends Event 
	{
		
		public static const START:String = "start";
		public static const CONTINUE:String = "continue";
		
		
		public function MenuEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new MenuEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("MenuEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}