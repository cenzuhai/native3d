package lz.native3d.core ;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Lib;
import flash.Vector;
//{
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	class BasicDoTransform3D 
	{
		private var passNodes:Vector<Node3D>;
		private var rawData:Vector<Float> ;
		public function new() 
		{
			passNodes = new Vector<Node3D>();
			rawData = new Vector<Float>(#if flash 16 #end);
		}
		
		inline public function doTransform(nodes:Vector<Node3D>):Vector<Node3D> {
			#if flash
			passNodes.length = 0;
			#else
			passNodes = new Vector<Node3D>();
			#end
			doTransformNodes(nodes,false);
			return passNodes;
		}
		public function doTransformNodes(nodes:Vector<Node3D>,parentMatrixChanged:Bool=false):Void {
			for(i in 0...nodes.length)
			{
				var node:Node3D = nodes[i];
				doTransformNode(node,parentMatrixChanged);
			}
		}
		public function doTransformNode(node:Node3D, parentMatrixChanged:Bool):Void {
			if (node.compsVersion>node.matrixVersion) {
				node.matrix.recompose(node.comps);
				parentMatrixChanged = true;
				node.matrixVersion = node.compsVersion;
			}
			if (node.worldVersion!=node.matrixVersion) {
				parentMatrixChanged = true;
			}
			if (parentMatrixChanged) {
				#if flash
				node.worldMatrix.copyFrom(node.matrix);
				#else
				node.worldMatrix.rawData = node.matrix.rawData.copy();
				#end
				node.worldMatrix.append(node.parent.worldMatrix);
				
				#if flash
				node.worldMatrix.copyRawDataTo(node.worldRawData);
				#else
				node.worldRawData = node.worldMatrix.rawData;
				#end
				
				node.worldVersion++;
				if (node.matrixVersion == node.compsVersion) {
					node.compsVersion = node.worldVersion;
				}else {
					node.compsVersion = node.worldVersion - 1;
				}
				node.matrixVersion = node.worldVersion;
				
			}
			if (node.drawAble != null) {
				passNodes.push(node);
			}
			
			for (i in 0...node.children.length)
			{
				var cnode:Node3D = node.children[i];
				doTransformNode(cnode,parentMatrixChanged);
			}
		}
		
		inline public function doTransformCamera(camera:Camera3D):Void {
			doTransformNode(camera, false);
			if (camera.invertVersion != camera.worldVersion) {
				#if flash
				camera.invert.copyFrom(camera.worldMatrix);
				#else
				camera.invert.rawData = camera.worldMatrix.rawData.copy();
				#end
				
				camera.invert.invert();
				
				#if flash
				camera.perspectiveProjectionMatirx.copyFrom(camera.invert);
				#else
				camera.perspectiveProjectionMatirx.rawData = camera.invert.rawData.copy();
				#end
				
				camera.perspectiveProjectionMatirx.append(camera.perspectiveProjection);
				camera.invertVersion = camera.worldVersion;
				
				#if flash
				camera.perspectiveProjectionMatirx.copyRawDataTo(rawData,0,true);//testMatr.rawData;//camera.perspectiveProjectionMatirx.rawData;
				#else
				rawData = camera.perspectiveProjectionMatirx.rawData.copy();// TODO : xxx
				#end
				
				var plane:Vector3D;
	 
				var frustumPlanes:Vector<Vector3D> = camera.frustumPlanes;
				//http://jacksondunstan.com/articles/1811
				// left = row1 + row4
				if(frustumPlanes!=null){
					plane = frustumPlanes[0];
					plane.x = rawData[0] + rawData[12];
					plane.y = rawData[1] + rawData[13];
					plane.z = rawData[2] + rawData[14];
					plane.w = rawData[3] + rawData[15];
		 
					// right = -row1 + row4
					plane = frustumPlanes[1];
					plane.x = -rawData[0] + rawData[12];
					plane.y = -rawData[1] + rawData[13];
					plane.z = -rawData[2] + rawData[14];
					plane.w = -rawData[3] + rawData[15];
		 
					// bottom = row2 + row4
					plane = frustumPlanes[2];
					plane.x = rawData[4] + rawData[12];
					plane.y = rawData[5] + rawData[13];
					plane.z = rawData[6] + rawData[14];
					plane.w = rawData[7] + rawData[15];
		 
					// top = -row2 + row4
					plane = frustumPlanes[3];
					plane.x = -rawData[4] + rawData[12];
					plane.y = -rawData[5] + rawData[13];
					plane.z = -rawData[6] + rawData[14];
					plane.w = -rawData[7] + rawData[15];
		 
					// near = row3 + row4
					plane = frustumPlanes[4];
					plane.x = rawData[8] /*+ rawData[12]*/;
					plane.y = rawData[9] /*+ rawData[13]*/;
					plane.z = rawData[10] /*+ rawData[14]*/;
					plane.w = rawData[11] /*+ rawData[15]*/;
		 
					// far = -row3 + row4
					plane = frustumPlanes[5];
					plane.x = -rawData[8] + rawData[12];
					plane.y = -rawData[9] + rawData[13];
					plane.z = -rawData[10] + rawData[14];
					plane.w = -rawData[11] + rawData[15];
				}
			}
		}
		
		
	}

//}