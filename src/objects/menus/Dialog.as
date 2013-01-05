package objects.menus 
{
	import com.citrusengine.core.CitrusEngine;
	import com.greensock.TweenLite;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import mx.utils.StringUtil;
	import objects.platformer.BossSpot;
	import objects.platformer.Knight;
	import objects.platformer.Princess;
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
		private var _keys:XML;
		
		private var _timer:Timer = new Timer(2000);
		
		private var _bossSpot:BossSpot;
		private var textArray:Array;
		private var _knight:Knight;
		private var _princess:Princess;
		
		private var _keyToContinue:String;
		
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
			
		public function set keys( keys:XML ) : void
		{
			_keys = keys;
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
				
				_ce.playing = false;
				gotoAndStop( 'main' );
				TweenLite.to( this, 0.2, {alpha:1} );
				TweenLite.to( blackBandTop, 0.5, { y:0 } );
				TweenLite.to( blackBandBottom, 0.5, { y:472 } );
				
				_knight = (_ce.state.getFirstObjectByType( Knight ) as Knight );
				if ( _knight != null )
				{
					_knight._talking = true;
					_knight.stop();
				}
				
				_princess = ( _ce.state.getFirstObjectByType( Princess ) as Princess );
				if ( _princess != null )
				{
					_princess.animation = 'idle';
					_princess.stuck = true;
				}
				
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
						
			if ( XmlGameData.getInstance().texts.texts.child(text).key == undefined )
				_keyToContinue = 'space,enter';
			else
				_keyToContinue = XmlGameData.getInstance().texts.texts.child(text).key;
				
			_keyToContinue = 'space,enter';
								
			text_space.text = text_space.text.replace( '[KEY]', formatKeyText( _keyToContinue.split(',') ) );
			
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
			
			if ( XmlGameData.getInstance().texts.texts.child(textKey).key == undefined )
				_keyToContinue = 'space,enter';
			else
				_keyToContinue = XmlGameData.getInstance().texts.texts.child(textKey).key;
				
			_keyToContinue = 'space,enter';
				
			//text_space.text = _keyToContinue;
			text_space.text = XmlGameData.getInstance().texts.texts.text_space.child(_lang);
			text_space.text = text_space.text.replace( '[KEY]', formatKeyText( _keyToContinue.split(',') ) );
			
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
				//else
					//_ce.state.hideDialog();
				
				_ce.stage.removeChild( this );
				
				_ce.stage.focus = _ce.state;
				
				if ( currentLabel == 'main' )
				{
					blackBandTop.y = -128;
					blackBandBottom.y = 600;
				}
				
				if ( _timer.running )
				{
					_timer.removeEventListener( TimerEvent.TIMER, hide );
					_timer.stop();
				}

				_knight = (_ce.state.getFirstObjectByType( Knight ) as Knight );
				if ( _knight != null )
				{
					_knight._talking = false;
					_knight.start();
				}
				
				_princess = ( _ce.state.getFirstObjectByType( Princess ) as Princess );
				if ( _princess != null )
				{
					_princess.stuck = false;
				}
				
				if ( !_ce.playing )
					_ce.playing = true;
					
				alpha = 0;
			}
		}
		
		public function hideKeyboard( e:KeyboardEvent ) : void
		{		
			
			if ( _keyToContinue.indexOf( "," ) != -1 )
			{
				var keys:Array = _keyToContinue.split(',');
				for each( var key:String in keys )
				{
					
					if ( e.keyCode.toString() == _keys.child(key) )
					{
						hide();	
					}
				}
			}
			else if ( e.keyCode.toString() == _keys.child(_keyToContinue) )
			{
				hide();	
			}
		}
		
		private function formatKeyText( keys:Array ) : String
		{
						
			var keyText:String = "";
			var i:uint = 0;
			for each( var key:String in keys )
			{
				keyText = keyText + XmlGameData.getInstance().texts.texts.child(key).child(_lang);
				
				if ( ++i != keys.length )
				keyText = keyText += " "+XmlGameData.getInstance().texts.texts.or.child(_lang)+" ";
			}
			
			return keyText;
		}
		
	}

}