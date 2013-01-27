package objects.menus 
{
	import com.citrusengine.core.CitrusEngine;
	import com.greensock.TweenLite;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import mx.utils.StringUtil;
	import objects.events.DialogEvent;
	import objects.platformer.BossSpot;
	import singletons.XmlGameData;
	/**
	 * ...
	 * @author Matt
	 */
	public class Dialog extends DialogBox 
	{
	
		private static var _instance:Dialog;
		private var displayed:Boolean = false;
		
		private var _lang:String;
		private var _characters:XML;
		
		private var _timer:Timer = new Timer(2000);
		
		private var _bossSpot:BossSpot;
		private var textArray:Array;
		
		public static function getInstance() : Dialog
		{
			if ( _instance == null )
			_instance = new Dialog();
			return _instance;
		}
		
		public function Dialog(  ) 
		{
			super();
		}
		
		public function setXml ( lang:String, texts:XML, characters:XML ) : void
		{
			_lang = lang;
			_characters = characters;
		}
					
		public function show( text:String, character:String = 'knight', timer:uint = 2000, pause:Boolean = false, bossTrigger:BossSpot = null, forced:Boolean=false ) : void
		{								
			var _ce:CitrusEngine = CitrusEngine.getInstance();
			
			if ( text.indexOf( "," ) != -1 )
			{
				textArray = text.split(',');
				text = textArray.shift();
			}
						
			if ( pause )
			{
								
				if ( _timer.running )
				{
					_timer.stop();
					
					if ( _timer.hasEventListener( TimerEvent.TIMER ) )
						_timer.removeEventListener( TimerEvent.TIMER, hide );
				}
				
				gotoAndStop( 'main' );
				TweenLite.to( this, 0.2, {alpha:1} );
												
			}
			else
			{
				_timer.delay = timer;
				gotoAndStop( 'small' );
				_timer.addEventListener( TimerEvent.TIMER, hide );
				_timer.start();
				TweenLite.to( this, 0.2, {alpha:1} );
			}
			
			text_space.text = XmlGameData.getInstance().texts.texts.text_space.child(_lang);
			
			if ( XmlGameData.getInstance().texts.texts.child(text) == undefined || XmlGameData.getInstance().texts.texts.child(text).child(_lang) == undefined )
				this.text.text = text;
			else
				this.text.text = XmlGameData.getInstance().texts.texts.child(text).child(_lang);
			
			text_space.visible = !forced;
			
			if ( !forced )
				_ce.stage.addEventListener( KeyboardEvent.KEY_UP, hideKeyboard );
			
			if ( bossTrigger != null )
				_bossSpot = bossTrigger;
			
			_ce.stage.addChild( this );
		
			displayed = true;
		}
		
		public function nextText() : void
		{
						
			var textKey:String = textArray.shift();
			this.text.text = XmlGameData.getInstance().texts.texts.child( textKey ).child(_lang);
							
			//text_space.text = _keyToContinue;
			text_space.text = XmlGameData.getInstance().texts.texts.text_space.child(_lang);
			
			if ( textArray.length == 0 )
			textArray = null;
		}
		
		// BUG the startBossFight should use event/signal
		// BUG the hideDialog should use event/signal
		public function hide( e:TimerEvent=null ) : void
		{
			
			if ( textArray != null )
			{
				nextText();
			}
			else
			{
				displayed = false;
				var _ce:CitrusEngine = CitrusEngine.getInstance();
				
				if ( _ce.stage.hasEventListener( KeyboardEvent.KEY_UP ) )
					_ce.stage.removeEventListener( KeyboardEvent.KEY_UP, hideKeyboard );
				
				if ( _bossSpot != null )
				{
					//_ce.state.startBossFight( _bossSpot );
					_bossSpot = null;
				}
				
				_ce.stage.removeChild( this );
				
				_ce.stage.focus = _ce.state;
								
				if ( _timer.running )
				{
					_timer.removeEventListener( TimerEvent.TIMER, hide );
					_timer.stop();
				}
									
				alpha = 0;
				
				CitrusEngine.getInstance().stage.dispatchEvent( new DialogEvent( DialogEvent.DIALOG_HIDE ) );
			}
		}
		
		public function hideKeyboard( e:KeyboardEvent ) : void
		{		
			
			if ( e.keyCode == Keyboard.SPACE || e.keyCode == Keyboard.ENTER )
			{
				hide();	
			}

		}
				
	}

}