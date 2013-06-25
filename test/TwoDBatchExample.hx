package ;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display3D.Context3DTextureFormat;
import flash.events.Event;
import flash.geom.Point;
import flash.Lib;
import lz.native3d.core.BasicView;
import lz.native3d.core.Camera3D;
import lz.native3d.core.DrawAble3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.TextureSet;
import lz.native3d.core.twoDAnimation.TDSpriteData;
import lz.native3d.core.TwoDData;
import lz.native3d.ctrls.TwoDBatAnmCtrl;
import lz.native3d.materials.TwoDBatchMaterial;
import lz.native3d.meshs.MeshUtils;
import lz.net.LoaderBat;
import net.hires.debug.Stats;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class TwoDBatchExample extends Sprite
{
	var bv:BasicView;
	var node:Node3D;
	var bmd:BitmapData;
	var xml:Xml;

	public function new() 
	{
		super();
		var loader:LoaderBat = new LoaderBat();
		loader.addEventListener(Event.COMPLETE, loader_complete);
		loader.addImageLoader("../assets/sheet/explode/sheet.png");
		loader.addUrlLoader("../assets/sheet/explode/sheet.xml");
		//loader.addImageLoader("../assets/sheet/smoke/sheet.png");
		//loader.addUrlLoader("../assets/sheet/smoke/sheet.xml");
		loader.start();
		
	}
	
	private function loader_complete(e:Event):Void 
	{
		for (cell in  cast(e.currentTarget,LoaderBat).loaderComps) {
			if (cell.getImage()!=null) {
				bmd = cell.getImage();
			}else {
				xml = Xml.parse(cell.getText());
			}
		}
		
		bv = new BasicView(200, 200,true);
		bv.instance3Ds[0].camera = new Camera3D(200, 200, bv.instance3Ds[0],true);
		bv.instance3Ds[0].camera.frustumPlanes = null;
		addChild(bv);
		bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, context3dCreate);
		addChild(new Stats());
	}
	
	private function context3dCreate(e:Event):Void 
	{
		node = new Node3D();
		var drawable:DrawAble3D = MeshUtils.createPlane(10, bv.instance3Ds[0]);
		node.drawAble = drawable;
		var textureset:TextureSet = new TextureSet(bv.instance3Ds[0]);
		textureset.setBmd(bmd,Context3DTextureFormat.BGRA);
		node.material = new TwoDBatchMaterial(textureset.texture,bv.instance3Ds[0]);
		bv.instance3Ds[0].root.add(node);
		
		var td:TDSpriteData= TDSpriteData.create1(bmd, xml, new Point(300,300));
		
		var c:Int = 10;
		while (c-->0) {
			var player:Node3D = new Node3D();
			
			player.x = stage.stageWidth*(Math.random()-.5);
			player.y = stage.stageHeight * (Math.random() - .5);
			node.add(player);
			var twoDNode:Node3D = new Node3D();
			player.add(twoDNode);
			var twoD:TwoDData = new TwoDData();
			twoD.anmCtrl = new TwoDBatAnmCtrl();
			twoD.anmCtrl.speed = .1+Math.random()*.1;
			twoD.anmCtrl.data = td;
			twoD.anmCtrl.node3d = twoDNode;
			twoDNode.twoDData = twoD;
		}
		
		addEventListener(Event.ENTER_FRAME, enterFrame);
	}
	
	private function enterFrame(e:Event):Void 
	{
		/*for (c in node.children) {
			c.rotationZ ++;
		}*/
		for (i3d in bv.instance3Ds) {
			i3d.render();
		}
	}
	
	public static function main():Void {
		Lib.current.addChild(new TwoDBatchExample());
	}
	
}