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
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import objects.events.CinematicEvent;
	import objects.events.DialogEvent;
	import objects.events.EndGameEvent;
	import objects.events.FightEvent;
	import objects.events.KnightEvent;
	import objects.events.StateEvent;
	import objects.events.SwitchEvent;
	import objects.events.TeleportEvent;
	import objects.menus.MobileMenu;
	import objects.menus.PauseMenu;
	import objects.platformer.BossSpot;
	import objects.platformer.CameraSpot;
	import objects.platformer.Ennemy;
	import objects.platformer.Gate;
	import objects.platformer.Knight;
	import objects.platformer.Lift;
	import objects.platformer.Princess;
	import objects.platformer.PrincessPhysics;
	import objects.platformer.PrincessSprite;
	import objects.platformer.Runner;
	import objects.platformer.Ennemy;
	import objects.platformer.Switch;
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
		private var _scenesData:XML;
		private var _hero:Princess;
		private var _knight:Knight;
		private var _healthbar:Healthbar;
		private var _bosshealthbar:Healthbar;
		private var _levelName:String;
		private var _inMenu:Boolean;
		
		private var _currentEnnemy:Ennemy;
		private var _fightRound:uint = 0;
		
		private var _switch:String = null;
		
		//private var _lang:String;
		private var cinematic:XML;
		public var playIntro:Boolean = false;
		private var cinematicActionStep:uint = 0;
		
		private var cinematicLineTop:BlackBand;
		private var cinematicLineBottom:BlackBand;
		
		public function GameState(levelData:XML, textData:XML, name:String, scenesData:XMLList = null, inMenu:Boolean = false)
		{
			_textData = textData;
			_levelName = name;
			_inMenu = inMenu;
		}
		
		override public function initialize():void
		{
			super.initialize();
						
			//Create Box2D
			var box2D:Box2D = new Box2D("Box2D");
			add(box2D);
			
			//Create the level objects from the XML file.
			ObjectMaker.FromLevelArchitect(readLvl());
						
			_hero = getFirstObjectByType(Princess) as Princess;
			/*if (_hero)
			{
				_hero.controlsEnabled = false;
				view.cameraTarget = _hero;
				view.cameraOffset = new MathVector(stage.stageWidth / 4, (stage.stageHeight / 3) * 2);
				view.cameraEasing = new MathVector(1, 1);
			}*/
			
			_knight = getFirstObjectByType(Knight) as Knight;
						
			addEventListener(StateEvent.START, start);
			
			loadCinematicXml();
		
		}
		
		private function loadCinematicXml():void
		{			
			var myfile:File = new File( "app:/xml/"+_levelName+".xml" );
			var fileStream:FileStream = new FileStream();
			fileStream.open(myfile, FileMode.READ);
			_scenesData = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close();
			handleLoadComplete();
		}
		
		private function readLvl() : XML
		{
			var myfile:File = new File( "app:/levels/"+_levelName+".lev" );
			var fileStream:FileStream = new FileStream();
			fileStream.open(myfile, FileMode.READ);
			var prefsXML:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close();
			return prefsXML;
		}
		
		private function handleLoadComplete():void
		{
			dispatchEvent(new Event(Event.COMPLETE));
			
			if (!_inMenu)
			{
				start();
			}
			else
			{
				ConstantState.getInstance().runningCinematic = true;
			}
		}
		
		public function start(e:StateEvent = null):void
		{
			removeEventListener(StateEvent.START, start);
			
			//Find the hero object, and make it the camera target if it exists.		
			if (_hero)
			{
				_hero.controlsEnabled = true;
				view.cameraTarget = _hero;
				view.cameraOffset = new MathVector(stage.stageWidth / 2, (stage.stageHeight / 3) * 2);
				view.cameraEasing = new MathVector(0.4, 0.4);
			}
						
			if (_knight != null && _levelName != Levels.LEVEL_TUTORIAL)
			{
				_healthbar = new Healthbar();
				_healthbar.name = "HealthBar";
				_healthbar.x = 5;
				_healthbar.y = 5;
				addChild(_healthbar);
			}
			
			// dialog	
			Dialog.getInstance().setXml(XmlGameData.getInstance().lang, _textData);
			_textData = null;
			
			_bosshealthbar = new Healthbar();
			_bosshealthbar.x = (stage.stageWidth - _bosshealthbar.width) - 5;
			_bosshealthbar.y = 5;
			
			if (_scenesData.length() != 0 && _scenesData.child("startAnimation").length() != 0)
			{
				playCinematic(null, "startAnimation");
			}
			
			if (_knight != null)
				stage.addEventListener(KnightEvent.KNIGHT_REMOVED, removeKnight);
			
			stage.addEventListener(DialogEvent.DIALOG_SHOW, showDialog);
			stage.addEventListener(DialogEvent.DIALOG_HIDE, hideDialog);
			stage.addEventListener(FightEvent.START_FIGHT, startFight);
			stage.addEventListener(CinematicEvent.PLAY_CINEMATIC, playCinematic);
			stage.addEventListener(KnightEvent.KNIGHT_START, knightStart);
			stage.addEventListener(KnightEvent.KNIGHT_STOP, knightStop);
			stage.addEventListener(SwitchEvent.SWITCH_OVER, switchOver);
			stage.addEventListener(SwitchEvent.SWITCH_OUT, switchOut);
		
			//CitrusEngine.getInstance().stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			
			if ( CONFIG::mobile )
				addChild( MobileMenu.getInstance() );
		
		}
		
		private function showBlackBands():void
		{
			if (cinematicLineTop == null)
			{
				cinematicLineTop = new BlackBand();
				cinematicLineTop.x = 0;
				cinematicLineTop.y = cinematicLineTop.height * -1;
				this.addChild(cinematicLineTop);
			}
			
			if ( CONFIG::desktop )
				TweenLite.to(cinematicLineTop, 0.5, { y: 0 } );
			else
				TweenLite.to(cinematicLineTop, 0.5, { y: -50 } );
			
			if (cinematicLineBottom == null)
			{
				cinematicLineBottom = new BlackBand();
				cinematicLineBottom.x = 0;
				cinematicLineBottom.y = CitrusEngine.getInstance().stage.stageHeight;
				this.addChild(cinematicLineBottom);
			}
			
			if ( CONFIG::desktop )
				TweenLite.to(cinematicLineBottom, 0.5, { y: 472 } );
			else
				TweenLite.to(cinematicLineBottom, 0.5, { y: 422 } );
		}
		
		private function hideBlackBands():void
		{
			TweenLite.to(cinematicLineTop, 0.5, {y: -127});
			TweenLite.to(cinematicLineBottom, 0.5, {y: CitrusEngine.getInstance().stage.stageHeight});
		}
		
		public function playCinematic(event:CinematicEvent = null, name:String = null):void
		{
			if ( CONFIG::mobile )
				MobileMenu.getInstance().hide();
			
			if (event != null)
				name = event.name;
			
			showBlackBands();
			cinematicActionStep = 0;
			ConstantState.getInstance().runningCinematic = true;
			var _ce:CitrusEngine = CitrusEngine.getInstance();
			//_ce.playing = false;
			
			_hero.controlsEnabled = false;
			_knight.stop();
			
			cinematic = XML(_scenesData.child(name).toXMLString());
			
			cinematicAction();
		}
		
		private function cinematicAction():void
		{
			
			if (cinematic.action[cinematicActionStep] == undefined)
			{
				var _ce:CitrusEngine = CitrusEngine.getInstance();
				_ce.playing = true;
				ConstantState.getInstance().runningCinematic = false;
				hideBlackBands();
					
				if ( CONFIG::mobile )
					MobileMenu.getInstance().show();
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'animation')
			{
				
				var _char:PhysicsObject = getObjectByName(cinematic.action[cinematicActionStep].character) as PhysicsObject;
				
				_char.animation = cinematic.action[cinematicActionStep].animation;
				
				if (!cinematic.action[cinematicActionStep].hasOwnProperty("stopanimation"))
				{
					setTimeout(cinematicAction, 200);
					cinematicActionStep++;
				}
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'temp')
			{
				setTimeout(cinematicAction, cinematic.action[cinematicActionStep].time);
				cinematicActionStep++;
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'run')
			{
				var _runner:Runner = getObjectByName(cinematic.action[cinematicActionStep].character) as Runner;
				_runner.running = true;
				setTimeout(cinematicAction, 200);
				cinematicActionStep++;
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'move')
			{
				setTimeout(cinematicAction, cinematic.action[cinematicActionStep].time);
								
				if (cinematic.action[cinematicActionStep].effect == 'bounce')
				{
					TweenLite.to((getObjectByName(cinematic.action[cinematicActionStep].character) as PhysicsObject), cinematic.action[cinematicActionStep].time / 1000, {y: cinematic.action[cinematicActionStep].y, ease: Bounce.easeOut});
				}
				else if ((getObjectByName(cinematic.action[cinematicActionStep].character) as PhysicsObject) != null)
				{
					if (cinematic.action[cinematicActionStep].x != undefined && cinematic.action[cinematicActionStep].y != undefined)
						TweenLite.to((getObjectByName(cinematic.action[cinematicActionStep].character) as PhysicsObject), cinematic.action[cinematicActionStep].time / 1000, {x: cinematic.action[cinematicActionStep].x, y: cinematic.action[cinematicActionStep].y, ease: Linear.easeNone});
					else if (cinematic.action[cinematicActionStep].x != undefined)
						TweenLite.to((getObjectByName(cinematic.action[cinematicActionStep].character) as PhysicsObject), cinematic.action[cinematicActionStep].time / 1000, {x: cinematic.action[cinematicActionStep].x, ease: Linear.easeNone});
					else if (cinematic.action[cinematicActionStep].y != undefined)
						TweenLite.to((getObjectByName(cinematic.action[cinematicActionStep].character) as PhysicsObject), cinematic.action[cinematicActionStep].time / 1000, {y: cinematic.action[cinematicActionStep].y, ease: Linear.easeNone});
				}
				
				cinematicActionStep++;
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'unblock')
			{
				_hero.controlsEnabled = true;
				setTimeout(cinematicAction, 200);
				cinematicActionStep++;
				
				if (_knight)
					_knight.start();
				
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'dialog')
			{
				Dialog.getInstance().show(cinematic.action[cinematicActionStep].text, 'knight', 2000, false, null, true);
				
				setTimeout(cinematicAction, 2000);
				cinematicActionStep++;
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'start_sound')
			{
				if (!SoundManager.getInstance().hasSound(cinematic.action[cinematicActionStep].file))
					SoundManager.getInstance().addSound(cinematic.action[cinematicActionStep].file, cinematic.action[cinematicActionStep].file);
				
				SoundManager.getInstance().playSound(cinematic.action[cinematicActionStep].file);
				
				setTimeout(cinematicAction, 200);
				cinematicActionStep++;
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'stop_sound')
			{
				if (SoundManager.getInstance().hasSound(cinematic.action[cinematicActionStep].file))
					SoundManager.getInstance().stopSound(cinematic.action[cinematicActionStep].file);
				;
				
				setTimeout(cinematicAction, 200);
				cinematicActionStep++;
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'add_object')
			{
				if (cinematic.action[cinematicActionStep].type == "Knight")
				{
					
					var params:Object = new Object();
					params.speed = cinematic.action[cinematicActionStep].speed;
					params.startingDirection = "right";
					params.gravity = 1.6;
					params.parallax = 1;
					params.registration = "center";
					params.view = "art/knight.swf";
					params.x = cinematic.action[cinematicActionStep].x;
					params.y = cinematic.action[cinematicActionStep].y;
					params.width = 87;
					params.height = 78;
					
					_knight = new Knight("Knight", params);
					_knight.stop();
					add(_knight);
				}
				
				setTimeout(cinematicAction, 200);
				cinematicActionStep++;
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'remove_object')
			{
				remove(getObjectByName(cinematic.action[cinematicActionStep].object));
				setTimeout(cinematicAction, 200);
				cinematicActionStep++;
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'camera_target')
			{
				view.cameraTarget = getObjectByName(cinematic.action[cinematicActionStep].object);
				setTimeout(cinematicAction, 200);
				cinematicActionStep++;
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'turnaround')
			{
				var temp:PhysicsObject = getObjectByName(cinematic.action[cinematicActionStep].character) as PhysicsObject;
				temp._inverted = !temp._inverted;
				setTimeout(cinematicAction, 200);
				cinematicActionStep++;
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'stuck')
			{
				//_hero.setStuck(true);
				setTimeout(cinematicAction, 200);
				cinematicActionStep++;
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'lift_start')
			{
				(getObjectByName(cinematic.action[cinematicActionStep].object) as Lift).enabled = true;
			}
			else if (cinematic.action[cinematicActionStep].attribute("type") == 'teleport')
			{
				stage.dispatchEvent(new TeleportEvent(TeleportEvent.CHANGE, cinematic.action[cinematicActionStep].level));
			}
		
		}
		
		/*public function heal() : void
		   {
		   if ( _knight != null && _healthbar != null )
		   {
		   _knight.healthPoints += _hero.healingPower;
		   if ( _knight.healthPoints > _knight.maxHealthPoints )
		   _knight.healthPoints = _knight.maxHealthPoints;
		
		   _healthbar.life.width = _knight.healthPoints / 4;
		   }
		 }*/
		
		/*override public function startBossFight( spot:BossSpot ) : void
		   {
		   _knight.start();
		   view.cameraTarget = getObjectByName( spot.cameraName );
		   startFight( getObjectByName( spot.bossName ) as Ennemy );
		   addChild( _bosshealthbar );
		   remove( spot );
		 }*/
		
		/*private function keyDownHandler( e:KeyboardEvent ) : void
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
		
		 }*/
		
		/*private function pauseContinue( e:Event ) : void
		   {
		   paused = false;
		   pauseScreen.hide();
		   pauseScreen.removeEventListener( Event.COMPLETE, pauseContinue );
		   removeChild( pauseScreen );
		   CitrusEngine.getInstance().playing = true;
		   stage.focus = this;
		 }*/
		
		/*public function getKnightHealth() : uint
		   {
		   return _knight.healthPoints;
		 }*/
		
		/*public function setKnightHealth( value:uint ) : void
		   {
		   if ( _knight != null )
		   {
		   _knight.healthPoints = value;
		   _healthbar.life.width = _knight.healthPoints / 4;
		   }
		 }*/
		
		/*override public function destroy() : void
		   {
		   stage.removeEventListener( KnightEvent.KNIGHT_START, knighStartRequest );
		   stage.removeEventListener( KnightEvent.KNIGHT_REMOVED, knightRemoved );
		   CitrusEngine.getInstance().stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
		
		   super.destroy();
		 }*/
		
		override public function update(timeDelta:Number):void
		{
			
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
			handleInputs();
			
			//Update the state's view
			_view.update();
		
		}
		
		protected function handleInputs():void
		{
			
			var _ce:CitrusEngine = CitrusEngine.getInstance();
			var _mobile:MobileMenu = MobileMenu.getInstance();
			
			if (_ce.input.isDown(Keyboard.RIGHT) || _mobile.rightArrowDown)
			{
				_hero.moveRight();
			}
			
			if (_ce.input.isDown(Keyboard.LEFT) || _mobile.leftArrowDown)
			{
				_hero.moveLeft();
			}
			
			if (_ce.input.isDown(Keyboard.DOWN))
			{
				trace("down");
			}
			
			if (_ce.input.isDown(Keyboard.UP))
			{
				trace("up");
			}
			
			if (_ce.input.isDown(Keyboard.ESCAPE))
			{
				trace("escape");
				stage.displayState = StageDisplayState.NORMAL;
			}
			
			if (_ce.input.isDown(Keyboard.CONTROL) || _mobile.healButtonDown)
			{
				_hero.startHealing();
			}
			else if (_hero.healing)
			{
				_hero.stopHealing();
			}
			
			if (_ce.input.isDown(Keyboard.SPACE) || _mobile.switchButtonDown)
			{
				if (_switch != null)
					activateSwitch();
			}
		
		}
		
		private function removeKnight(e:KnightEvent = null):void
		{
			remove(_knight);
		}
		
		private function showDialog(e:DialogEvent):void
		{
			
			Dialog.getInstance().show(e.text, 'knight', e.timer, e.block);
			
			if (e.block)
			{
				_hero.controlsEnabled = false;
				_knight.stop(true);
				_hero.animation = 'idle';
				CitrusEngine.getInstance().playing = false;
				showBlackBands();
			}
			
			if ( CONFIG::mobile )
				MobileMenu.getInstance().hide();
		
		}
		
		private function hideDialog(e:DialogEvent):void
		{
			_hero.controlsEnabled = true;
			_knight.start();
			CitrusEngine.getInstance().playing = true;
			hideBlackBands();
			
			view.cameraTarget = _hero;
		
			if ( CONFIG::mobile )
				MobileMenu.getInstance().show();
		}
		
		private function startFight(e:FightEvent):void
		{
			ConstantState.getInstance().fightTing = true;
			
			var i:uint = _objects.length;
			trace(_objects);
			while ( i-- > 0 )
			{
				trace(_objects[i].name);
				
				if (_objects[i].name == e.ennemy)
				{
					trace("found ennemy! " + e.ennemy);
				}
			}
			
			_currentEnnemy = (getObjectByName(e.ennemy) as Ennemy);
			_knight.startFighting();
			_fightRound = 0;
			handleFight();
		}
		
		private function stopFight(won:Boolean = true):void
		{
			ConstantState.getInstance().fightTing = false;
			_knight.stopFighting(won);
			_currentEnnemy.stopFighting(won);
		}
		
		private function handleFight():void
		{
			if (++_fightRound % 2 == 0)
			{
				_knight.hurt();
				_knight.healthPoints -= _currentEnnemy.hitPoints;
				_healthbar.life.width = _knight.healthPoints / 4;
			}
			else
			{
				_currentEnnemy.healthPoints -= _knight.hitPoints;
			}
			
			if ( _currentEnnemy.healthPoints < 0)
			{
				stopFight();
			}
			else if (_knight.healthPoints < 0)
			{
				stopFight(false);
			}
			else
			{
				setTimeout(handleFight, _knight.hitFrequency);
			}
		}
		
		protected function knightStart(e:KnightEvent):void
		{
			_knight.start();
		}
		
		protected function knightStop(e:KnightEvent):void
		{
			_knight.stop();
		}
		
		protected function switchOver(e:SwitchEvent):void
		{
			_switch = e.name;
			
			if ( CONFIG::mobile )
				MobileMenu.getInstance().showSwitchButton();
		}
		
		protected function switchOut(e:SwitchEvent):void
		{
			_switch = null;
			
			if ( CONFIG::mobile )
				MobileMenu.getInstance().hideSwitchButton();
		}
		
		protected function activateSwitch():void
		{
			var switchO:Switch = (getObjectByName(_switch) as Switch);
			
			if (!switchO.pressed)
			{
				
				if (switchO.otherElementToremove != "")
				{
					if ( getObjectByName(switchO.otherElementToremove) != null )
						remove(getObjectByName(switchO.otherElementToremove));
				}
				
				if (switchO.animationToStart != "")
				{
					playCinematic(null, switchO.animationToStart);
				}
				
				if (switchO.gate != "")
				{
					(getObjectByName(switchO.gate) as Gate).toggle();
				}
				
				switchO.pressed = true;
				
			}
		
		}
	
	}

}