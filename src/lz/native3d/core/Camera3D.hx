package lz.native3d.core;
//{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.Vector;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	 class Camera3D extends Node3D
	{
		private var _fieldOfViewY:Float;
		private var _aspectRatio:Float;
		private var _zNear:Float=1;
		private var _zFar:Float=400000;
		public var invert:Matrix3D;// = new Matrix3D();
		public var perspectiveProjection:Matrix3D;// = new Matrix3D();
		
		public var viewMatrix:Matrix3D;// = new Matrix3D();
		public var perspectiveProjectionMatirx:Matrix3D;// = new Matrix3D();
		public var invertVersion:Int = -212;
		public var frustumPlanes:Vector<Vector3D>;
		
		public var is2d:Bool = false;
		public var i3d:Instance3D;
		public function new(width:Int,height:Int,i3d:Instance3D,is2d:Bool=false) 
		{
			super();
			this.i3d = i3d;
			this.is2d = is2d;
			invert = new Matrix3D();
			perspectiveProjection = new Matrix3D();
			viewMatrix = new Matrix3D();
			perspectiveProjectionMatirx = new Matrix3D();
			add(new Node3D());
			
			if (is2d) {
				_zNear = 0;
				orthoLH(width, height, _zNear, _zFar);
			}else {
				_zNear = 1;
				perspectiveFieldOfViewLH(Math.PI / 4, width/height, _zNear, _zFar);
			}
			
			
			parent = new Node3D();
			#if flash
			frustumPlanes = Vector.ofArray([new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D()]);
			#else
			frustumPlanes = [new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D()];
			#end
		}
		public function perspectiveFieldOfViewLH(fieldOfViewY:Float, 
												 aspectRatio:Float, 
												 zNear:Float, 
												 zFar:Float):Void {
			_zFar = zFar;
			_zNear = zNear;
			_aspectRatio = aspectRatio;
			_fieldOfViewY = fieldOfViewY;
			var yScale:Float = 1.0/Math.tan(fieldOfViewY/2.0);
			var xScale:Float = yScale / aspectRatio; 
			var vs:Vector<Float> = new Vector<Float>(#if flash 16 #end);
			vs[0] = xScale;
			vs[5] = yScale;
			vs[10] = zFar / ( zFar-zNear);
			//vs[10] = 1 / ( zFar-zNear);
			vs[11] = 1;
			vs[14] = (zNear * zFar) / (zNear - zFar);
			vs[15] = 0;
			
			#if flash
			perspectiveProjection.copyRawDataFrom(vs);
			#else
			perspectiveProjection.rawData = vs;
			#end
			
			invertVersion = -3;
			/*perspectiveProjection.copyRawDataFrom(Vector<Float>(
				xScale, 0.0, 0.0, 0.0,
				0.0, yScale, 0.0, 0.0,
				0.0, 0.0, , 1.0,
				0.0, 0.0, (zNear*zFar)/(zNear-zFar), 0.0
			));*/
		}
		
		public function orthoLH(width:Float, height:Float, zNear:Float, zFar:Float):Void {
			_zFar = zFar;
			_zNear = zNear;
			/*			perspectiveProjection.identity();
			perspectiveProjection.appendScale(scaleX, -scaleY, 1/10000000);*/
			perspectiveProjection.copyRawDataFrom(Vector.ofArray([
				2.0/width, 0.0, 0.0, 0.0,
				0.0, 2.0/height, 0.0, 0.0,
				0.0, 0.0, 1.0/(zFar-zNear), 0.0,
				0.0, 0.0, zNear/(zNear-zFar), 1.0
			]));
		}
		
		public function resize(width:Int, height:Int):Void {
			if (is2d) {
				orthoLH(i3d.width, i3d.height, _zNear, _zFar);
			}else {
				perspectiveFieldOfViewLH(Math.PI / 4, i3d.width/i3d.height, _zNear, _zFar);
			}
		}
		
		/*public function get fieldOfViewY():Float 
		{
			return _fieldOfViewY;
		}
		
		public function set fieldOfViewY(value:Float):Void 
		{
			_fieldOfViewY = value;
			perspectiveFieldOfViewLH(_fieldOfViewY,_aspectRatio,_zNear,_zFar);
		}
		
		public function get aspectRatio():Float 
		{
			return _aspectRatio;
		}
		
		public function set aspectRatio(value:Float):Void 
		{
			_aspectRatio = value;
			perspectiveFieldOfViewLH(_fieldOfViewY,_aspectRatio,_zNear,_zFar);
		}
		
		public function get zNear():Float 
		{
			return _zNear;
		}
		
		public function set zNear(value:Float):Void 
		{
			_zNear = value;
			perspectiveFieldOfViewLH(_fieldOfViewY,_aspectRatio,_zNear,_zFar);
		}
		
		public function get zFar():Float 
		{
			return _zFar;
		}
		
		public function set zFar(value:Float):Void 
		{
			_zFar = value;
			perspectiveFieldOfViewLH(_fieldOfViewY,_aspectRatio,_zNear,_zFar);
		}*/
		
		
		
		/**
		*   Get the distance between a point and a plane
		* http://jacksondunstan.com/articles/1811
		*   @param point Point to get the distance between
		*   @param plane Plane to get the distance between
		*   @return The distance between the given point and plane
		*/
		private inline static function pointPlaneDistance(point:Vector<Float>, plane:Vector3D): Float
		{
			// plane distance + (point [dot] plane)
			return (plane.w + (point[12]*plane.x + point[13]*plane.y + point[14]*plane.z));
		}
 
		/**
		*   Check if a point is in the viewing frustum
		* http://jacksondunstan.com/articles/1811
		*   @param point Point to check
		*   @return If the given point is in the viewing frustum
		*/
		public function isPointInFrustum(point:Vector<Float>,radius:Float):Bool
		{
			for (plane in frustumPlanes)
			{
				if (pointPlaneDistance(point, plane) < radius)
				{
					return false;
				}
			}
			return true;
		}
 
		/**
		*   Check if a sphere is in the viewing frustum
		* http://jacksondunstan.com/articles/1811
		*   @param sphere Sphere to check. XYZ are the center, W is the radius.
		*   @return If any part of the given sphere is in the viewing frustum
		*/
		/*public function isSphereInFrustum(sphere:Vector3D): Bool
		{
			// Test all extents of the sphere 
			var minusRadius:Float = -sphere.w;
			for  (plane in frustumPlanes)
			{
				if (pointPlaneDistance(sphere, plane) < minusRadius)
				{
					return false;
				}
			}
			return true;
		}*/
	}

//}