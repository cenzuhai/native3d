package ;
//{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.Lib;
	import flash.Vector;
	import lz.native3d.core.BasicLight3D;
	import lz.native3d.core.BasicPass3D;
	import lz.native3d.core.BasicView;
	import lz.native3d.core.Camera3D;
	import lz.native3d.core.DrawAble3D;
	import lz.native3d.core.Node3D;
	import lz.native3d.core.PassTarget;
	import lz.native3d.core.TextureSet;
	import lz.native3d.materials.ColorMaterial;
	import lz.native3d.materials.DisMaterial;
	import lz.native3d.materials.ImageMaterial;
	import lz.native3d.materials.ShadowMaterial;
	import lz.native3d.meshs.MeshUtils;
	import lz.native3d.utils.Color;
	#if flash
	import net.hires.debug.Stats;
	#end
	

	 class ShadowMapExample extends Sprite
	{
		
		public static function main() {
			Lib.current.addChild( new ShadowMapExample());
		}
		
		private var bv:BasicView;
		private var rnode:Node3D;
		private var drawAble:DrawAble3D;
		private var texture:TextureBase;
		private var light:BasicLight3D;
		private var pass:BasicPass3D;
		public function new()
		{
			super();
			rnode = new Node3D();
			bv = new BasicView();
			addChild(bv);
			bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, initializeScene);
			#if flash
			addChild(new Stats());
			#end
		}
		
		public function initializeScene(e:Event) : Void
		{
			pass = new BasicPass3D(bv.instance3Ds[0]);
			pass.camera = new Camera3D(400,400,bv.instance3Ds[0]);
			pass.camera.perspectiveFieldOfViewLH(Math.PI /2, 1, 1, 40000000);
			pass.target = new PassTarget(512);
			bv.instance3Ds[0].passs.unshift(pass);
			
			drawAble = MeshUtils.createCube(.5,bv.instance3Ds[0]);
			var textureset:TextureSet = new TextureSet(bv.instance3Ds[0]);
			var bmd:BitmapData = new BitmapData(128, 128, true);
			bmd.perlinNoise(50, 50, 2, 1, true, true);
			textureset.setBmd(bmd, Context3DTextureFormat.BGRA);
			bmd.dispose();
			texture = textureset.texture;
			
			light = new BasicLight3D();
			pass.material = new DisMaterial(light);
			light.scaleZ = 30;
			bv.instance3Ds[0].root.add(light);
			bv.instance3Ds[0].lights.push(light);
		
			var c:Int = 20;
			while (c-->0) {
				addObj();
			}
			
			var planeDrawAble = MeshUtils.createPlane(30,bv.instance3Ds[0]);
			var plane = new Node3D();
			plane.rotationX = 80;
			plane.y = 0;
			plane.drawAble = planeDrawAble;
			plane.material = new ShadowMaterial(texture, Std.random(0xffffff),Std.random(0xffffff), light,pass);
			bv.instance3Ds[0].root.add(plane);
			
			bv.instance3Ds[0].root.add(rnode);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			bv.instance3Ds[0].camera.z = -100;
			
			//pass.target = null;
			//bv.instance3Ds[0].passs.pop();
			
		}
		
		public function enterFrameHandler(event : Event) : Void
		{
			
			//rnode.rotationX+=.1;
			//rnode.rotationY += .2;
			for (i in 0...rnode.children.length) {
				var node:Node3D = rnode.children[i];
				node.rotationY++;
			}
			
			//bv.instance3Ds[0].camera.rotationZ += .3;
			
			var a:Float = Lib.getTimer() / 1000;
			var d = 20;
			light.x = d*Math.sin(a);
			light.z = d * Math.cos(a);
			light.y = 1200;
			light.matrix.recompose(light.comps);
			light.matrixVersion = light.compsVersion;
			light.matrix.pointAt(new Vector3D(0,0,0),Vector3D.Z_AXIS,Vector3D.Y_AXIS);
			light.matrixVersion++;
			pass.camera.matrix.copyFrom(light.matrix);
			pass.camera.matrixVersion = light.matrixVersion;
			bv.instance3Ds[0].render();
		}
		
		private function addObj() : Node3D
		{
			var node:Node3D = new Node3D();
			node.drawAble = drawAble;
			var d:Int = 30;
			node.setPosition(d * (Math.random() - .5), d * (Math.random() - .5),d * (Math.random() - .5));
			node.setRotation(360 * Math.random(), 360 * Math.random(), 360 * Math.random());
			node.setScale(5, 5, 5);
			rnode.add(node);
			var ml:BasicLight3D=light;
			if (light == null) {
				ml = new BasicLight3D();
			}
			node.material =  new ShadowMaterial(texture, Std.random(0xffffff), Std.random(0xffffff), light,pass);
			//node.material = new DisMaterial(light); //new ShadowMaterial(pass.target.texture, new Vector3D(1, 1, 1, 1), new Vector3D(), light);
			return node;
		}
	}
//}