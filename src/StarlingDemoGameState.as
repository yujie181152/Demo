package  
{
	import Box2D.Dynamics.Contacts.b2PolyAndCircleContact;
	import citrus.core.CitrusEngine;
	import citrus.core.CitrusObject;
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.core.starling.StarlingState;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.box2d.Coin;
	import citrus.objects.platformer.box2d.Enemy;
	import citrus.objects.platformer.box2d.Hero;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.physics.box2d.Box2D;
	import citrus.view.starlingview.AnimationSequence;
	import citrus.view.starlingview.StarlingView;
	import citrus.utils.objectmakers.ObjectMakerStarling;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author Cain
	 */
	public class StarlingDemoGameState extends MyState
	{
		[Embed(source = "Hero.png")]
		private var _heroPng:Class;
		[Embed(source = "Hero.xml", mimeType = "application/octet-stream")]
		private var _heroConfig:Class;
		[Embed(source = "bg.jpg")]
		private var BG_IMAGE:Class;
		private var citrusEngine:CitrusEngine;
		public function StarlingDemoGameState() 
		{
			super();
			//匯入物件
			var objects:Array = [Platform, Hero, Enemy];
		}
		/**
		 * 初始化
		 */
		override public function initialize():void 
		{
			super.initialize();
			//取得遊戲引擎
			citrusEngine = CitrusEngine.getInstance();
			//遊戲資料初始化
			citrusEngine.gameData.lives = 3;
			citrusEngine.gameData.score = 0;
			//bgm
			citrusEngine.sound.playSound("bgm", 0.5);
			//背景
			addChildAt(new Image(Texture.fromBitmap(new BG_IMAGE as Bitmap)),0);
			//分數欄位
			var _scoreTd:CitrusSprite = new CitrusSprite("scoreTd", { view: new TextField(200, 50, "分數:0") , x:80, y:0, group:2 });
			_scoreTd.parallaxY = 0;
			add(_scoreTd);
			//生命欄位
			var _livesTd:CitrusSprite = new CitrusSprite("livesTd", { view: new TextField(200, 50, "生命:" + citrusEngine.gameData.lives) , x:180, y:0, group:2 } ) ;
			_livesTd.parallaxY = 0;
			add(_livesTd);
			//載入建立的場景
			var _loader:Loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onViewLoaded);
			_loader.load(new URLRequest("gameState.swf"));
			
		}
		/**
		 * gameState.swf載入
		 * @param	e
		 */
		private function onViewLoaded(e:Event):void 
		{
			e.target.removeEventListener(Event.COMPLETE, onViewLoaded);
			var _loader:Loader = LoaderInfo(e.target).loader;
			//加入Box2D物理引擎
			var box2D:Box2D = new Box2D("box2D");
			//box2D.visible = true; //debug模式開關
			add(box2D);
			//建立場景
			ObjectMakerStarling.FromMovieClip(_loader.content as MovieClip);
			_loader.unloadAndStop();
			//加入地板
			var bottom:Platform = getObjectByName("bottom") as Platform;
			bottom.view = "500x30.jpg";
			//加入角色
			var bitmap:Bitmap = new _heroPng();
			var texture:Texture = Texture.fromBitmap(bitmap);
			var xml:XML = XML(new _heroConfig());
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			var hero:Hero = getFirstObjectByType(Hero) as Hero;
			hero.acceleration = 0.3; //加速度
			hero.maxVelocity = 5; //速度極限
			hero.view = new AnimationSequence(sTextureAtlas, ["walk", "duck", "idle", "jump", "hurt"], "idle");
			hero.offsetY = -10;
			hero.group = 1;
			
			hero.onJump.add(heroOnJump);//跳躍觸發
			hero.onGiveDamage.add(heroOnGiveDamage);//攻擊觸發
			hero.onTakeDamage.add(heroOnTakeDamage);//被攻擊觸發
			
			//加入一個平台
			
			var _CitrusObjectVec:Vector.<CitrusObject> = getObjectsByName("cloud");
			var _num:int = _CitrusObjectVec.length;
			var _cloud:Platform;
			var i:int;
			for (i = 0; i < _num; i++) 
			{
				_cloud = _CitrusObjectVec[i] as Platform; 
				_cloud.view = "200x30.jpg";
				_cloud.oneWay = true;
			}
			//加入一個金幣
			_CitrusObjectVec = getObjectsByType(Coin);
			_num = _CitrusObjectVec.length;
			var _coin:Coin;
			for (i = 0; i <_num ; i++)
			{
				_coin = Coin(_CitrusObjectVec[i]);
				_coin.view = "gold.png";
				//取得金幣觸發
				_coin.onBeginContact.add(heroGetGold);
			}
			
			//加入敵人
			var enemy:Enemy = getFirstObjectByType(Enemy) as Enemy;
			enemy.leftBound = 130;
			enemy.rightBound = 270;
			enemy.view = "Enemy.png";
			
			//鏡頭控制
			view.camera.target = hero;
			view.camera.offset.x = 250;
			view.camera.offset.y = 200;
			view.camera.bounds = new Rectangle(0, -400, 500, 800);
			//gameData變動
			citrusEngine.gameData.dataChanged.add(gameDataChanged);
		}
		
		private function gameDataChanged(data:String, num:int ):void 
		{
			var _citrusSprite:CitrusSprite;
			switch (data) 
			{
				case "lives": //生命值變動
					_citrusSprite = getObjectByName("livesTd") as CitrusSprite;
 					TextField(_citrusSprite.view).text = "生命:" + num;
					if (num<=0) 
					{
						lvlEnded.dispatch();
					}
				break;
				case "score": //分數變動
					_citrusSprite = getObjectByName("scoreTd") as CitrusSprite;
 					TextField(_citrusSprite.view).text = "分數:" + num;
				break;
				default:
					trace(data, num);
			}
		}
		/**
		 * 被攻擊
		 */
		private function heroOnTakeDamage():void 
		{
			citrusEngine.sound.playSound("takeDamage", 1, 0);
			citrusEngine.gameData.lives--;
		}
		/**
		 * 踩踏敵人
		 */
		private function heroOnGiveDamage():void 
		{
			citrusEngine.sound.playSound("giveDamage", 1, 0);
			
		}
		/**
		 * 跳躍觸發
		 */
		private function heroOnJump():void 
		{
			citrusEngine.sound.playSound("jump", 1, 0);
		}
		/**
		 * 取得金幣
		 */
		private function heroGetGold(e:b2PolyAndCircleContact):void 
		{
			citrusEngine.sound.playSound("gold", 1, 0);
			citrusEngine.gameData.score++;
		}
		
		/// Called by the Citrus Engine.
		override public function destroy () : void
		{
			citrusEngine = null;
		}

	}
}