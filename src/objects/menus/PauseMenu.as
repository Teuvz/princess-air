package objects.menus 
{
	import com.greensock.plugins.EndVectorPlugin;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import objects.events.EndGameEvent;
	/**
	 * ...
	 * @author matt
	 */
	public class PauseMenu extends PauseScreen 
	{
		
		private static var instance:PauseMenu;
		
		public function PauseMenu( lang:String, _textData:XML ) 
		{
			super();
			
			//returnBtn.returnLbl.text = _texts.texts.menu_return.child(lang);
			this.pauseLbl.text = _textData.texts.pause_pause.child(lang);
			this.reloadBtn.text = _textData.texts.pause_reload.child(lang);
			this.continueBtn.text = _textData.texts.pause_continue.child(lang);
			this.exitBtn.text = _textData.texts.pause_exit.child(lang);
			
			this.reloadBtn.addEventListener( MouseEvent.CLICK, clickReload );
			this.continueBtn.addEventListener( MouseEvent.CLICK, clickContinue );
			this.exitBtn.addEventListener( MouseEvent.CLICK, clickExit );
			
		}
		
		public function show() : void
		{
			//Mouse.show();
		}
		
		public function hide() : void
		{
			Mouse.hide();
		}
		
		private function clickContinue( e:MouseEvent ) : void
		{
			trace( "continue" );
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function clickReload( e:MouseEvent ) : void
		{
			trace( "reload" );
			stage.dispatchEvent( new EndGameEvent( EndGameEvent.RELOAD ) );
		}
		
		private function clickExit( e:MouseEvent ) : void
		{
			trace( "exit" );
			stage.dispatchEvent( new EndGameEvent( EndGameEvent.EXIT ) );
		}
		
	}

}