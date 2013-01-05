package objects.events 
{
	import flash.events.Event;
	import objects.platformer.Ennemy;
	
	/**
	 * ...
	 * @author matt
	 */
	public class FightEvent extends Event 
	{
		
		public static var START_FIGHT:String = "start_fight";
		public static var STOP_FIGHT:String = "stop_fight";
		
		public var ennemy:String;
		
		public function FightEvent(type:String, ennemy:String ) 
		{ 
			super(type, false, false);
			this.ennemy = ennemy;
			trace( "created event " + type + " for ennemy " + ennemy );
		} 
		
		public override function clone():Event 
		{ 
			return new FightEvent(type, ennemy);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("FightEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}