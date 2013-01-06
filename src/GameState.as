package  
{
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.CitrusObject;
	import com.citrusengine.core.SoundManager;
	import com.citrusengine.core.State;
	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.objects.PhysicsObject;
	import com.citrusengine.objects.platformer.Hero;
	import com.citrusengine.physics.Box2D;
	import com.citrusengine.utils.ObjectMaker;
	import com.citrusengine.view.spriteview.SpriteArt;
	import com.greensock.easing.Linear;
	import com.greensock.easing.Bounce;
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import objects.events.CinematicEvent;
	import objects.events.EndGameEvent;
	import objects.events.FightEvent;
	import objects.events.KnightEvent;
	import objects.events.StateEvent;
	import objects.events.TeleportEvent;
	import objects.menus.PauseMenu;
	import objects.platformer.BossSpot;
	import objects.platformer.CameraSpot;
	import objects.platformer.Checkpoint;
	import objects.platformer.Ennemy;
	import objects.platformer.Knight;
	import objects.platformer.Lift;
	import objects.platformer.Princess;
	import objects.platformer.PrincessPhysics;
	import objects.platformer.PrincessSprite;
	import objects.platformer.Runner;
	import objects.platformer.Ennemy;
	import objects.platformer.TextSpot;
	import objects.menus.Dialog;
	import singletons.ConstantState;
	import singletons.Levels;
	import singletons.XmlGameData;
	
	public class GameState extends State
	{
				
		private var paused:Boolean = false;
		private var pauseScreen:PauseMenu;
		
		private var _textData:XML;
		private var _charsData:XML;
		//private var _levelData:XML;
		private var _scenesData:XMLList;
		public var _hero:Princess;
		private var _knight:Knight;
		private var _currentEnnemy:Ennemy;
		private var _healthbar:Healthbar;
		private var _bosshealthbar:Healthbar;
		private var _levelName:String;
		private var _inMenu:Boolean;
		
		//private var _lang:String;
		private var cinematic:XML;
		public var playIntro:Boolean = false;
		private var cinematicActionStep:uint = 0;
		
		private var cinematicLineTop:BlackBand;
		private var cinematicLineBottom:BlackBand;
		
				
		public function GameState(levelData:XML, textData:XML, charsData:XML, name:String, scenesData:XMLList = null, inMenu:Boolean = false ) 
		{
			//This is the level XML file that was generated by the Level Architect.
			//_levelData = levelData;
			//_levelData = Levels.getLevelXml( name )
			_textData = textData;			
			_charsData = charsData;
			_scenesData = Levels.getCinematicXml(name);
			_levelName = name;
			_inMenu = inMenu;
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			//_view.loadManager.onLoadComplete.addOnce( handleLoadComplete );
			
			//Create Box2D
			var box2D:Box2D = new Box2D("Box2D");
			add(box2D);
			
			//Create the level objects from the XML file.
			/*if (_levelData)
				ObjectMaker.FromLevelArchitect(_levelData);*/
				ObjectMaker.FromLevelArchitect( Levels.getLevelXml( _levelName ) );
				//System.disposeXML( Levels.getLevelXml(_levelName) );
				
			//trace( "load level " + _levelName );
				
			_hero = getFirstObjectByType(Princess) as Princess;
			if ( _hero )
			{
				_hero.controlsEnabled = false;
				view.cameraTarget = _hero;
				view.cameraOffset = new MathVector(stage.stageWidth / 4, (stage.stageHeight / 3) * 2 );
				view.cameraEasing = new MathVector(1, 1);
			}
				
			if ( !_inMenu )
			{
				start();
			}
			
			stage.addEventListener( CinematicEvent.PLAY_CINEMATIC, playCinematic );
			//stage.addEventListener( CinematicEvent.PLAY_INTRO, playIntro );
			stage.addEventListener( FightEvent.START_FIGHT, startFight );
			addEventListener( StateEvent.START, start );
			
			handleLoadComplete();			
		}
		
		public function start( e:StateEvent=null ) : void
		{
			if ( e != null )
				removeEventListener( StateEvent.START, start );
			
			//Find the hero object, and make it the camera target if it exists.
			
			//trace( "state start" );
			
			_hero = getFirstObjectByType(Princess) as Princess;
			if (_hero)
			{
				_hero.controlsEnabled = true;
				view.cameraTarget = _hero;
				view.cameraOffset = new MathVector(stage.stageWidth / 2, (stage.stageHeight / 3)*2 );
				view.cameraEasing = new MathVector(0.4, 0.4);
			}
						
			_knight = getFirstObjectByType(Knight) as Knight;
					
			if ( _knight != null && _levelName != Levels.LEVEL_TUTORIAL )
			{
				_healthbar = new Healthbar();
				_healthbar.name = "HealthBar";
				_healthbar.x = 5;
				_healthbar.y = 5;
				addChild( _healthbar );
			}
			
			stage.addEventListener( KnightEvent.KNIGHT_START, knighStartRequest );
			stage.addEventListener( KnightEvent.KNIGHT_REMOVED, knightRemoved );
			
			// dialog	
			Dialog.getInstance().setXml( XmlGameData.getInstance().lang, _textData, _charsData );
			_textData = null;
			_charsData = null;
			
			_bosshealthbar = new Healthbar();
			_bosshealthbar.x = (stage.stageWidth - _bosshealthbar.width) - 5;
			_bosshealthbar.y = 5;
					
			if ( _scenesData.length() != 0 && _scenesData.child( "startAnimation" ).length() != 0 )
			{
				ConstantState.getInstance().runningCinematic = true;
				var _ce:CitrusEngine = CitrusEngine.getInstance();
				//_ce.playing = false;
				
				if ( _knight )
				_knight.stop();
							
				if (_hero)
				_hero.controlsEnabled = false;
				
				cinematic = XML( _scenesData.child( "startAnimation" ).toXMLString() );
				//_scenesData = null;
								
				showBlackBands();
				cinematicAction();
			}
			
			CitrusEngine.getInstance().stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
		}
		
		private function showBlackBands() : void
		{
			if ( cinematicLineTop == null )
			{
				cinematicLineTop = new BlackBand();
				cinematicLineTop.x = 0;
				cinematicLineTop.y = cinematicLineTop.height * -1;
				this.addChild( cinematicLineTop );
			}
			TweenLite.to( cinematicLineTop, 0.5, { y:0 } );
			
			if ( cinematicLineBottom == null )
			{
				cinematicLineBottom = new BlackBand();
				cinematicLineBottom.x = 0;
				cinematicLineBottom.y = CitrusEngine.getInstance().stage.stageHeight;
				this.addChild( cinematicLineBottom );
			}
			TweenLite.to( cinematicLineBottom, 0.5, { y:472 } );
		}
		
		private function hideBlackBands() : void
		{
			TweenLite.to( cinematicLineTop, 0.5, { y: -127 } );
			TweenLite.to( cinematicLineBottom, 0.5, { y: CitrusEngine.getInstance().stage.stageHeight } );
		}
		
		public function playCinematic( event:CinematicEvent = null, name:String = null ) : void
		{			
			
			if ( event != null )
				name = event.name;
			
			showBlackBands();
			cinematicActionStep = 0;
			ConstantState.getInstance().runningCinematic = true;
			var _ce:CitrusEngine = CitrusEngine.getInstance();
			//_ce.playing = false;
							
			_hero.controlsEnabled = false;
			
			cinematic = XML( _scenesData.child( name ).toXMLString() );
						
			cinematicAction();
		}
		
		private function cinematicAction() : void
		{
						
			if ( cinematic.action[cinematicActionStep] == undefined )
			{
				var _ce:CitrusEngine = CitrusEngine.getInstance();
				_ce.playing = true;
				ConstantState.getInstance().runningCinematic = false;
				//trace( "undefined cinematic" );
				hideBlackBands();
				//System.disposeXML( XmlGameData.getInstance().cinematics );
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'animation' )
			{				
								
				var _char:PhysicsObject = getObjectByName( cinematic.action[cinematicActionStep].character ) as PhysicsObject;				
							
				_char.animation = cinematic.action[cinematicActionStep].animation;
				
				
				if ( !cinematic.action[cinematicActionStep].hasOwnProperty( "stopanimation" ) )
				{
					setTimeout( cinematicAction, 200 );
					cinematicActionStep++;
				}
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'temp' )
			{
				setTimeout( cinematicAction, cinematic.action[cinematicActionStep].time );
				cinematicActionStep++;
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'run' )
			{				
				var _runner:Runner = getObjectByName( cinematic.action[cinematicActionStep].character ) as Runner;
				_runner.running = true;
				setTimeout( cinematicAction, 200 );
				cinematicActionStep++;
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'move' )
			{
				setTimeout( cinematicAction, cinematic.action[cinematicActionStep].time );
				
				/*if ( cinematic.action[cinematicActionStep].character == _knight.name )
				{
					trace( "this is knight" );
					trace( "is knight stopped? " + _knight._stopped );
					_knight.start();
					trace( "is knight stopped? " + _knight._stopped );
				}*/
							
				if ( cinematic.action[cinematicActionStep].effect == 'bounce' )
				{
					TweenLite.to( (getObjectByName( cinematic.action[cinematicActionStep].character ) as PhysicsObject), cinematic.action[cinematicActionStep].time / 1000, { y:cinematic.action[cinematicActionStep].y, ease:Bounce.easeOut } );
				}
				else if ( (getObjectByName( cinematic.action[cinematicActionStep].character ) as PhysicsObject) != null )
				{
					if ( cinematic.action[cinematicActionStep].x != undefined && cinematic.action[cinematicActionStep].y != undefined )
						TweenLite.to( (getObjectByName( cinematic.action[cinematicActionStep].character ) as PhysicsObject), cinematic.action[cinematicActionStep].time / 1000, { x:cinematic.action[cinematicActionStep].x, y:cinematic.action[cinematicActionStep].y, ease:Linear.easeNone } );
					else if ( cinematic.action[cinematicActionStep].x != undefined )
						TweenLite.to( (getObjectByName( cinematic.action[cinematicActionStep].character ) as PhysicsObject), cinematic.action[cinematicActionStep].time / 1000, { x:cinematic.action[cinematicActionStep].x, ease: Linear.easeNone } );
					else if ( cinematic.action[cinematicActionStep].y != undefined )
						TweenLite.to( (getObjectByName( cinematic.action[cinematicActionStep].character ) as PhysicsObject), cinematic.action[cinematicActionStep].time / 1000, { y:cinematic.action[cinematicActionStep].y, ease:Linear.easeNone } );
				}
				
				cinematicActionStep++;
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'unblock' )
			{				
				_hero.controlsEnabled = true;
				setTimeout( cinematicAction, 200 );
				cinematicActionStep++;
				
				if ( _knight )
				_knight.start();
				
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'dialog' )
			{				
				Dialog.getInstance().show( cinematic.action[cinematicActionStep].text, 'knight', 2000, false, null, true );
					
				setTimeout( cinematicAction, 2000 );
				cinematicActionStep++;
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'start_sound' )
			{
				if ( !SoundManager.getInstance().hasSound( cinematic.action[cinematicActionStep].file ) )
				SoundManager.getInstance().addSound( cinematic.action[cinematicActionStep].file, cinematic.action[cinematicActionStep].file );
				
				SoundManager.getInstance().playSound( cinematic.action[cinematicActionStep].file );
				trace( cinematic.action[cinematicActionStep].file );
				
				//SoundManager.getInstance().setGlobalVolume( this.volume/10 );
								
				setTimeout( cinematicAction, 200 );
				cinematicActionStep++;
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'stop_sound' )
			{				
				if ( SoundManager.getInstance().hasSound( cinematic.action[cinematicActionStep].file ) )
					SoundManager.getInstance().stopSound( cinematic.action[cinematicActionStep].file );;
				
				setTimeout( cinematicAction, 200 );
				cinematicActionStep++;
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'add_object' ) 
			{				
				if ( cinematic.action[cinematicActionStep].type == "Knight" )
				{
					
					var params:Object = new Object();
					params.speed = 3;
					params.startingDirection = "right";
					params.gravity = 1.6;
					params.parallax = 1;
					params.registration = "center";
					params.view = "art/knight.swf";
					params.x = cinematic.action[cinematicActionStep].x;
					params.y = cinematic.action[cinematicActionStep].y;
					params.width = 87;
					params.height = 78;
					
					_knight = new Knight( "Knight", params );
					_knight.stop();
					add( _knight );
				}
				
				setTimeout( cinematicAction, 200 );
				cinematicActionStep++;
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'remove_object' ) 
			{
				remove( getObjectByName( cinematic.action[cinematicActionStep].object ) );
				setTimeout( cinematicAction, 200 );
				cinematicActionStep++;
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'camera_target' ) 
			{
				
				if ( cinematic.action[cinematicActionStep].object == "Knight" )
				{
					//trace( getObjectByName( cinematic.action[cinematicActionStep].object ) );
				}
				
				view.cameraTarget = getObjectByName( cinematic.action[cinematicActionStep].object );
				setTimeout( cinematicAction, 200 );
				cinematicActionStep++;
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'turnaround' ) 
			{
				var temp:PhysicsObject = getObjectByName( cinematic.action[cinematicActionStep].character ) as PhysicsObject;
				temp._inverted = !temp._inverted;
				setTimeout( cinematicAction, 200 );
				cinematicActionStep++;
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'stuck' ) 
			{
				_hero.stuck = true;
				setTimeout( cinematicAction, 200 );
				cinematicActionStep++;
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'lift_start' )
			{
				(getObjectByName( cinematic.action[cinematicActionStep].object ) as Lift).enabled = true;
			}
			else if ( cinematic.action[cinematicActionStep].attribute("type") == 'teleport' )
			{
				//trace( "load " + cinematic.action[cinematicActionStep].level );
				stage.dispatchEvent( new TeleportEvent( TeleportEvent.CHANGE, cinematic.action[cinematicActionStep].level ) );
			}
			
		}
		
		override public function update(timeDelta:Number):void
		{			
			manageFight();
						
			//Call update on all objects
			var garbage:Array = [];
			var n:Number = _objects.length;
					
			for (var i:int = 0; i < n; i++)
			{
				var object:CitrusObject = _objects[i];
				if (object.kill)
					garbage.push(object);
				else
					object.update(timeDelta);
			}
			
			//Destroy all objects marked for destroy
			n = garbage.length;
			for (i = 0; i < n; i++)
			{
				var garbageObject:CitrusObject = garbage[i];
				_objects.splice(_objects.indexOf(garbageObject), 1);
				garbageObject.destroy();
				_view.removeArt(garbageObject);
			}
			
			//Update the input object
			_input.update();
			
			//Update the state's view
			_view.update();
					
		}
		
		public function startFight( event:FightEvent=null, ennemy:Ennemy=null ) : void
		{
			if ( event != null )
				ennemy = getObjectByName( event.ennemy ) as Ennemy;
								
			if ( _knight == null )
				_knight = getFirstObjectByType( Knight ) as Knight;
			
			if ( ennemy != null && _knight != null )
			{
				_currentEnnemy = ennemy;
				_knight.startFighting( );
				_currentEnnemy.startFighting();
				_view.cameraTarget = _knight;
			}
			
		}
		
		public function stopFight( ennemyDead:Boolean, knightDead:Boolean ) : void
		{
			if ( _currentEnnemy != null )
			{
				
				if ( knightDead )
					stage.dispatchEvent( new EndGameEvent( EndGameEvent.KNIGHT_DEAD ) );
				
				if ( _currentEnnemy.isBoss && ennemyDead )
				{
					remove( _currentEnnemy );
					removeChild( _bosshealthbar );
					stage.dispatchEvent( new KnightEvent( KnightEvent.KNIGHT_START ) );
					view.cameraTarget = _hero;
				}
				
				_knight.stopFighting(knightDead);
				_currentEnnemy.stopFighting( ennemyDead );
								
				_currentEnnemy = null;
				//_view.cameraTarget = _hero;
			}
			
		}
		
		private function manageFight() : void
		{
			if ( _currentEnnemy != null )
			{
				_knight.healthPoints -= _currentEnnemy.hitPoints;
				_currentEnnemy.healthPoints -= _knight.hitPoints;
				
				_healthbar.life.width = _knight.healthPoints / 4;
				
				if ( _currentEnnemy.isBoss )
				_bosshealthbar.life.width = _currentEnnemy.healthPoints / 4;
				
				if ( _currentEnnemy.healthPoints <= 0 )
					stopFight( true, false );
				
				if ( _knight.healthPoints <= 0 )
					stopFight( false, true );
				
			}
		}
		
		public function heal() : void
		{
			if ( _knight != null && _healthbar != null )
			{				
				_knight.healthPoints += _hero.healingPower;
				if ( _knight.healthPoints > _knight.maxHealthPoints )
					_knight.healthPoints = _knight.maxHealthPoints;
					
				_healthbar.life.width = _knight.healthPoints / 4;	
			}
		}
		
		/*override public function startBossFight( spot:BossSpot ) : void
		{
			_knight.start();
			view.cameraTarget = getObjectByName( spot.cameraName );
			startFight( getObjectByName( spot.bossName ) as Ennemy );
			addChild( _bosshealthbar );
			remove( spot );
		}*/
					
		/*public function hideDialog() : void
		{
			view.cameraTarget = _hero;		
		}*/
		
		private function handleLoadComplete() : void
		{
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function knighStartRequest( e:KnightEvent ) : void
		{
			e.stopPropagation();
			_knight.start();
		}
		
		private function knightRemoved( e:KnightEvent ) : void
		{			
			if ( _knight == null )
			_knight == getFirstObjectByType( Knight ) as Knight;
			
			e.stopPropagation();
			remove( _knight );
			
			if ( _healthbar != null && getChildByName( _healthbar.name ) != null )
			removeChild( _healthbar );
			
		}
		
		private function keyDownHandler( e:KeyboardEvent ) : void
		{
								
			if ( e.keyCode == Keyboard.P || e.keyCode == Keyboard.ESCAPE )
			{
				if ( paused )
				{
					paused = false;
					pauseScreen.hide();
					pauseScreen.removeEventListener( Event.COMPLETE, pauseContinue );
					removeChild( pauseScreen );
					CitrusEngine.getInstance().playing = true;
				}
				else if ( _hero.controlsEnabled && CitrusEngine.getInstance().playing )
				{
					
					if ( pauseScreen == null )
					pauseScreen = new PauseMenu( XmlGameData.getInstance().lang, _textData );
					pauseScreen.addEventListener( Event.COMPLETE, pauseContinue );
					pauseScreen.show();
					addChild( pauseScreen );
					
					paused = true;
					CitrusEngine.getInstance().playing = false;
				}
			}
			else if ( e.keyCode == Keyboard.DOWN )
			{
				_knight.comeBack();
			}
			
		}
		
		private function pauseContinue( e:Event ) : void
		{
			paused = false;
			pauseScreen.hide();
			pauseScreen.removeEventListener( Event.COMPLETE, pauseContinue );
			removeChild( pauseScreen );
			CitrusEngine.getInstance().playing = true;
			stage.focus = this;
		}
		
		/*override public function activateCheckpoint( checkpoint:Checkpoint ) : void
		{
			this.checkpoint = checkpoint;
		}*/
		
		public function setPrincessStartPosition( x:uint, y:uint ) : void 
		{ 
			_hero.x = x;
			_hero.y = y;
			
			if ( _knight != null )
			{
				_knight.x = _hero.x + 20;
				_knight.y = _hero.y;
			}
			
		}
		
		public function getKnightHealth() : uint
		{
			return _knight.healthPoints;
		}
		
		public function setKnightHealth( value:uint ) : void
		{
			if ( _knight != null )
			{
				_knight.healthPoints = value;
				_healthbar.life.width = _knight.healthPoints / 4;
			}
		}
		
		override public function destroy() : void
		{			
			stage.removeEventListener( KnightEvent.KNIGHT_START, knighStartRequest );
			stage.removeEventListener( KnightEvent.KNIGHT_REMOVED, knightRemoved );
			CitrusEngine.getInstance().stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			
			super.destroy();
		}
		
	}

}