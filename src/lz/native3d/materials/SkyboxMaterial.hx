package lz.native3d.materials;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.textures.TextureBase;
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
			uv:Float2,
			norm:Float3,
		};
			var dir:Float3;
		function vertex( mpos : M44, mproj : M44, cameraPos:Float4) {
			var wpos = input.pos.xyzw * mpos;
			out = wpos * mproj;
			dir = wpos.xyz - cameraPos.xyz;
		}
		function fragment( tex:CubeTexture) {
			out = tex.get(dir);
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
class SkyboxMaterial extends MaterialBase
{
	private static var shader:IShader = new IShader();
	public var texture:TextureBase;
	public function new(texture:TextureBase) 
	{
		super();
		if (shader.i == null) {
			shader.create(Instance3D.getInstance().c3d);
		}
		this.texture = texture;
		vertex = new Vector<Float>(4,true);
		progrom = shader.i.program;
	}
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
			var c3d:Context3D = Instance3D.getInstance().c3d;
			
			Instance3D.getInstance().c3d.setDepthTest(true, passCompareMode);
			c3d.setBlendFactors(sourceFactor, destinationFactor);
			c3d.setProgram(progrom);
			var xyz:VertexBufferSet = node.drawAble.xyz;
			c3d.setVertexBufferAt(0, xyz.vertexBuff, 0, xyz.format);
			c3d.setTextureAt(0, texture);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, node.worldMatrix, true);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, pass.camera.perspectiveProjectionMatirx, true);
			vertex[0] = pass.camera.worldRawData[12];
			vertex[1] = pass.camera.worldRawData[13];
			vertex[2] = pass.camera.worldRawData[14];
			c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 8, vertex);
			c3d.drawTriangles(node.drawAble.indexBufferSet.indexBuff);
			c3d.setVertexBufferAt(0,null, 0, xyz.format);
			c3d.setTextureAt(0, null);
		}
		override public function init(node:Node3D):Void {
			node.drawAble.xyz.init();
			node.drawAble.indexBufferSet.init();
		}
}