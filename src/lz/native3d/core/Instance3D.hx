package lz.native3d.core ;
//{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.Vector;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	class Instance3D extends EventDispatcher
	{
		public static var _instances:Vector<Instance3D>=new Vector<Instance3D>();
		public var c3d:Context3D;
		
		public var root:Node3D;// = new Node3D();
		public var camera:Camera3D;// = new Camera3D();
		public var doTransform:BasicDoTransform3D;// = new BasicDoTransform3D();
		public var passs:Vector<BasicPass3D>;// = new Vector<BasicPass3D>();
		public var lights:Vector<BasicLight3D>;
		public var width:Int=400;
		public var height:Int = 400;
		#if flash
		public var culling:Context3DTriangleFace;
		#else
		public var culling:Int;
		#end
		public function new() 
		{
			super();	
			culling = Context3DTriangleFace.FRONT;
			root = new Node3D();
			camera = new Camera3D(width,height,this);
			 doTransform = new BasicDoTransform3D();
			 passs = new Vector<BasicPass3D>();
			 lights = new Vector<BasicLight3D>();
		}
		 static public function getInstance(i:Int=0):Instance3D
		{
			return _instances[i];
		}
		
		public function init(c3d:Context3D):Void {
			this.c3d = c3d;
			passs.push(new BasicPass3D(this));
			//root.add(camera);
			//c3d.configureBackBuffer(400, 400, 0);
			resize(width, height);
			c3d.setCulling(culling);
			dispatchEvent(new Event(Event.CONTEXT3D_CREATE));
		}
		
		public function render():Void {
			var nodes:Vector<Node3D> = doTransform.doTransform(root.children);
			//for (light in lights) {
				//light.wpos = light.worldMatrix.position;
			//}
			for (i in 0...passs.length) {
				var pass:BasicPass3D = passs[i];
				if (pass.camera!=null) doTransform.doTransformCamera(pass.camera);
				pass.pass(pass.cnodes!=null?doTransform.doTransform(pass.cnodes):nodes);
			}
		}
		
		public function resize(width:Int, height:Int):Void {
			this.width = width;
			this.height = height;
			if (c3d!=null) {
				c3d.configureBackBuffer(width, height, 0);
				
				for (i in 0...passs.length) {
					var pass:BasicPass3D = passs[i];
					if (pass.camera != null) {
						pass.camera.resize(width, height);
					}
				}
				camera.resize(width, height);
			}
		}
		
	}

//}