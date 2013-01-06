package objects.platformer
{
	import Box2DAS.Collision.Shapes.b2PolygonShape;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.b2FixtureDef;
	import Box2DAS.Dynamics.ContactEvent;
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.PhysicsObject;
	import com.citrusengine.objects.platformer.Baddy;
	import com.citrusengine.objects.platformer.Hero;
	import com.citrusengine.objects.platformer.Platform;
	import com.citrusengine.physics.CollisionCategories;
	import com.citrusengine.utils.Box2DShapeMaker;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import objects.events.CinematicEvent;
	import org.osflash.signals.Signal;
	
	
	
	/**
	 * This is a common example of a side-scrolling bad guy. He has limited logic, basically
	 * only turning around when he hits a wall.
	 * 
	 * When controlling collision interactions between two objects, such as a Horo and Baddy,
	 * I like to let each object perform its own actions, not control one object's action from the other object.
	 * For example, the Hero doesn't contain the logic for killing the Baddy, and the Baddy doesn't contain the
	 * logic for making the hero "Spring" when he kills him. 
	 */	
	public class Runner extends PhysicsObject
	{
		[Property(value="1.3")]
		public var speed:Number = 5;
		[Property(value="right")]
		public var startingDirection:String = "right";
		[Citrus(value="10")]
		public var wallSensorOffset:Number = 10;
		[Citrus(value="2")]
		public var wallSensorWidth:Number = 2;
		[Citrus(value="2")]
		public var wallSensorHeight:Number = 2;
		[Property(value="100")]
		public var healthPoints:Number = 100;
		[Property(value = "false")]
		public var running:Boolean = false;
		
		protected var _leftSensorShape:b2PolygonShape;
		protected var _rightSensorShape:b2PolygonShape;
		protected var _leftSensorFixture:b2Fixture;
		protected var _rightSensorFixture:b2Fixture;
		protected var _sensorFixtureDef:b2FixtureDef;
		
		protected var _groundContacts:Array = [];//Used to determine if he's on ground or not.
		protected var _stopped:Boolean = false;
		protected var _onGround:Boolean = false;
			
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, speed:Number, view:* = null, leftBound:Number = -100000, rightBound:Number = 100000, startingDirection:String = "left"):Runner
		{
			if (view == null) view = MovieClip;
			return new Runner(name, { x: x, y: y, width: width, height: height, speed: speed, view: view, leftBound: leftBound, rightBound: rightBound, startingDirection: startingDirection } );
		}
		
		public function Runner(name:String, params:Object=null)
		{
			
			if ( name == "Boss" )
			params.view = asset_Boss;
			
			super(name, params);
							
			if (startingDirection == "right")
			{
				_inverted = true;
			}
		
		}
		
		override public function destroy():void
		{
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_leftSensorFixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleSensorBeginContact);
			_rightSensorFixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleSensorBeginContact);
			_sensorFixtureDef.destroy();
			_leftSensorShape.destroy();
			_rightSensorShape.destroy();
			super.destroy();
		}
					
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			var position:V2 = _body.GetPosition();
			
			var velocity:V2 = _body.GetLinearVelocity();	
			
			if ( running )
			velocity.x = speed;
			else
			velocity.x = 0;
			
			_body.SetLinearVelocity(velocity);
			
			updateAnimation();
		}
				
		override protected function createBody():void
		{
			super.createBody();
			_body.SetFixedRotation(true);
		}
		
		override protected function createShape():void
		{
			_shape = Box2DShapeMaker.BeveledRect(_width, _height, 0.2);
			
			var sensorWidth:Number = wallSensorWidth / _box2D.scale;
			var sensorHeight:Number = wallSensorHeight / _box2D.scale;
			var sensorOffset:V2 = new V2( -_width / 2 - (sensorWidth / 2), _height / 2 - (wallSensorOffset / _box2D.scale));
			_leftSensorShape = new b2PolygonShape();
			_leftSensorShape.SetAsBox(sensorWidth, sensorHeight, sensorOffset);
			
			sensorOffset.x = -sensorOffset.x;
			_rightSensorShape = new b2PolygonShape();
			_rightSensorShape.SetAsBox(sensorWidth, sensorHeight, sensorOffset);
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.friction = 0;
			_fixtureDef.filter.categoryBits = CollisionCategories.Get("BadGuys");
			_fixtureDef.filter.maskBits = CollisionCategories.GetAllExcept("Items");
			
			_sensorFixtureDef = new b2FixtureDef();
			_sensorFixtureDef.shape = _leftSensorShape;
			_sensorFixtureDef.isSensor = true;
			_sensorFixtureDef.filter.categoryBits = CollisionCategories.Get("BadGuys");
			_sensorFixtureDef.filter.maskBits = CollisionCategories.GetAllExcept("Items");
		}
		
		override protected function createFixture():void
		{
			super.createFixture();
			_fixture.m_reportBeginContact = true;
			_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_fixture.addEventListener(ContactEvent.END_CONTACT, handleEndContact);
			
			_leftSensorFixture = body.CreateFixture(_sensorFixtureDef);
			_leftSensorFixture.m_reportBeginContact = true;
			_leftSensorFixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleSensorBeginContact);
			
			_sensorFixtureDef.shape = _rightSensorShape;
			_rightSensorFixture = body.CreateFixture(_sensorFixtureDef);
			_rightSensorFixture.m_reportBeginContact = true;
			_rightSensorFixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleSensorBeginContact);
		}
		
		protected function handleBeginContact(e:ContactEvent):void
		{
			var collider:PhysicsObject = e.other.GetBody().GetUserData();
							
			if (e.normal) //The normal property doesn't come through all the time. I think doesn't come through against sensors.
			{
				var collisionAngle:Number = new MathVector(e.normal.x, e.normal.y).angle * 180 / Math.PI;
				if (collisionAngle > 45 && collisionAngle < 135)
				{
					_groundContacts.push(e.other);
					_onGround = true;
				}
			}
			
		}
		
		// BUG stop fight
		protected function handleEndContact(e:ContactEvent):void
		{
			//Remove from ground contacts, if it is one.
			var index:int = _groundContacts.indexOf(e.other);
			if (index != -1)
			{
				_groundContacts.splice(index, 1);
				if (_groundContacts.length == 0)
				{
					_onGround = false;
				}
			}
			
			//_ce.state.stopFight( false, false );
			
		}
		
		protected function handleSensorBeginContact(e:ContactEvent):void
		{
			if (_body.GetLinearVelocity().x < 0 && e.fixture == _rightSensorFixture)
				return;
			
			if (_body.GetLinearVelocity().x > 0 && e.fixture == _leftSensorFixture)
				return;
				
			var collider:PhysicsObject = e.other.GetBody().GetUserData();
			var velocity:V2 = _body.GetLinearVelocity();
									
			if ( collider is Princess )
			{
				trace( 'ahah, got you!' );
			}
			
			if ( collider is Gate )
			{
				running = false;
				CitrusEngine.getInstance().stage.dispatchEvent( new CinematicEvent( CinematicEvent.PLAY_CINEMATIC, "bossFall" ) ); 
				//_ce.state.playCinematic( "bossFall" );
			}
								
		}
		
		protected function updateAnimation():void
		{			
			if ( running )
				_animation = "walk";
		}
						
	}
}