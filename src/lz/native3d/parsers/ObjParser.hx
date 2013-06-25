package lz.native3d.parsers;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.TextureBase;
import flash.errors.Error;
import flash.events.Event;
import flash.Lib;
import flash.utils.ByteArray;
import flash.utils.RegExp;
import flash.Vector;
import haxe.Timer;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.DrawAble3D;
import lz.native3d.core.IndexBufferSet;
import lz.native3d.core.Node3D;
import lz.native3d.core.TextureSet;
import lz.native3d.core.VertexBufferSet;
import lz.native3d.materials.ColorMaterial;
import lz.native3d.materials.ImageMaterial;
import lz.native3d.meshs.MeshUtils;
import lz.native3d.utils.Color;
import lz.net.LoaderBat;
import lz.net.LoaderCell;

/**
 * http://www.douban.com/note/142379570/
 * @author lizhi http://matrix3d.github.io/
 */
class ObjParser extends AbsParser
{
	private var maxTime:Float = .02;
	private var ctime:Float;
	private var cline:Int = 0;
	private var adata:Array<String>;
	private var len:Int;
	private var v:Vector<Float>;
	private var vt:Vector<Float>;
	private var cnode:ObjNode;
	private var mit2node:Map < String,ObjNode> ;
	public var mitName:String;
	private var mit2Color:Map<String,String>;
	public var textureUrl:String;
	public function new(data:Dynamic,mitName:String,textureUrl:String) 
	{
		super(data);
		this.mitName = mitName;
		this.textureUrl = textureUrl;
	}
	
	override public function parser():Void {
		if (mitName!=null) {
			var mittxt:String = getBytes(mitName).toString();
			mit2Color = new Map<String,String>();
			var madata = mittxt.split("\r\n");
			var nowMtl:String=null;
			for (line in madata) {
				var aline:Array<String> = str2Strs(line);
				var fl:String = aline[0];
				if (fl=="newmtl") {
					nowMtl = aline[1];
				}else if (fl == "map_Kd") {
					var kd:String = aline[1];
					mit2Color.set(nowMtl, kd.substring(kd.lastIndexOf("\\")+1,kd.lastIndexOf(".")));
				}
			}
		}
		
		mit2node = new Map<String,ObjNode>();
		var sdata:String = cast(data, ByteArray).toString();
		adata = sdata.split("\r\n");
		v = new Vector<Float>();
		vt = new Vector<Float>();
		len = adata.length;
		frameParser();
		if(cline<len){
			Lib.current.addEventListener(Event.ENTER_FRAME, current_enterFrame);
		}
	}
	
	private function current_enterFrame(e:Event):Void 
	{
		frameParser();
	}
	
	private function frameParser():Void {
		ctime = Timer.stamp();
		while (cline<len) {
			if ((Timer.stamp() - ctime) > maxTime) {
				//trace("return");
				return;
			}
			var line:String = adata[cline++];
			var trunk:Array<String> = str2Strs(line);
			var type:String = trunk[0];
			if (type == "v") {
				v.push(Std.parseFloat(trunk[1]));
				v.push(Std.parseFloat(trunk[2]));
				v.push(Std.parseFloat(trunk[3]));
			}else if (type=="vt") {
				vt.push(Std.parseFloat(trunk[1]));
				vt.push(1-Std.parseFloat(trunk[2]));
			}
			else if (type == "f") {
				var ps:Vector<UInt> = new Vector<UInt>();
				var tps:Vector<UInt> = new Vector<UInt>();
				for (i in 1...trunk.length) {
					var ps2:Array<String> = trunk[i].split("/");
					var ps20:Int = Std.parseInt(ps2[0]);
					var ps21:Int = Std.parseInt(ps2[1]);
					ps.push(ps20);
					tps.push(ps21);
				}
				polygon2triangle(ps, cnode.f);
				polygon2triangle(tps, cnode.tf);
			}else if (type == "g") {
				/*cnode = new ObjNode();
				cnode.node = new Node3D();
				f = new Vector<UInt>();
				cnode.f = f;
				node.add(cnode.node);*/
			}else if (type == "o") {
				//trace("o");
			}
			if (type == "usemtl") {
				if (!mit2node.exists(trunk[1])) {
					cnode = new ObjNode();
					cnode.mit = trunk;
					cnode.f = new Vector<UInt>();
					cnode.tf = new Vector<UInt>();
					cnode.node = new Node3D();
					mit2node.set(trunk[1], cnode);
				}
				cnode = mit2node.get(trunk[1]);
			}
		}
		Lib.current.removeEventListener(Event.ENTER_FRAME, current_enterFrame);
		for (node in mit2node) {
			var newv:Vector<Float> = new Vector<Float>();
			var newvt:Vector<Float> = new Vector<Float>();
			var index:Vector<UInt> = new Vector<UInt>();
			for (i in 0...node.f.length) {
				index.push(i);
				var i3:Int = node.f[i] * 3-3;
				var i2:Int = node.tf[i] * 2-2;
				newv.push(v[i3++]);
				newv.push(v[i3++]);
				newv.push(v[i3]);
				newvt.push(vt[i2++]);
				newvt.push(vt[i2]);
				if (newv.length/3>=65531) {
					break;
				}
			}
			
			var drawable:DrawAble3D = new DrawAble3D();
			drawable.indexBufferSet = new IndexBufferSet(index.length, index, 0);
			drawable.xyz = new VertexBufferSet(untyped(newv.length/3), 3, newv, 0);
			drawable.uv = new VertexBufferSet(untyped(newvt.length/2), 2, newvt, 0);
			MeshUtils.computeNorm(drawable);
			node.node.drawAble = drawable;
			node.node.material = new ImageMaterial(TextureSet.getTempTexture(), 0x808080,0x808080, new BasicLight3D());
			this.node.add(node.node);
		}
		dispatchEvent(new Event(Event.COMPLETE));
		var bat:LoaderBat = new LoaderBat();
		for (key in mit2node.keys()) {
			var name:String = mit2Color.get(key);
			var url:String = textureUrl + "/" +name  + ".jpg";
			bat.addImageLoader(url, name);
		}
		bat.addEventListener(Event.COMPLETE, bat_complete);
		bat.start();
	}
	
	private function bat_complete(e:Event):Void 
	{
		var bat:LoaderBat = cast(e.currentTarget, LoaderBat);
		for (key in mit2node.keys()) {
			var image:BitmapData = bat.getImage(mit2Color.get(key));
			if (image == null) {
				continue;
			}
			var set:TextureSet = new TextureSet();
			set.setBmd(image, Context3DTextureFormat.BGRA);
			cast( mit2node.get(key).node.material, ImageMaterial).texture = set.texture;
		}
	}
	
	private function getTexture(mtl:String):TextureBase {
		return TextureSet.getTempTexture();
		var texture:TextureSet = new TextureSet();
		return texture.texture;
	}
	
}

class ObjNode {
	public var mit:Array<String>;
	public var f:Vector<UInt>;
	public var tf:Vector<UInt>;
	public var node:Node3D;
	public function new():Void {
		
	}
}