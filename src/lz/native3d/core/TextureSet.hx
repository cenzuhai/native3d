package lz.native3d.core ;
//{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.CubeTexture;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	class TextureSet 
	{
		public var texture:TextureBase;
		public var version:Int = -1;
		public var changed:Bool = false;
		private var _bmd:BitmapData;
		private var ttexture:Texture;
		
		private static var tempTexture:TextureBase;
		public var i3d:Instance3D;
		public var width:Int;
		public var height:Int;
		public function new(i3d:Instance3D) 
		{
			this.i3d = i3d;
		}
		
		/*public function get bmd():BitmapData 
		{
			return _bmd;
		}*/
		
		public function setBmd(bmd:BitmapData,format:Context3DTextureFormat, optimizeForRenderToTexture:Bool=false, streamingLevels:Int=0):Void 
		{
			if (bmd == null) return;
			if (texture!=null) texture.dispose();
			var w:Int = 2048;
			var h:Int = 2048;
			for (i in 0...12 ) {
				var pow:Int = Std.int(Math.pow(2, i));
				if (pow>=bmd.width) {
					w = pow;
					width = w;
					break;
				}
			}
			for (i in 0...12 ) {
				var pow:Int = Std.int(Math.pow(2, i));
				if (pow>=bmd.height) {
					h = pow;
					height = h;
					break;
				}
			}
			
			texture = i3d.c3d.createTexture(w, h, Context3DTextureFormat.BGRA, false);
			ttexture = cast( texture,Texture);
			
			var level 		: Int 			= 0;
			var size		: Int 			= w > h ? w : h;
			var _bitmapData:BitmapData = new BitmapData(size, size, bmd.transparent, 0);
			_bitmapData.draw(bmd , new Matrix(size / bmd.width, 0, 0, size / bmd.height), null, null, null, true);
			var transform 	: Matrix 		= new Matrix();
			var tmp 		: BitmapData 	= new BitmapData(
				size,
				size,
				bmd.transparent,
				0
			);
			
			while (size >= 1)
			{
				tmp.draw(_bitmapData, transform, null, null, null, true);
				ttexture.uploadFromBitmapData(tmp, level);
				
				transform.scale(.5, .5);
				level++;
				size >>= 1;
				if (tmp.transparent)
					tmp.fillRect(tmp.rect, 0);
			}
			tmp.dispose();
			
			
			_bmd = bmd;
			changed = true;
		}
		
		public function createCubeTextureBy6Bitmap( _bitmapDatas:Array<BitmapData>) : Void {
			var _size:#if flash UInt #else Int #end = _bitmapDatas[0].width;
			var context3D:Context3D = i3d.c3d;
			var _resource:CubeTexture = context3D.createCubeTexture(_size, Context3DTextureFormat.BGRA, true);
			
			for ( side in 0...6)
			{
				var mipmapId	: #if flash UInt #else Int #end			= 0;
				var mySize		: #if flash UInt #else Int #end			= _size;
				var bitmapData	: BitmapData	= _bitmapDatas[side];
				
				while (mySize >= 1)
				{
					var tmpBitmapData	: BitmapData	= new BitmapData(mySize, mySize, bitmapData.transparent, 0x005500);
					var tmpMatrix		: Matrix		= new Matrix();
					
					tmpMatrix.a		= mySize / bitmapData.width;
					tmpMatrix.d		= mySize / bitmapData.height;
					
					tmpBitmapData.draw(bitmapData, tmpMatrix);
					_resource.uploadFromBitmapData(tmpBitmapData, side, mipmapId);
					
					++mipmapId;
					mySize = untyped(mySize/2);
				}
			}
			texture = _resource;
		}
		
		
		public static function getTempTexture(i3d:Instance3D):TextureBase {
			if (tempTexture == null) {
				var bmd:BitmapData = new BitmapData(128, 128, false);
				bmd.perlinNoise(100, 100, 3, 1, true, true);
				var tb:TextureSet = new TextureSet(i3d);
				tb.setBmd(bmd, Context3DTextureFormat.BGRA);
				tempTexture = tb.texture;
			}
			return tempTexture;
		}
	}

//}