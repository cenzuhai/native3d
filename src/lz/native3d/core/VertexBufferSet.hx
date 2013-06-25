package lz.native3d.core ;
//{
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.Vector;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	class VertexBufferSet 
	{
		private var start:Int;
		public var num:Int;
		public var data32PerVertex:Int;
		public var data:Vector<Float>;
		public var vertexBuff:VertexBuffer3D;
		public var format:Context3DVertexBufferFormat ;//= "float4";
		public var i3d:Instance3D;
		public function new(num:Int, data32PerVertex:Int,data:Vector<Float>,start:Int,i3d:Instance3D) 
		{
			this.num = num;
			this.start = start;
			this.format = Context3DVertexBufferFormat.createByName("FLOAT_"+data32PerVertex,null);
			this.data = data;
			this.data32PerVertex = data32PerVertex;
			this.i3d = i3d;
		}
		
		public function init():Void {
			if (vertexBuff==null){
			vertexBuff = i3d.c3d.createVertexBuffer(num, data32PerVertex);
			upload();
			}
		}
		
		public function upload():Void {
			vertexBuff.uploadFromVector(data, start, num);
		}
		
	}

//}