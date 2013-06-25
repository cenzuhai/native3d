package lz.native3d.ctrls;
import flash.geom.Matrix;
import flash.utils.Function;
import lz.native3d.core.Node3D;
import lz.native3d.core.twoDAnimation.TDFrame;
import lz.native3d.core.twoDAnimation.TDSpriteData;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class TwoDBatAnmCtrl
{

	public var data:TDSpriteData;
	public var frame:Float ;
	public var speed:Float = 1;
	public var frameScript:Function;
	public var node3d:Node3D;
	
	private var lastFrame:TDFrame;
	public function new() 
	{
		frame = 1000 * Math.random();
		var a = new TDFrame();
		var b = new TDSpriteData();
	}
	public function next():Void {
		if (frameScript!=null) {
			frameScript(this);
		}
		frame += speed;
		var eframe:TDFrame = data.frames[Std.int(frame) % data.totalFrame];
		if (eframe != lastFrame) {
			lastFrame = eframe;
			node3d.twoDData.uvChanged = true;
			node3d.matrix = eframe.matrix;
			node3d.matrixVersion++;
			node3d.twoDData.uvData = lastFrame.uv;
		}
		
		
		/*matrix.copyFrom(eframe.matrix);
		matrix.scale(scale.x, scale.y);
		matrix.translate(pos.x, pos.y);
		if (display) {
			display.graphics.clear();
		}
		graphics.beginBitmapFill(data.sheetImage, matrix, false,true);
		graphics.drawRect(pos.x + eframe.offset.x * scale.x, pos.y + eframe.offset.y * scale.y, eframe.size.x * scale.x, eframe.size.y * scale.y);
		graphics.endFill();*/
	}
	
}