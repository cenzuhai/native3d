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

private class IShader extends Shader {
	static var SRC = {
		var input : {
			pos : Float3,
		};
		function vertex( mpos : M44, mproj : M44) {
			out = input.pos.xyzw*mpos* mproj;
		}
		function fragment(ids:Float4) {
			out = ids;
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
class IDMaterial extends MaterialBase
{
	private static var shader:IShader = new IShader();
	public function new() 
	{
		super();
		if (shader.i == null) {
			shader.create(Instance3D.getInstance().c3d);
		}
		//fragment = new Vector<Float>(4,true);
		progrom = shader.i.program;
	}
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
			var c3d:Context3D = Instance3D.getInstance().c3d;
			
			Instance3D.getInstance().c3d.setDepthTest(true, passCompareMode);
			c3d.setBlendFactors(sourceFactor, destinationFactor);
			c3d.setProgram(progrom);
			var xyz:VertexBufferSet = node.drawAble.xyz;
			c3d.setVertexBufferAt(0, xyz.vertexBuff, 0, xyz.format);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, node.worldMatrix, true);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, pass.camera.perspectiveProjectionMatirx, true);
			//c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 8, vertex);
			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, node.idVector);
			c3d.drawTriangles(node.drawAble.indexBufferSet.indexBuff);
			c3d.setVertexBufferAt(0,null, 0, xyz.format);
		}
		override public function init(node:Node3D):Void {
			node.drawAble.xyz.init();
			node.drawAble.indexBufferSet.init();
		}
}