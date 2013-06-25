package lz.native3d.core ;
//{
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;
	import flash.Vector;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	 class PassTarget 
	{
		public var texture:TextureBase;
		public var enableDepthAndStencil:Bool = true;
		public var antiAlias:Int = 0;
		public var surfaceSelector:Int = 0; 
		public var colorOutputIndex:Int = 0;
		private var _clear:Bool = true;
		public var size:Int;
		public var i3dIndex:Int = 0;
		public function new(size:Int) 
		{
			this.size = size;
			texture = Instance3D.getInstance(i3dIndex).c3d.createTexture(size, size, Context3DTextureFormat.BGRA, true);
		}
		public function pass(pass:BasicPass3D, nodes:Vector<Node3D>):Void {
			pass.i3d.c3d.setRenderToTexture(texture, enableDepthAndStencil, antiAlias, surfaceSelector);
			pass.i3d.c3d.clear(0,0,0,0);
			for (node in nodes) {
				pass.doPass(node);
			}
		}
		
		/*public function get clear():Bool 
		{
			return _clear;
		}*/
		
		public function clear(value:Bool):Void 
		{
			_clear = value;
			if (!value) {
				Instance3D.getInstance().c3d.setRenderToTexture(texture, enableDepthAndStencil, antiAlias, surfaceSelector);
				Instance3D.getInstance().c3d.clear(0,0,0,0);
			}
		}
		
	}

//}