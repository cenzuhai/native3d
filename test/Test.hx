package ;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.utils.ByteArray;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.Json;
import haxe.zip.Entry;
import haxe.zip.Reader;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicView;
import lz.native3d.core.Node3D;
import lz.native3d.materials.ColorMaterial;
import lz.native3d.materials.SkinMaterial;
import lz.native3d.parsers.AbsParser;
import lz.native3d.parsers.BSP30Parser;
import lz.native3d.parsers.ColladaParser;
import lz.net.LoaderBat;
import net.hires.debug.Stats;
import nochump.util.zip.Inflater;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class Test extends Sprite
{
	private var bv:BasicView;
	private var parser:BSP30Parser;
	private var node:Node3D;
	public function new() 
	{
		super();
		bv = new BasicView(400, 400, false);
		addChild(bv);
		bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, bv_context3dCreate);
		addChild(new Stats());
	}
	
	private function bv_context3dCreate(e:Event):Void 
	{
		parser = new BSP30Parser(null);
		parser.addEventListener(Event.COMPLETE, parser_complete);
		parser.fromUrlZip("../assets/model/es_iceworld.zip", "es_iceworld.bsp");
		//rootNode.add(parser.node);
		addEventListener(Event.ENTER_FRAME, enterFrame);
		bv.instance3Ds[0].camera.z = -1500;
		
	}
	
	private function parser_complete(e:Event):Void 
	{
		node = new Node3D();
		node.drawAble = parser.drawAble;
		node.material = new ColorMaterial(Std.random(0xffffff), Std.random(0xffffff), new BasicLight3D());
		bv.instance3Ds[0].root.add(node);
	}
	
	private function enterFrame(e:Event):Void 
	{
		if (node!=null) {
			node.rotationX++;
			node.rotationY++;
		}
		bv.instance3Ds[0].render();
	}
	public static function main() {
		Lib.current.addChild(new Test());
	}
	
}