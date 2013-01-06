package 
{
	import org.flixel.*;
	import org.flixel.system.*;

	[SWF(width="1200", height="800", backgroundColor="#FFFFFF")]
    [Frame(factoryClass = "Preloader")]
	
	public class Main extends FlxGame 
	{
		public function Main():void
		{
			super(600, 400, GameState, 2, 60, 60);
		}
	}
}