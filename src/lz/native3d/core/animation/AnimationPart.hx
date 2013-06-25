package lz.native3d.core.animation;
import flash.geom.Matrix3D;
import flash.Vector;
import lz.native3d.core.Node3D;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class AnimationPart
{
	public var channels:Vector<Channel>;
	public var target:Node3D;
	public function new() 
	{
		channels = new Vector<Channel>();
	}
	
	public function doAnimation(time:Float,maxTime:Float):Void {
		var rd:Vector<Float> = target.matrix.rawData;
		for (cannel in channels) {
			var i = 0;
			var len = cannel.input.length;
			while (i < len) {
				if (cannel.input[i] > time) {
					break;
				}
				i++;
			}
			var j = i - 1;
			var v:Float = 0;
			if (j < 0) {
				j = len - 1;
				v =(time-cannel.input[j]+maxTime) / (cannel.input[i] - cannel.input[j]+maxTime);
			}else if (i>=len) {
				i = 0;
				v = (time-cannel.input[j]) / (cannel.input[i]+maxTime - cannel.input[j]);
			}else {
				v = (time-cannel.input[j]) / (cannel.input[i] - cannel.input[j]);
			}
			if (cannel.index == -1) {
				var mj:Matrix3D = cannel.outputMatirxs[j];
				var mi:Matrix3D = cannel.outputMatirxs[i];
				mj.interpolateTo(mi, v);
				mj.copyRawDataTo(rd);
			}else {
				rd[cannel.index] = cannel.output[j] + (cannel.output[i] - cannel.output[j]) * v;
			}
		}
		target.matrix.copyRawDataFrom(rd); 
		target.matrixVersion++;
	}
}