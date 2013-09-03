package lz.native3d.core ;
//{
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Vector3D;
	import flash.Vector;
	#if flash
	import lz.native3d.materials.MaterialBase;
	#end
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	 class BasicPass3D 
	{
		public var target:PassTarget;
		public var cnodes:Vector<Node3D>;
		public var camera:Camera3D;
		#if flash
		public var material:MaterialBase;
		#end
		public var i3d:Instance3D;
		public function new(i3d:Instance3D) 
		{
			this.i3d = i3d;
			camera = i3d.camera;
		}
		
		public function pass(nodes:Vector<Node3D>):Void {
			if (target!=null) {
				target.pass(this, nodes);
			}else{
				i3d.c3d.clear(0, 0, 0, 0);
				for(i in 0...nodes.length) {
					var node:Node3D = nodes[i];
					doPass(node);
				}
			}
			i3d.c3d.present();
		}
		
		inline public function doPass(node:Node3D):Void {
			#if flash
			var m = material;
			#else 
			var m = null;
			#end
			if (m == null) {
				m = node.material;
			}
			if (camera.frustumPlanes==null||node.frustumCulling == null || node.frustumCulling.culling(camera)) {
				m.draw(node,this);
			}
		}
	}

//}