package  
{
	import citrus.objects.CitrusSprite;
	import starling.text.TextField;
	import flash.utils.setTimeout;
	/**
	 * 結束畫面
	 * @author Cain
	 */
	public class EndState extends MyState 
	{
		
		public function EndState() 
		{
			super();
		}
		
		override public function initialize () : void
		{
			super.initialize();
			add(new CitrusSprite("endTd", {
					view:new TextField(500, 400, "GameOver", "", 60,0xff0000)
				}));
			setTimeout(function ():void 
			{
				_ce.levelManager.gotoLevel(1);
			},3000)
		}
	}

}