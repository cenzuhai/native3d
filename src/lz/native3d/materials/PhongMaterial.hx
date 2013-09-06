#if flash
package lz.native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.display3D.textures.TextureBase;
import flash.errors.Error;
import flash.geom.Vector3D;
import flash.Vector;
import hxsl.Shader.ShaderInstance;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.VertexBufferSet;

/**
 * ...
 * @author lizhi
 */
class PhongMaterial extends MaterialBase
{
	private var shader:PhongShader;
	private var lightNode:BasicLight3D;
	private var diffuseTex:TextureBase;
	private var shaderInstance:ShaderInstance;
	public function new(i3d:Instance3D,lightNode:BasicLight3D,AmbientColor:Vector3D,DiffuseColor:Vector3D,SpecularColor:Vector3D,SpecularExponent:Float,diffuseTex:TextureBase) 
	{
		super();
		shader = new PhongShader();
		shader.AmbientColor = AmbientColor;
		shader.DiffuseColor = DiffuseColor;
		shader.SpecularColor = SpecularColor;
		shader.SpecularExponent = SpecularExponent;
		shader.LightPosition = lightNode.position;
		this.diffuseTex = diffuseTex;
		shader.DiffuseTex = diffuseTex;
		shader.hasDiffuseTex = diffuseTex != null;
		shaderInstance = shader.getInstance();
		if (shaderInstance.program==null) {
			shaderInstance.program = i3d.c3d.createProgram();
			shaderInstance.program.upload(shaderInstance.vertexBytes.getData(), shaderInstance.fragmentBytes.getData());
		}
		vertex = shaderInstance.vertexVars.toData().concat();
		fragment = shaderInstance.fragmentVars.toData().concat();
		progrom = shaderInstance.program;
		this.lightNode = lightNode;
	}
	
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
		var c3d:Context3D = pass.i3d.c3d;
		c3d.setDepthTest(true, passCompareMode);
		c3d.setBlendFactors(sourceFactor, destinationFactor);
		c3d.setProgram(progrom);
		var xyz:VertexBufferSet = node.drawAble.xyz;
		c3d.setVertexBufferAt(0, xyz.vertexBuff, 0, xyz.format);
		var norm:VertexBufferSet=null;
		if (shader.DiffuseColor != null || shader.SpecularColor != null) {
			norm = node.drawAble.norm;
			c3d.setVertexBufferAt(1, norm.vertexBuff, 0, norm.format);
			vertex[32] = lightNode.worldRawData[12];
			vertex[33] = lightNode.worldRawData[13];
			vertex[34] = lightNode.worldRawData[14];
		}
		var uv:VertexBufferSet=null;
		if(diffuseTex!=null){
			uv= node.drawAble.uv;
			c3d.setVertexBufferAt(2, uv.vertexBuff, 0, uv.format);
		}
		node.worldMatrix.copyRawDataTo(vertex, 0, true);
		pass.camera.perspectiveProjectionMatirx.copyRawDataTo(vertex, 16, true);
		c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, vertex);
		c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fragment);
		for (i in 0...shaderInstance.textures.length) {
			c3d.setTextureAt(i, shaderInstance.textures[i]);
		}
		c3d.drawTriangles(node.drawAble.indexBufferSet.indexBuff);
		c3d.setVertexBufferAt(0,null, 0, xyz.format);
		if(norm!=null)c3d.setVertexBufferAt(1, null, 0, norm.format);
		if(uv!=null)c3d.setVertexBufferAt(2, null, 0, uv.format);
		for (i in 0...shaderInstance.textures.length) {
			c3d.setTextureAt(i, null);
		}
	}
	override public function init(node:Node3D):Void {
		node.drawAble.xyz.init();
		if(shader.DiffuseColor!=null||shader.SpecularColor!=null)
		node.drawAble.norm.init();
		if(diffuseTex!=null)
		node.drawAble.uv.init();
		node.drawAble.indexBufferSet.init();
	}
}
#else
package lz.native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.display3D.textures.TextureBase;
import flash.geom.Vector3D;
import flash.Vector;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.VertexBufferSet;
import flash.display3D.shaders.glsl.GLSLProgram;
import flash.display3D.shaders.glsl.GLSLFragmentShader;
import flash.display3D.shaders.glsl.GLSLVertexShader;
import openfl.gl.GL;
class PhongMaterial extends MaterialBase
{
	static var glslProgram :GLSLProgram;
	private var lightNode:BasicLight3D;
	private var LightPositionV:Vector<Float>;
	private var AmbientColorV:Vector<Float>;
	private var DiffuseColorV:Vector<Float>;
	private var SpecularColorV:Vector<Float>;
	private var SpecularExponentV:Vector<Float>;
	public function new(i3d:Instance3D,lightNode:BasicLight3D,AmbientColor:Vector3D,DiffuseColor:Vector3D,SpecularColor:Vector3D,SpecularExponent:Float,diffuseTex:TextureBase) 
	{
		super();
		createProgram();
		this.lightNode = lightNode;
		LightPositionV = Vector.ofArray([0.0,0,0,0]);
		AmbientColorV = Vector.ofArray([AmbientColor.x,AmbientColor.y,AmbientColor.z,AmbientColor.w]);
		DiffuseColorV = Vector.ofArray([DiffuseColor.x,DiffuseColor.y,DiffuseColor.z,DiffuseColor.w]);
		SpecularColorV = Vector.ofArray([SpecularColor.x,SpecularColor.y,SpecularColor.z,SpecularColor.w]);
		SpecularExponentV = Vector.ofArray([SpecularExponent, 0, 0, 0]);
		
		AmbientColorV[0] = Math.random();
		AmbientColorV[1] = Math.random();
		AmbientColorV[2] = Math.random();
		AmbientColorV[3] = 1;
	}
	
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
		var c3d = pass.i3d.c3d;
		glslProgram.attach();
		glslProgram.setVertexUniformFromMatrix("mpos", node.worldMatrix, true);
		glslProgram.setVertexUniformFromMatrix("mproj", pass.camera.perspectiveProjectionMatirx, true);
		glslProgram.setVertexBufferAt("pos", node.drawAble.xyz.vertexBuff, 0, flash.display3D.Context3DVertexBufferFormat.FLOAT_3);
		//glslProgram.setVertexBufferAt("norm", node.drawAble.norm.vertexBuff, 0, flash.display3D.Context3DVertexBufferFormat.FLOAT_3);
		//LightPositionV[0] = lightNode.worldRawData[12];
		//LightPositionV[1] =lightNode.worldRawData[13];
		//LightPositionV[2] = lightNode.worldRawData[14];
		//glslProgram.setVertexUniformFromVector("lightPosition", LightPositionV);
		//glslProgram.setFragmentUniformFromVector("ambientColor", AmbientColorV);
		//glslProgram.setFragmentUniformFromVector("diffuseColor",DiffuseColorV );
		//glslProgram.setFragmentUniformFromVector("specularColor", SpecularColorV);
		//glslProgram.setFragmentUniformFromVector("specularExponent",SpecularExponentV );
		glslProgram.setFragmentUniformFromVector("color",AmbientColorV );
		c3d.drawTriangles(node.drawAble.indexBufferSet.indexBuff);
	}
	private function createProgram ():Void {
		 if (glslProgram!=null) {
			 return;
		 }
        glslProgram = new GLSLProgram(Instance3D.getInstance().c3d);
        var vertexShaderSource =
       "
	   attribute vec3 pos;
	   //attribute vec3 norm;
	   //uniform vec3 lightPosition;

		//varying vec3 LightVec;
		//varying vec3 SurfaceNormal;
		//varying vec3 ReflectedLightVec;
		//varying vec3 ViewVec;

		uniform mat4 mproj;
        uniform mat4 mpos;
		void main()
		{
			//vec3 eyespacePos   = (mpos * vec4(pos,1)).xyz;

			//SurfaceNormal      = normalize((mpos * vec4(norm,1)).xyz);
			//LightVec           = normalize(lightPosition - eyespacePos);
			//ViewVec            = normalize(-eyespacePos);
			//ReflectedLightVec  = normalize(-reflect(SurfaceNormal, LightVec));

			vec4 wpos = mpos * vec4(pos, 1);
            gl_Position = mproj * wpos;
		}";
        var vertexShader = new GLSLVertexShader(vertexShaderSource);
		
        var fragmentShaderSource =
        "
		uniform vec4 color;
		//uniform vec3 ambientColor;
		//uniform vec3 diffuseColor;
		//uniform vec3 specularColor;
		//uniform float specularExponent;

		//varying vec3 LightVec;
		//varying vec3 SurfaceNormal;
		//varying vec3 ReflectedLightVec;
		//varying vec3 ViewVec;

		void main()
		{
			//vec3 color = ambientColor;
			//color += diffuseColor * max(0, dot(LightVec, SurfaceNormal));
			//color += specularColor * pow(max(0, dot(ReflectedLightVec, ViewVec)), specularExponent);
			gl_FragColor = color;
		}";
        var fragmentShader = new GLSLFragmentShader(fragmentShaderSource);
        glslProgram.upload(vertexShader, fragmentShader);
    }
	override public function init(node:Node3D):Void {
		node.drawAble.xyz.init();
		node.drawAble.norm.init();
		node.drawAble.indexBufferSet.init();
	}
}
#end