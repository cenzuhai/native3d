package lz.native3d.core.animation;
import flash.display3D.Context3DVertexBufferFormat;
import flash.geom.Matrix3D;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.Vector;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.ByteArraySet;
import lz.native3d.core.DrawAble3D;
import lz.native3d.core.IndexBufferSet;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.VertexBufferSet;
import lz.native3d.materials.ColorMaterial;
import lz.native3d.materials.SkinMaterial;
import lz.native3d.meshs.MeshUtils;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class Animation
{
	public var parts:Vector<AnimationPart>;
	public var jointRoot:Node3D;
	public var maxTime:Float = 0;
	public var numFrame:Int = 0;
	public var frame:Int = 0;
	public function new() 
	{
		parts = new Vector<AnimationPart>();
	}
	
	public function startCache(skins:Vector<Skin>):Void {
		var time = .0;
		while(time<=maxTime){
			for (anm in parts) {	
				anm.doAnimation(time,maxTime);
			}
			Instance3D.getInstance().doTransform.doTransformNodes(jointRoot.children, false);
			for (skin in skins) {
				if (skin.cacheMatrixs==null) {
					skin.cacheMatrixs = new Vector<Vector<Matrix3D>>();
				}
				var matrixs:Vector<Matrix3D> = new Vector<Matrix3D>();
				skin.cacheMatrixs.push(matrixs);
				for (i in 0...skin.joints.length) {
					var joint = skin.joints[i];
					var matrix:Matrix3D = new Matrix3D();
					matrix.copyFrom(joint.worldMatrix);
					matrix.prepend(skin.invBindMatrixs[i]);
					matrixs.push(matrix);
				}
			}
			numFrame++;
			time += 1 / 60;
		}
		
		for (skin in skins) {
			skin.numFrame = numFrame;
			
			skin.bindShapeMatrix.transformVectors(skin.daeXyz, skin.daeXyz);
			var maxWeightLen = 0.0;
			var weights = new Vector<Vector<Float>>();
			var matrixIndexs = new Vector<Vector<Int>>();
			
			
			var j:Int = 0;
			for (i in 0...skin.vcount.length) {
				var mweight = new Vector<Float>();
				weights.push(mweight);
				var matrixIndex = new Vector<Int>();
				matrixIndexs.push(matrixIndex);
				var len:Int = skin.vcount[i] * 2 + j;
				while (j < len ) {
					matrixIndex.push(skin.v[j]);
					var w:Float = skin.weights[skin.v[j + 1]];
					mweight.push(w);
					j += 2;
				}
				maxWeightLen = Math.max(maxWeightLen, matrixIndex.length);
			}
			// TODO : maxWeightLen
			maxWeightLen = 3;
			
			skin.draws = new Vector<SkinDrawAble>();
			
			var daeIndexs =new Vector<Vector<Int>>();
			var daeUVIndexs =new Vector<Vector<Int>>();
			var i = 0;
			var maxn = 39;
			while (i < skin.daeIndexs.length) {
				var indexs = skin.daeIndexs[i];
				var uvs = skin.daeUVIndexs[i];
				var mimap = new Map<Int,Bool>();
				var count = 0;
				for (index in indexs) {
					for (j in 0...matrixIndexs[index].length) {
						var mi = matrixIndexs[index][j];
						if (mimap.get(mi)==null) {
							mimap.set(mi, true);
							count++;
							if (count>maxn) {
								break;
							}
						}
					}
					if (count > maxn) {
						break;
					}
				}
				if (count > maxn) {
					i++;
					continue;
				}
				for (j in i + 1...skin.daeIndexs.length) {
					var indexs2 = skin.daeIndexs[j];
					var uv2 = skin.daeUVIndexs[j];
					for (index in indexs2) {
						for (j in 0...matrixIndexs[index].length) {
							var mi = matrixIndexs[index][j];
							if (mimap.get(mi)==null) {
								mimap.set(mi, true);
								count++;
								if (count>maxn) {
									break;
								}
							}else {
							}
						}
						if (count>maxn) {
							break;
						}
					}
					if (count>maxn) {
						break;
					}else {
						indexs = indexs.concat(indexs2);
						uvs = uvs.concat(uv2);
						i++;
					}
				}
				daeIndexs.push(indexs);
				daeUVIndexs.push(uvs);
				i++;
			}
			
			for (a in 0...daeIndexs.length) {
				var indexs = daeIndexs[a];
				var uvsi = daeUVIndexs[a];
				var skinDrawAble = new SkinDrawAble();
				var newIndexs = new Vector<#if flash UInt #else Int #end>(indexs.length);
				var i2newi = new Map<Int,Int>();
				var vs = skin.daeXyz;
				var uvs = skin.daeUV;
				var newVs  = new Vector<Float>(vs.length);
				var newUVs  = new Vector<Float>(vs.length);
				var newWeights  = new Vector<Float>(Std.int(weights.length * maxWeightLen));
				var newMatrixIndexs  = new Vector<Float>(Std.int(weights.length * maxWeightLen));
				var newi = 0;
				var maxNowi = 0;
				
				var newiM = 0;
				var i2newiM = new Map<Int,Int>();
				var newMatrixs:Vector<Int> = new Vector<Int>();
				
				for (i in 0...indexs.length) {
					var oldi = indexs[i];
					var oldUVI = uvsi[i];
					if (!i2newi.exists(oldi)) {
						i2newi.set(oldi, newi);
						maxNowi = Std.int(Math.max(newi, maxNowi));
						newi++;
					}
					var nowi = i2newi.get(oldi);
					
					newIndexs[i] = nowi;
					for (j in 0...3) {
						newVs[nowi * 3 + j] = vs[oldi * 3 + j];
					}
					//for (j in 0...2) {
						newUVs[nowi * 2] = uvs[oldUVI * 3];
						newUVs[nowi * 2 + 1] = 1 - uvs[oldUVI * 3 + 1];
					//}
					for (j in 0...weights[oldi].length) {
						newWeights[Std.int(nowi * maxWeightLen + j)] = weights[oldi][j];
					}
					for (j in 0...matrixIndexs[oldi].length) {
						var mi = matrixIndexs[oldi][j];
						if (!i2newiM.exists(mi)) {
							i2newiM.set(mi, newiM);
							newMatrixs.push(mi);
							newiM++;
						}
						var nowiM = i2newiM.get(mi);
						newMatrixIndexs[Std.int(nowi * maxWeightLen + j)] = nowiM * 3 + 3;
					}
				}
				if (newMatrixs.length > 39) {
					continue;
				}
				skin.draws.push(skinDrawAble);
				skinDrawAble.cacheBytes = new Vector<ByteArraySet>();
				var temp = new Matrix3D();
				for (cmatrixs in skin.cacheMatrixs) {
					var catchVector = new Vector<Float>(16);
					var catchByte = new ByteArray();
					catchByte.endian = Endian.LITTLE_ENDIAN;
					temp.copyRawDataTo(catchVector, 0, true);
					for (j in 0...12) {
						catchByte.writeFloat(catchVector[j]);
					}
					for (i in 0...newMatrixs.length) {
						cmatrixs[newMatrixs[i]].copyRawDataTo(catchVector,0, true);
						for (j in 0...12) {
							catchByte.writeFloat(catchVector[j]);
						}
					}
					catchByte.position = 0;
					
					var byteSet = new ByteArraySet();
					skinDrawAble.cacheBytes.push(byteSet);
					byteSet.byteArrayOffset = 0;
					byteSet.data = catchByte;
					byteSet.numRegisters = Std.int((newMatrixs.length + 1) * 3);
				}
				
				newWeights.length = newMatrixIndexs.length = newVs.length = (maxNowi + 1) * 3;
				newUVs.length = (maxNowi + 1) * 2;
				skinDrawAble.weightBuff = new VertexBufferSet(Std.int(newWeights.length/maxWeightLen), Std.int(maxWeightLen), newWeights, 0,Instance3D.getInstance());
				skinDrawAble.matrixBuff = new VertexBufferSet(Std.int(newWeights.length / maxWeightLen), Std.int(maxWeightLen), newMatrixIndexs, 0,Instance3D.getInstance());
				skinDrawAble.xyz = new VertexBufferSet(Std.int(newVs.length/3), 3, newVs, 0,Instance3D.getInstance());
				skinDrawAble.uv = new VertexBufferSet(Std.int(newUVs.length/2), 2, newUVs, 0,Instance3D.getInstance());
				skinDrawAble.indexBufferSet = new IndexBufferSet(newIndexs.length, newIndexs, 0,Instance3D.getInstance());
				MeshUtils.computeNorm(skinDrawAble);
				skinDrawAble.material = new SkinMaterial(skin, Std.random(0xffffff), Std.random(0xffffff), new BasicLight3D());
				skinDrawAble.xyz.init();
				skinDrawAble.uv.init();
				skinDrawAble.norm.init();
				skinDrawAble.indexBufferSet.init();
				skinDrawAble.weightBuff.init();
				skinDrawAble.matrixBuff.init();
				skin.node.drawAble = new DrawAble3D();
				skin.node.drawAble.radius = MeshUtils.computeRadius(vs);
				skin.node.material=new SkinMaterial(skin, Std.random(0xffffff), Std.random(0xffffff), new BasicLight3D());
			}
		}
		
	}
	
}