package lz.native3d.materials;
import flash.geom.Matrix3D;
import flash.Vector;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.utils.Color;
import flash.display3D.Context3DProgramType;
//import flash.display3D.shaders.glsl.GLSLFragmentShader;
//import openfl.display3D.shaders.glsl.GLSLProgram;
//import flash.display3D.shaders.glsl.GLSLVertexShader;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class NmeTestMaterial
{

	static var glslProgram :GLSLProgram;
	 private var lightNode:BasicLight3D;
	 var fragment:Vector<Float>;
	 var vertex:Vector<Float>;
	public function new(diffuse:Int,ambient:Int,lightNode:BasicLight3D) 
	{
		this.lightNode = lightNode;
		var dc = Color.toRGBA(diffuse);
		var ac = Color.toRGBA(ambient);
		fragment = #if flash Vector.ofArray( #end [dc.x, dc.y, dc.z, dc.w] #if flash ) #end ;
		vertex = new Vector<Float>(#if flash 4 #end);
		vertex[3] = 1;
		createProgram();
	}
	public function draw(node:Node3D, pass:BasicPass3D):Void { 
		var c3d = Instance3D.getInstance().c3d;
		glslProgram.attach();
		glslProgram.setVertexUniformFromMatrix("mpos", node.worldMatrix, true);
		glslProgram.setVertexUniformFromMatrix("mproj", pass.camera.perspectiveProjectionMatirx, true);
		glslProgram.setVertexBufferAt("pos", node.drawAble.xyz.vertexBuff, 0, flash.display3D.Context3DVertexBufferFormat.FLOAT_3);
		//glslProgram.setVertexBufferAt("norm", node.drawAble.norm.vertexBuff, 0, nme.display3D.Context3DVertexBufferFormat.FLOAT_3);
		//vertex[0] = lightNode.worldRawData[12];
		//vertex[1] = lightNode.worldRawData[13];
		//vertex[2] = lightNode.worldRawData[14];
		glslProgram.fragmentShader.setUniformFromVector(c3d, "color", fragment);
	//	glslProgram.vertexShader.setUniformFromVector(c3d, "lightPos", vertex);
		c3d.drawTriangles(node.drawAble.indexBufferSet.indexBuff);
	}
	
	 private function createProgram ():Void {
		 if (glslProgram!=null) {
			 return;
		 }
        glslProgram = new GLSLProgram(Instance3D.getInstance().c3d);
        var vertexShaderSource =
        "attribute vec3 pos;
		//attribute vec3 norm;
        uniform mat4 mproj;
        uniform mat4 mpos;
        //uniform vec4 lightPos;
		//varying float tl;
        void main(void) {
			vec4 wpos = mpos * vec4(pos, 1);
            gl_Position = mproj * wpos;
			//vec4 nnorm = normalize(mpos * vec4(norm,1));
			//tl = dot(nnorm.xyz, normalize(wpos.xyz - lightPos.xyz));
			//if (tl>1) {
			//	tl = 1;
			//}
        }";
        var vertexShader = new GLSLVertexShader(vertexShaderSource);
		
        var fragmentShaderSource =
        "uniform vec4 color;
		//varying float tl;
		void main(void) {
        gl_FragColor = color;
        }";
        var fragmentShader = new GLSLFragmentShader(fragmentShaderSource);
        glslProgram.upload(vertexShader, fragmentShader);
    }
	public function init(node:Node3D):Void {
		node.drawAble.xyz.init();
		//node.drawAble.norm.init();
		node.drawAble.indexBufferSet.init();
	}
}