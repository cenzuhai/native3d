package ;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display3D.Context3DTextureFormat;
import flash.events.Event;
import flash.geom.Vector3D;
import flash.Lib;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicView;
import lz.native3d.core.DrawAble3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.TextureSet;
import lz.native3d.materials.ImageMaterial;
import lz.native3d.materials.SkyboxMaterial;
import lz.native3d.meshs.MeshUtils;
import net.hires.debug.Stats;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class SkyboxExample extends Sprite
{
	private var bv:BasicView;
	public function new() 
	{
		super();
		bv = new BasicView(400, 400, true);
		addChild(bv);
		bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, initializeScene);
		addChild(new Stats());
	}
	public function initializeScene(e:Event) : Void
	{
		var drawAble:DrawAble3D = MeshUtils.createCube(2000,bv.instance3Ds[0],true);
		var textureset:TextureSet = new TextureSet(bv.instance3Ds[0]);
		textureset.createCubeTextureBy6Bitmap([new PX(0,0),new NX(0,0),new PY(0,0),new NY(0,0),new PZ(0,0),new NZ(0,0)]);
		var skybox:Node3D = new Node3D();
		skybox.frustumCulling = null;
		bv.instance3Ds[0].root.add(skybox);
		skybox.drawAble = drawAble;
		skybox.material = new SkyboxMaterial(textureset.texture);
		
		addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}
	
	public function enterFrameHandler(event : Event) : Void
	{
		bv.instance3Ds[0].camera.rotationX+=0.2;
		bv.instance3Ds[0].camera.rotationZ += 0.22 ;
		bv.instance3Ds[0].render();
	}
	
	public static function main() {
		Lib.current.addChild( new SkyboxExample());
	}
	
}

@:bitmap("assets/skybox/px.jpg")private class PX extends BitmapData { }
@:bitmap("assets/skybox/nx.jpg")private class NX extends BitmapData { }
@:bitmap("assets/skybox/py.jpg")private class PY extends BitmapData { }
@:bitmap("assets/skybox/ny.jpg")private class NY extends BitmapData { }
@:bitmap("assets/skybox/pz.jpg")private class PZ extends BitmapData { }
@:bitmap("assets/skybox/nz.jpg")private class NZ extends BitmapData { }