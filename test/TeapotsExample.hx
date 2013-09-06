package ;
//{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.Lib;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.Vector;
	import lz.native3d.core.BasicLight3D;
	import lz.native3d.core.BasicView;
	import lz.native3d.core.DrawAble3D;
	import lz.native3d.core.Node3D;
	import lz.native3d.core.TextureSet;
	import lz.native3d.materials.PhongMaterial;
	import lz.native3d.meshs.MeshUtils;
	import openfl.display.FPS;
	#if flash
	import net.hires.debug.Stats;
	#end
	using OpenFLStage3D;
	

	 class TeapotsExample extends Sprite
	{
		
		public static function main() {
			Lib.current.addChild( new TeapotsExample());
		}
		
		private var bv:BasicView;
		private var rnode:Node3D;
		private var drawAble:DrawAble3D;
		private var texture:TextureBase;
		private var light:BasicLight3D;
		private var count:Int = 0;
		
		private var label:TextField;
		
		public function new()
		{
			super();
			rnode = new Node3D();
			bv = new BasicView(400,400,true);
			addChild(bv);
			bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, initializeScene);
			#if flash
			addChild(new Stats());
			#end
			label = new TextField();
			label.autoSize = TextFieldAutoSize.LEFT;
			label.textColor = 0xffffff;
			label.x = 200;
			label.defaultTextFormat = new TextFormat(null, 40);
			label.text = "click";
			label.selectable = false;
			addEventListener(MouseEvent.CLICK, label_click);
			addChild(label);
		}
		
		private function label_click(e:MouseEvent):Void 
		{
			var c:Int = 100;
			while (c-->0) {
				addCube();
			}
		}
		
		public function initializeScene(e:Event) : Void
		{
			drawAble = MeshUtils.createCube(30,bv.instance3Ds[0]);
			//drawAble = MeshUtils.createTeaPot(bv.instance3Ds[0]);
			//drawAble = MeshUtils.createPlane(10);
			var textureset:TextureSet = new TextureSet(bv.instance3Ds[0]);
			var bmd:BitmapData = new BitmapData(128, 128, true);
			bmd.perlinNoise(250, 250, 2, 1, true, true);
			textureset.setBmd(bmd,Context3DTextureFormat.BGRA);
			texture = textureset.texture;
			
			light = new BasicLight3D();
			//light.drawAble = drawAble;
			bv.instance3Ds[0].root.add(light);
			bv.instance3Ds[0].lights.push(light);
			light.x = 100;
			light.y = 50;
			light.z = -200;
			//light.material = new ColorMaterial(new Vector3D(Math.random() / 5, Math.random() / 5, Math.random() / 5, 1), new Vector3D(Math.random(), Math.random(), Math.random(), 1), new BasicLight3D());
			
			var c:Int = 50;
			while (c-->0) {
				addCube();
			}
			bv.instance3Ds[0].root.add(rnode);
			#if flash
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			#else
			bv.instance3Ds[0].c3d.setRenderCallback( enterFrameHandler);
			bv.instance3Ds[0].camera.frustumPlanes = null;
			#end
			bv.instance3Ds[0].camera.z = -1300;
		}
		
		public function enterFrameHandler( event : Event) : Void
		{
			label.text = rnode.children.length + " click";
			rnode.rotationX+=0.2;
			rnode.rotationZ += 0.22 ;
			//bv.instance3Ds[0].camera.z +=  Math.sin(count / 150) * 5;
			count++;
			bv.instance3Ds[0].render();
		}
		
		private function addCube() : Node3D
		{
			var node:Node3D = new Node3D();
			node.frustumCulling = null;
			node.drawAble = drawAble;
			node.radius = -drawAble.radius * .3;
			var d:Int = 600;
			node.setPosition(d * (Math.random() - .5), d * (Math.random() - .5),d * (Math.random() - .5));
			node.setRotation(360 * Math.random(), 360 * Math.random(), 360 * Math.random());
			node.setScale(2,2,2);
			rnode.add(node);
			var ml:BasicLight3D=light;
			if (light == null) {
				ml = new BasicLight3D();
			}
			node.material = new PhongMaterial(bv.instance3Ds[0], ml,
			new Vector3D(.2, .2, .2),//AmbientColor
			//null,
			new Vector3D(Math.random()/2+.5,Math.random()/2+.5,Math.random()/2+.5),//DiffuseColor
			new Vector3D(.8,.8,.8),//SpecularColor
			200,
			null
			//texture
			);
			
			return node;
		}
	}
//}