package  
{
	import citrus.core.starling.StarlingState;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author Cain
	 */
	public class MyState extends StarlingState 
	{
		public var lvlEnded:Signal;
		public function MyState() 
		{
			super();
			//場景結束Signal
			lvlEnded = new Signal();
		}
		
	}

}