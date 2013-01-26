package objects.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author matt
	 */
	public class DialogEvent extends Event 
	{
		
		public static const DIALOG_SHOW:String = "dialog_show";
		public static const DIALOG_HIDE:String = "dialog_hide";
		
		public var text:String;
		public var block:Boolean;
		public var forced:Boolean;
		public var timer:uint;
		
		public function DialogEvent(type:String, text:String=null, block:Boolean=true, forced:Boolean=false, timer:uint=200) 
		{ 
			super(type, false, true);
			
			this.text = text;
			this.block = block;
			this.forced = forced;
			this.timer = timer;
			
		} 
		
		public override function clone():Event 
		{ 
			return new DialogEvent(type, text,block, forced, timer);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("DialogEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}