package lz.native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
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
import flash.display3D.Context3DCompareMode;

private class IShader extends Shader {
	static var SRC = {
		var input : {
			pos : Float3,
			offset : Float2,
			scale : Float,
			color : Float4,
			uv:Float2,
		};
			var diffuse:Float4;
			var tuv:Float2;
		function vertex( mpos : M44, invert:M44, mproj : M44) {
			var wpos = input.pos.xyzw*mpos*invert;
			wpos.xy += (input.offset.xy)*input.scale;
			out = wpos * mproj;
			diffuse = input.color;
			tuv = input.uv;
		}
		function fragment(tex:Texture) {
			out = tex.get(tuv)*diffuse;
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
class ParticleMaterial extends MaterialBase
{
	private static var shader:IShader = new IShader();
	private var texture:TextureBase;
	public function new(texture:TextureBase) 
	{
		super();
		
		sourceFactor = Context3DBlendFactor.SOURCE_ALPHA;
		destinationFactor = Context3DBlendFactor.ONE;
		passCompareMode = Context3DCompareMode.ALWAYS;
		
		this.texture = texture;
		if (shader.i == null) {
			shader.create(Instance3D.getInstance().c3d);
		}
		progrom = shader.i.program;
	}
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
			var c3d = Instance3D.getInstance().c3d;
			
			Instance3D.getInstance().c3d.setDepthTest(true, passCompareMode);
			c3d.setBlendFactors(sourceFactor, destinationFactor);
			c3d.setProgram(progrom);
			var xyz = node.drawAble.xyz;
			c3d.setVertexBufferAt(0, xyz.vertexBuff, 0, xyz.format);
			var offset = node.drawAble.offset;
			c3d.setVertexBufferAt(1, offset.vertexBuff, 0, offset.format);
			var scale = node.drawAble.scale;
			c3d.setVertexBufferAt(2, scale.vertexBuff, 0, scale.format);
			var color = node.drawAble.color;
			c3d.setVertexBufferAt(3, color.vertexBuff, 0, color.format);
			var uv = node.drawAble.uv;
			c3d.setVertexBufferAt(4, uv.vertexBuff, 0, uv.format);
			c3d.setTextureAt(0, texture);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, node.worldMatrix, true);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, pass.camera.invert, true);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 8, pass.camera.perspectiveProjection, true);
			c3d.drawTriangles(node.drawAble.indexBufferSet.indexBuff);
			c3d.setVertexBufferAt(0,null, 0, xyz.format);
			c3d.setVertexBufferAt(1,null, 0, offset.format);
			c3d.setVertexBufferAt(2,null, 0, scale.format);
			c3d.setVertexBufferAt(3, null, 0, color.format);
			c3d.setVertexBufferAt(4, null, 0, uv.format);
			c3d.setTextureAt(0, null);
		}
		override public function init(node:Node3D):Void {
			node.drawAble.xyz.init();
			node.drawAble.uv.init();
			node.drawAble.offset.init();
			node.drawAble.scale.init();
			node.drawAble.color.init();
			node.drawAble.indexBufferSet.init();
		}
}