package objects.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author matt
	 */
	public class CinematicEvent extends Event 
	{
		
		public static var PLAY_CINEMATIC:String = "play_cinematic";
		public static var PLAY_INTRO:String = "play_intro";
		
		public var name:String;
		
		public function CinematicEvent(type:String, name:String ) 
		{ 
			super(type, false, false);
			this.name = name;
		} 
		
		public override function clone():Event 
		{ 
			return new CinematicEvent(type, name);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("CinematicEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}