package ;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.ui.Keyboard;
import flash.Vector;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicView;
import lz.native3d.core.DrawAble3D;
import lz.native3d.core.Node3D;
import lz.native3d.materials.ColorMaterial;
import lz.native3d.meshs.MeshUtils;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class MagicCube extends Sprite
{
	private var cell:Vector<Vector<Vector<Node3D>>>;
	private var bv:BasicView;
	private var root3d:Node3D;
	private var axiss:Vector<Axis>;
	private var axisVs:Vector<Vector3D>;
	private var axisCode:Int=0;
	private var line:Int = 0;
	private var help:TextField;
	private var neg:Int = 1;
	public function new() 
	{
		super();
		bv = new BasicView();
		addChild(bv);
		bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, bv_context3dCreate);
		
		help = new TextField();
		help.autoSize = TextFieldAutoSize.LEFT;
		help.textColor = 0xffff00;
		help.text = "press key num_1--num_7";
		addChild(help);
	}
	
	private function stage_keyDown(e:KeyboardEvent):Void 
	{
		if (e.keyCode>=49&&e.keyCode<=51) {
			line = e.keyCode-49;
		}
		if (e.keyCode>=52&&e.keyCode<=54) {
			axisCode = e.keyCode-52;
		}
		if (e.keyCode==55) {
			neg *= -1;
		}
		
		if (axiss == null) {
			axiss = new Vector<Axis>();
			for (x in 0...3) {
				for (y in 0...3) {
					for (z in 0...3) {
						if (axisCode==0) {//x
							if (x!=line) {
								continue;
							}
						}else if (axisCode==1) {//y
							if (y!=line) {
								continue;
							}
						}else if(axisCode==2){
							if (z!=line) {
								continue;
							}
						}
						var node:Node3D = cell[x][y][z];
						axiss.push(Axis.create(axisVs[axisCode], node,neg*90));
					}
				}
			}
		}
	}
	
	private function enterFrame(e:Event):Void 
	{
		bv.instance3Ds[0].render();
		root3d.rotationX+=.2;
		root3d.rotationY+=.4;
		if (axiss != null) {
			var flag:Bool = false;
			for (axis in axiss) {
				if (axis.percent < 1) {
					var tp:Float = axis.percent + .1;
					if (tp > 1) tp = 1;
					axis.setPercent(tp);
				}else {
					flag = true;
					break;
				}
			}
			if (flag) {
				for (axis in axiss) {
					var node:Node3D = axis.target;
					var x:Int = Math.round(node.x/2)+1;
					var y:Int = Math.round(node.y/2)+1;
					var z:Int = Math.round(node.z/2)+1;
					cell[x][y][z] = node;
				}
				axiss = null;
			}
		}
	}
	
	private function bv_context3dCreate(e:Event):Void 
	{
		addEventListener(Event.ENTER_FRAME, enterFrame);
		axisVs = new Vector<Vector3D>();
		axisVs.push(Vector3D.X_AXIS);
		axisVs.push(Vector3D.Y_AXIS);
		axisVs.push(Vector3D.Z_AXIS);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDown);
		root3d = new Node3D();
		bv.instance3Ds[0].root.add(root3d);
		var light:BasicLight3D = new BasicLight3D();
		bv.instance3Ds[0].root.add(light);
		light.x = light.z =light.y= -10;
		var da:DrawAble3D = MeshUtils.createCube(1,bv.instance3Ds[0]);
		bv.instance3Ds[0].camera.z = -25;
		cell = new Vector<Vector<Vector<Node3D>>>(3);
		for (x in 0...3) {
			cell[x] = new Vector<Vector<Node3D>>(3);
			for (y in 0...3) {
				cell[x][y] = new Vector<Node3D>(3);
				for (z in 0...3) {
					var node:Node3D = new Node3D();
					node.x = (x - 1) * 2;
					node.y = (y - 1) * 2;
					node.z = (z - 1) * 2;
					root3d.add(node);
					node.drawAble = da;
					node.material = new ColorMaterial(Std.random(0xffffff), 0x808080, light);
					cell[x][y][z] = node;
				}
			}
		}
	}
	public static function main():Void {
		Lib.current.addChild(new MagicCube());
	}
	
}
class Axis {
	public var target:Node3D;
	public var from:Matrix3D;
	public var percent:Float = 0;
	public var degrees:Float;
	public var axisv:Vector3D;
	public function new():Void {
		
	}
	
	public function setPercent(percent:Float):Void {
		this.percent = percent;
		var to:Matrix3D = from.clone();
		to.appendRotation(degrees * percent, axisv);
		target.matrix.copyFrom(to);
		target.matrixVersion++;
	}
	
	public static function create(axisv:Vector3D, target:Node3D,degrees:Float):Axis {
		var axis:Axis = new Axis();
		axis.axisv = axisv;
		axis.from = target.matrix.clone();
		axis.degrees = degrees;
		axis.target = target;
		return axis;
	}
}