package lz.native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.geom.Vector3D;
import flash.Vector;
import hxsl.Shader;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.VertexBufferSet;
import lz.native3d.utils.Color;

private class IShader extends Shader {
	static var SRC = {
		var input : {
			pos : Float3,
			norm:Float3,
		};
			var tl:Float;
		function vertex( mpos : M44, mproj : M44, lightPos:Float4) {
			var wpos = input.pos.xyzw * mpos;
			out = wpos * mproj;
			var nnorm = normalize(input.norm * mpos);
			tl = sat(nnorm.dot(normalize(lightPos.xyz - wpos.xyz)));
		}
		function fragment(diffuse:Float4,ambient:Float4) {
			out = diffuse+ambient*tl;
		}
	};
	public var i:ShaderInstance;
	public function create(c:Context3D) {
		i = getInstance();
		i.program = c.createProgram();
		i.program.upload(i.vertexBytes.getData(), i.fragmentBytes.getData());
	}
}
/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class ColorMaterial extends MaterialBase
{
	private static var shader:IShader = new IShader();
	private var lightNode:BasicLight3D;
	public function new(diffuse:Int,ambient:Int,lightNode:BasicLight3D) 
	{
		super();
		this.lightNode = lightNode;
		if (shader.i == null) {
			shader.create(Instance3D.getInstance().c3d);
		}
		var dc = Color.toRGBA(diffuse);
		var ac = Color.toRGBA(ambient);
		fragment = Vector.ofArray([dc.x, dc.y, dc.z, dc.w, ac.x, ac.y, ac.z, ac.w]);
		vertex = new Vector<Float>(#if flash 4 #end);
		progrom = shader.i.program;
	}
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
			var c3d:Context3D = pass.i3d.c3d;
			
			c3d.setDepthTest(true, passCompareMode);
			c3d.setBlendFactors(sourceFactor, destinationFactor);
			c3d.setProgram(progrom);
			var xyz:VertexBufferSet = node.drawAble.xyz;
			c3d.setVertexBufferAt(0, xyz.vertexBuff, 0, xyz.format);
			var norm:VertexBufferSet = node.drawAble.norm;
			c3d.setVertexBufferAt(1, norm.vertexBuff, 0, norm.format);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, node.worldMatrix, true);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, pass.camera.perspectiveProjectionMatirx, true);
			vertex[0] = lightNode.worldRawData[12];
			vertex[1] = lightNode.worldRawData[13];
			vertex[2] = lightNode.worldRawData[14];
			c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 8, vertex);
			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fragment);
			c3d.drawTriangles(node.drawAble.indexBufferSet.indexBuff);
			c3d.setVertexBufferAt(0,null, 0, xyz.format);
			c3d.setVertexBufferAt(1,null, 0, norm.format);
		}
		override public function init(node:Node3D):Void {
			node.drawAble.xyz.init();
			node.drawAble.norm.init();
			node.drawAble.indexBufferSet.init();
		}
}