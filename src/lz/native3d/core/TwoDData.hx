package lz.native3d.core;
import flash.utils.ByteArray;
import flash.Vector;
import lz.native3d.ctrls.TwoDBatAnmCtrl;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class TwoDData
{

	////////////////////////////2d 
	/**
	 * 2d xyz 的版本号
	 */
	public var posVersion:Int = -1;
	/**
	 * 2d uv的版本号
	 */
	public var uvChanged:Bool = true;
	public var uvData:Vector<Float>;
	public var anmCtrl:TwoDBatAnmCtrl;
	public function new() 
	{
		uvData = Vector.ofArray([
		0.0, 1, 1, 1, 0, 0, 1, 0
		]);
	}
	
}