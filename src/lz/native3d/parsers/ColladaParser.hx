package lz.native3d.parsers;
import flash.display.BitmapData;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.utils.ByteArray;
import flash.Vector;
import lz.native3d.core.animation.Animation;
import lz.native3d.core.animation.AnimationPart;
import lz.native3d.core.animation.Channel;
import lz.native3d.core.animation.Skin;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.DrawAble3D;
import lz.native3d.core.IndexBufferSet;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.TextureSet;
import lz.native3d.core.VertexBufferSet;
import lz.native3d.materials.ColorMaterial;
import lz.native3d.materials.SkinMaterial;
import lz.native3d.meshs.MeshUtils;

/**
 * 参考文献
 * 
 * http://blog.csdn.net/qyfcool/article/details/6775309
 * http://www.the3frames.com/?p=788
* http://www.wazim.com/Collada_Tutorial_1.htm
 * @author lizhi http://matrix3d.github.io/
 */
class ColladaParser extends AbsParser
{
	private var dae:Xml;
	public var anms:Animation;
	public var skins:Vector<Skin>;
	public var id2node:Map<String,Node3D>;
	public var sid2node:Map<String,Node3D>;
	public var jointRoot:Node3D;
	public var texture:TextureSet;
	public function new(data:Dynamic) 
	{
		super(data);
		texture = new TextureSet(Instance3D.getInstance());
		
	}
	
