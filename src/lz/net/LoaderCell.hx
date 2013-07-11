package lz.net;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.errors.Error;
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
class LoaderCell extends EventDispatcher
{
	public var loader:Loader;
	public var urlLoader:URLLoader;
	public var request:URLRequest;
	public var bytes:ByteArray;
	public var name:String;
	public var userData:Dynamic;
	public var data:Dynamic;
	public var isCache:Bool;
	public function new(isCache:Bool=false) 
	{
		super();
		this.isCache = isCache;
	}
	
	public function start():Void {
		if (request!=null) {
			data = LoaderCacher.getAsset(request.url);
			if (data!=null) {
				complete(new Event(Event.COMPLETE));
				return;
			}
		}
		
		var ed:EventDispatcher = urlLoader;
		if (ed == null)
		ed= loader.contentLoaderInfo;
		if (ed == null) return;
		ed.addEventListener(ProgressEvent.PROGRESS, progressevent);
		ed.addEventListener(Event.COMPLETE, complete);
		ed.addEventListener(IOErrorEvent.IO_ERROR, ioError);
		if (urlLoader != null) {
			urlLoader.load(request);
		}else if (loader!=null) {
			if (bytes!=null) {
				loader.loadBytes(bytes);
			}else {
				loader.load(request);
			}
		}
	}
	
	public function close():Void {
		var ed:EventDispatcher = null;
		if (loader!=null) {
			loader.close();
			ed = loader.contentLoaderInfo;
		}else if (urlLoader!=null) {
			ed = urlLoader;
		}
		if (ed!=null) {
			ed.removeEventListener(ProgressEvent.PROGRESS, progressevent);
			ed.removeEventListener(Event.COMPLETE, complete);
			ed.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
		}
	}
	
	public function getImage():BitmapData {
		if(data==null){
		try {
			data=cast(loader.content, Bitmap).bitmapData;
		}catch (e:Error) { }
		}
		return untyped(data);
	}
	
	public function getBytes():ByteArray {
		if(data==null)
		data=cast(urlLoader.data,ByteArray);
		return untyped(data);
	}
	public function getText():String {
		if(data==null)
		data = cast(urlLoader.data, String);
		return untyped(data);
	}
	
	private function ioError(e:IOErrorEvent):Void 
	{
		dispatchEvent(e);
	}
	
	private function complete(e:Event):Void 
	{
		if (isCache) {
			if (urlLoader != null) {
				if(urlLoader.data!=null)
				LoaderCacher.addAsset(request.url, urlLoader.data);
			}else if (loader!=null) {
				if (loader.content != null)
				LoaderCacher.addAsset(request.url, cast(loader.content,Bitmap).bitmapData);
			}
		}
		dispatchEvent(e);
	}
	
	private function progressevent(e:ProgressEvent):Void 
	{
		dispatchEvent(e);
	}
	
	static public function createImageLoader(url:String,name:String,useDate:Dynamic=null):LoaderCell {
		var cell:LoaderCell = new LoaderCell();
		cell.name = name;
		cell.loader = new Loader();
		cell.request = new URLRequest(url);
		return cell;
	}
	
	static public function createBytesImageLoader(bytes:ByteArray,name:String,useDate:Dynamic=null):LoaderCell {
		var cell:LoaderCell = new LoaderCell();
		cell.name = name;
		cell.loader = new Loader();
		cell.bytes = bytes;
		return cell;
	}
	
	static public function createBytesLoader(url:String,name:String,useDate:Dynamic=null):LoaderCell {
		var cell:LoaderCell = new LoaderCell();
		cell.name = name;
		cell.urlLoader = new URLLoader();
		cell.urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		cell.request = new URLRequest(url);
		return cell;
	}
	
	static public function createUrlLoader(url:String,name:String,useDate:Dynamic=null):LoaderCell {
		var cell:LoaderCell = new LoaderCell();
		cell.name = name;
		cell.urlLoader = new URLLoader();
		cell.urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
		cell.request = new URLRequest(url);
		return cell;
	}
	
}