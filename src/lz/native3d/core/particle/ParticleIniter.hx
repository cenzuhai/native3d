package lz.native3d.core.particle;
import flash.display3D.Context3DVertexBufferFormat;
import flash.Vector;
import lz.native3d.core.DrawAble3D;
import lz.native3d.core.IndexBufferSet;
import lz.native3d.core.Instance3D;
import lz.native3d.core.VertexBufferSet;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class ParticleIniter
{

	public var i3d:Instance3D;
	public function new(i3d:Instance3D) 
	{
		this.i3d = i3d;
	}
	
	public function init(wrapper:ParticleWrapper):Void {
		wrapper.drawAble = new DrawAble3D();
		var data = new Vector<Float>(3 * wrapper.particles.length * 4, true);
		var sdata = new Vector<Float>(wrapper.particles.length * 4, true);
		var cdata = new Vector<Float>(4 * wrapper.particles.length * 4, true);
		var odata = new Vector<Float>(2 * wrapper.particles.length * 4, true);
		var uvdata = new Vector<Float>(2 * wrapper.particles.length * 4, true);
		var iData = new Vector<#if flash UInt #else Int #end>(wrapper.particles.length * 6);
		
		for (i in 0...wrapper.particles.length) {
			var p = wrapper.particles[i];
			p.indexs.push(i*4);
			p.indexs.push(i*4+1);
			p.indexs.push(i*4+2);
			p.indexs.push(i * 4+3);
			odata[i * 8] = -1;
			odata[i * 8+1] = -1;
			odata[i * 8+2] = 1;
			odata[i * 8+3] = -1;
			odata[i * 8+4] = -1;
			odata[i * 8+5] = 1;
			odata[i * 8+6] = 1;
			odata[i * 8 + 7] = 1;
			
			uvdata[i * 8] = 0;
			uvdata[i * 8+1] = 1;
			uvdata[i * 8+2] = 1;
			uvdata[i * 8+3] = 1;
			uvdata[i * 8+4] = 0;
			uvdata[i * 8+5] = 0;
			uvdata[i * 8+6] = 1;
			uvdata[i * 8 + 7] = 0;
			
			iData[i * 6] = i * 4;
			iData[i * 6+1] = i * 4+1;
			iData[i * 6+2] = i * 4+2;
			iData[i * 6+3] = i * 4+2;
			iData[i * 6+4] = i * 4+1;
			iData[i * 6+5] = i * 4+3;
		}
		
		wrapper.drawAble.xyz = new VertexBufferSet(wrapper.particles.length*4, 3, data, 0,i3d);
		wrapper.drawAble.offset = new VertexBufferSet(wrapper.particles.length*4, 2, odata, 0,i3d);
		wrapper.drawAble.uv = new VertexBufferSet(wrapper.particles.length*4, 2, uvdata, 0,i3d);
		wrapper.drawAble.scale = new VertexBufferSet(wrapper.particles.length*4, 1, sdata, 0,i3d);
		wrapper.drawAble.color = new VertexBufferSet(wrapper.particles.length*4, 4, cdata, 0,i3d);
		wrapper.drawAble.indexBufferSet = new IndexBufferSet(iData.length, iData, 0,i3d);
	}
	
}