	override public function parser():Void {
		texture.setBmd(bmd, Context3DTextureFormat.BGRA);
		jointRoot = new Node3D();
		var xml:Xml = Xml.parse(cast(cast(data,ByteArray).toString(),String));
		dae = ne(xml, "COLLADA");
		var root:Xml = ne2(dae, "scene", "instance_visual_scene");
		id2node = new Map<String, Node3D>();
		sid2node = new Map<String, Node3D>();
		skins = new Vector<Skin>();
		node.type = Node3D.NODE_TYPE;
		buildNode(root, node);
		for (skin in skins) {
			skin.joints = new Vector<Node3D>();
			for (name in skin.jointNames) {
				skin.joints.push(sid2node.get(name));
			}
		}
		buildAnimation();
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	private function buildNode(xml:Xml, node:Node3D,isJoint:Bool=false):Void {
		var url = xml.get("url");
		if (url != null) {
			xml =  idne2(dae,"library_visual_scenes", "visual_scene", url.substr(1));
		}
		for (child in xml.elements()) {
			if (child.nodeName == "instance_controller") {
				var controllerId = child.get("url").substr(1);
				var controller = idne2(dae, "library_controllers", "controller", controllerId);
				for (skin in controller.elements()) {
					if (skin.nodeName=="skin") {
						var meshNode = new Node3D();
						node.add(meshNode);
						var source = skin.get("source").substr(1);
						var geometry = idne2(dae, "library_geometries", "geometry", source);
						var mesh = ne(geometry, "mesh");
						var vertices = ne(mesh, "vertices");
						var vlib = getVerticesById(vertices.get("id"), mesh);
						
						var dskin = new Skin();
						dskin.texture = texture;
						var vs = str2Floats(ne(vlib, "float_array").firstChild().nodeValue);
						dskin.daeXyz = vs;
						dskin.daeIndexs = new Vector<Vector<Int>>();
						dskin.daeUVIndexs = new Vector<Vector<Int>>();
						for (triangle in mesh.elements()) {
							// TODO : polylist
							if (triangle.nodeName == "triangles") {
								if (dskin.daeUV==null) {
									dskin.daeUV=str2Floats(ne(getVerticesById(idne(triangle, "input", "TEXCOORD", "semantic").get("source").substr(1),mesh),"float_array").firstChild().nodeValue);
								}
								var inc:Vector<Int> = new Vector<Int>();
								var uv:Vector<Int> = new Vector<Int>();
								dskin.daeIndexs.push(inc);
								dskin.daeUVIndexs.push(uv);
								var materialName = triangle.get("material");
								var parray = str2Ints(ne(triangle, "p").firstChild().nodeValue);
								var i = 0;
								var len = parray.length;
								while (i < len) {
									inc.push(parray[i]);
									inc.push(parray[i + 6]);
									inc.push(parray[i + 3]);
									
									uv.push(parray[i + 2]);
									uv.push(parray[i + 8]);
									uv.push(parray[i + 5]);
									i += 9;
								}
							}
						}
						var drawableNode = new Node3D();
						meshNode.add(drawableNode);
						
						dskin.node = drawableNode;
						skins.push(dskin);
						dskin.bindShapeMatrix = str2Matrix(ne(skin, "bind_shape_matrix").firstChild().nodeValue);
						var vertexWeights = ne(skin, "vertex_weights");
						var jointId = idne(vertexWeights,"input","JOINT","semantic").get("source").substr(1);
						dskin.jointNames = str2Strs(ne(idne(skin, "source", jointId), "Name_array").firstChild().nodeValue);
						var weightId = idne(vertexWeights,"input","WEIGHT","semantic").get("source").substr(1);
						dskin.weights = str2Floats(ne(idne(skin, "source", weightId), "float_array").firstChild().nodeValue);
						dskin.vcount = str2Ints(ne(vertexWeights, "vcount").firstChild().nodeValue);
						dskin.v = str2Ints(ne(vertexWeights, "v").firstChild().nodeValue);
						var invBindMatrixId = idne2(skin,"joints","input","INV_BIND_MATRIX","semantic").get("source").substr(1);
						dskin.invBindMatrixs = str2Matrixs(ne(idne(skin, "source", invBindMatrixId), "float_array").firstChild().nodeValue);
					}
				}
			}
		}
		for (child in xml.elements()) {
			if (child.nodeName == "node") {
				var childNode = new Node3D();
				node.add(childNode);
				id2node.set(child.get("id"), childNode);
				if (child.get("type") == "NODE") {
					childNode.type = Node3D.NODE_TYPE;
				}else if (child.get("type") == "JOINT") {
					if (node.type==Node3D.NODE_TYPE&&!isJoint) {
						isJoint = true;
						jointRoot.add(node);
					}else {
					}
					sid2node.set(child.get("sid"), childNode);
					childNode.type = Node3D.JOINT_TYPE;
				}
				childNode.name = child.get("name");
				var matrixXml = ne(child, "matrix");
				if(matrixXml!=null){
					var matrix:Matrix3D = str2Matrix(matrixXml.firstChild().nodeValue);
					childNode.matrix.copyFrom(matrix);
					childNode.matrixVersion++;
				}
				buildNode(child, childNode,isJoint);
			}
		}
	}
	
	private function buildAnimation():Void {
		var areg = ~/(.+)\/(.+)\((\d+)\)\((\d+)\)/;
		var areg2 = ~/(.+)\/(.+)/;
		anms = new Animation();
		anms.jointRoot = jointRoot;
		for (child in dae.elements()) {
			if (child.nodeName == "library_animations") {
				for (xa in child.elements()) {
					if (xa.nodeName=="animation") {
						var anm = new AnimationPart();
						anms.parts.push(anm);
						for (channel in xa.elements()) {
							if (channel.nodeName == "channel") {
								var sourceId = channel.get("source").substr(1);
								var sampler = idne(xa, "sampler", sourceId);
								var inputId =idne(sampler,"input","INPUT","semantic").get("source").substr(1);
								var outputId = idne(sampler, "input", "OUTPUT", "semantic").get("source").substr(1);
								var input = str2Floats(ne(idne(xa, "source", inputId), "float_array").firstChild().nodeValue);
								var output = str2Floats(ne(idne(xa, "source", outputId), "float_array").firstChild().nodeValue);
								for (tt in input) {
									if (anms.maxTime < tt) anms.maxTime = tt;
								}
								var target = channel.get("target");
								var can = new Channel();
								if (areg.match(target)) {
									var targetId = areg.matched(1);
									anm.target = id2node.get(targetId);
									var targetKey = areg.matched(2);
									if(targetKey=="transform"){
										var x = Std.parseInt(areg.matched(3));
										var y = Std.parseInt(areg.matched(4));
										can.input = input;
										can.output = output;
										can.index = y + x * 4;
										if (can.index != 15) {
											anm.channels.push(can);
										}
									}
									
								}else {
									if (areg2.match(target)) {
										var targetId = areg2.matched(1);
										anm.target = id2node.get(targetId);
										var targetKey = areg2.matched(2);
										if(targetKey=="transform"){
											can.input = input;
											can.outputMatirxs = floats2Matrixs(output);
											can.index = -1;
											anm.channels.push(can);
										}
									}else {
										throw "error";
									}
								}
							}
						}
					}
				}
			}
		}
		
		anms.startCache(skins);
	}
}