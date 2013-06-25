package lz.net;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class LoaderBat extends EventDispatcher
{
	public var loaders:Array<LoaderCell>;
	public var loadereds:Array<LoaderCell>;
	public var loaderErrors:Array<LoaderCell>;
	public var loaderComps:Array<LoaderCell>;
	public var nowLoader:LoaderCell;
	public var userData:Dynamic;
	public function new() 
	{
		super();
		loaders = new Array<LoaderCell>();
		loaderComps = new Array<LoaderCell>();
	}
	
	public function addBytesImageLoader(bytes:ByteArray,name:String,userData:Dynamic=null):LoaderCell {
		return  addLoader(LoaderCell.createBytesImageLoader(bytes, name),userData);
	}
	
	public function addImageLoader(url:String,name:String,userData:Dynamic=null):LoaderCell {
		return  addLoader(LoaderCell.createImageLoader(url, name),userData);
	}
	
	public function addBytesLoader(url:String,name:String,userData:Dynamic=null):LoaderCell {
		return  addLoader(LoaderCell.createBytesLoader(url, name),userData);
	}
	
	public function addUrlLoader(url:String,name:String,userData:Dynamic=null):LoaderCell {
		return  addLoader(LoaderCell.createUrlLoader(url, name),userData);
	}
	
	public function getCell(name:String):LoaderCell {
		for (cell in loaderComps) {
			if (cell.name!=null&&cell.name==name) {
				return cell;
			}
		}
		return null;
	}
	
	public function getImage(name:String):BitmapData {
		var cell:LoaderCell = getCell(name);
		if (cell == null) return null;
		return getCell(name).getImage();
	}
	public function getBytes(name:String):ByteArray {
		return getCell(name).getBytes();
	}
	public function getText(name:String):String {
		return getCell(name).getText();
	}
	
	
	public function addLoader(loader:LoaderCell, userData:Dynamic = null):LoaderCell {
		loader.userData = userData;
		loaders.push(loader);
		return loader;
	}
	
	public function start():Void {
		next();
	}
	
	public function close():Void {
		for (loader in loaders) {
			loader.close();
		}
	}
	
	public function next():Void {
		if (nowLoader!=null) {
			
		}if (loaders.length>0) {
			nowLoader = loaders.shift();
			nowLoader.addEventListener(ProgressEvent.PROGRESS, progressevent);
			nowLoader.addEventListener(Event.COMPLETE, complete);
			nowLoader.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			nowLoader.start();
		}else {
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
	
	private function ioError(e:Event):Void 
	{
		nowLoader = null;
		//trace(e.toString());
		next();
	}
	
	private function complete(e:Event):Void 
	{
		nowLoader = null;
		loaderComps.push(e.currentTarget);
		next();
	}
	
	private function progressevent(e:ProgressEvent):Void 
	{
		dispatchEvent(e);
	}
}