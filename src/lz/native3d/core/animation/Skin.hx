package lz.native3d.core.animation;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.utils.ByteArray;
import flash.Vector;
import lz.native3d.core.ByteArraySet;
import lz.native3d.core.Node3D;
import lz.native3d.core.TextureSet;
import lz.native3d.core.VertexBufferSet;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class Skin
{
	public var jointNames:Array<String>;
	public var joints:Vector<Node3D>;
	public var vin:Vector<Float>;
	public var vout:Vector<Float>;
	public var bindShapeMatrix:Matrix3D;
	public var invBindMatrixs:Vector<Matrix3D>;
	public var vcount:Vector<#if flash UInt #else Int #end>;
	public var v:Vector<#if flash UInt #else Int #end>;
	public var weights:Vector<Float>;
	public var node:Node3D;
	
	public var cacheMatrixs:Vector<Vector<Matrix3D>>;
	public var frame:Int;
	public var numFrame:Int;
	
	public var daeIndexs:Vector<Vector<Int>>;
	public var daeUVIndexs:Vector<Vector<Int>>;
	public var daeXyz:Vector<Float>;
	public var daeUV:Vector<Float>;
	
	public var draws:Vector<SkinDrawAble>;
	
	public var texture:TextureSet;
	public function new() 
	{
		
	}
	
	public function doSkin(frame:Int):Void {
		this.frame = frame;
		return;
		var matrixs:Vector<Matrix3D> = cacheMatrixs[frame];
		if(vin==null){
			vin = new Vector<Float>(#if flash node.drawAble.xyz.data.length #end);
			bindShapeMatrix.transformVectors(node.drawAble.xyz.data, vin);
			vout = new Vector<Float>(#if flash vin.length #end);
		}else {
			//return;
		}
		
		#if flash
		vout.length = 0;
		vout.length = vin.length;
		#end 
		
		var j:#if flash UInt #else Int #end = 0;
		var len2:#if flash UInt #else Int #end;
		var pos = new Vector3D();
		for (i in 0...vcount.length) {
			var ix:Int = i * 3;
			var iy:Int = ix + 1;
			var iz:Int = iy + 1;
			pos.x = vin[ix];
			pos.y = vin[iy];
			pos.z = vin[iz];
			len2 = vcount[i] * 2 + j;
			while(j < len2 ) {
				var m = matrixs[v[j]];
				var w = weights[v[j + 1]];
				var pos2 = m.transformVector(pos);
				vout[ix] += pos2.x * w;
				vout[iy] += pos2.y * w;
				vout[iz] += pos2.z * w;
				j += 2;
			}
		}
		node.drawAble.xyz.vertexBuff.uploadFromVector(vout, 0, untyped(vout.length / 3));
	}
	
}