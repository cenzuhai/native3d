package lz.native3d.utils;
import flash.geom.Vector3D;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class Color
{
	public static function fromRGBA(r:Float, g:Float, b:Float, a:Float):Int{
		return (Std.int(a * 0xff) << 24) | (Std.int(r * 0xff) << 16) | (Std.int(g * 0xff) << 8) | (Std.int(b * 0xff));
	}
	public static function toRGBA(color:Int):Vector3D {
		return new Vector3D((color<<8 >>> 24)/0xff,(color << 16 >>> 24)/0xff,(color << 24 >>> 24) / 0xff,(color >>> 24) / 0xff);
	}
	
}