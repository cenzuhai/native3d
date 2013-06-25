package lz.native3d.ctrls;
import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.ui.Keyboard;
import lz.native3d.core.Node3D;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class FirstPersonCtrl
{
	private var node:Node3D;
	private var keys:Map<Int,Bool>;
	private var helpMatrix:Matrix3D;
	private var helpV:Vector3D;
	private var speed:Float = 3;
	private var lastPos:Point;
	
	private var rotation:Vector3D;
	private var lastRotation:Vector3D;
	private var position:Vector3D;
	private var stage:Stage;
	public function new(stage:Stage,node:Node3D) 
	{
		this.node = node;
		this.stage = stage;
		helpV = new Vector3D();
		rotation = new Vector3D();
		position = new Vector3D();
		helpMatrix = new Matrix3D();
		keys = new Map<Int,Bool>();
		stage.addEventListener(Event.ENTER_FRAME, stage_enterFrame);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUp);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
	}
	
	private function stage_mouseUp(e:MouseEvent):Void 
	{
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
	}
	
	private function stage_mouseMove(e:MouseEvent):Void 
	{
		rotation.y = lastRotation.y + (e.localX - lastPos.x)/5;
		rotation.x = lastRotation.x + (e.localY - lastPos.y)/5;
	}
	
	private function stage_mouseDown(e:MouseEvent):Void 
	{
		stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
		lastPos = new Point(e.localX, e.localY);
		lastRotation = rotation.clone();
	}
	
	private function stage_enterFrame(e:Event):Void 
	{
		helpMatrix.identity();
		helpMatrix.appendRotation(rotation.x, Vector3D.X_AXIS);
		helpMatrix.appendRotation(rotation.y, Vector3D.Y_AXIS);
		helpV.x = helpV.y = 0;
		helpV.z = 0;
		if (keys.exists(Keyboard.W)) {
			helpV.z += speed;
		}else if (keys.exists(Keyboard.S)) {
			helpV.z -= speed;
		}else if (keys.exists(Keyboard.A)) {
			helpV.x -= speed;
		}else if (keys.exists(Keyboard.D)) {
			helpV.x += speed;
		}
		helpV = helpMatrix.transformVector(helpV);
		position.x += helpV.x;
		position.y += helpV.y;
		position.z += helpV.z;
		helpMatrix.appendTranslation(position.x, position.y, position.z);
		node.matrix.copyFrom(helpMatrix);
		node.matrixVersion++;
	}
	
	private function stage_keyUp(e:KeyboardEvent):Void 
	{
		keys.remove(e.keyCode);
	}
	
	private function stage_keyDown(e:KeyboardEvent):Void 
	{
		keys.set(e.keyCode, true);
	}
	
}