package objects.platformer
{
	import Box2DAS.Dynamics.ContactEvent;
	import Box2DAS.Dynamics.b2Body;
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	
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
	public class Gate extends PhysicsObject
	{
		/**
		 * Dispatches on first contact with the sensor.
		 */
		public var onBeginContact:Signal;
		/**
		 * Dispatches when the object leaves the sensor.
		 */
		public var onEndContact:Signal;
		
		[Property(value="down")]
		public var position:String = "down";
					
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, view:* = null):Gate
		{
			if (view == null) view = MovieClip;
			return new Gate(name, { x: x, y: y, width: width, height: height, view: view } );
		}
		
		public function Gate(name:String, params:Object=null)
		{
			params.view = asset_GateGate;
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
		
		public function toggle() : void
		{
			if ( position == "down" )
			{
				TweenLite.to( this, 0.5, { y: this.y - 150 } );
				( _ce.state.getFirstObjectByType( Knight ) as Knight ).start();
				position = "up";
			}
			else
			{
				TweenLite.to( this, 0.5, { y: this.y + 150 } );
				position = "down";
			}
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
			
			trace("oh hello you");
		}
		
		protected function handleEndContact(e:ContactEvent):void
		{
			onEndContact.dispatch(e);
		}
	}
}