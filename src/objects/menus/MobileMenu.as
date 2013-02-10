package objects.menus 
{
	import com.greensock.TweenLite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author matt
	 */
	public class MobileMenu extends AndroidMenu 
	{

		private static var instance:MobileMenu;
		
		public var leftArrowDown:Boolean = false;
		public var rightArrowDown:Boolean = false;
		public var healButtonDown:Boolean = false;
		public var switchButtonDown:Boolean = false;
		
		public function MobileMenu() 
		{
			super();
			this.alpha = 0;
			switchButton.alpha = 0;
			
			this.leftArrow.addEventListener( MouseEvent.MOUSE_DOWN, leftArrowDownHandle );			
			this.rightArrow.addEventListener( MouseEvent.MOUSE_DOWN, rightArrowDownHandle );
			this.healButton.addEventListener( MouseEvent.MOUSE_DOWN, healDownHandle );
		}
		
		public static function getInstance() : MobileMenu
		{
			if ( instance == null )
				instance = new MobileMenu();
				
			return instance;
		}
		
		public function show() : void
		{
			TweenLite.to(this, 0.5, {alpha:0.8} );
		}
		
		public function hide() : void
		{
			TweenLite.to(this, 0.5, {alpha:0} );
		}
		
		public function showSwitchButton() : void
		{
			TweenLite.to(switchButton, 0.2, { alpha:0.8 } );
			this.switchButton.addEventListener(MouseEvent.MOUSE_DOWN, switchButtonDownHandle);
		}
		
		public function hideSwitchButton() : void
		{
			if ( switchButton.alpha > 0 )
			{
				TweenLite.to(switchButton, 0.2, { alpha:0 } );
				this.switchButton.removeEventListener(MouseEvent.MOUSE_DOWN, switchButtonDownHandle);
			}
		}
		
		private function leftArrowDownHandle( e:MouseEvent ) : void
		{
			e.stopPropagation();
			this.leftArrow.removeEventListener(MouseEvent.MOUSE_DOWN, leftArrowDownHandle);
			this.leftArrow.addEventListener(MouseEvent.MOUSE_UP, leftArrowUpHandle);
			leftArrowDown = true;
		}
		
		private function rightArrowDownHandle( e:MouseEvent ) : void
		{
			e.stopPropagation();
			this.rightArrow.removeEventListener(MouseEvent.MOUSE_DOWN, rightArrowDownHandle);
			this.rightArrow.addEventListener(MouseEvent.MOUSE_UP, rightArrowUpHandle);
			rightArrowDown = true;
		}
		
		private function leftArrowUpHandle( e:MouseEvent ) : void
		{
			e.stopPropagation();
			this.leftArrow.addEventListener(MouseEvent.MOUSE_DOWN, leftArrowDownHandle);
			this.leftArrow.removeEventListener(MouseEvent.MOUSE_UP, leftArrowUpHandle);
			leftArrowDown = false;
		}
		
		private function rightArrowUpHandle( e:MouseEvent ) : void
		{
			e.stopPropagation();
			this.rightArrow.addEventListener(MouseEvent.MOUSE_DOWN, rightArrowDownHandle);
			this.rightArrow.removeEventListener(MouseEvent.MOUSE_UP, rightArrowUpHandle);
			rightArrowDown = false;
		}
		
		private function healDownHandle( e:MouseEvent ) : void
		{
			e.stopPropagation();
			this.healButton.removeEventListener(MouseEvent.MOUSE_DOWN, healDownHandle);
			this.healButton.addEventListener(MouseEvent.MOUSE_UP, healUpHandle);
			healButtonDown = true;
		}
		
		private function healUpHandle( e:MouseEvent ) : void
		{
			e.stopPropagation();
			this.healButton.addEventListener(MouseEvent.MOUSE_DOWN, healDownHandle);
			this.healButton.removeEventListener(MouseEvent.MOUSE_UP, healUpHandle);
			healButtonDown = false;
		}
		
		private function switchButtonDownHandle( e:MouseEvent ) : void
		{
			e.stopPropagation();
			switchButtonDown = true;
			hideSwitchButton();
		}
		
	}

}