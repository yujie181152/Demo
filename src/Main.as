package 
{
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.utils.AGameData;
	import citrus.utils.LevelManager;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Cain
	 */
	[Frame(factoryClass="Preloader")]
	public class Main extends StarlingCitrusEngine 
	{

		public function Main():void 
		{
			super();
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			//啟動Starling
			setUpStarling(true);
			gameData = new AGameData();
			//啟動遊戲場景
			//state = new StarlingDemoGameState();
			//場景控制器
			levelManager = new LevelManager(MyState);
			levelManager.levels = [StarlingDemoGameState,EndState];
			levelManager.onLevelChanged.add(_onLevelChanged);
			levelManager.gotoLevel();
			//載入音效
			sound.addSound("gold", "gold.mp3"); //取得金幣
			sound.addSound("jump", "jump.mp3"); //跳躍
			sound.addSound("bgm", "bgm.mp3"); //背景音樂
			sound.addSound("giveDamage", "giveDamage.mp3"); //攻擊
			sound.addSound("takeDamage", "takeDamage.mp3"); //被攻擊
		}
		
		private function _onLevelChanged(lvl:MyState):void 
		{
			state = lvl;
			lvl.lvlEnded.add(_nextState);
		}
		
		private function _nextState():void 
		{
			levelManager.nextLevel();
		}

	}

}