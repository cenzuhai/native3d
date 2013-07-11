package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import lz.native3d.core.BasicLight3D;
	import lz.native3d.core.BasicView;
	import lz.native3d.core.DrawAble3D;
	import lz.native3d.core.Node3D;
	import lz.native3d.materials.ColorMaterial;
	import lz.native3d.meshs.MeshUtils;
//	import net.hires.debug.Stats;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class Test extends Sprite
	{
		private var bv:BasicView;
		private var drawAble:DrawAble3D;
		private var node:Node3D;
		
		public function Test() 
		{
			bv = new BasicView(1,1,true);
			addChild(bv);
			bv.instance3D.addEventListener(Event.CONTEXT3D_CREATE, instance3D_context3dCreate);
		}
		
		private function instance3D_context3dCreate(e:Event):void 
		{
			drawAble = MeshUtils.createTeaPot();
			node = new Node3D;
			node.radius = -drawAble.radius;
			node.drawAble = drawAble;
			bv.instance3D.root.add(node);
			node.set_material(new ColorMaterial(0xffffff*Math.random(), 0xffffff*Math.random(), new BasicLight3D));
			
			bv.instance3D.camera.z=-100;
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
		//	addChild(new Stats);
		}
		
		private function enterFrame(e:Event):void 
		{
			node.setPosition(1, 1, 1);
			node.x=(mouseX-bv.width3d/2)/10;
			node.y = -(mouseY - bv.height3d/2) / 10;
			node.z =  node.y;
			node.rotationX += .2;
			node.rotationY += .4;
			bv.instance3D.render();
		}
		
	}

}