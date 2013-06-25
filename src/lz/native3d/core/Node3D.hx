package lz.native3d.core ;

	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.Lib;
	import flash.Vector;
	import lz.native3d.core.animation.Skin;
	#if flash
	import lz.native3d.materials.MaterialBase;
	import lz.native3d.materials.SkinMaterial;
	#else
	import lz.native3d.materials.NmeTestMaterial;
	#end
	import lz.native3d.utils.Color;
	//import lz.native3d.ns.native3d;
	//use namespace native3d;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	 class Node3D 
	{
		public static inline var NODE_TYPE:String = "NODE";
		public static inline var JOINT_TYPE:String = "JOINT";
		public var name:String;
		public var type:String;
		
		private static var ID:Int = 0;
		public static var NODES:Map<Int,Node3D> = new Map<Int,Node3D>();
		private static var toAngle:Float =  180 / Math.PI;
		private static var toRadian:Float =  Math.PI / 180;
		
		public var id:Int;
		public var idVector:Vector<Float>;
		public var parent:Node3D;
		public var children:Vector<Node3D>;// = new Vector<Node3D>();
		public var skin:Skin;//皮肤
		public var frame:Int;
		//native3d var compChanged:Bool = false;
		//public var matrixChanged:Bool = false;
		public var matrix:Matrix3D ;//= new Matrix3D();
		
		/**@private**/
		public var matrixVersion:Int = -1;
		/**@private**/
		public var comps:Vector<Vector3D>;
		/**@private**/
		public var compsVersion:Int = -1;
		/**@private**/
		public var position:Vector3D;// = comps[0];
		/**@private**/
		public var rotation:Vector3D;// = comps[1];
		/**@private**/
		public var scale:Vector3D;// = comps[2];
		
		public var worldMatrix:Matrix3D;// = new Matrix3D();
		public var worldRawData:Vector<Float>;
		/**@private**/
		public var worldVersion:Int = -123;
		public var drawAble:DrawAble3D;
		
		#if flash
		private var _material:MaterialBase;
		public var material(get_material, set_material):MaterialBase;
		#else
		public var material:NmeTestMaterial;
		#end
		
		/**@getter,setter**/
		#if swc @:extern #end public var x(get_x,set_x):Float;
		#if swc @:extern #end public var y(get_y,set_y):Float;
		#if swc @:extern #end public var z(get_z,set_z):Float;
		 #if swc @:extern #end public var rotationX(get_rotationX,set_rotationX):Float;
		#if swc @:extern #end public var rotationY(get_rotationY,set_rotationY):Float;
		#if swc @:extern #end public var rotationZ(get_rotationZ,set_rotationZ):Float;
		#if swc @:extern #end public var scaleX(get_scaleX,set_scaleX):Float;
		#if swc @:extern #end public var scaleY(get_scaleY,set_scaleY):Float;
		#if swc @:extern #end public var scaleZ(get_scaleZ,set_scaleZ):Float;
		 public var frustumCulling:FrustumCulling;
		 
		 /**
		  * 摄像机裁剪需要的半径 填负数，因为动态计算矩阵 会造成不必要的性能消耗，所以这里用折中的办法，手动填写，参看TeapotsExample.hx
		  */
		 public var radius:Float = 0;
		 
		 public var twoDData:TwoDData;
		
		public function new() 
	{
		frame =  Std.random(100000);
		//super();
		id =++ID;
		NODES.set(id, this);
		var rgba = Color.toRGBA(id);
		idVector = new Vector<Float>(#if flash 4 #end);
		idVector[0] = rgba.x;
		idVector[1] = rgba.y;
		idVector[2] = rgba.z;
		idVector[3] = rgba.w;
		children = new Vector<Node3D>();
		matrix = new Matrix3D();
		comps = matrix.decompose();
		position = comps[0];
		rotation = comps[1];
		scale = comps[2];
		worldMatrix = new Matrix3D();
		worldRawData = worldMatrix.rawData;
		frustumCulling = new FrustumCulling();
		frustumCulling.node = this;
	}
		public function add(node:Node3D):Void
		{
			if (node.parent!=null) {
				node.parent.remove(node);
			}
			children.push(node);
			node.parent = this;
		}
		
		public function remove(node:Node3D):Void {
			node.parent = null;
			for (i in 0...children.length) {
				if (children[i]==node) {
					children.splice(i, 1);
					break;
				}
			}
			/*var i = children.indexOf(node);
			if (i!=-1) {
				children.splice(i, 1);
			}*/
		}
		
		#if swc @:getter(x) #end inline private function get_x():Float 
		{
			decompose();
			return position.x;
		}
		#if swc @:setter(x) #end inline private function set_x(value:Float):Float 
		{
			compsVersion++;
			//compChanged = true;
			return position.x = value;
		}
		
		#if swc @:getter(y) #end inline private function get_y():Float 
		{
			decompose();
			return position.y;
		}
		
		#if swc @:setter(y) #end inline private function set_y(value:Float):Float 
		{
			
			compsVersion++;
			return position.y = value;
		}
		
		#if swc @:getter(z) #end inline private function get_z():Float 
		{
			decompose();
			return position.z;
		}
		
		#if swc @:setter(z) #end inline private function set_z(value:Float):Float 
		{
			
			compsVersion++;
			return position.z = value;
		}
		
		#if swc @:getter(rotationX) #end inline private function get_rotationX():Float 
		{
			decompose();
			return rotation.x*toAngle;
		}
		
		#if swc @:setter(rotationX) #end inline private function set_rotationX(value:Float):Float 
		{
			
			compsVersion++;
			return rotation.x = value * toRadian;
		}
		
		#if swc @:getter(rotationY) #end inline private function get_rotationY():Float 
		{
			decompose();
			return rotation.y*toAngle;
		}
		
		#if swc @:setter(rotationY) #end inline private function set_rotationY(value:Float):Float 
		{
			
			compsVersion++;
			return rotation.y = value * toRadian;
		}
		
		#if swc @:getter(rotationZ) #end inline private function get_rotationZ():Float 
		{
			decompose();
			return rotation.z*toAngle;
		}
		
		#if swc @:setter(rotationZ) #end inline private function set_rotationZ(value:Float):Float 
		{
			
			compsVersion++;
			return rotation.z = value * toRadian;
		}
		
		#if swc @:getter(scaleX) #end inline private function get_scaleX():Float 
		{
			decompose();
			return scale.x;
		}
		
		#if swc @:setter(scaleX) #end inline private function set_scaleX(value:Float):Float 
		{
			
			compsVersion++;
			return scale.x = value;
		}
		
		#if swc @:getter(scaleY) #end inline private function get_scaleY():Float 
		{
			decompose();
			return scale.y;
		}
		
		#if swc @:setter(scaleY) #end inline private function set_scaleY(value:Float):Float 
		{
			
			compsVersion++;
			return scale.y = value;
		}
		
		#if swc @:getter(scaleZ) #end inline private function get_scaleZ():Float 
		{
			decompose();
			return scale.z;
		}
		
		#if swc @:setter(scaleZ) #end inline private function set_scaleZ(value:Float):Float 
		{
			
			compsVersion++;
			return scale.z = value;
		}
		
		#if flash
		private function get_material():MaterialBase 
		{
			return _material;
		}
		
		private function set_material(value:MaterialBase):MaterialBase 
		{
			_material = value;
			if(value!=null)
			value.init(this);
			return _material;
		}
		#end
		
		inline public function setPosition(x:Float, y:Float, z:Float):Void {
			this.x = x;
			this.y = y;
			this.z = z;
		}
		inline public function setRotation(x:Float, y:Float, z:Float):Void {
			rotationX = x;
			rotationY = y;
			rotationZ = z;
		}
		inline public function setScale(x:Float, y:Float, z:Float):Void {
			scaleX = x;
			scaleY = y;
			scaleZ = z;
		}
		
		inline public function decompose():Void {
			if(compsVersion<matrixVersion){
				var comps = matrix.decompose();
				position.copyFrom(comps[0]);
				rotation.copyFrom(comps[1]);
				scale.copyFrom(comps[2]);
				compsVersion = matrixVersion;
			}
		}
		
		public function clone():Node3D {
			var node:Node3D = new Node3D();
			node.matrix = matrix.clone();
			node.matrixVersion = matrixVersion;
			node.compsVersion = compsVersion;
			node.position.copyFrom(position);
			node.rotation.copyFrom(rotation);
			node.scale.copyFrom(scale);
			
			#if flash
			node.worldMatrix.copyFrom(worldMatrix);
			#else
			node.worldMatrix.rawData = worldMatrix.rawData.copy();
			#end
			
			node.worldVersion = worldVersion;
			node.drawAble = drawAble;
			
			#if flash
			if (Std.is(material,SkinMaterial)) {
				var m:SkinMaterial = cast(material, SkinMaterial);
				var m2:SkinMaterial = new SkinMaterial(m.skin, Std.random(0xffffff), Std.random(0xffffff), m.lightNode);
				node.material = m2;
			}else {
				node.material = material;
			}
			#end
			
			for (child in children) {
				if (child.type != JOINT_TYPE) {
					node.add(child.clone());
				}
			}
			return node;
		}
		
	}

