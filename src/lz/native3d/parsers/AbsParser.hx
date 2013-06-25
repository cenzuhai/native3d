package lz.native3d.parsers;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Matrix3D;
import flash.utils.ByteArray;
import flash.Vector;
import haxe.zip.Entry;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.Entry;
import haxe.zip.Reader;
import lz.native3d.core.Node3D;
import lz.net.LoaderBat;
import nochump.util.zip.Inflater;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class AbsParser extends EventDispatcher
{
	public var node:Node3D;
	public var data:Dynamic;
	private var name:String;
	private var bmdName:String;
	public var bmd:BitmapData;
	private var loader:LoaderBat;
	private var entrys:List<Entry>;
	public function new(data:Dynamic) 
	{
		super();
		this.data = data;
		node = new Node3D();
	}
	
	public function fromUrl(url:String, bmdUrl:String = null):Void {
		name = url;
		bmdName = bmdUrl;
		loader = new LoaderBat();
		loader.addBytesLoader(url, name);
		if (bmdUrl!=null) {
			loader.addImageLoader(bmdUrl,bmdUrl);
		}
		loader.start();
		loader.addEventListener(Event.COMPLETE, loader_complete2);
	}
	
	public function fromUrlZip(url:String, name:String,bmdName:String=null):Void {
		loader = new LoaderBat();
		loader.addBytesLoader(url, name);
		this.name = name;
		this.bmdName = bmdName;
		loader.start();
		loader.addEventListener(Event.COMPLETE, loader_complete);
	}
	
	private function loader_complete2(e:Event):Void 
	{
		if (bmdName!=null) {
			bmd = loader.getImage(bmdName);
		}
		data = loader.getBytes(name);
		parser();
	}
	
	private function loader_complete(e:Event):Void 
	{
		var byteArray:ByteArray = loader.getBytes(name);
		var bytes:Bytes = Bytes.ofData(byteArray);
		var input:BytesInput = new BytesInput(bytes);
		
		var reader:Reader = new Reader(input);
		entrys = reader.read();
		if(bmdName!=null){
			var b2:ByteArray = getBytes(bmdName);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bmd_loader_complete);
			loader.loadBytes(b2);
			return;
		}
				
		data = getBytes(name);
		parser();
	}
	
	private function getBytes(name:String):ByteArray {
		for (entry in entrys) {
			if(entry.fileName==name){
				var inf:Inflater = new Inflater();
				inf.setInput(entry.data.getData());
				var b:ByteArray = new ByteArray();
				inf.inflate(b);
				return b;
			}
		}
		return null;
	}
	
	private function bmd_loader_complete(e:Event):Void 
	{
		bmd = cast(cast(e.currentTarget, LoaderInfo).content, Bitmap).bitmapData;
		data = getBytes(name);
		parser();
	}
	
	public function parser():Void {
		
	}
	
	
	public function polygon2triangle(ps:Vector<UInt>,vs:Vector<UInt>):Void {
		for (i in 1...ps.length-1) {
			vs.push(ps[0]);
			vs.push(ps[i+1]);
			vs.push(ps[i]);
		}
	}
	
	public function str2Strs(str:String):Array<String> {
		var r = ~/\s+/g;
		var arr = r.split(str);
		while (arr[0]=="") {
			arr.shift();
		}
		if (arr[arr.length-1]=="") {
			arr.pop();
		}
		return arr;
	}
	
	public function str2Floats(str:String):Vector<Float> {
		var arr:Array<String> = str2Strs(str);
		var ret:Vector<Float> = new Vector<Float>();
		for (v in arr) {
			ret.push(Std.parseFloat(v));
		}
		return ret;
	}
	
	public function str2Ints(str:String):Vector<#if flash UInt #else Int #end> {
		var arr:Array<String> = str2Strs(str);
		var ret:Vector<#if flash UInt #else Int #end> = new Vector<#if flash UInt #else Int #end>();
		for (v in arr) {
			ret.push(untyped(Std.parseInt(v)));
		}
		return ret;
	}
	
	public function str2Matrix(str:String):Matrix3D{
		return str2Matrixs(str).pop();
	}
	
	public function str2Matrixs(str:String):Vector<Matrix3D>{
		var vs = str2Floats(str);
		return floats2Matrixs(vs);
		
	}
	
	public function floats2Matrixs(vs:Vector<Float>):Vector<Matrix3D> {
		var ms = new Vector<Matrix3D>();
		var i = 0;
		while (i < vs.length) {
			var m = new Matrix3D();
			m.copyRawDataFrom(vs, i, true);
			ms.push(m);
			i += 16;
		}
		return ms;
	}
	
	public function getVerticesById(id:String, mesh:Xml):Xml
	{
		for (child in mesh.elements()) {
			if (child.nodeName=="source"&&child.get("id")==id) {
				return child;
			}
			if (child.nodeName=="vertices"&&child.get("id")==id) {
				return getVerticesById(ne(child,"input").get("source").substr(1),mesh);
			}
		}
		return null;
	}
	
	public function ne(xml:Xml, name:String):Xml {
		for (child in xml.elements()) {
			if (child.nodeName == name) return child;
		}
		return null;
	}
	
	public function ne2(xml:Xml, name1:String, name2:String):Xml {
		return ne(ne(xml, name1), name2);
	}
	public function idne(xml:Xml, name:String,id:String,idName:String="id"):Xml {
		for (child in xml.elements()) {
			if (child.nodeName == name&&child.get(idName)==id) return child;
		}
		return null;
	}
	public function idne2(xml:Xml, name1:String, name2:String, id:String,idName:String="id"):Xml {
		var xml2:Xml = ne(xml,name1);
		return idne(xml2, name2, id,idName);
	}
	
}