package lz.native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.textures.Texture;
import flash.display3D.textures.TextureBase;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.utils.ByteArray;
import flash.Vector;
import hxsl.Shader;
import lz.native3d.core.animation.Skin;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.ByteArraySet;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.VertexBufferSet;
import lz.native3d.utils.Color;

private class IShader extends Shader {
	static var SRC = {
		var input : {
			pos : Float3,
			norm:Float3,
			weight:Float3,
			matrixIndex:Float4,
			uv:Float2
		};
		var tl:Float;
		var tuv:Float2;
		function vertex(fs:Float4<117>, mpos : M44, mproj : M44, lightPos:Float4) {
			var wpos = input.pos.xyzw;
			var t = input.matrixIndex.x;
			wpos.x = dp4(input.pos.xyzw, fs[input.matrixIndex.x]);
			t += lightPos.w;
			wpos.y = dp4(input.pos.xyzw, fs[t]);
			t += lightPos.w;
			wpos.z = dp4(input.pos.xyzw, fs[t]);
			wpos.w = input.pos.w;
			var wpos2 = wpos*input.weight.x;
			
			t = input.matrixIndex.y;
			wpos.x = dp4(input.pos.xyzw, fs[t]);
			t += lightPos.w;
			wpos.y = dp4(input.pos.xyzw, fs[t]);
			t += lightPos.w;
			wpos.z = dp4(input.pos.xyzw, fs[t]) ;
			wpos.w = input.pos.w;
			wpos2 += wpos * input.weight.y;
			
			t = input.matrixIndex.z;
			wpos.x = dp4(input.pos.xyzw, fs[t]);
			t += lightPos.w;
			wpos.y = dp4(input.pos.xyzw, fs[t]);
			t += lightPos.w;
			wpos.z = dp4(input.pos.xyzw, fs[t]) ;
			wpos.w = input.pos.w;
			wpos2 += wpos * input.weight.z;
			
			out = wpos2 * mpos * mproj;
			var nnorm = normalize(input.norm * mpos);
			tl = sat(nnorm.dot(normalize(lightPos.xyz - wpos.xyz)));
			
			tuv = input.uv;
		}
		function fragment(tex:Texture,diffuse:Float4,ambient:Float4) {
			out = tex.get(tuv.xy)*(diffuse+ambient*tl);
			//out  = tuv.xyxy * tl;// diffuse * tuv.xyxy * ambient * tl;
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
 * ...max skeleton num 29
 * @author lizhi http://matrix3d.github.io/
 */
class SkinMaterial extends MaterialBase
{
	private static var shader:IShader = new IShader();
	public var lightNode:BasicLight3D;
	public var skin:Skin;
	public function new(skin:Skin,diffuse:Int,ambient:Int,lightNode:BasicLight3D) 
	{
		super();
		this.skin = skin;
		this.lightNode = lightNode;
		shader.create(Instance3D.getInstance().c3d);
		var dc = Color.toRGBA(diffuse);
		var ac = Color.toRGBA(ambient);
		fragment = Vector.ofArray([dc.x, dc.y, dc.z, dc.w, ac.x, ac.y, ac.z, ac.w]);
		vertex = new Vector<Float>(4, true);
		vertex[3] = 1;
		progrom = shader.i.program;
	}
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
		var c3d:Context3D = Instance3D.getInstance().c3d;
		Instance3D.getInstance().c3d.setDepthTest(true, passCompareMode);
		c3d.setBlendFactors(sourceFactor, destinationFactor);
		c3d.setProgram(progrom);
		
		c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 117, node.worldMatrix, true);
		c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 121, pass.camera.perspectiveProjectionMatirx, true);
		vertex[0] = lightNode.worldRawData[12];
		vertex[1] = lightNode.worldRawData[13];
		vertex[2] = lightNode.worldRawData[14];
		c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 125, vertex);
		c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fragment);
		node.frame = node.frame % skin.numFrame;
		var xyz:VertexBufferSet = null;
		var uv:VertexBufferSet = null;
		c3d.setTextureAt(0, skin.texture.texture);
		for(drawAble in skin.draws){
			xyz = drawAble.xyz;
			c3d.setVertexBufferAt(0, xyz.vertexBuff, 0, xyz.format);
			var norm:VertexBufferSet = drawAble.norm;
			c3d.setVertexBufferAt(1, norm.vertexBuff, 0, norm.format);
			c3d.setVertexBufferAt(2, drawAble.weightBuff.vertexBuff, 0, drawAble.weightBuff.format);
			c3d.setVertexBufferAt(3, drawAble.matrixBuff.vertexBuff, 0, drawAble.matrixBuff.format);
			uv = drawAble.uv;
			c3d.setVertexBufferAt(4, uv.vertexBuff, 0, uv.format);
			
			var byteSet:ByteArraySet = drawAble.cacheBytes[node.frame];
			c3d.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, 0,byteSet.numRegisters,byteSet.data,0);
			c3d.drawTriangles(drawAble.indexBufferSet.indexBuff);
		}
		node.frame++;
		c3d.setVertexBufferAt(0,null, 0, xyz.format);
		c3d.setVertexBufferAt(1, null, 0, xyz.format);
		c3d.setVertexBufferAt(2, null, 0, xyz.format);
		c3d.setVertexBufferAt(3, null, 0, xyz.format);
		c3d.setVertexBufferAt(4, null, 0, uv.format);
		c3d.setTextureAt(0, null);
	}
	override public function init(node:Node3D):Void {
		//if(node.drawAble.xyz!=null)node.drawAble.xyz.init();
		//if(node.drawAble.norm!=null)node.drawAble.norm.init();
		//if(node.drawAble.indexBufferSet!=null)node.drawAble.indexBufferSet.init();
	}
}