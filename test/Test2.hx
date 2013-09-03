package ;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import lz.native3d.materials.PhongMaterial;
import lz.native3d.materials.PhongShader;

/**
 * ...
 * @author lizhi
 */
class Test2
{

	public function new() 
	{
		
	}
	
	public static function main() {
		var shader = new PhongShader();
		shader.gl_ModelViewMatrix = new Matrix3D();
		var shaderInstance = shader.getInstance();
		trace(shaderInstance);
		trace(shaderInstance.vertexMap);
		trace(shaderInstance.fragmentMap);
		//var material = new PhongMaterial(null,null,null,null,null,0);
	}
}