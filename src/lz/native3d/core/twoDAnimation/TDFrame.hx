package lz.native3d.core.twoDAnimation ;
//{
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.Vector;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	 class TDFrame 
	{
		public var matrix:Matrix3D;
		public var size:Point;
		public var offset:Point;
		public var uv:Vector<Float>;
		public function new() 
		{
			size =  new Point();
			offset = new Point();
		}
		
	}

//}