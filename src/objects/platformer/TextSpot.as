package objects.platformer
{
	import Box2DAS.Dynamics.ContactEvent;
	import Box2DAS.Dynamics.b2Body;
	import com.citrusengine.core.CitrusEngine;
	import flash.display.MovieClip;
	import objects.events.DialogEvent;
	
	import com.citrusengine.objects.PhysicsObject;
	
	import org.osflash.signals.Signal;
	
	/**
	 * Sensors simply listen for when an object begins and ends contact with them. They disaptch a signal
	 * when contact is made or ended, and this signal can be used to perform custom game logic such as
	 * triggering a scripted event, ending a level, popping up a dialog box, and virtually anything else.
	 * 
	 * Remember that signals dispatch events when ANY Box2D object collides with them, so you will want
	 * your collision handler to ignore collisions with objects that it is not interested in, or extend
	 * the sensor and use maskBits to ignore collisions altogether.  
	 * 
	 * Events
	 * onBeginContact - Dispatches on first contact with the sensor.
	 * onEndContact - Dispatches when the object leaves the sensor.
	 */	
	public class TextSpot extends PhysicsObject
	{
		/**
		 * Dispatches on first contact with the sensor.
		 */
		public var onBeginContact:Signal;
		/**
		 * Dispatches when the object leaves the sensor.
		 */
		public var onEndContact:Signal;
		
		// text id
		[Property(value="hello world")]
		public var text:String;
		
		// true to pause game when show text
		[Property(value="true")]
		public var pauseOnRead:Boolean = true;
		
		// time (in ms) before dialog auto-closes
		[Property(value="2000")]
		public var displayTime:uint = 2000;
		
		// true if the knight starts the dialog
		[Property(value="true")]
		public var readByKnight:Boolean = true;
		
		// text to show if the princess touches this spot a 2nd time
		[Property(value="")]
		public var switchText:String;
						
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, view:* = null):TextSpot
		{
			if (view == null) view = MovieClip;
			return new TextSpot(name, { x: x, y: y, width: width, height: height, view: view } );
		}
		
		public function TextSpot(name:String, params:Object=null)
		{
			super(name, params);
			onBeginContact = new Signal(ContactEvent);
			onEndContact = new Signal(ContactEvent);
		}
		
		override public function destroy():void
		{
			onBeginContact.removeAll();
			onEndContact.removeAll();
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_fixture.removeEventListener(ContactEvent.END_CONTACT, handleEndContact);
			super.destroy();
		}
		
		[Property(value="30")]
		override public function set width(value:Number):void
		{
			super.width = value;
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			_bodyDef.type = b2Body.b2_staticBody;
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.isSensor = true;
		}
		
		override protected function createFixture():void
		{
			super.createFixture();
			_fixture.m_reportBeginContact = true;
			_fixture.m_reportEndContact = true;
			_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_fixture.addEventListener(ContactEvent.END_CONTACT, handleEndContact);
		}
		
		protected function handleBeginContact(e:ContactEvent):void
		{
			onBeginContact.dispatch(e);
			
			var collider:PhysicsObject = e.other.GetBody().GetUserData();
			var _ce:CitrusEngine = CitrusEngine.getInstance();
			
			if ( collider is Princess )
			{
				_ce.stage.dispatchEvent( new DialogEvent( DialogEvent.DIALOG_SHOW, this.text, this.pauseOnRead, false, this.displayTime ) );
				
				if ( this.switchText != null && this.switchText != "" )
				{
					this.text = this.switchText;
					this.switchText = null;
				}
				else
				{
					_ce.state.remove(this);
				}
				
				_ce.state.view.cameraTarget = collider;
			}
			else if ( collider is Knight && this.readByKnight )
			{
				_ce.stage.dispatchEvent( new DialogEvent( DialogEvent.DIALOG_SHOW, this.text, this.pauseOnRead, false, this.displayTime ) );
				_ce.state.view.cameraTarget = collider;
				_ce.state.remove(this);
			}
		}
		
		protected function handleEndContact(e:ContactEvent):void
		{
			onEndContact.dispatch(e);
		}
	}
}