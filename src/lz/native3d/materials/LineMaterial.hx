package lz.native3d.materials;

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.Vector;
import hxsl.Shader;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.VertexBufferSet;
import lz.native3d.utils.Color;
/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class LineMaterial extends MaterialBase
{
	private static var shader:LineShader = new LineShader();
	public function new(color:Int) 
	{
		super();
		if (shader.i == null) {
			shader.create(Instance3D.getInstance().c3d);
		}
		var c = Color.toRGBA(color);
		fragment = Vector.ofArray([c.x,c.y,c.z,c.w,.04,1,0,.5]);
		progrom = shader.i.program;
	}
	
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
		var c3d:Context3D = Instance3D.getInstance().c3d;
		Instance3D.getInstance().c3d.setDepthTest(true, passCompareMode);
		c3d.setBlendFactors(sourceFactor, destinationFactor);
		c3d.setProgram(progrom);
		var xyz:VertexBufferSet = node.drawAble.xyz;
		c3d.setVertexBufferAt(0, xyz.vertexBuff, 0, xyz.format);
		var edge:VertexBufferSet = node.drawAble.edge;
		c3d.setVertexBufferAt(1, edge.vertexBuff, 0, edge.format);
		c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, node.worldMatrix, true);
		c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, pass.camera.perspectiveProjectionMatirx, true);
		c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fragment);
		c3d.drawTriangles(node.drawAble.indexBufferSet.indexBuff);
		c3d.setVertexBufferAt(0,null, 0, xyz.format);
		c3d.setVertexBufferAt(1,null, 0, edge.format);
	}
	override public function init(node:Node3D):Void {
		node.drawAble.xyz.init();
		node.drawAble.edge.init();
		node.drawAble.indexBufferSet.init();
	}
	
}

class LineShader extends Shader {
	var SRC = {
		var input: {
			pos:Float3,
			edge:Float2,
		};
			var t:Float2;
			function vertex(mpos : M44, mproj : M44) {
				var wpos = input.pos.xyzw * mpos;
				out = wpos * mproj;
				t = input.edge;
				
			}
			function fragment(color:Float4, edgeV:Float4) {
				var out2 = edgeV.yy - t;
				out2 = min(out2,t);
				out2 = gt(out2, edgeV.zz) * lt(out2, edgeV.xx);
				kill(out2.x+out2.y-edgeV.w);
				out = color;
			}
		
	};
	
		public var i:ShaderInstance;
		public  function create(c:Context3D) {
			i = getInstance();
			i.program = c.createProgram();
			i.program.upload(i.vertexBytes.getData(), i.fragmentBytes.getData());
		}
		
}