package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display3D.Context3DTextureFormat;
import flash.events.Event;
import flash.filters.BlurFilter;
import flash.geom.Vector3D;
import flash.Lib;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicView;
import lz.native3d.core.particle.Particle;
import lz.native3d.core.particle.ParticleWrapper;
import lz.native3d.core.TextureSet;
import lz.native3d.materials.ColorMaterial;
import lz.native3d.materials.ParticleMaterial;
import lz.native3d.meshs.MeshUtils;
import net.hires.debug.Stats;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class ParticleExample extends Sprite
{
	private var bv:BasicView;
	private var pw:ParticleWrapper;

	public function new() 
	{
		super();
		bv = new BasicView();
		addChild(bv);
		bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, bv_context3dCreate);
	}
	
	private function bv_context3dCreate(e:Event):Void 
	{
		
		pw = new ParticleWrapper(bv.instance3Ds[0]);
		var d = 10;
		for (i in 0...160) {
			var p:Particle = new Particle(d * (Math.random() - .5), d * (Math.random() - .5), i, 1);
			p.color.x = Math.random()/2;
			p.color.y = Math.random()/2;
			p.color.z = Math.random()/2;
			p.color.w = 1;
			pw.particles.push(p);
		}
		pw.init();
		
		var shadow = new BitmapData(32, 32, true, 0);
		var pen = new Sprite();
		pen.graphics.beginFill(0xffffff);
		pen.graphics.drawCircle(16, 16, 10);
		pen.graphics.endFill();
		pen.filters = [new BlurFilter(4,4,3)];
		shadow.draw(pen);
		var texture = new TextureSet(bv.instance3Ds[0]);
		texture.setBmd(shadow, Context3DTextureFormat.BGRA, false, 0);
		pw.material = new ParticleMaterial(texture.texture);
		bv.instance3Ds[0].root.add(pw);
		bv.instance3Ds[0].camera.z = -10;
		addEventListener(Event.ENTER_FRAME, enterFrame);
		addChild(new Stats());
		
	}
	
	private function enterFrame(e:Event):Void 
	{
		pw.particles[0].x = (mouseX/200-1)*5;
		pw.particles[0].y = (1-mouseY/200)*5;
		for (i in 1...pw.particles.length) {
			var p = pw.particles[i];
			p.x += (pw.particles[i - 1].x - p.x) * .3;
			p.y += (pw.particles[i - 1].y - p.y) * .3;
		}
		pw.update();
		bv.instance3Ds[0].render();
	}
	public static function main() {
		Lib.current.addChild(new ParticleExample());
	}
	
}