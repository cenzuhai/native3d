package lz.native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.geom.Vector3D;
import flash.Vector;
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
	private static var SHADER:PhongShader = new PhongShader();
	private static var PROGROM:Program3D; 
	private static var SHADER_INSTANCE;
	private var lightNode:BasicLight3D;
	public function new(i3d:Instance3D,lightNode:BasicLight3D,AmbientColor:Vector3D,DiffuseColor:Vector3D,SpecularColor:Vector3D,SpecularExponent:Float) 
	{
		super();
		if (PROGROM==null) {
			PROGROM = i3d.c3d.createProgram();
			SHADER_INSTANCE = SHADER.getInstance();
			PROGROM.upload(SHADER_INSTANCE.vertexBytes.getData(), SHADER_INSTANCE.fragmentBytes.getData());
		}
		vertex = SHADER_INSTANCE.vertexVars.toData().concat();
		fragment = SHADER_INSTANCE.fragmentVars.toData().concat();
		progrom = PROGROM;
		copyRawDataTo(fragment, AmbientColor, 0);
		copyRawDataTo(fragment, DiffuseColor, 4);
		copyRawDataTo(fragment, SpecularColor, 8);
		fragment[12] = SpecularExponent;
		this.lightNode = lightNode;
	}
	
	private function copyRawDataTo(vector:Vector<Float>, v3d:Vector3D, index:Int):Void {
		vector[index++] = v3d.x;
		vector[index++] = v3d.y;
		vector[index++] = v3d.z;
		vector[index++] = v3d.w;
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
		vertex[0] = lightNode.worldRawData[12];
		vertex[1] = lightNode.worldRawData[13];
		vertex[2] = lightNode.worldRawData[14];
		node.worldMatrix.copyRawDataTo(vertex, 4, true);
		pass.camera.perspectiveProjectionMatirx.copyRawDataTo(vertex, 20, true);
		c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, vertex);
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