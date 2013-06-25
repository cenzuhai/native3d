package ;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Vector3D;
import flash.Lib;
import flash.utils.ByteArray;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.Entry;
import haxe.zip.Reader;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicView;
import lz.native3d.core.Node3D;
import lz.native3d.ctrls.FirstPersonCtrl;
import lz.native3d.materials.ColorMaterial;
import lz.native3d.materials.SkinMaterial;
import lz.native3d.parsers.AbsParser;
import lz.native3d.parsers.BSP30Parser;
import lz.native3d.parsers.ColladaParser;
import lz.native3d.parsers.ObjParser;
import lz.net.LoaderBat;
import net.hires.debug.Stats;
import nochump.util.zip.Inflater;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class Sponza extends Sprite
{
	private var bv:BasicView;
	private var parser:ObjParser;
	private var node:Node3D;
	public function new() 
	{
		super();
		bv = new BasicView(400, 400, true);
		addChild(bv);
		bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, bv_context3dCreate);
		addChild(new Stats());
	}
	
	private function bv_context3dCreate(e:Event):Void 
	{
		parser = new ObjParser(null,"sponza.mtl","../assets/model/sponza_texture");
		parser.addEventListener(Event.COMPLETE, parser_complete);
		parser.fromUrlZip("../assets/model/sponza_obj.zip","sponza.obj");
		addEventListener(Event.ENTER_FRAME, enterFrame);
		bv.instance3Ds[0].camera.frustumPlanes = null;
		new FirstPersonCtrl(stage, bv.instance3Ds[0].camera);
	}
	
	private function parser_complete(e:Event):Void 
	{
		bv.instance3Ds[0].root.add(parser.node);
		node = parser.node;
	}
	
	private function enterFrame(e:Event):Void 
	{
		bv.instance3Ds[0].render();
	}
	public static function main() {
		Lib.current.addChild(new Sponza());
	}
	
}