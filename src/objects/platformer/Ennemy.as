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
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import objects.events.FightEvent;
	import org.osflash.signals.Signal;
	import singletons.Assets;
	
	
	
	/**
	 * This is a common example of a side-scrolling bad guy. He has limited logic, basically
	 * only turning around when he hits a wall.
	 * 
	 * When controlling collision interactions between two objects, such as a Horo and Baddy,
	 * I like to let each object perform its own actions, not control one object's action from the other object.
	 * For example, the Hero doesn't contain the logic for killing the Baddy, and the Baddy doesn't contain the
	 * logic for making the hero "Spring" when he kills him. 
	 */	
	public class Ennemy extends PhysicsObject
	{
		[Property(value="1.3")]
		public var speed:Number = 5;
		[Property(value="right")]
		public var startingDirection:String = "right";
		[Property(value="5000")]
		public var hurtDuration:Number = 5000;
		[Property(value="-100000")]
		public var leftBound:Number = -100000;
		[Property(value="100000")]
		public var rightBound:Number = 100000;
		[Citrus(value="10")]
		public var wallSensorOffset:Number = 10;
		[Citrus(value="2")]
		public var wallSensorWidth:Number = 2;
		[Citrus(value="2")]
		public var wallSensorHeight:Number = 2;
		[Property(value="100")]
		public var healthPoints:Number = 100;
		public var originalHealthPoints:Number = 100;
		[Property(value="5")]
		public var hitPoints:Number = 5;
		[Property(value="true")]
		public var canMove:Boolean = true;
		[Property(value="false")]
		public var isBoss:Boolean = false;
		[Property(value="Skeleton")]
		public var type:String = "Skeleton";
		
		/**
		 * This is the initial velocity that the hero will move at when he jumps.
		 */
		[Property(value="14")]
		public var jumpHeight:Number = 14;
		
		protected var _hurtTimeoutID:Number = 0;
		protected var _hurt:Boolean = false;
		protected var _enemyClass:* = Baddy;
		protected var _lastXPos:Number;
		protected var _lastTimeTurnedAround:Number = 0;
		protected var _waitTimeBeforeTurningAround:Number = 1000;
		
		protected var _leftSensorShape:b2PolygonShape;
		protected var _rightSensorShape:b2PolygonShape;
		protected var _leftSensorFixture:b2Fixture;
		protected var _rightSensorFixture:b2Fixture;
		protected var _sensorFixtureDef:b2FixtureDef;
		
		protected var _groundContacts:Array = [];//Used to determine if he's on ground or not.
		protected var _stopped:Boolean = false;
		protected var _onGround:Boolean = false;
		
		protected var _originalX:Number;
		protected var _fighting:Boolean = false;
		protected var _knight:Knight = null;
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, speed:Number, view:* = null, leftBound:Number = -100000, rightBound:Number = 100000, startingDirection:String = "left"):Ennemy
		{
			if (view == null) view = MovieClip;
			return new Ennemy(name, { x: x, y: y, width: width, height: height, speed: speed, view: view, leftBound: leftBound, rightBound: rightBound, startingDirection: startingDirection } );
		}
		
		public function Ennemy(name:String, params:Object=null)
		{
			
			/*switch( params.type )
			{
				case "Boss":
					params.view = asset_Boss;
					break;
				default:
					params.view = asset_Skeleton;
					//params.view = getDefinitionByName("asset_Skeleton");
					break;
			}*/

			params.view = Assets.getInstance().formatName( params.view );
			
			super(name, params);
						
			originalHealthPoints = healthPoints;
			
			if (startingDirection == "left")
			{
				_inverted = true;
			}
			//this._box2D.visible = false;
			
			_originalX = this.x;
			leftBound = this.x - leftBound;
			rightBound = this.x + rightBound;		
		}
		
		override public function destroy():void
		{
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_leftSensorFixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleSensorBeginContact);
			_rightSensorFixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleSensorBeginContact);
			clearTimeout(_hurtTimeoutID);
			_sensorFixtureDef.destroy();
			_leftSensorShape.destroy();
			_rightSensorShape.destroy();
			super.destroy();
		}
		
		public function get enemyClass():*
		{
			return _enemyClass;
		}
		
		[Property(value="com.citrusengine.objects.platformer.Baddy")]
		public function set enemyClass(value:*):void
		{
			if (value is String)
				_enemyClass = getDefinitionByName(value) as Class;
			else if (value is Class)
				_enemyClass = value;
		}
		
		override public function update(timeDelta:Number):void
		{
			
			if ( CitrusEngine.getInstance().playing )
			{
			
				super.update(timeDelta);
				
				var position:V2 = _body.GetPosition();
				_lastXPos = position.x;
				
				//Turn around when they pass their left/right bounds
				if ((_inverted && position.x * 30 < leftBound) || (!_inverted && position.x * 30 > rightBound))
					turnAround();
				
				var velocity:V2 = _body.GetLinearVelocity();
				if (canMove && !_stopped && !_fighting)
				{
					if (_inverted)
						velocity.x = -speed;
					else
						velocity.x = speed;
				}
				else
				{
					velocity.x = 0;
				}
										
				_body.SetLinearVelocity(velocity);
				
				updateAnimation();
			
			}

		}
		
		public function hurt():void
		{
			//this._bodyDef.active = false;
			_hurt = true;
			_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);
		}
		
		public function turnAround():void
		{
			_inverted = !_inverted;
			_lastTimeTurnedAround = new Date().time;
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
			
			/*if (collider is _enemyClass && collider.body.GetLinearVelocity().y > enemyKillVelocity)
				hurt();*/
				
			if ( collider is Knight && !_hurt && !kill )
			{
				//_ce.state.startFight( this );
				CitrusEngine.getInstance().stage.dispatchEvent( new FightEvent( FightEvent.START_FIGHT, this.name ) );
			}
				
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
		
		// BUG the stopFight should use event/signal
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
									
			if ( collider is Hero )
			{
				trace( 'ahah, got you!' );
			}
			else
			{
				turnAround();
			}
								
		}
		
		protected function updateAnimation():void
		{			
			if ( _hurt )
				_animation = "die";
			else if ( _fighting )
				_animation = "fight";
			else
				_animation = "walk";
		}
		
		protected function endHurtState():void
		{
			
			if ( CitrusEngine.getInstance().playing )
			{
				healthPoints = originalHealthPoints;
				_hurt = false;
				body.SetActive(true );
			}
			else
				_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);
		}
		
		public function startFighting() : void
		{
			_fighting = true;
		}
		
		public function stopFighting( dead:Boolean ) : void
		{
			_fighting = false;
			if ( dead )
			{
				body.SetActive(false);
				hurt();
			}
		}
		
	}
}