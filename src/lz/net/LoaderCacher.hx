package lz.net;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class LoaderCacher
{
	private static var assets:Map<String,Dynamic>=new Map<String,Dynamic>();
	public static function addAsset(url:String, data:Dynamic):Void {
		assets.set(url, data);
	}
	
	public static function getAsset(url:String):Dynamic {
		return assets.get(url);
	}
	
}