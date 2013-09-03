package ;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.ByteArray;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.Entry;
import haxe.zip.Reader;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicView;
import lz.native3d.core.Node3D;
import lz.native3d.materials.SkinMaterial;
import lz.native3d.parsers.AbsParser;
import lz.native3d.parsers.ColladaParser;
import lz.net.LoaderBat;
import net.hires.debug.Stats;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class SkeletonAnimationExample extends Sprite
{
	private var bv:BasicView;
	private var light:BasicLight3D;
	private var node:Node3D;
	private var parser:ColladaParser;
	private var rootNode:Node3D;
	private var label:TextField;
	public function new() 
	{
		super();
		bv = new BasicView(400,400,true);
		addChild(bv);
		bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, bv_context3dCreate);
	}
	
	private function bv_context3dCreate(e:Event):Void 
	{
		rootNode = new Node3D();
		bv.instance3Ds[0].root.add(rootNode);
		addChild(new Stats());
		bv.instance3Ds[0].camera.z = -50;
		bv.instance3Ds[0].camera.frustumPlanes = null;
		parser = new ColladaParser(null);
		parser.addEventListener(Event.COMPLETE, parser_complete);
		parser.fromUrlZip("../assets/model/astroBoy_walk_Max.zip", "astroBoy_walk_Max.xml","boy_10.jpg");
		//parser.fromUrlZip("../assets/model/monster.zip", "monster.dae","monster.jpg");
		//parser.fromUrlZip("model/astroBoy_walk_Max.zip", "astroBoy_walk_Max.xml","boy_10.jpg");
		addEventListener(Event.ENTER_FRAME, enterFrame);
		
	}
	
	private function parser_complete(e:Event):Void 
	{
		label = new TextField();
		label.autoSize =  TextFieldAutoSize.LEFT;
		label.textColor = 0xffffff;
		label.x = 200;
		label.defaultTextFormat = new TextFormat(null, 40);
		label.text = "click";
		label.selectable = false;
		label.addEventListener(MouseEvent.CLICK, label_click);
		addChild(label);
		
		label_click(null);
	}
	
	private function label_click(e:MouseEvent):Void 
	{
		var c:Int = 20;
		for (x in 0...c ) {
			for(y in 0...c){
				var clone:Node3D = parser.node.clone();
				clone.frustumCulling = null;
				var d:Int = 60;
				clone.setPosition(d * (x/c-.5), d * (y/c - .5), 0/*d * (.5 - Math.random())*/);
				//clone.setRotation(360 * Math.random(), 360 * Math.random(), 360 * Math.random());
				rootNode.add(clone);
			}
		}
		label.text = rootNode.children.length + " click";
	}
	
	private function enterFrame(e:Event):Void 
	{
		rootNode.rotationX += .2;
		rootNode.rotationY += .4;
		bv.instance3Ds[0].render();
	}
	public static function main() {
		Lib.current.addChild(new SkeletonAnimationExample());
	}
	
}