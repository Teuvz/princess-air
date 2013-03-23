package 
{
	
	CONFIG::desktop
	import air.update.ApplicationUpdaterUI;
	
	import com.greensock.TweenLite;
	import flash.events.ContextMenuEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import flash.ui.ContextMenu;
	import objects.events.StateEvent;
	import objects.platformer.Switch;
	import singletons.ConstantState;
	import net.hires.debug.Stats;
	import objects.platformer.Ennemy;
	import objects.platformer.Gate;
	import objects.platformer.Ennemy;
	import objects.platformer.PrincessPhysics;
	import objects.platformer.PrincessPlatform;
	import objects.platformer.PrincessSprite;
	import singletons.XmlGameData;
	
	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.core.SoundManager;
	import com.citrusengine.objects.CitrusSprite;
	import com.citrusengine.objects.PhysicsObject;
	import com.citrusengine.objects.platformer.Baddy;
	import com.citrusengine.objects.platformer.Coin;
	import com.citrusengine.objects.platformer.Crate;
	import com.citrusengine.objects.platformer.Hero;
	import com.citrusengine.objects.platformer.Missile;
	import com.citrusengine.objects.platformer.MovingPlatform;
	import com.citrusengine.objects.platformer.Platform;
	import com.citrusengine.objects.platformer.RewardBox;
	import com.citrusengine.objects.platformer.Sensor;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import objects.events.EndGameEvent;
	import objects.events.MenuEvent;
	import objects.events.TeleportEvent;
	import objects.menus.Dialog;
	import objects.menus.StartMenu;
	import objects.platformer.AnimationSpot;
	import objects.platformer.Destructible;
	import objects.platformer.Exploding;
	import objects.platformer.Runner;

	import singletons.Levels;
	
	import objects.platformer.Knight;
	import objects.platformer.Ennemy;
	import objects.platformer.StopSpot;
	import objects.platformer.BossSpot;
	import objects.platformer.CameraSpot;
	import objects.platformer.StartSpot;
	import objects.platformer.DirectionSpot;
	import objects.platformer.Princess;
	import objects.platformer.Lift;
	import objects.platformer.TextSpot;
	import objects.platformer.DestroySpot;
	import objects.platformer.TeleportSpot;
	
	public class Main extends CitrusEngine 
	{
			
		[Embed(source="../lib/xml/text.xml", mimeType="application/octet-stream")]
		private var textRaw:Class;
		
		private var mainMenu:StartMenu;
		private var mainMenuBackground:MainMenuBack;
		private var inMenu:Boolean = true;
		private var endScreen:GameOverScreen;
		private var gameXml:XML;
		private var currentLevel:String = Levels.LEVEL_TUTORIAL;
		private var previousKnightHealth:uint;
		
		private var assetsLoaded:Boolean = false;
		private var objectsLoaded:Boolean = false;
		
		private var intro:filmIntro;
		private var version:TextField;
		private var versionFormat:TextFormat;
		
		public function Main():void 
		{			
			super();
			update();
			
			addEventListener( Event.ADDED_TO_STAGE, init );
			
			var byteArray:ByteArray = new textRaw() as ByteArray;
			XmlGameData.getInstance().texts = new XML(byteArray.readUTFBytes(byteArray.length));
				
			
		}
		
		CONFIG::desktop
		private function update() : void
		{
			var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI();
			appUpdater.configurationFile = new File("app:/updateConfig.xml"); 
			appUpdater.initialize();
		}
		
		CONFIG::mobile
		private function update() : void
		{
			
		}
				
		private function init( e:Event ) : void
		{			
			
			if ( CONFIG::mobile ) {
				stage.stageHeight = 480;
				stage.stageWidth = 762;
			}
			
			stage.focus = this;
			stage.stageFocusRect = false;
			
			if ( CONFIG::desktop ) {
				Mouse.hide();
				stage.scaleMode = StageScaleMode.EXACT_FIT;
				
				if ( CONFIG::release )
					stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
			
			removeEventListener( Event.ADDED_TO_STAGE, init );
			var classes:Array = [CitrusSprite, MovingPlatform, PhysicsObject, Platform, Knight, StopSpot, StartSpot, DirectionSpot, Ennemy, Princess, Lift, BossSpot, CameraSpot, TextSpot, DestroySpot, TeleportSpot, Exploding, AnimationSpot, Destructible, Runner, Gate, Ennemy, PrincessSprite, PrincessPlatform, PrincessPhysics, Switch ];
										
			// display main menu
			mainMenu = new StartMenu();
			mainMenu.name = "MainMenu";
			mainMenu.x = 60;
			mainMenuBackground = new MainMenuBack();
			mainMenuBackground.alpha = 0.3;
			//addChild( mainMenu );
			
			if ( e is EndGameEvent )
			{
				currentLevel = Levels.LEVEL_TUTORIAL
				inMenu = true;
				startGame();
			}
			else				
			{
				intro = new filmIntro();
				addChild( intro );
				
				this.addEventListener( MouseEvent.MOUSE_DOWN, skipIntro );
				this.addEventListener( KeyboardEvent.KEY_DOWN, skipIntro );
			}
						
			this.addEventListener( Event.COMPLETE, levelLoadComplete );
			stage.addEventListener( EndGameEvent.RELOAD, reload );
			stage.addEventListener( EndGameEvent.EXIT, init );
			
			this.version = new TextField();
			this.versionFormat = new TextFormat();
			versionFormat.color = 0xFFFFFF;
			version.selectable = false;
			version.width = 150;
			version.text = Version.Major+"."+Version.Minor+"."+Version.Build;
			
			if ( CONFIG::debug )
			{
				var stats:Stats = new Stats();
				addChild( stats );
				version.appendText(" DEBUG");
			}
			else
				version.appendText(" RELEASE");
				
			if ( CONFIG::mobile )
				version.appendText(" MOBILE");
			
			version.setTextFormat( versionFormat, 0, version.length );
			version.x = stage.stageWidth - version.textWidth - 5;
			version.y = stage.stageHeight - version.textHeight - 5;
			addChild( version );
			
		}
				
		private function skipIntro( e:Event ) : void
		{
			this.removeEventListener( MouseEvent.MOUSE_DOWN, skipIntro );
			this.removeEventListener( KeyboardEvent.KEY_DOWN, skipIntro );
			removeChild( intro );
			intro = null;
			startGame();
		}
							
		private function startGame( e:Event=null ) : void
		{					
			
			playing = false;
						
			if ( e != null )
			mainMenu.removeEventListener( Event.COMPLETE, startGame );
			
			stage.addEventListener( EndGameEvent.KNIGHT_DEAD, endGame );
			stage.addEventListener( EndGameEvent.PRINCESS_DEAD, endGame );
			stage.addEventListener( EndGameEvent.WIN, endGame );
			stage.addEventListener( TeleportEvent.CHANGE, changeLevel );
			
			showLoading();
									
			assetsLoaded = false;
			objectsLoaded = false;
			
				state = new GameState(null, null, currentLevel, null, inMenu );
			ConstantState.getInstance().runningCinematic = false;
			XmlGameData.getInstance().lang = mainMenu.lang;
			SoundManager.getInstance().setGlobalVolume( mainMenu.volume);
			stage.focus = state; 
			state.addEventListener( Event.COMPLETE, loadComplete );
			
		}	
		
		private function startNewGame( e:Event ) : void
		{
		
			if ( e != null )
			mainMenu.removeEventListener( Event.COMPLETE, startGame );
			
			mainMenu.killKeyboard();
			
			inMenu = false;
			
			if ( CONFIG::release )
				Mouse.hide();
			
			if ( getChildByName( mainMenu.name) != null )
			removeChild( mainMenu );
			if ( getChildByName( mainMenuBackground.name) != null )
			removeChild( mainMenuBackground );
			this.stage.focus = state;
			playing = true;
			state.dispatchEvent( new StateEvent( StateEvent.START ) );
			//(state as GameState).start();
		}
		
		private function continueGame( e:Event=null ) : void
		{
			
			//trace( "continue game" );
			
			mainMenu.killKeyboard();
			
			inMenu = false;
			//var mySO:SharedObject = SharedObject.getLocal("save");	
			//currentLevel = mySO.data.currentLevel;
			currentLevel = mainMenu.chapterToLoad;
			startGame();
		}
		
		private function endGame( e:EndGameEvent ) : void
		{
			
			//Mouse.show();
			
			playing = false;
			stage.removeEventListener( e.type, endGame );
			
			endScreen = new GameOverScreen();
			
			if ( e.type == EndGameEvent.KNIGHT_DEAD )
				endScreen.gotoAndStop( EndGameEvent.KNIGHT_DEAD );
			else if ( e.type == EndGameEvent.PRINCESS_DEAD )
				endScreen.gotoAndStop( EndGameEvent.PRINCESS_DEAD );
			else if ( e.type == EndGameEvent.WIN )
				endScreen.gotoAndStop( EndGameEvent.WIN );
			
			if ( e.type != EndGameEvent.WIN )
			{
				endScreen.tryAgainBtn.buttonMode = true;
				endScreen.addEventListener( MouseEvent.MOUSE_UP, reload );
								
				if ( e.type == EndGameEvent.KNIGHT_DEAD )
				endScreen.gameover_knight.text = XmlGameData.getInstance().texts.texts.gameover_knight.child(mainMenu.lang);
				if ( e.type == EndGameEvent.PRINCESS_DEAD )
				endScreen.gameover_princess.text = XmlGameData.getInstance().texts.texts.gameover_princess.child(mainMenu.lang);
				
				endScreen.gameover_gameover.text = XmlGameData.getInstance().texts.texts.gameover_gameover.child(mainMenu.lang);
				endScreen.tryAgainBtn.tryAgainBtn.text = XmlGameData.getInstance().texts.texts.tryAgainBtn.child(mainMenu.lang);
			}
			else
			{				
				endScreen.gameover_finished.text = XmlGameData.getInstance().texts.texts.gameover_finished.child(mainMenu.lang);
				endScreen.gameover_visit.text = XmlGameData.getInstance().texts.texts.gameover_visit.child(mainMenu.lang);
			}
			
			addChild( endScreen );
		}
		
		private function reload( e:Event ) : void
		{
			playing = false;
			
			if ( endScreen != null && endScreen.hasEventListener( MouseEvent.MOUSE_UP ) )
				endScreen.removeEventListener( MouseEvent.MOUSE_UP, reload );
			
			showLoading();
			
			assetsLoaded = false;
			objectsLoaded = false;
			
			//lastCheckpoint = state.checkpoint;
			
			if ( endScreen != null && getChildByName( endScreen.name ) != null )
				removeChild( endScreen );
				
			state = new GameState(gameXml, null, currentLevel, null);
			ConstantState.getInstance().runningCinematic = false;
			// BUG the playIntro should use event/signal
			//state.playIntro = false;
			
			state.addEventListener( Event.COMPLETE, loadComplete );
			
			stage.focus = this;
						
		}
		
		// BUG knight health should be managed otherwise
		private function changeLevel( e:TeleportEvent ) : void
		{
					
			//previousKnightHealth = state.getKnightHealth();
			
			playing = false;
			
			showLoading();
			
			assetsLoaded = false;
			objectsLoaded = false;
			
			//trace( "got event to load " + e.lvl );
			currentLevel = e.lvl;
						
			gameXml = Levels.getLevelXml( currentLevel );
									
			state = null;			
			state = new GameState(gameXml, null, currentLevel, null);
			ConstantState.getInstance().runningCinematic = false;
			
			state.addEventListener( Event.COMPLETE, loadComplete );
			
			stage.focus = this;

		}
				
		public function loadComplete( e:Event=null ) : void
		{						
			state.removeEventListener( Event.COMPLETE, loadComplete );
			
			assetsLoaded = true;
			
			if ( objectsLoaded )
			{
				playing = true;
				//removeChild( mainMenu );
				
				setTimeout( startPlaying, 300 );
				
				stage.addEventListener( EndGameEvent.KNIGHT_DEAD, endGame );
				stage.addEventListener( EndGameEvent.PRINCESS_DEAD, endGame );
				stage.addEventListener( EndGameEvent.WIN, endGame );
				stage.addEventListener( TeleportEvent.CHANGE, changeLevel );
			}
		}
		
		public function levelLoadComplete( e:Event = null ) : void
		{
			
			objectsLoaded = true;
			
			if ( assetsLoaded )
			{
				playing = true;
				//removeChild( mainMenu );
								
				setTimeout( startPlaying, 300 );
				
				stage.addEventListener( EndGameEvent.KNIGHT_DEAD, endGame );
				stage.addEventListener( EndGameEvent.PRINCESS_DEAD, endGame );
				stage.addEventListener( EndGameEvent.WIN, endGame );
				stage.addEventListener( TeleportEvent.CHANGE, changeLevel );
				
			}
		}
		
		// BUG the setKnightHealth should be managed otherwise
		private function startPlaying() : void
		{			
			
			if ( inMenu )
			{	
				mainMenu.gotoAndPlay( "main" );
				mainMenu.addEventListener( MenuEvent.START, startNewGame );
				mainMenu.addEventListener( MenuEvent.CONTINUE, continueGame );
				mainMenu.activate();
				
				ConstantState.getInstance().runningCinematic = true;
				( state.getFirstObjectByType( Princess ) as Princess ).animation = "sleeping";
			}
			else
			{
				if ( CONFIG::release )
					Mouse.hide();
					
				var mySO:SharedObject = SharedObject.getLocal("save");	
				mySO.data.currentLevel = currentLevel;
								
				removeChild( mainMenu );
				removeChild( mainMenuBackground );
				playing = true;
			}
		}
		
		private function loging( str:String ) : void
		{
			if ( ExternalInterface.available )
				ExternalInterface.call( "console.log", str );
			else
				trace( str );
		}
		
		private function showLoading() : void
		{
			mainMenu.alpha = 1;
			mainMenu.gotoAndStop( 'loading' );
			mainMenu.loadingLbl.text = XmlGameData.getInstance().texts.texts.menu_loading.child(mainMenu.lang);
			
			var j:uint = Math.floor( Math.random() * StartMenu.loadingImages.length);
			
			//trace( "loader: " + j );
			
			for ( var i:uint = 0; i < StartMenu.loadingImages.length; i++ )
			{
				if ( i != j )
					mainMenu.getChildByName( StartMenu.loadingImages[i] ).visible = false;
				else
					mainMenu.getChildByName( StartMenu.loadingImages[i] ).visible = true;
			}
			
			if ( getChildByName( mainMenu.name ) == null )
			{
				addChild( mainMenuBackground );
				addChild( mainMenu );
			}
							
		}
				
	}
	
}