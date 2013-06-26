package lz.native3d.core.twoDAnimation ;
//{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.Vector;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	 class TDSpriteData 
	{
		
		public var sheetImage:BitmapData;
		public var sheetXML:Xml;
		public var center:Point;
		
		public var totalFrame:Int;
		public var frames:Vector<TDFrame>;
		public function new() 
		{
			center = new Point();
			frames =  new Vector<TDFrame>();
		}
		
		public static function create1(sheet:BitmapData, xml:Xml, center:Point):TDSpriteData {
			var data:TDSpriteData = new TDSpriteData();
			data.sheetImage = sheet;
			if (center == null) center = new Point();
			for (sub1 in xml.elements()) {
				if (sub1.nodeName == "TextureAtlas")
				for (sub in sub1.elements()) {
					if (sub.nodeName == "SubTexture") {
						var frame:TDFrame = new TDFrame();
						frame.matrix = new Matrix3D();
						frame.offset.x = Std.parseFloat(sub.get("fx")) - center.x;
						frame.offset.y = Std.parseFloat(sub.get("fy")) - center.y;
						var x:Float = Std.parseFloat(sub.get("x"));
						var y:Float = Std.parseFloat(sub.get("y"));
						frame.size.x = Std.parseFloat(sub.get("width"));
						frame.size.y = Std.parseFloat(sub.get("height"));
						frame.matrix.appendScale(frame.size.x, frame.size.y, 1);
						frame.matrix.appendTranslation(frame.size.x / 2, frame.size.y / 2, 0);
						frame.matrix.appendTranslation(frame.offset.x, frame.offset.y, 0);
						//0 1
						//2 3
						frame.uv = Vector.ofArray([
						x/sheet.width, y/sheet.height,
						(x+frame.size.x)/sheet.width, y/sheet.height,
						x/sheet.width, (y+frame.size.y)/sheet.height, 
						(x+frame.size.x)/sheet.width, (y+frame.size.y)/sheet.height
						]);
						data.frames.push(frame);
					}
				}
			}
			
			data.totalFrame = data.frames.length;
			if (data.frames.length == 0) {
				throw "err";
			}
			return data;
		}
		
		/*public static function split(data:EffectSpriteData, sdata:Array):Vector.<EffectSpriteData> {
			var c:int = 0;
			var ret:Vector.<EffectSpriteData> = new Vector.<EffectSpriteData>;
			for each(var n:int in sdata) {
				var sub:EffectSpriteData = new EffectSpriteData;
				sub.sheetImage = data.sheetImage;
				ret.push(sub);
				for (var i:int = 0; i < n;i++,c++ ) {
					sub.frames.push(data.frames[c]);
				}
				sub.totalFrame = sub.frames.length;
			}
			return ret;
		}*/
		
	}

//}