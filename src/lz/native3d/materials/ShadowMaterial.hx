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
import lz.native3d.core.Camera3D;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.VertexBufferSet;
import lz.native3d.utils.Color;

private class IShader extends Shader {
	//http://www.cnblogs.com/cxrs/archive/2009/10/17/1585038.html
	static var SRC = {
		var input : {
			pos : Float3,
			uv:Float2,
			norm:Float3,
		};
			var tuv:Float2;
			var mlight:Float4;
			var tl:Float;
		function vertex( mpos : M44, mproj : M44,lightCamProj:M44 ,lightPos:Float4,temp:Float4) {
			var wpos = input.pos.xyzw * mpos;
			out = wpos * mproj;
			
			var tlight = wpos * lightCamProj;
			tlight.xy=tlight.xy / tlight.ww * temp.xy + temp.xx;
			mlight = tlight;
			
			tuv = input.uv;
			var nnorm = normalize(input.norm * mpos);
			tl = sat(nnorm.dot(normalize(lightPos.xyz - wpos.xyz)));
		}
		function fragment( tex:Texture, lightTex:Texture, diffuse:Float4, ambient:Float4,bitSh:Float4) {
			var c = lightTex.get(mlight.xy);
			
			var la = lte(mlight.z / mlight.w,dot(bitSh,c) );
			var tv = diffuse + ambient * tl*la;
			out = tex.get(tuv)*tv;
		}
		function lerp( x : Float, y : Float, v : Float ) {
			return x * (1 - v) + y * v;
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
class ShadowMaterial extends MaterialBase
{
	private static var shader:IShader = new IShader();
	public var texture:TextureBase;
	private var lightNode:BasicLight3D;
	private var lightPass:BasicPass3D;
	public function new(texture:TextureBase,diffuse:#if flash UInt #else Int #end,ambient:#if flash UInt #else Int #end,lightNode:BasicLight3D,lightPass:BasicPass3D) 
	{
		super();
		this.lightNode = lightNode;
		this.lightPass = lightPass;
		if (shader.i == null) {
			shader.create(Instance3D.getInstance().c3d);
		}
		this.texture = texture;
		
			var dc = Color.toRGBA(diffuse);
			var ac = Color.toRGBA(ambient);
			fragment = Vector.ofArray([dc.x, dc.y, dc.z, dc.w, ac.x, ac.y, ac.z, ac.w]);
		fragment = Vector.ofArray([dc.x, dc.y, dc.z, dc.w, ac.x, ac.y, ac.z, ac.w,1. / (256. * 256. * 256.), 1. / (256. * 256.), 1. / 256., 1.]);
		vertex = new Vector<Float>(8, true);
		vertex[3] = 1;
		vertex[4] =  0.5;
		vertex[5] =  -0.5;
		progrom = shader.i.program;
	}
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
			var c3d:Context3D = Instance3D.getInstance().c3d;
			
			Instance3D.getInstance().c3d.setDepthTest(true, passCompareMode);
			c3d.setBlendFactors(sourceFactor, destinationFactor);
			c3d.setProgram(progrom);
			var xyz:VertexBufferSet = node.drawAble.xyz;
			c3d.setVertexBufferAt(0, xyz.vertexBuff, 0, xyz.format);
			var norm:VertexBufferSet = node.drawAble.norm;
			c3d.setVertexBufferAt(2, norm.vertexBuff, 0, norm.format);
			var uv:VertexBufferSet = node.drawAble.uv;
			c3d.setVertexBufferAt(1, uv.vertexBuff, 0, uv.format);
			c3d.setTextureAt(0, texture);
			c3d.setTextureAt(1, lightPass.target.texture);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, node.worldMatrix, true);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, pass.camera.perspectiveProjectionMatirx, true);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 8, lightPass.camera.perspectiveProjectionMatirx, true);
			vertex[0] = lightNode.worldRawData[12];
			vertex[1] = lightNode.worldRawData[13];
			vertex[2] = lightNode.worldRawData[14];
			c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 12, vertex);
			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fragment);
			c3d.drawTriangles(node.drawAble.indexBufferSet.indexBuff);
			c3d.setVertexBufferAt(0,null, 0, xyz.format);
			c3d.setVertexBufferAt(1, null, 0, uv.format);
			c3d.setVertexBufferAt(2, null, 0, uv.format);
			c3d.setTextureAt(0, null);
			c3d.setTextureAt(1, null);
		}
		override public function init(node:Node3D):Void {
			node.drawAble.xyz.init();
			node.drawAble.uv.init();
			node.drawAble.norm.init();
			node.drawAble.indexBufferSet.init();
		}
}