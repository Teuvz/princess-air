package objects.platformer
{
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.ContactEvent;
	import Box2DAS.Dynamics.b2Body;
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.objects.platformer.Baddy;
	import com.citrusengine.objects.platformer.Coin;
	import com.citrusengine.objects.platformer.Sensor;
	import com.citrusengine.physics.CollisionCategories;
	import com.citrusengine.utils.Box2DShapeMaker;
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	import objects.events.CinematicEvent;
	import objects.events.EndGameEvent;
	import objects.events.TeleportEvent;
	import objects.menus.Dialog;
	import objects.platformer.Knight;
	import singletons.ConstantState;
	
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.PhysicsObject;
	
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	import org.osflash.signals.Signal;
	
	/**
	 * This is a common, simple, yet solid implementation of a side-scrolling Princess. 
	 * The Princess can run, jump, get hurt, and kill enemies. It dispatches signals
	 * when significant events happen. The game state's logic should listen for those signals
	 * to perform game state updates (such as increment coin collections).
	 * 
	 * Don't store data on the Princess object that you will need between two or more levels (such
	 * as current coin count). The Princess should be re-created each time a state is created or reset.
	 */	
	public class Princess extends PhysicsObject
	{
		//properties
		/**
		 * This is the rate at which the Princess speeds up when you move him left and right. 
		 */
		[Property(value="1")]
		public var acceleration:Number = 1;
		
		/**
		 * This is the fastest speed that the Princess can move left or right. 
		 */
		[Property(value="8")]
		public var maxVelocity:Number = 8;
										
		[Property(value="2")]
		public var healingPower:Number = 2;
		
		[Property(value="")]
		public var initialAnimation:String = "";
						
		//events
			
		protected var _groundContacts:Array = [];//Used to determine if he's on ground or not.
		protected var _enemyClass:Class = Baddy;
		protected var _onGround:Boolean = false;
		protected var _springOffEnemy:Number = -1;
		protected var _hurtTimeoutID:Number;
		protected var _hurt:Boolean = false;
		protected var _friction:Number = 0.75;
		protected var _playerMovingHero:Boolean = false;
		protected var _controlsEnabled:Boolean = true;
		protected var _combinedGroundAngle:Number = 0;
		
		protected var _movingRight:Boolean = false;
		protected var _movingLeft:Boolean = false;
		
		protected var _healing:Boolean = false;
		
		/*protected var triggerBossAfterDialog:Boolean = false;
		protected var currentBossSpot:BossSpot;
		protected var stuck:Boolean = false;
						
		private var healingStamp:Number;
		private var jamHealing:Boolean = false;
		private var healBtnWasPressed:Boolean = false;*/
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, view:* = null):Princess
		{
			if (view == null) view = MovieClip;
			return new Princess(name, { x: x, y: y, width: width, height: height, view: view } );
		}
		
		/**
		 * Creates a new Princess object.
		 */		
		public function Princess(name:String, params:Object = null)
		{
			params.view = asset_Princess;
			super(name, params);
			
		}
		
		override public function destroy():void
		{
			_fixture.removeEventListener(ContactEvent.PRE_SOLVE, handlePreSolve);
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_fixture.removeEventListener(ContactEvent.END_CONTACT, handleEndContact);
			clearTimeout(_hurtTimeoutID);
			super.destroy();
		}
		
		/**
		 * Whether or not the player can move and jump with the Princess. 
		 */	
		public function get controlsEnabled():Boolean
		{
			return _controlsEnabled;
		}
		
		public function set controlsEnabled(value:Boolean):void
		{
			_controlsEnabled = value;
			
			if (!_controlsEnabled)
				_fixture.SetFriction(_friction);
		}
		
		/**
		 * Returns true if the Princess is on the ground and can jump. 
		 */		
		public function get onGround():Boolean
		{
			return _onGround;
		}
		
		/**
		 * The Princess uses the enemyClass parameter to know who he can kill (and who can kill him).
		 * Use this setter to to pass in which base class the Princess's enemy should be, in String form
		 * or Object notation.
		 * For example, if you want to set the "Baddy" class as your Princess's enemy, pass
		 * "com.citrusengine.objects.platformer.Baddy", or Baddy (with no quotes). Only String
		 * form will work when creating objects via a level editor.
		 */
		[Property(value="com.citrusengine.objects.platformer.Baddy")]
		public function set enemyClass(value:*):void
		{
			if (value is String)
				_enemyClass = getDefinitionByName(value as String) as Class;
			else if (value is Class)
				_enemyClass = value;
		}
		
		/**
		 * This is the amount of friction that the Princess will have. Its value is multiplied against the
		 * friction value of other physics objects.
		 */	
		public function get friction():Number
		{
			return _friction;
		}
		
		[Property(value="0.75")]
		public function set friction(value:Number):void
		{
			_friction = value;
			
			if (_fixture)
			{
				_fixture.SetFriction(_friction);
			}
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
			
		override protected function defineBody():void
		{
			super.defineBody();
			_bodyDef.fixedRotation = true;
			_bodyDef.allowSleep = false;
		}
		
		override protected function createShape():void
		{
			_shape = Box2DShapeMaker.BeveledRect(_width, _height, 0.1);
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.friction = _friction;
			_fixtureDef.restitution = 0;
			_fixtureDef.filter.categoryBits = CollisionCategories.Get("GoodGuys");
			_fixtureDef.filter.maskBits = CollisionCategories.GetAll();
		}
		
		override protected function createFixture():void
		{
			super.createFixture();
			_fixture.m_reportPreSolve = true;
			_fixture.m_reportBeginContact = true;
			_fixture.m_reportEndContact = true;
			_fixture.addEventListener(ContactEvent.PRE_SOLVE, handlePreSolve);
			_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_fixture.addEventListener(ContactEvent.END_CONTACT, handleEndContact);
		}
		
		protected function handlePreSolve(e:ContactEvent):void 
		{				
			var other:PhysicsObject = e.other.GetBody().GetUserData() as PhysicsObject;
			
			var heroTop:Number = y;
			var objectBottom:Number = other.y + (other.height / 2);
			
			if (objectBottom < heroTop)
				e.contact.Disable();
		}
		
		protected function handleBeginContact(e:ContactEvent):void
		{
			var collider:PhysicsObject = e.other.GetBody().GetUserData();		
			
			/*if ( collider is BossSpot )
			{
				currentBossSpot = collider as BossSpot;
				CitrusEngine.getInstance().state.view.cameraTarget = CitrusEngine.getInstance().state.getObjectByName( currentBossSpot.cameraName );
				forceDialog( 'boss', true );
				_ce.state.remove( collider );
			}
			
			if ( collider is Knight )
			{
				
				if ( stuck )
				{
					_ce.state.view.cameraTarget = this;
					stuck = false;
					Dialog.getInstance().show( 'unstuck', 'knight', 2000, true );
				}
			}
			
			if ( collider is AnimationSpot )
			{		
				_ce.stage.dispatchEvent( new CinematicEvent( CinematicEvent.PLAY_CINEMATIC, (collider as AnimationSpot).cinematic ) );
				//_ce.state.playCinematic( (collider as AnimationSpot).cinematic );
				_ce.state.remove( collider );
			}
			
			if ( collider is CameraSpot )
			{
				if ( (collider as CameraSpot).fixOnTouch == true )
				_ce.state.view.cameraTarget = collider;
			}
							
			if ( collider is DestroySpot )
				destroyElement( collider as DestroySpot );
				
			if ( collider is Switch )
				onSwitch( collider as Switch );
				
			if ( collider is Ennemy || collider is Runner )
				_ce.stage.dispatchEvent( new EndGameEvent( EndGameEvent.PRINCESS_DEAD ) );
				
			if ( collider is TeleportSpot )
			{
				//_ce.stage.dispatchEvent( new TeleportEvent( (collider as TeleportSpot).level ) );
				_ce.stage.dispatchEvent( new TeleportEvent( TeleportEvent.CHANGE, (collider as TeleportSpot).level ) );
			}
			
			if ( collider is GameOverSpot )
				_ce.stage.dispatchEvent( new EndGameEvent( EndGameEvent.WIN ) );
				
			if ( collider is StartSpot )
			{
				//trace( "start knight" );
				( _ce.state.getFirstObjectByType( Knight ) as Knight ).start();
			}*/
				
			//Collision angle
			if (e.normal) //The normal property doesn't come through all the time. I think doesn't come through against sensors.
			{
				var collisionAngle:Number = new MathVector(e.normal.x, e.normal.y).angle * 180 / Math.PI;
				if (collisionAngle > 45 && collisionAngle < 135)
				{
					_groundContacts.push(e.other);
					_onGround = true;
					updateCombinedGroundAngle();
				}
			}
		}
		
		/*protected function destroyElement( spot:DestroySpot ) : void
		{
			_ce.state.remove( _ce.state.getObjectByName( spot.elementToDestroy ) );
			_ce.state.remove( spot );
		}*/
		
		protected function handleEndContact(e:ContactEvent):void
		{
			//Remove from ground contacts, if it is one.
			var index:int = _groundContacts.indexOf(e.other);
			if (index != -1)
			{
				_groundContacts.splice(index, 1);
				if (_groundContacts.length == 0)
					_onGround = false;
				updateCombinedGroundAngle();
			}
			
		}
		
		protected function getSlopeBasedMoveAngle():V2
		{
			return new V2(acceleration, 0).rotate(_combinedGroundAngle);
		}
		
		protected function updateCombinedGroundAngle():void
		{
			_combinedGroundAngle = 0;
			
			if (_groundContacts.length == 0)
				return;
			
			for each (var contact:b2Fixture in _groundContacts)
				_combinedGroundAngle += contact.GetBody().GetAngle();
			_combinedGroundAngle /= _groundContacts.length;
		}
		
		protected function endHurtState():void
		{
			_hurt = false;
			controlsEnabled = true;
		}
			
		protected function updateAnimation():void
		{													
			if ( ConstantState.getInstance().runningCinematic == false )
			{
				
				if ( _healing )
				{
					_animation = "heal";
				}
				else if (_hurt)
				{
					_animation = "hurt";
				}
				else if (!_onGround)
				{
					_animation = "jump";
				}
				else
				{
					var walkingSpeed:Number = getWalkingSpeed();
					if (walkingSpeed < -acceleration)
					{
						_inverted = true;
						_animation = "walk";
					}
					else if (walkingSpeed > acceleration)
					{
						_inverted = false;
						_animation = "walk";
					}
					else
					{
						_animation = "idle";
					}
				}
							
			}
		}
	
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			var velocity:V2 = _body.GetLinearVelocity();
					
			if (controlsEnabled )
			{
								
				if (_movingRight)
				{
					velocity = V2.add(velocity, getSlopeBasedMoveAngle());
					stopHealing();
				}
				
				if (_movingLeft)
				{
					velocity = V2.subtract(velocity, getSlopeBasedMoveAngle());
					stopHealing();
				}
								
				//If player just started moving the Princess this tick.
				if (!_playerMovingHero)
				{
					_playerMovingHero = true;
					_fixture.SetFriction(0); //Take away friction so he can accelerate.
				}
				//Player just stopped moving the Princess this tick.
				else if (_playerMovingHero)
				{
					_playerMovingHero = false;
					_fixture.SetFriction(_friction); //Add friction so that he stops running
				}
				
				//Cap velocities
				if (velocity.x > (maxVelocity))
					velocity.x = maxVelocity;
				else if (velocity.x < (-maxVelocity))
					velocity.x = -maxVelocity;
				
				//update physics with new velocity
				_body.SetLinearVelocity(velocity);
				
			}
			
			_movingRight = false;
			_movingLeft = false;
			
			updateAnimation();
		}
		
		public function moveRight() : void
		{
			_movingRight = true;
		}
		
		public function moveLeft() : void
		{
			_movingLeft = true;
		}
		
		public function get healing() : Boolean
		{
			return _healing;
		}
		
		public function startHealing() : void
		{
			if ( !_movingRight && !_movingLeft )
			{
				_healing = true;
			}
		}
		
		public function stopHealing() : void
		{
			_healing = false;
		}

	}
}