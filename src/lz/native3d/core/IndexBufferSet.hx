package lz.native3d.core ;
//{
	import flash.display3D.IndexBuffer3D;
	import flash.Vector;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	class IndexBufferSet 
	{
		public var num:Int;
		private var start:Int;
		public var data:Vector<#if flash UInt #else Int #end>;
		public var indexBuff:IndexBuffer3D;
		public var i3d:Instance3D;
		
		public function new(num:Int,data:Vector<#if flash UInt #else Int #end>,start:Int,i3d:Instance3D) 
		{
			this.start = start;
			this.num = num;
			this.data = data;
			this.i3d = i3d;
		}
		public function init():Void {
			if(indexBuff==null){
			indexBuff = i3d.c3d.createIndexBuffer(num);
			upload();
			}
		}
		
		public function upload():Void {
			indexBuff.uploadFromVector(data, start, num);
		}
	}

//}