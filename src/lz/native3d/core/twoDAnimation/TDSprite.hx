package effect 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class EffectSprite 
	{
		public var data:EffectSpriteData;
		public var graphics:Graphics;
		public var display:Sprite;
		public var frame:Number = 0;
		public var speed:Number = 1;
		public var matrix:Matrix = new Matrix;
		public var pos:Point = new Point;
		public var scale:Point = new Point(1, 1);
		public var frameScript:Function;
		public var world:EffectWorld;
		public function EffectSprite(graphics:Graphics,data:EffectSpriteData) 
		{
			this.graphics = graphics;
			this.data = data;
			
		}
		
		public function update():void {
			if (frameScript!=null) {
				frameScript(this);
			}
			frame += speed;
		}
		
		public function render():void {
			if (graphics == null || data == null) return;
			var eframe:EffectFrame = data.frames[int(frame) % data.totalFrame];
			matrix.copyFrom(eframe.matrix);
			matrix.scale(scale.x, scale.y);
			matrix.translate(pos.x, pos.y);
			if (display) {
				display.graphics.clear();
			}
			graphics.beginBitmapFill(data.sheetImage, matrix, false,true);
			graphics.drawRect(pos.x + eframe.offset.x * scale.x, pos.y + eframe.offset.y * scale.y, eframe.size.x * scale.x, eframe.size.y * scale.y);
			graphics.endFill();
		}
		
	}

}