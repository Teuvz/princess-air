package objects.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author matt
	 */
	public class StateEvent extends Event 
	{

		public static var START:String = "start";
		
		public function StateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new StateEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("StateEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}