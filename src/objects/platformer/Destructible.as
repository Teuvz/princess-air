package objects.platformer
{
	import Box2DAS.Collision.Shapes.b2MassData;
	import Box2DAS.Dynamics.b2Body;
	import flash.display.MovieClip;
	import singletons.Assets;
	
	import com.citrusengine.objects.PhysicsObject;
	
	/**
	 * A very simple physics object. I just needed to add bullet mode and zero restitution
	 * to make it more stable, otherwise it gets very jittery. 
	 */	
	public class Destructible extends PhysicsObject
	{
				
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, view:* = null):Destructible
		{
			if (view == null) view = MovieClip;
			return new Destructible(name, { x: x, y: y, width: width, height: height, view: view } );
		}
		
		public function Destructible(name:String, params:Object=null)
		{
			
			params.view = Assets.getInstance().formatName(params.view);		
			
			super(name, params);
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			_bodyDef.bullet = true;
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.density = 0.1;
			_fixtureDef.restitution = 0;
		}
		
		//This is only used to register the Destructible with the Level Architect
		[Property(value="30")]
		override public function set width(value:Number):void
		{
			super.width = value;
		}
		
		public function destruct() : void
		{
			destroy();
		}
	}
}