package objects.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author matt
	 */
	public class SwitchEvent extends Event 
	{
		public static const SWITCH_OVER:String = "switch_over";
		public static const SWITCH_OUT:String = "switch_out";
		
		public var name:String;
		
		public function SwitchEvent(type:String, switchName:String=null) 
		{ 
			super(type);
			name = switchName;
		} 
		
		public override function clone():Event 
		{ 
			return new SwitchEvent(type);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SwitchEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}