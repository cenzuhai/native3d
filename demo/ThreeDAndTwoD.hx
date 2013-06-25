package ;
//{
	import flash.display.BitmapData;
	import flash.display.Sprite;
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
	import lz.native3d.core.Camera3D;
	import lz.native3d.core.DrawAble3D;
	import lz.native3d.core.Instance3D;
	import lz.native3d.core.Node3D;
	import lz.native3d.core.TextureSet;
	import lz.native3d.meshs.MeshUtils;
	#if flash
	import net.hires.debug.Stats;
	import lz.native3d.materials.ColorMaterial;
	import lz.native3d.materials.DisMaterial;
	import lz.native3d.materials.ImageMaterial;
	#else
	
	import lz.native3d.materials.NmeTestMaterial;
	#end
	

	 class ThreeDAndTwoD extends Sprite
	{
		
		public static function main() {
			Lib.current.addChild( new ThreeDAndTwoD());
		}
		
		private var bv:BasicView;
		private var rnode:Node3D;
		private var drawAble:DrawAble3D;
		private var texture:TextureBase;
		private var light:BasicLight3D;
		private var count:Int = 0;
		
		private var label:TextField;
		
		public var i3d:Instance3D;
		public var i2d:Instance3D;
		public function new()
		{
			super();
			rnode = new Node3D();
			bv = new BasicView(200, 200, false, 2);
			i3d = bv.instance3Ds[0];
			if (bv.numInstance3d == 2) {
				i2d = bv.instance3Ds[1];
			}
			addChild(bv);
			bv.instance3Ds[1].addEventListener(Event.CONTEXT3D_CREATE, initializeScene);
			#if flash
			//addChild(new Stats());
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
			if (i2d.c3d != null && i3d.c3d != null) {
				
				drawAble = MeshUtils.createCube(5,i3d);
				//drawAble = MeshUtils.createTeaPot();
				//drawAble = MeshUtils.createPlane(10);
				var textureset:TextureSet = new TextureSet(i2d);
				var bmd:BitmapData = new BitmapData(128, 128, true);
				bmd.perlinNoise(50, 50, 2, 1, true, true);
				textureset.setBmd(bmd,Context3DTextureFormat.BGRA);
				texture = textureset.texture;
				
				light = new BasicLight3D();
				i3d.root.add(light);
				i3d.lights.push(light);
				light.x = 100;
				light.y = 50;
				
				var c:Int = 500;
				while (c-->0) {
					addCube();
				}
				i3d.root.add(rnode);
				#if flash
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				#else
				nme.display3D.Context3DUtils.setRenderCallback(i3d.c3d, enterFrameHandler);
				i3d.camera.frustumPlanes = null;
				i3d.c3d.setBlendFactors
				#end
				i3d.camera.z = -1300;
				
				var n2d:Node3D = new Node3D();
				n2d.drawAble = MeshUtils.createCube(10,i2d);
				n2d.material = new ImageMaterial(texture,Std.random(0xffffff), Std.random(0xffffff),light,i2d);
				i2d.root.add(n2d);
				i2d.camera.z = -200;
				n2d.frustumCulling = null;
				i2d.camera = new Camera3D(200, 200, i2d, false);
			}
		}
		
		public function enterFrameHandler(#if flash event : Event #end) : Void
		{
			//3d
			if (i3d.c3d != null) {
				i3d.c3d.enableErrorChecking = true;
				label.text = rnode.children.length + " click";
				rnode.rotationX+=0.2;
				rnode.rotationZ += 0.22 ;
				i3d.camera.z +=  Math.sin(count / 150) * 5;
				count++;
				i3d.render();
				bv.stage.stage3Ds[0].x = 0;
				bv.stage.stage3Ds[0].y = 0;
			}
			
			//2d
			if (i2d!=null&&i2d.c3d!=null) {
				i2d.c3d.enableErrorChecking = true;
				bv.stage.stage3Ds[1].x = 100;
				bv.stage.stage3Ds[1].y = 0;
				i2d.render();
			}
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
			//node.setScale(3.3, 3.3, 3.3);
			rnode.add(node);
			var ml:BasicLight3D=light;
			if (light == null) {
				ml = new BasicLight3D();
			}
			
			#if flash
			node.material =
			new ColorMaterial(Std.random(0xffffff), Std.random(0xffffff), ml);
			#else
			node.material = new NmeTestMaterial(Std.random(0xffffff),0,light);
			node.material.init(node);
			#end
			
			return node;
		}
	}
//}