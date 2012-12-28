package objects.events 
{
	import flash.events.Event;
	import objects.platformer.Knight;
	
	/**
	 * ...
	 * @author Matt
	 */
	public class TeleportEvent extends Event 
	{
		public static const RELOAD:String = 'reload';
		
		public static const CHANGE:String = 'change';
		public var lvl:String;
		
		public function TeleportEvent(type:String, _lvl:String, bubbles:Boolean = false, cancelable:Boolean = false) 
		{ 
			super(type, bubbles, cancelable);
			lvl = _lvl;
		} 
		
		public override function clone():Event 
		{ 
			return new TeleportEvent(type, lvl, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("TeleportEvent", "lvl", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}