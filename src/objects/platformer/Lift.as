package objects.platformer
{
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.ContactEvent;
	import Box2DAS.Dynamics.b2Body;
	import com.citrusengine.core.SoundManager;
	import com.citrusengine.objects.platformer.Platform;
	import flash.display.MovieClip;
	import singletons.Assets;
	
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.PhysicsObject;
	
	/**
	 * A platform that moves between two points. The Lift has several properties that
	 * can customize it.
	 * 
	 * Properties:
	 * speed - The speed at which the moving platform travels. 
	 * enabled - Whether or not the Lift can move, no matter the condition.
	 * startX -  The initial starting X position of the Lift, and the place it returns to when it reaches the end destination.
	 * startY -  The initial starting Y position of the Lift, and the place it returns to when it reaches the end destination.
	 * endX -  The ending X position of the Lift, and the place it returns to when it reaches the start destination.
	 * endY -  The ending Y position of the Lift, and the place it returns to when it reaches the start destination.
	 * waitForPassenger - If set to true, Lift will not move unless there is a passenger. If set to false, it continually moves.
	 */	
	public class Lift extends Platform
	{
		/**
		 * The speed at which the moving platform travels. 
		 */
		[Property(value="1")]
		public var speed:Number = 1;
		
		/**
		 * Whether or not the Lift can move, no matter the condition. 
		 */		
		[Property(value="false")]
		public var enabled:Boolean = false;
		
		/**
		 * If set to true, the Lift will not move unless there is a passenger. 
		 */
		[Property(value="false")]
		public var waitForPassenger:Boolean = false;
		
		protected var _start:MathVector = new MathVector();
		protected var _end:MathVector = new MathVector();
		protected var _forward:Boolean = true;
		protected var _passengers:Vector.<b2Body> = new Vector.<b2Body>();
				
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, endX:Number, endY:Number, view:* = null, speed:Number = 1, waitForPassenger:Boolean = false):Lift
		{
			if (view == null) view = MovieClip;
			return new Lift(name, { x: x, y: y, width: width, height: height, endX: endX, endY: endY, view: view, speed: speed, waitForPassenger: waitForPassenger } );
		}
		
		public function Lift(name:String, params:Object=null)
		{
			params.view = Assets.getInstance().formatName(params.view);
						
			super(name, params);
		}
		
		override public function destroy():void
		{
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_fixture.removeEventListener(ContactEvent.END_CONTACT, handleEndContact);
			_passengers.length = 0;
			super.destroy();
		}
		
		[Property(value="0")]
		override public function set x(value:Number):void
		{
			super.x = value;
			
			_start.x = value / _box2D.scale;
		}
		
		[Property(value="0")]
		override public function set y(value:Number):void
		{
			super.y = value;
			
			_start.y = value / _box2D.scale;
		}
		
		/**
		 * The initial starting X position of the Lift, and the place it returns to when it reaches
		 * the end destination.
		 */		
		public function get startX():Number
		{
			return _start.x * _box2D.scale;
		}
		
		public function set startX(value:Number):void
		{
			_start.x = value / _box2D.scale;
		}
		
		/**
		 * The initial starting Y position of the Lift, and the place it returns to when it reaches
		 * the end destination.
		 */		
		public function get startY():Number
		{
			return _start.y * _box2D.scale;
		}
		
		public function set startY(value:Number):void
		{
			_start.y = value / _box2D.scale;
		}
		
		/**
		 * The ending X position of the Lift.
		 */		
		public function get endX():Number
		{
			return _end.x * _box2D.scale;
		}
		
		[Property(value="0")]
		public function set endX(value:Number):void
		{
			_end.x = value / _box2D.scale;
		}
		
		/**
		 * The ending Y position of the Lift.
		 */		
		public function get endY():Number
		{
			return _end.y * _box2D.scale;
		}
		
		[Property(value="0")]
		public function set endY(value:Number):void
		{
			_end.y = value / _box2D.scale;
		}
		
		override public function update(timeDelta:Number):void
		{
			
			super.update(timeDelta);
			
			var velocity:V2 = _body.GetLinearVelocity();
			
			if ((waitForPassenger && _passengers.length == 0) || !enabled)
			{				
				//Platform should not move
				velocity.zero();				
			}
			else
			{
				//Move the platform according to its destination
			
				var destination:V2 = new V2(_end.x, _end.y);
				if (!_forward)
					destination = new V2(_start.x, _start.y);
				
				velocity = destination.subtract(_body.GetPosition());
				
				if (velocity.length() > speed / 30)
				{
					//Still has further to go. Normalize the velocity to the max speed
					velocity = velocity.normalize(speed);
										
				}
				else
				{
					//Destination is very close. Switch the travelling direction
					//_forward = !_forward;
					speed = 0;					
				}
			}
			
			_body.SetLinearVelocity(velocity);
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			_bodyDef.type = b2Body.b2_kinematicBody; //Kinematic bodies don't respond to outside forces, only velocity.
			_bodyDef.allowSleep = false;
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
			/*if ( e.other.GetBody().GetUserData() is Princess )
				enabled = true;*/
			
			_passengers.push(e.other.GetBody());
		}
		
		protected function handleEndContact(e:ContactEvent):void
		{
			_passengers.splice(_passengers.indexOf(e.other.GetBody()), 1); 
			
			if ( e.other.GetBody().GetUserData() is Princess )
				enabled = false;
		}
	}
}