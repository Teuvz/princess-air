package objects.menus 
{
	import com.greensock.TweenLite;
	import fl.events.SliderEvent;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import flash.system.System;
	import flash.ui.Keyboard;
	import objects.events.MenuEvent;
	import singletons.Levels;
	import singletons.XmlGameData;
	/**
	 * ...
	 * @author Matt
	 */
	public class StartMenu extends MainMenu 
	{
	
		public var chapterToLoad:String;
		
		public var lang:String = 'fr';
		public var volume:Number = 4;
		private var page:String = 'main';
		public var startMode:String = 'new';
		
		public static var loadingImages:Array = new Array( "anim_knight_walk", "anim_knight_fight", "anim_princess_walk", "anim_princess_heal" );
		
		private const CURSOR_MAIN_NEW:Point = new Point(400, 200);
		private const CURSOR_MAIN_CONTINUE:Point = new Point(400, 238);
		private const CURSOR_MAIN_OPTION:Point = new Point(400, 279);
		private const CURSOR_MAIN_CREDITS:Point = new Point(400, 320);
		/***/
		private const CURSOR_CHAPTER_TUTORIAL:Point = new Point(75, 280);
		private const CURSOR_CHAPTER_CORRIDOR:Point = new Point(340, 280);
		private const CURSOR_CHAPTER_THRONE:Point = new Point(600, 280);
		private const CURSOR_CHAPTER_LIFT:Point = new Point(75, 475);
		private const CURSOR_CHAPTER_WALL:Point = new Point(340, 475);
		private const CURSOR_CHAPTER_YARD:Point = new Point(600, 475);
		private const CURSOR_CHAPTER_RETURN:Point = new Point( 300, 524 );
		/***/
		private const CURSOR_OPTIONS_FRENCH:Point = new Point(412, 192);
		private const CURSOR_OPTIONS_ENGLISH:Point = new Point(542, 192);
		private const CURSOR_OPTIONS_VOLUME:Point = new Point(466, 264);
		private const CURSOR_OPTIONS_RETURN:Point = new Point(477, 368);
		/***/
		private const CURSOR_CREDITS_RETURN:Point = new Point( 510, 510 );
		
		private var cursor:Sprite;
		private var selectedChapter:String;
		
		private const PAGE_MAIN:String = "main";
		private const PAGE_OPTIONS:String = "options";
		private const PAGE_CREDITS:String = "credits";
		private const PAGE_CHAPTERS:String = "chapters";
		
		public function StartMenu() 
		{
			super();
			
			activate();
			
			this.addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
		}
		
		private function onAddedToStage( e:Event ) : void
		{
			this.removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
			
			cursor = new Sprite();
			cursor.graphics.beginFill( 0x000000 );
			cursor.graphics.drawCircle( 0, 0, 10 );
			cursor.graphics.endFill();
			cursor.x = CURSOR_MAIN_NEW.x;
			cursor.y = CURSOR_MAIN_NEW.y;
			addChild( cursor );
			
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}
		
		public function activate() : void
		{
			changeTexts();
			
			this.startBtn.buttonMode = true;
			this.optionsBtn.buttonMode = true;
			this.creditsBtn.buttonMode = true;
			
			//this.startBtn.addEventListener( MouseEvent.MOUSE_UP, startBtnHandle );
			//this.optionsBtn.addEventListener( MouseEvent.MOUSE_UP, optionsBtnHandle );
			//this.creditsBtn.addEventListener( MouseEvent.MOUSE_UP, creditsBtnHandle );
			
			var mySO:SharedObject = SharedObject.getLocal("save");						
			if ( mySO.data.currentLevel != undefined )
				activateContinueButton();
				
			TweenLite.to( this, 1, { alpha: 1 } );
		}
				
		private function activateContinueButton() : void
		{
			continueBtn.continueBtn.textColor = 0xFFFFFF;
			this.continueBtn.addEventListener( MouseEvent.MOUSE_UP, continueBtnHandle );
		}
		
		private function exitBtnHandle( e:MouseEvent ) : void
		{
			System.exit( 0 );
		}
		
		private function optionsBtnHandle( e:MouseEvent=null ) : void
		{
			alpha = 0;
			
			page = PAGE_OPTIONS;
			this.gotoAndStop( page );
			changeTexts();
			this.returnBtn.buttonMode = true;
			frenchLbl.buttonMode = true;
			englishLbl.buttonMode = true;
			volumeBtn.value = this.volume;
			
			if ( stage.displayState == StageDisplayState.FULL_SCREEN )
			fullscreenCb.selected = true;
			
			fullscreenCb.visible = false;
			
			this.returnBtn.addEventListener( MouseEvent.MOUSE_UP, returnBtnHandle );
			this.frenchLbl.addEventListener( MouseEvent.MOUSE_UP, frenchHandle );
			this.englishLbl.addEventListener( MouseEvent.MOUSE_UP, englishHandle );
			this.volumeBtn.addEventListener( SliderEvent.CHANGE, volumeHandle );
			this.fullscreenCb.addEventListener( Event.CHANGE, fullscreenCbHandle );
			
			TweenLite.to( this, 1, { alpha: 1 } );
			
			cursor.x = CURSOR_OPTIONS_FRENCH.x;
			cursor.y = CURSOR_OPTIONS_FRENCH.y;
		}
		
		private function fullscreenCbHandle( e:Event ) : void
		{
			if ( fullscreenCb.selected )
				stage.displayState = StageDisplayState.FULL_SCREEN;
			else
				stage.displayState = StageDisplayState.NORMAL;
		}
		
		private function creditsBtnHandle( e:MouseEvent=null ) : void
		{
			alpha = 0;
			page = PAGE_CREDITS;
			this.gotoAndStop( page );
			changeTexts();
			this.returnBtn.buttonMode = true;
			this.returnBtn.addEventListener( MouseEvent.MOUSE_UP, returnBtnHandle );
			
			cursor.x = CURSOR_CREDITS_RETURN.x;
			cursor.y = CURSOR_CREDITS_RETURN.y;
			
			TweenLite.to( this, 1, { alpha: 1 } );
		}
		
		private function returnBtnHandle( e:MouseEvent=null ) : void
		{			
			alpha = 0;
			
			switch( page )
			{				
				case PAGE_CHAPTERS:
					cursor.x = CURSOR_MAIN_CONTINUE.x;
					cursor.y = CURSOR_MAIN_CONTINUE.y;
					break;
				case PAGE_OPTIONS:
					cursor.x = CURSOR_MAIN_OPTION.x;
					cursor.y = CURSOR_MAIN_OPTION.y;
					break;
				case PAGE_CREDITS:
					cursor.x = CURSOR_MAIN_CREDITS.x;
					cursor.y = CURSOR_MAIN_CREDITS.y;
					break;
			}
			
			page = PAGE_MAIN;
			this.returnBtn.removeEventListener( MouseEvent.MOUSE_UP, returnBtnHandle );			
			this.gotoAndStop( page );
			changeTexts();
			//this.startBtn.addEventListener( MouseEvent.MOUSE_UP, startBtnHandle );
			//this.optionsBtn.addEventListener( MouseEvent.MOUSE_UP, optionsBtnHandle );
			//this.creditsBtn.addEventListener( MouseEvent.MOUSE_UP, creditsBtnHandle );
			//this.exitBtn.addEventListener( MouseEvent.MOUSE_UP, exitBtnHandle );
			
			var mySO:SharedObject = SharedObject.getLocal("save");						
			if ( mySO.data.currentLevel != undefined )
				activateContinueButton();
			
			TweenLite.to( this, 1, { alpha: 1 } );
			
		}
		
		private function startBtnHandle( e:MouseEvent=null ) : void
		{
			TweenLite.to( this, 1, { alpha: 0 } );
			dispatchEvent( new MenuEvent( MenuEvent.START ) );
			
			//stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		}
		
		private function continueBtnHandle( e:MouseEvent=null ) : void
		{
			alpha = 0;
			var mySO:SharedObject = SharedObject.getLocal("save");	
			mySO.data.currentLevel;
									
			page = PAGE_CHAPTERS;
			this.gotoAndStop( page );
			changeTexts();
			this.returnBtn.buttonMode = true;
			this.returnBtn.addEventListener( MouseEvent.MOUSE_UP, returnBtnHandle );
			
			chapterCorridorBtn.gotoAndStop( "disabled" );
			chapterThroneBtn.gotoAndStop( "disabled" );
			chapterLiftBtn.gotoAndStop( "disabled" );
			chapterWallBtn.gotoAndStop( "disabled" );
			chapterYardBtn.gotoAndStop( "disabled" );
			
			switch( mySO.data.currentLevel )
			{
				case Levels.LEVEL_YARD:
					this.chapterYardBtn.buttonMode = true;
					chapterYardBtn.gotoAndStop( "grey" );
					chapterYardBtn.addEventListener( MouseEvent.MOUSE_OVER, chapterButtonOverHandle );
					chapterYardBtn.addEventListener( MouseEvent.MOUSE_OUT, chapterButtonOutHandle );
					chapterYardBtn.addEventListener( MouseEvent.MOUSE_UP, chapterButtonClickHandle );
				case Levels.LEVEL_WALL:
					this.chapterWallBtn.buttonMode = true;
					chapterWallBtn.gotoAndStop( "grey" );
					chapterWallBtn.addEventListener( MouseEvent.MOUSE_OVER, chapterButtonOverHandle );
					chapterWallBtn.addEventListener( MouseEvent.MOUSE_OUT, chapterButtonOutHandle );
					chapterWallBtn.addEventListener( MouseEvent.MOUSE_UP, chapterButtonClickHandle );
				case Levels.LEVEL_LIFT:
					this.chapterLiftBtn.buttonMode = true;
					chapterLiftBtn.gotoAndStop( "grey" );
					chapterLiftBtn.addEventListener( MouseEvent.MOUSE_OVER, chapterButtonOverHandle );
					chapterLiftBtn.addEventListener( MouseEvent.MOUSE_OUT, chapterButtonOutHandle );
					chapterLiftBtn.addEventListener( MouseEvent.MOUSE_UP, chapterButtonClickHandle );
				case Levels.LEVEL_THRONE:
					this.chapterThroneBtn.buttonMode = true;
					chapterThroneBtn.gotoAndStop( "grey" );
					chapterThroneBtn.addEventListener( MouseEvent.MOUSE_OVER, chapterButtonOverHandle );
					chapterThroneBtn.addEventListener( MouseEvent.MOUSE_OUT, chapterButtonOutHandle );
					chapterThroneBtn.addEventListener( MouseEvent.MOUSE_UP, chapterButtonClickHandle );
				case Levels.LEVEL_CORRIDOR:
					this.chapterCorridorBtn.buttonMode = true;
					chapterCorridorBtn.gotoAndStop( "grey" );
					chapterCorridorBtn.addEventListener( MouseEvent.MOUSE_OVER, chapterButtonOverHandle );
					chapterCorridorBtn.addEventListener( MouseEvent.MOUSE_OUT, chapterButtonOutHandle );
					chapterCorridorBtn.addEventListener( MouseEvent.MOUSE_UP, chapterButtonClickHandle );
				case Levels.LEVEL_TUTORIAL:
					this.chapterTurorialBtn.buttonMode = true;
					chapterTurorialBtn.addEventListener( MouseEvent.MOUSE_OVER, chapterButtonOverHandle );
					chapterTurorialBtn.addEventListener( MouseEvent.MOUSE_OUT, chapterButtonOutHandle );
					chapterTurorialBtn.addEventListener( MouseEvent.MOUSE_UP, chapterButtonClickHandle );
			}
			
			//dispatchEvent( new MenuEvent( MenuEvent.CONTINUE ) );
			
			chapterTurorialBtn.gotoAndStop( "color" );
			selectedChapter = Levels.LEVEL_TUTORIAL;
			
			TweenLite.to( this, 1, { alpha: 1 } );
			
			cursor.x = CURSOR_CHAPTER_TUTORIAL.x;
			cursor.y = CURSOR_CHAPTER_TUTORIAL.y;
		}
		
		private function chapterButtonOverHandle( e:MouseEvent=null ) : void
		{			
			switch( e.target.name )
			{
				case "chapterTurorialBtn":
					chapterTurorialBtn.gotoAndStop( "color" );
				break;
				case "chapterCorridorBtn":
					chapterCorridorBtn.gotoAndStop( "color" );
				break;
				case "chapterThroneBtn":
					chapterThroneBtn.gotoAndStop( "color" );
				break;
				case "chapterLiftBtn":
					chapterLiftBtn.gotoAndStop( "color" );
				break;
				case "chapterWallBtn":
					chapterWallBtn.gotoAndStop( "color" );
				break;
				case "chapterYardBtn":
					chapterYardBtn.gotoAndStop( "color" );
				break;
			}
			
		}
		
		private function chapterButtonOutHandle( e:MouseEvent=null ) : void
		{
			switch( e.target.name )
			{
				case "chapterTurorialBtn":
					chapterTurorialBtn.gotoAndStop( "grey" );
				break;
				case "chapterCorridorBtn":
					chapterCorridorBtn.gotoAndStop( "grey" );
				break;
				case "chapterThroneBtn":
					chapterThroneBtn.gotoAndStop( "grey" );
				break;
				case "chapterLiftBtn":
					chapterLiftBtn.gotoAndStop( "grey" );
				break;
				case "chapterWallBtn":
					chapterWallBtn.gotoAndStop( "grey" );
				break;
				case "chapterYardBtn":
					chapterYardBtn.gotoAndStop( "grey" );
				break;
			}
		}
		
		private function chapterButtonClickHandle( e:MouseEvent=null ) : void
		{
			
			switch( e.target.name )
			{
				case "chapterTurorialBtn":
					chapterToLoad = Levels.LEVEL_TUTORIAL;
					chapterTurorialBtn.removeEventListener( MouseEvent.MOUSE_OVER, chapterButtonOverHandle );
					chapterTurorialBtn.removeEventListener( MouseEvent.MOUSE_OUT, chapterButtonOutHandle );
					chapterTurorialBtn.removeEventListener( MouseEvent.MOUSE_UP, chapterButtonClickHandle );
				break;
				case "chapterCorridorBtn":
					chapterToLoad = Levels.LEVEL_CORRIDOR;
					chapterCorridorBtn.removeEventListener( MouseEvent.MOUSE_OVER, chapterButtonOverHandle );
					chapterCorridorBtn.removeEventListener( MouseEvent.MOUSE_OUT, chapterButtonOutHandle );
					chapterCorridorBtn.removeEventListener( MouseEvent.MOUSE_UP, chapterButtonClickHandle );
				break;
				case "chapterThroneBtn":
					chapterToLoad = Levels.LEVEL_THRONE;
					chapterThroneBtn.removeEventListener( MouseEvent.MOUSE_OVER, chapterButtonOverHandle );
					chapterThroneBtn.removeEventListener( MouseEvent.MOUSE_OUT, chapterButtonOutHandle );
					chapterThroneBtn.removeEventListener( MouseEvent.MOUSE_UP, chapterButtonClickHandle );
				break;
				case "chapterLiftBtn":
					chapterToLoad = Levels.LEVEL_LIFT;
					chapterLiftBtn.removeEventListener( MouseEvent.MOUSE_OVER, chapterButtonOverHandle );
					chapterLiftBtn.removeEventListener( MouseEvent.MOUSE_OUT, chapterButtonOutHandle );
					chapterLiftBtn.removeEventListener( MouseEvent.MOUSE_UP, chapterButtonClickHandle );
				break;
				case "chapterWallBtn":
					chapterToLoad = Levels.LEVEL_WALL;
					chapterWallBtn.removeEventListener( MouseEvent.MOUSE_OVER, chapterButtonOverHandle );
					chapterWallBtn.removeEventListener( MouseEvent.MOUSE_OUT, chapterButtonOutHandle );
					chapterWallBtn.removeEventListener( MouseEvent.MOUSE_UP, chapterButtonClickHandle );
				break;
				case "chapterYardBtn":
					chapterToLoad = Levels.LEVEL_YARD;
					chapterYardBtn.removeEventListener( MouseEvent.MOUSE_OVER, chapterButtonOverHandle );
					chapterYardBtn.removeEventListener( MouseEvent.MOUSE_OUT, chapterButtonOutHandle );
					chapterYardBtn.removeEventListener( MouseEvent.MOUSE_UP, chapterButtonClickHandle );
				break;
			}
			
			dispatchEvent( new MenuEvent( MenuEvent.CONTINUE ) );
		}
		
		private function volumeHandle( e:SliderEvent ) : void
		{
			this.volume = e.value;
		}
		
		private function frenchHandle( e:MouseEvent=null ) : void
		{
			this.lang = 'fr';
			changeTexts();
		}

		private function englishHandle( e:MouseEvent=null ) : void
		{
			this.lang = 'en';
			changeTexts();
		}
		
		private function changeTexts() : void
		{
			titleLabel.text = XmlGameData.getInstance().texts.texts.menu_title.child(lang);
			copyrightLabel.text = XmlGameData.getInstance().texts.texts.menu_copyright.child(lang);
			
			switch( page )
			{
				case PAGE_MAIN:
					startBtn.startBtn.text = XmlGameData.getInstance().texts.texts.menu_start.child(lang);
					optionsBtn.optionsBtn.text = XmlGameData.getInstance().texts.texts.menu_options.child(lang);
					creditsBtn.creditsBtn.text = XmlGameData.getInstance().texts.texts.menu_credits.child(lang);
					//exitBtn.exitBtn.text = _texts.texts.menu_exit.child( lang );					
				break;
				case PAGE_OPTIONS:
					returnBtn.returnLbl.text = XmlGameData.getInstance().texts.texts.menu_return.child(lang);
					languageLabel.text = XmlGameData.getInstance().texts.texts.menu_language.child(lang);
					volumeLabel.text = XmlGameData.getInstance().texts.texts.menu_volume.child(lang);
					frenchLbl.frenchLabel.text = XmlGameData.getInstance().texts.texts.menu_fr.child(lang);
					englishLbl.englishLabel.text = XmlGameData.getInstance().texts.texts.menu_en.child(lang);
					fullscreenCb.label = XmlGameData.getInstance().texts.texts.menu_fullscreen.child(lang);
				break;
				case PAGE_CREDITS:
					returnBtn.returnLbl.text = XmlGameData.getInstance().texts.texts.menu_return.child(lang);
					programingLabel.text = XmlGameData.getInstance().texts.texts.menu_programing.child(lang);
					designLabel.text = XmlGameData.getInstance().texts.texts.menu_design.child(lang);
					scribblesLabel.text = XmlGameData.getInstance().texts.texts.menu_scribbles.child(lang);
					//spritesLabel.text = _texts.texts.menu_sprites.child(lang);
					//musicLabel.text = _texts.texts.menu_music.child(lang);
					citrusLabel.text = XmlGameData.getInstance().texts.texts.menu_citrus.child(lang);
				break;
			}
			
		}
		
		private function onKeyDown( e:KeyboardEvent ) : void
		{
		
			//trace( "key down" );
			
			if ( e.keyCode == Keyboard.UP )
				cursorUp();
			else if ( e.keyCode == Keyboard.DOWN )
				cursorDown();
			else if ( e.keyCode == Keyboard.RIGHT )
				cursorRight();
			else if ( e.keyCode == Keyboard.LEFT )
				cursorLeft();
			else if ( e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.SPACE )
				cursorEnter();
			
		}
		
		private function activateChapterButton( selected:String = null ) : void
		{
			chapterTurorialBtn.gotoAndStop( "disabled" );
			chapterCorridorBtn.gotoAndStop( "disabled" );
			chapterThroneBtn.gotoAndStop( "disabled" );
			chapterLiftBtn.gotoAndStop( "disabled" );
			chapterWallBtn.gotoAndStop( "disabled" );
			chapterYardBtn.gotoAndStop( "disabled" );
			
			var mySO:SharedObject = SharedObject.getLocal("save");	
			mySO.data.currentLevel;
			
			switch( mySO.data.currentLevel )
			{
				case Levels.LEVEL_YARD:
					chapterYardBtn.gotoAndStop( "grey" );
				case Levels.LEVEL_WALL:
					chapterWallBtn.gotoAndStop( "grey" );
				case Levels.LEVEL_LIFT:
					chapterLiftBtn.gotoAndStop( "grey" );
				case Levels.LEVEL_THRONE:
					chapterThroneBtn.gotoAndStop( "grey" );
				case Levels.LEVEL_CORRIDOR:
					chapterCorridorBtn.gotoAndStop( "grey" );
				case Levels.LEVEL_TUTORIAL:
					chapterTurorialBtn.gotoAndStop( "grey" );
					break;
			}
			
			switch( selected )
			{
				case Levels.LEVEL_YARD:
					cursor.x = CURSOR_CHAPTER_YARD.x;
					cursor.y = CURSOR_CHAPTER_YARD.y;
					if ( chapterYardBtn.currentFrameLabel == "grey" )
					chapterYardBtn.gotoAndStop( "color" );
					break;
				case Levels.LEVEL_WALL:
					cursor.x = CURSOR_CHAPTER_WALL.x;
					cursor.y = CURSOR_CHAPTER_WALL.y;
					if ( chapterWallBtn.currentFrameLabel == "grey" )
					chapterWallBtn.gotoAndStop( "color" );
					break;
				case Levels.LEVEL_LIFT:
					cursor.x = CURSOR_CHAPTER_LIFT.x;
					cursor.y = CURSOR_CHAPTER_LIFT.y;
					if ( chapterLiftBtn.currentFrameLabel == "grey" )
					chapterLiftBtn.gotoAndStop( "color" );
					break;
				case Levels.LEVEL_THRONE:
					cursor.x = CURSOR_CHAPTER_THRONE.x;
					cursor.y = CURSOR_CHAPTER_THRONE.y;
					if ( chapterThroneBtn.currentFrameLabel == "grey" )
					chapterThroneBtn.gotoAndStop( "color" );
					break;
				case Levels.LEVEL_CORRIDOR:
					cursor.x = CURSOR_CHAPTER_CORRIDOR.x;
					cursor.y = CURSOR_CHAPTER_CORRIDOR.y;
					if ( chapterCorridorBtn.currentFrameLabel == "grey" )
					chapterCorridorBtn.gotoAndStop( "color" );
					break;
				case Levels.LEVEL_TUTORIAL:
					cursor.x = CURSOR_CHAPTER_TUTORIAL.x;
					cursor.y = CURSOR_CHAPTER_TUTORIAL.y;
					if ( chapterTurorialBtn.currentFrameLabel == "grey" )
					chapterTurorialBtn.gotoAndStop( "color" );
					break; 
				default:
					cursor.x = CURSOR_CHAPTER_RETURN.x;
					cursor.y = CURSOR_CHAPTER_RETURN.y;
					break;
			}
			
			selectedChapter = selected;
		}
			
		private function cursorRight() : void
		{			
			switch ( page )
			{
				case PAGE_CHAPTERS:			
					
					switch( selectedChapter )
					{
						case Levels.LEVEL_TUTORIAL:
							activateChapterButton( Levels.LEVEL_CORRIDOR );
						break;
						case Levels.LEVEL_CORRIDOR:
							activateChapterButton( Levels.LEVEL_THRONE );
						break;
						case Levels.LEVEL_THRONE:
							activateChapterButton( Levels.LEVEL_LIFT );
						break;
						case Levels.LEVEL_LIFT:
							activateChapterButton( Levels.LEVEL_WALL );
						break;
						case Levels.LEVEL_WALL:
							activateChapterButton( Levels.LEVEL_YARD );
						break;
						case Levels.LEVEL_YARD:
							activateChapterButton();
						break;
						default:
							activateChapterButton( Levels.LEVEL_TUTORIAL );
						break;
					}
					
					break;
				case PAGE_OPTIONS:
					if ( cursor.x == CURSOR_OPTIONS_FRENCH.x && cursor.y == CURSOR_OPTIONS_FRENCH.y )
						cursor.x = CURSOR_OPTIONS_ENGLISH.x;
					
					if ( cursor.y == CURSOR_OPTIONS_VOLUME.y )
					{
						volume++;
						volumeBtn.value++;
					}
						
					break;
			}
		}
		
		private function cursorLeft() : void
		{
			switch ( page )
			{
				case PAGE_CHAPTERS:
					
					switch( selectedChapter )
					{
						case Levels.LEVEL_TUTORIAL:
							activateChapterButton();
						break;
						case Levels.LEVEL_CORRIDOR:
							activateChapterButton( Levels.LEVEL_TUTORIAL );
						break;
						case Levels.LEVEL_THRONE:
							activateChapterButton( Levels.LEVEL_CORRIDOR );
						break;
						case Levels.LEVEL_LIFT:
							activateChapterButton( Levels.LEVEL_THRONE );
						break;
						case Levels.LEVEL_WALL:
							activateChapterButton( Levels.LEVEL_LIFT );
						break;
						case Levels.LEVEL_YARD:
							activateChapterButton( Levels.LEVEL_WALL );
						break;
						default:
							activateChapterButton( Levels.LEVEL_YARD );
						break;
					}
					
					break;
				case PAGE_OPTIONS:
					if ( cursor.x == CURSOR_OPTIONS_ENGLISH.x && cursor.y == CURSOR_OPTIONS_ENGLISH.y )
						cursor.x = CURSOR_OPTIONS_FRENCH.x;
					
					if ( cursor.y == CURSOR_OPTIONS_VOLUME.y )
					{
						volume--;
						volumeBtn.value--;
					}
					
					break;
			}
		}
		
		private function cursorUp() : void
		{
			
			switch ( page )
			{
				case PAGE_MAIN:
					
					switch( cursor.y )
					{
						case CURSOR_MAIN_CONTINUE.y:
							cursor.y = CURSOR_MAIN_NEW.y;
						break;
						case CURSOR_MAIN_OPTION.y:
							cursor.y = CURSOR_MAIN_CONTINUE.y;
						break;
						case CURSOR_MAIN_CREDITS.y:
							cursor.y = CURSOR_MAIN_OPTION.y;
						break;
					}
					
					break;
				case PAGE_CHAPTERS:
					
					switch( selectedChapter )
					{
						case Levels.LEVEL_TUTORIAL:
							activateChapterButton();
						break;
						case Levels.LEVEL_CORRIDOR:
							activateChapterButton();
						break;
						case Levels.LEVEL_THRONE:
							activateChapterButton();
						break;
						case Levels.LEVEL_LIFT:
							activateChapterButton( Levels.LEVEL_TUTORIAL );
						break;
						case Levels.LEVEL_WALL:
							activateChapterButton( Levels.LEVEL_CORRIDOR );
						break;
						case Levels.LEVEL_YARD:
							activateChapterButton( Levels.LEVEL_THRONE );
						break;
						default:
							activateChapterButton( Levels.LEVEL_WALL );
						break;
					}
					
					break;
				case PAGE_OPTIONS:
					
					switch ( cursor.y )
					{
						case CURSOR_OPTIONS_VOLUME.y:
							cursor.y = CURSOR_OPTIONS_FRENCH.y;
							cursor.x = CURSOR_OPTIONS_FRENCH.x;
							break;
						case CURSOR_OPTIONS_RETURN.y:
							cursor.y = CURSOR_OPTIONS_VOLUME.y;
							cursor.x = CURSOR_OPTIONS_VOLUME.x;
							break;
					}
					
					break;
			}
			
		}
		
		private function cursorDown() : void
		{
			switch ( page )
			{
				case PAGE_MAIN:
					
					switch( cursor.y )
					{
						case CURSOR_MAIN_NEW.y:
							cursor.y = CURSOR_MAIN_CONTINUE.y;
						break;
						case CURSOR_MAIN_CONTINUE.y:
							cursor.y = CURSOR_MAIN_OPTION.y;
						break;
						case CURSOR_MAIN_OPTION.y:
							cursor.y = CURSOR_MAIN_CREDITS.y;
						break;
					}
					
					break;
				case PAGE_CHAPTERS:
					
					switch( selectedChapter )
					{
						case Levels.LEVEL_TUTORIAL:
							activateChapterButton( Levels.LEVEL_LIFT );
						break;
						case Levels.LEVEL_CORRIDOR:
							activateChapterButton( Levels.LEVEL_WALL );
						break;
						case Levels.LEVEL_THRONE:
							activateChapterButton( Levels.LEVEL_YARD );
						break;
						case Levels.LEVEL_LIFT:
							activateChapterButton();
						break;
						case Levels.LEVEL_WALL:
							activateChapterButton();
						break;
						case Levels.LEVEL_YARD:
							activateChapterButton();
						break;
						default:
							activateChapterButton( Levels.LEVEL_TUTORIAL );
						break;
					}
					
					break;
				case PAGE_OPTIONS:
					
					switch ( cursor.y )
					{
						case CURSOR_OPTIONS_FRENCH.y:
							cursor.y = CURSOR_OPTIONS_VOLUME.y;
							cursor.x = CURSOR_OPTIONS_VOLUME.x;
							break;
						case CURSOR_OPTIONS_VOLUME.y:
							cursor.y = CURSOR_OPTIONS_RETURN.y;
							cursor.x = CURSOR_OPTIONS_RETURN.x;
							break;
					}
					
					
					break;
			}
		}
		
		private function cursorEnter() : void
		{
			switch ( page )
			{
				case PAGE_MAIN:
										
					switch( cursor.y )
					{
						case CURSOR_MAIN_NEW.y:
							startBtnHandle();
						break;
						case CURSOR_MAIN_CONTINUE.y:
							continueBtnHandle();
						break;
						case CURSOR_MAIN_OPTION.y:
							optionsBtnHandle();
						break;
						case CURSOR_MAIN_CREDITS.y:
							creditsBtnHandle();
						break;
					}
					
					break;
				case PAGE_CHAPTERS:
										
					switch( selectedChapter )
					{
						case null:
							returnBtnHandle();
						break;
						default:
							chapterToLoad = selectedChapter;
							dispatchEvent( new MenuEvent( MenuEvent.CONTINUE ) );
						break;
					}
					
					break;
				case PAGE_OPTIONS:
					
					if ( cursor.x == CURSOR_OPTIONS_FRENCH.x && cursor.y == CURSOR_OPTIONS_FRENCH.y )
						frenchHandle();
					else if ( cursor.x == CURSOR_OPTIONS_ENGLISH.x && cursor.y == CURSOR_OPTIONS_ENGLISH.y )
						englishHandle();
					else if ( cursor.y == CURSOR_OPTIONS_RETURN.y )
						returnBtnHandle();
					
					break;
				case PAGE_CREDITS:
					returnBtnHandle();
					break;
			}
		}
		
		public function killKeyboard() : void
		{
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			//trace( "kill kenny" );
		}
		
	}

}