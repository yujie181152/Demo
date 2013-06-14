package  
{
	import Box2D.Dynamics.Contacts.b2PolyAndCircleContact;
	import citrus.core.CitrusEngine;
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
	import flash.display.Bitmap;
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
			citrusEngine.gameData.lives = 1;
			citrusEngine.gameData.score = 0;
			//bgm
			citrusEngine.sound.playSound("bgm", 0.5);
			//背景
			addChildAt(new Image(Texture.fromBitmap(new BG_IMAGE as Bitmap)),0);
			//分數欄位
			add(new CitrusSprite("scoreTd", { view: new TextField(200, 50, "分數:0") ,x:80,y:0,group:2}) );
			//生命欄位
			add(new CitrusSprite("livesTd", { view: new TextField(200, 50, "生命:"+citrusEngine.gameData.lives) ,x:180,y:0,group:2}) );
			
			//加入Box2D物理引擎
			var box2D:Box2D = new Box2D("box2D");
			//box2D.visible = true; //debug模式開關
			add(box2D);
			//加入地板
			var bottom:Platform = new Platform("bottom", { 
					x:stage.stageWidth / 2, 
					y:stage.stageHeight, 
					width:stage.stageWidth,
					view:"500x30.jpg"
				} );
			add(bottom);
			//加入角色
			var bitmap:Bitmap = new _heroPng();
			var texture:Texture = Texture.fromBitmap(bitmap);
			var xml:XML = XML(new _heroConfig());
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			
			var hero:Hero = new Hero("hero", {
					x:100, 
					y:200, 
					width:30, 
					height:120
				});
			hero.acceleration = 0.3; //加速度
			hero.maxVelocity = 5; //速度極限
			hero.view = new AnimationSequence(sTextureAtlas, ["walk", "duck", "idle", "jump", "hurt"], "idle");
			hero.offsetY = -10;
			hero.group = 1;
			add(hero);
			
			hero.onJump.add(heroOnJump);//跳躍觸發
			hero.onGiveDamage.add(heroOnGiveDamage);//攻擊觸發
			hero.onTakeDamage.add(heroOnTakeDamage);//被攻擊觸發
			
			//加入一個平台
			var cloud:Platform = new Platform("cloud", {
					x:250, 
					y:300, 
					width:100, 
					oneWay:true, //單一方向判定
					view:"100x30.jpg"
				});
			add(cloud);
			//加入一個金幣
			var coin:Coin = new Coin("coin", { x:250, y:150 } );
			coin.view = "gold.png";
			add(coin);
			//取得金幣觸發
			coin.onBeginContact.add(heroGetGold);
			
			//加入敵人
			var enemy:Enemy = new Enemy("enemy", {
					x:stage.stageWidth - 50, 
					y:350, 
					width:30, 
					height:30, 
					leftBound:20, 
					rightBound:stage.stageWidth - 20,
					view:"Enemy.png"
				});
			add(enemy);
			
			//邊界
			add(new Platform("left", {
					x: -10,
					y: stage.stageHeight >> 1,
					width:20,
					height:stage.stageHeight
				}));
			add(new Platform("right", {
					x: stage.stageWidth+10,
					y: stage.stageHeight >> 1,
					width:20,
					height:stage.stageHeight
				}));
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