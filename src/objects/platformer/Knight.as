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
	import com.citrusengine.view.CitrusView;
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import objects.events.KnightEvent;
	import objects.menus.Dialog;
	import org.osflash.signals.Signal;
	import singletons.ConstantState;
	
	
	
	/**
	 * This is a common example of a side-scrolling bad guy. He has limited logic, basically
	 * only turning around when he hits a wall.
	 * 
	 * When controlling collision interactions between two objects, such as a Horo and Baddy,
	 * I like to let each object perform its own actions, not control one object's action from the other object.
	 * For example, the Hero doesn't contain the logic for killing the Baddy, and the Baddy doesn't contain the
	 * logic for making the hero "Spring" when he kills him. 
	 */	
	public class Knight extends PhysicsObject
	{
		[Property(value="6")]
		public var speed:Number = 6;
		[Property(value="right")]
		public var startingDirection:String = "right";
		[Citrus(value="10")]
		public var wallSensorOffset:Number = 10;
		[Citrus(value="2")]
		public var wallSensorWidth:Number = 2;
		[Citrus(value="2")]
		public var wallSensorHeight:Number = 2;
		[Property(value="1000")]
		public var healthPoints:Number = 1000;
		[Property(value="1000")]
		public var maxHealthPoints:Number = 1000;
		[Property(value="5")]
		public var hitPoints:Number = 5;
		[Property(value = "200")]
		public var hitFrequency:Number = 180;
		[Property(value="true")]
		public var startRunning:Boolean = true;
		
		/**
		 * This is the initial velocity that the hero will move at when he jumps.
		 */
		[Property(value="14")]
		public var jumpHeight:Number = 14;
		
		protected var _enemyClass:* = Baddy;
		protected var _lastXPos:Number;
		
		protected var _leftSensorShape:b2PolygonShape;
		protected var _rightSensorShape:b2PolygonShape;
		protected var _leftSensorFixture:b2Fixture;
		protected var _rightSensorFixture:b2Fixture;
		protected var _sensorFixtureDef:b2FixtureDef;
		
		protected var _groundContacts:Array = [];//Used to determine if he's on ground or not.
		protected var _stopped:Boolean = false;
		protected var _onGround:Boolean = false;
		protected var _fighting:Boolean = false;
		protected var _comingBack:Boolean = false;
		protected var _talking:Boolean = false;
				
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, speed:Number, view:* = null, leftBound:Number = -100000, rightBound:Number = 100000, startingDirection:String = "left"):Knight
		{
			if (view == null) view = MovieClip;
			return new Knight(name, { x: x, y: y, width: width, height: height, speed: speed, view: view, leftBound: leftBound, rightBound: rightBound, startingDirection: startingDirection } );
		}
		
		public function Knight(name:String, params:Object=null)
		{
			params.view = asset_Knight;
			super(name, params);
			
			if (startingDirection == "left")
			{
				_inverted = true;
			}
			
			if ( !startRunning )
				stop();
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
		
		public function get enemyClass():*
		{
			return _enemyClass;
		}
		
		[Property(value="objects.platformer.Ennemy")]
		public function set enemyClass(value:*):void
		{
			if (value is String)
				_enemyClass = getDefinitionByName(value) as Class;
			else if (value is Class)
				_enemyClass = value;
		}
		
		override public function update(timeDelta:Number):void
		{
			
			super.update(timeDelta);
			
			if ( CitrusEngine.getInstance().playing && !ConstantState.getInstance().runningCinematic && !_stopped )
			{				
	
				var position:V2 = _body.GetPosition();
				_lastXPos = position.x;
								
				var velocity:V2 = _body.GetLinearVelocity();
		
				if (_inverted)
					velocity.x = -speed;
				else
					velocity.x = speed;
					
				_body.SetLinearVelocity(velocity);
	
				updateAnimation();
				
			}

		}
				
		public function turnAround():void
		{
			_inverted = !_inverted;
			//trace( 'Knight: TurnAround ' );
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
			//_fixtureDef.filter.categoryBits = CollisionCategories.Get("BadGuys");
			//_fixtureDef.filter.maskBits = CollisionCategories.GetAllExcept("Items");
			
			_sensorFixtureDef = new b2FixtureDef();
			_sensorFixtureDef.shape = _leftSensorShape;
			_sensorFixtureDef.isSensor = true;
			//_sensorFixtureDef.filter.categoryBits = CollisionCategories.Get("BadGuys");
			//_sensorFixtureDef.filter.maskBits = CollisionCategories.GetAllExcept("Items");
		}
		
		/**
		 * Returns the absolute walking speed, taking moving platforms into account.
		 * Isn't super performance-light, so use sparingly.
		 */
		public function getWalkingSpeed():Number
		{
			var groundVelocityX:Number = 0;
			for each (var groundContact:b2Fixture in _groundContacts)
			{
				groundVelocityX += groundContact.GetBody().GetLinearVelocity().x;
			}
			
			return _body.GetLinearVelocity().x - groundVelocityX;
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
															
			if ( collider is Gate )
			{
				trace("plop");
			}
			else if ( collider is GameOverSpot )
			{
				_ce.stage.dispatchEvent( new KnightEvent( KnightEvent.KNIGHT_REMOVED ) );
				//_ce.state.remove( this );
			}
			else if ( collider is Princess && _comingBack )
			{
				//trace( 'Knight: TurnAround ' );
				endComeBack();
			}
			else if ( collider is Destructible )
			{
				//(collider as Destructible).destruct();
				_ce.state.remove( collider );
			}
			else if ( collider is StartSpot )
			{
				start();
				//_ce.state.remove( collider );
				//trace( 'Knight: StartSpot ' + collider.name );
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
		
		}
		
		protected function handleSensorBeginContact(e:ContactEvent):void
		{
			if (_body.GetLinearVelocity().x < 0 && e.fixture == _rightSensorFixture)
				return;
			
			if (_body.GetLinearVelocity().x > 0 && e.fixture == _leftSensorFixture)
				return;
				
			var collider:PhysicsObject = e.other.GetBody().GetUserData();
													
			if ( collider is Destructible )
			{
				//(collider as Destructible).destruct();
				_ce.state.remove( collider );
			}
			else if ( collider is DirectionSpot )
			{
				_inverted = !_inverted;
				_ce.state.remove( collider );
				//trace( 'Knight: DirectionSpot ' + collider.name );
			} 
			else if ( collider is StopSpot )
			{
				
				if (  (collider as StopSpot).deleteOnTouch ) 
					_ce.state.remove( collider );
				
				stop();
				//_ce.state.remove( collider );
				//trace( 'Knight: StopSpot ' + collider.name );
			} 
			else if ( collider is StartSpot )
			{
				start();
				//_ce.state.remove( collider );
				//trace( 'Knight: StartSpot ' + collider.name );
			}
			else if ( collider is Gate )
			{
				trace("plop!");
			}
		}
		
		protected function updateAnimation():void
		{			
			if ( !ConstantState.getInstance().runningCinematic )
			{
				if ( _fighting )
					_animation = "fight";
				else if ( _talking )
					_animation = "talking";
				else if ( _stopped )
					_animation = "idle";
				else
					_animation = "walk";
			}
		}
						
		public function comeBack() : void
		{
			if ( !_comingBack )
			{
				_comingBack = true;
				this.turnAround();
				
				if ( _stopped )
					_stopped = false;
				
				Dialog.getInstance().show( 'text_comeback' );
				//_ce.state.showDialog( 'text_comeback', 1000, false );
			}
		}
		
		public function endComeBack() : void
		{
			_comingBack = false;
			this.turnAround();
		}
		
		public function start() : void
		{
			_stopped = false;
			_animation = "walk";
			
			if ( _talking )
				_talking = false;
		}
		
		public function stop( talking:Boolean = false ) : void
		{
			var velocity:V2 = _body.GetLinearVelocity();
			velocity.x = 0;
			_body.SetLinearVelocity(velocity);
			_stopped = true;
			_talking = talking;
		}
		
		public function startFighting() : void
		{
			stop();
			_fighting = true;
			_animation = "fight";
		}
		
		public function stopFighting( won:Boolean = true ) : void
		{
			_fighting = false;
			
			if ( won )
			{
				start();
			}
			else
			{
				trace('urg');
			}
		}
		
		public function hurt() : void
		{
			
		}
		
	}
}