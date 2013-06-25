package lz.native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DProgramType;
import flash.display3D.textures.Texture;
import flash.display3D.textures.TextureBase;
import flash.display3D.VertexBuffer3D;
import flash.geom.Matrix3D;
import flash.Vector;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.IndexBufferSet;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.VertexBufferSet;
import lz.native3d.meshs.MeshUtils;

import hxsl.Shader;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class TwoDBatchMaterial extends MaterialBase
{
	private var xyzBuff:VertexBufferSet;
	private var uvBuff:VertexBufferSet;
	private var indexBuff:IndexBufferSet;
	private var changed:Bool = true;
	private var nodes:Vector<Node3D>;
	private var lastLen:Int = 0;
	public var stepLen:Int = 50;
	public var i3d:Instance3D;
	
	public var plane:Vector<Float>;
	public var planeOut:Vector<Float>;
	private var texture:TextureBase;
	private static var shader:IShader = new IShader();
	public function new(texture:TextureBase,i3d:Instance3D) 
	{
		super();
		passCompareMode = Context3DCompareMode.ALWAYS;
		sourceFactor = Context3DBlendFactor.ONE;
		destinationFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
		//passCompareMode = Context3DCompareMode.NEVER;
		this.texture = texture;
		if (shader.i == null) {
			shader.create(Instance3D.getInstance().c3d);
		}
		progrom = shader.i.program;
		nodes = new Vector<Node3D>();
		this.i3d = i3d;
		indexBuff = new IndexBufferSet(0, new Vector<UInt>(), 0, i3d);
		xyzBuff = new VertexBufferSet(0, 3, new Vector<Float>(), 0, i3d);
		uvBuff = new VertexBufferSet(0, 2, new Vector<Float>(), 0, i3d);
		plane = MeshUtils.createPlane(.5, i3d).xyz.data;
		planeOut = new Vector<Float>(plane.length);
	}
	
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
		var c3d = pass.i3d.c3d;
		
		nodes.length = 0;
		var needUploadPos:Bool = false;
		var needUploadUV:Bool = false;
		doNode(node.children);
		if (nodes.length==0) {
			return;
		}
		if (nodes.length!=lastLen) {
			changed = true;
			var needLen:Int = Math.ceil(nodes.length / stepLen) * stepLen;
			var needLenX12:Int = 12 * needLen;
			var needLenX8:Int = 8 * needLen;
			if (xyzBuff.data.length != needLenX12) {
				xyzBuff.num = needLen*4;
				xyzBuff.data.length = needLenX12;
				xyzBuff.vertexBuff = xyzBuff.i3d.c3d.createVertexBuffer(xyzBuff.num, 3);
			}
			if (uvBuff.data.length != needLenX8) {
				uvBuff.num = needLen*4;
				uvBuff.data.length = needLenX8;
				uvBuff.vertexBuff = uvBuff.i3d.c3d.createVertexBuffer(uvBuff.num, 2);
			}
			var indexLen:Int = 6 * needLen;
			if (indexBuff.data.length!=indexLen) {
				indexBuff.num = indexLen;
				var lastIlen:Int = indexBuff.data.length;
				indexBuff.data.length = indexLen;
				indexBuff.indexBuff = indexBuff.i3d.c3d.createIndexBuffer(indexLen);
				for (i in Math.ceil(lastIlen/6)...needLen) {
					var ni:Int = i * 4;
					var n6:Int = i * 6;
					//3 0
					//2 1
					indexBuff.data[n6]=ni;
					indexBuff.data[n6+1]=ni + 1;
					indexBuff.data[n6+2]=ni + 2;
					indexBuff.data[n6+3] = ni + 1;
					indexBuff.data[n6+4]=ni + 3;
					indexBuff.data[n6+5]=ni + 2;
				}
				indexBuff.upload();
			}
			lastLen = nodes.length;
		}
		if (changed) {
			needUploadPos  = true;
			needUploadUV = true;
			for (i in 0...nodes.length) {
				var cnode:Node3D = nodes[i];
				cnode.twoDData.posVersion = cnode.worldVersion;
				cnode.twoDData.uvChanged = false;
				setPosData(cnode, i);
				setUvData(cnode, i);
			}

		}else{
			for (i in 0...nodes.length) {
				var cnode:Node3D = nodes[i];
				if (cnode.twoDData.posVersion!=cnode.worldVersion) {
					cnode.twoDData.posVersion = cnode.worldVersion;
					needUploadPos = true;
					setPosData(cnode, i);
				}
				if (cnode.twoDData.uvChanged) {
					cnode.twoDData.uvChanged = false;
					needUploadUV = true;
					setUvData(cnode, i);
				}
			}
		}
		if (needUploadPos) {
			xyzBuff.upload();
		}
		if (needUploadUV) {
			uvBuff.upload();
		}
		changed = false;
		//draw
		//return;
		c3d.setDepthTest(true, passCompareMode);
		c3d.setBlendFactors(sourceFactor, destinationFactor);
		c3d.setProgram(progrom);
		c3d.setVertexBufferAt(0, xyzBuff.vertexBuff, 0, xyzBuff.format);
		c3d.setVertexBufferAt(1, uvBuff.vertexBuff, 0, uvBuff.format);
		c3d.setTextureAt(0, texture);
		c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, pass.camera.perspectiveProjectionMatirx, true);
		c3d.drawTriangles(indexBuff.indexBuff,0,nodes.length*2);
		c3d.setVertexBufferAt(0,null, 0, xyzBuff.format);
		c3d.setVertexBufferAt(1, null, 0, uvBuff.format);
		c3d.setTextureAt(0, null);
		
	}
	
	inline private function setPosData(node:Node3D, i:Int):Void {
		node.worldMatrix.transformVectors(plane, planeOut);
		var x12:Int = i * 12;
		var data = xyzBuff.data;
		for (n in 0...12) {
			data[x12+n] = planeOut[n];
		}
	}
	inline private function setUvData(node:Node3D, i:Int):Void {
		var x8:Int = i * 8;
		var data = uvBuff.data;
		var uv = node.twoDData.uvData;
		for (n in 0...8) {
			data[x8+n] = uv[n];
		}
	}
	
	inline private function doNode(nodes:Vector<Node3D>):Void {
		for (node in nodes) {
			doNode(node.children);
			if (node.twoDData != null) {
				if (node.twoDData.anmCtrl!=null) {
					node.twoDData.anmCtrl.next();
				}
				this.nodes.push(node);
			}
			
		}
	}
	
}

private class IShader extends Shader {
	static var SRC = {
		var input: {
			pos : Float3,
			uv : Float2,
		}
		var uv:Float2;
		function vertex(mproj:M44) {
			out = input.pos.xyzw * mproj;
			uv = input.uv;
		}
		function fragment(tex:Texture) {
			out = tex.get(uv, wrap);
		}
	};
	public var i:ShaderInstance;
	public function create(c:Context3D):Void {
		i = getInstance();
		i.program = c.createProgram();
		i.program.upload(i.vertexBytes.getData(), i.fragmentBytes.getData());
	}
}