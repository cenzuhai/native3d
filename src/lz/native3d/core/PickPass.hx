package lz.native3d.core;
import flash.display.BitmapData;
import flash.geom.Matrix3D;
import flash.Vector;
import lz.native3d.materials.IDMaterial;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class PickPass extends BasicPass3D
{
	private var cameraM:Matrix3D;
	private var rawdata:Vector<Float>;
	public var targetBmd:BitmapData;
	public var nodeId:Int = 0;
	public var mouseNode:Node3D;
	public function new(i3d:Instance3D) 
	{
		super(i3d);
		rawdata = new Vector<Float>(16);
		targetBmd = new BitmapData(1, 1, false);
		material = new IDMaterial();
		camera = new Camera3D(400, 400,i3d);
		camera.frustumPlanes = null;
	}
	
	public function before(mouseX:Float,mouseY:Float):Void {
		var icamera:Camera3D = Instance3D.getInstance().camera;
		camera.worldVersion=camera.matrixVersion = 1;
		camera.invertVersion = 2;
		camera.worldMatrix.copyFrom(icamera.worldMatrix);
		icamera.perspectiveProjection.copyRawDataTo(rawdata);
		rawdata[8] = -mouseX / Instance3D.getInstance().width * 2;
		rawdata[9] = mouseY / Instance3D.getInstance().height * 2;
		camera.perspectiveProjection.copyRawDataFrom(rawdata);
		
	}
	
	override public function pass(nodes:Vector<Node3D>):Void {
		Instance3D.getInstance().c3d.clear(0,0,0,0);
		for(i in 0...nodes.length) {
			var node:Node3D = nodes[i];
			doPass(node);
		}
		Instance3D.getInstance().c3d.drawToBitmapData(targetBmd);
		nodeId = targetBmd.getPixel(0, 0);
		mouseNode = Node3D.NODES.get(nodeId);
	}
	
}