package lz.native3d.materials;
import hxsl.Shader;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class PhongShader extends Shader
{
	var SRC = { 
		var input: {
			gl_Vertex:Float3,
			gl_Normal:Float3,
		}
		
		var LightVec:Float3;
		var SurfaceNormal:Float3;
		var ReflectedLightVec:Float3;
		var ViewVec:Float3;
		
		function vertex(
			LightPosition:Float3,
			gl_ModelViewMatrix:M44,
			//gl_NormalMatrix:M44,
			gl_ProjectionMatrix:M44
		){
			var eyespacePos   = (input.gl_Vertex*gl_ModelViewMatrix).xyz;

			var surfaceNormal      = normalize(input.gl_Normal * gl_ModelViewMatrix/*gl_NormalMatrix*/);
			SurfaceNormal = surfaceNormal;
			var lightVec           = normalize(LightPosition - eyespacePos);
			LightVec = lightVec;
			ViewVec            = normalize(-eyespacePos);
			ReflectedLightVec  = normalize(2* dot(lightVec, surfaceNormal)* surfaceNormal-lightVec);
			out = input.gl_Vertex.xyzw*gl_ModelViewMatrix*gl_ProjectionMatrix;
		}
		
		function fragment(
			AmbientColor:Float3,
			DiffuseColor:Float3,
			SpecularColor:Float3,
			SpecularExponent:Float
		){
			// Ambient
			var color:Float3 = AmbientColor;

			// Diffuse
			color += DiffuseColor * max(0, dot(LightVec, SurfaceNormal));

			// Specular
			color += SpecularColor * pow(max(0, dot(ReflectedLightVec, ViewVec)), SpecularExponent);

			var colorT:Float4 = [1,1,1,1];
			colorT.xyz = color.xyz;
			out = colorT;
		}
	};
	public function new() 
	{
		super();
	}	
}