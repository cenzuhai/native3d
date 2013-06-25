/*
 * bsp.js
 * 
 * Copyright (c) 2012, Bernhard Manfred Gruber. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */
package lz.native3d.parsers;
import flash.display.BitmapData;
import flash.display3D.Context3DTextureFormat;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.Vector;
import lz.native3d.core.DrawAble3D;
import lz.native3d.core.IndexBufferSet;
import lz.native3d.core.Node3D;
import lz.native3d.core.TextureSet;
import lz.native3d.core.VertexBufferSet;
import lz.native3d.meshs.MeshUtils;
/**
 * https://github.com/dixxi/hlbsp
	 * Responsible for loading, storing and rendering the bsp tree.
 * @author lizhi http://matrix3d.github.io/
 */
class BSP30Parser extends AbsParser
{
	public var header:BspHeader;
	private var nodes:Vector<BspNode>;
	private var leaves:Vector<BspLeaf>;
	private var markSurfaces:Vector<Int>;
	private var planes:Vector<BspPlane>;
	private var vertices:Vector<Vector3D>;// actually not needed for rendering, vertices are stored in vertexBuffer. But just in case someone needs them for e.g. picking etc.
	private var edges:Vector<BspEdge>;
	private var faces:Vector<BspFace>;
	private var surfEdges:Vector<Int>;
	private var textureHeader:BspTextureHeader;
	private var mipTextures:Vector<BspMipTexture>;
	private var textureInfos:Vector<BspTextureInfo>;
	private var models:Vector<BspModel>;
	private var clipNodes:Vector<BspClipNode>;
	
	/** Array of Entity objects. @see Entity */
	private var entities:Vector<Entity>;
	
	/** References to the entities that are brush entities. Array of Entity references. */
	private var brushEntities:Vector<Entity>;
	
	//
	// Calculated
	//
	
	/** Stores the missing wads for this bsp file */
	//private var missingWads;

	/** Array (for each face) of arrays (for each vertex of a face) of JSONs holding s and t coordinate. */
	private var textureCoordinates:Vector<Vector<Point>>;
	//private var lightmapCoordinates;
	
	/**
	 * Contains a plan white 1x1 texture to be used, when a texture could not be loaded yet.
	 */
	private var whiteTexture:TextureSet;
	
	/** 
	 * Stores the texture IDs of the textures for each face.
	 * Most of them will be dummy textures until they are later loaded from the Wad files.
	 */
	private var textureLookup:Vector<TextureSet>;
	
	/** Stores the texture IDs of the lightmaps for each face */
	//private var lightmapLookup;
	
	/** Stores a list of missing textures */
	private var missingTextures:Vector<TextureSet>;
	
	/** An array (for each leaf) of arrays (for each leaf) of booleans. */
	//private var visLists;
	
	public var drawAble:DrawAble3D;
	public function new(data:Dynamic) 
	{
		super(data);
	}
	override public function parser():Void {
		var src = cast(data, ByteArray);
		src.endian = Endian.LITTLE_ENDIAN;
		readHeader(src);
		
		 readNodes(src);
		readLeaves(src);
		readMarkSurfaces(src);
		readPlanes(src);
		readVertices(src);
		readEdges(src);
		readFaces(src);
		readSurfEdges(src);
		readMipTextures(src);
		readTextureInfos(src);
		readModels(src);
		readClipNodes(src);
		
		loadEntities(src);   // muast be loaded before textures
		loadTextures(src);   // plus coordinates
		//loadLightmaps(src);  // plus coordinates
		//loadVIS(src);
		
		// FINALLY create buffers for rendering
		preRender();
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	private function readHeader(src:ByteArray):Void {
		header = new BspHeader();
		header.version = src.readInt();
		header.lumps = new Vector<BspLump>();
		for (i in 0...BspDef.HEADER_LUMPS) {
			var lump = new BspLump();
			lump.offset = src.readInt();
			lump.length = src.readInt();
			header.lumps.push(lump);
		}
	}
	private function readNodes(src:ByteArray):Void
	{
		src.position=this.header.lumps[BspDef.LUMP_NODES].offset;
		
		this.nodes = new Vector<BspNode>();

		for(i in 0...Std.int(this.header.lumps[BspDef.LUMP_NODES].length / BspDef.SIZE_OF_BSPNODE))
		{
			var node = new BspNode();
			
			node.plane = src.readUnsignedInt();
			
			node.children = new Vector<Int>();
			node.children.push(src.readShort());
			node.children.push(src.readShort());
			
			node.mins = new Vector<Int>();
			node.mins.push(src.readShort());
			node.mins.push(src.readShort());
			node.mins.push(src.readShort());
			
			node.maxs = new Vector<Int>();
			node.maxs.push(src.readShort());
			node.maxs.push(src.readShort());
			node.maxs.push(src.readShort());
			
			node.firstFace = src.readUnsignedShort();
			node.faces = src.readUnsignedShort();
			
			this.nodes.push(node);
		}
	}
	
	private function readLeaves(src:ByteArray):Void
	{
		src.position =this.header.lumps[BspDef.LUMP_LEAVES].offset;
		
		this.leaves = new Vector<BspLeaf>();

		for(i in 0... Std.int(this.header.lumps[BspDef.LUMP_LEAVES].length / BspDef.SIZE_OF_BSPLEAF))
		{
			var leaf = new BspLeaf();
			
			leaf.content = src.readInt();
			
			leaf.visOffset = src.readInt();
			
			leaf.mins = new Vector<Int>();
			leaf.mins.push(src.readShort());
			leaf.mins.push(src.readShort());
			leaf.mins.push(src.readShort());
			
			leaf.maxs = new Vector<Int>();
			leaf.maxs.push(src.readShort());
			leaf.maxs.push(src.readShort());
			leaf.maxs.push(src.readShort());
			
			leaf.firstMarkSurface = src.readUnsignedShort();
			
			leaf.markSurfaces = src.readUnsignedShort();
			
			leaf.ambientLevels = new Vector<#if flash UInt #else Int #end>();
			leaf.ambientLevels.push(src.readUnsignedByte());
			leaf.ambientLevels.push(src.readUnsignedByte());
			leaf.ambientLevels.push(src.readUnsignedByte());
			leaf.ambientLevels.push(src.readUnsignedByte());
			
			this.leaves.push(leaf);
		}
	}
	
	private function readMarkSurfaces(src:ByteArray):Void
	{
		src.position = Std.int(this.header.lumps[BspDef.LUMP_MARKSURFACES].offset);
		
		this.markSurfaces = new Vector<Int>();

		for(i in 0...Std.int(this.header.lumps[BspDef.LUMP_MARKSURFACES].length / BspDef.SIZE_OF_BSPMARKSURFACE)){
			this.markSurfaces.push(src.readUnsignedShort());
		}
		
	}
	
	private function readPlanes (src:ByteArray):Void
	{
		src.position =this.header.lumps[BspDef.LUMP_PLANES].offset;
		
		this.planes = new Vector<BspPlane>();
		
		for(i in 0...Std.int(this.header.lumps[BspDef.LUMP_PLANES].length / BspDef.SIZE_OF_BSPPLANE))
		{
			var plane = new BspPlane();
			
			plane.normal = new Vector3D();
			plane.normal.x = src.readFloat();
			plane.normal.y = src.readFloat();
			plane.normal.z = src.readFloat();
			
			plane.dist = src.readFloat();
			
			plane.type = src.readUnsignedInt();
			
			this.planes.push(plane);
		}
	}
	
	private function readVertices(src:ByteArray):Void
	{
		src.position =this.header.lumps[BspDef.LUMP_VERTICES].offset;
		
		this.vertices = new Vector<Vector3D>();
		
		for(i in 0...Std.int(this.header.lumps[BspDef.LUMP_VERTICES].length / BspDef.SIZE_OF_BSPVERTEX))
		{
			var vertex = new Vector3D();
			
			vertex.x = src.readFloat();
			vertex.y = src.readFloat();
			vertex.z = src.readFloat();
			
			this.vertices.push(vertex);
		}
	}
	
	private function readEdges(src:ByteArray):Void
	{
		src.position=this.header.lumps[BspDef.LUMP_EDGES].offset;
		
		this.edges = new Vector<BspEdge>();
		
		for(i in 0...Std.int(this.header.lumps[BspDef.LUMP_EDGES].length / BspDef.SIZE_OF_BSPEDGE))
		{
			var edge = new BspEdge();
			
			edge.vertices = new Vector<Int>();
			edge.vertices.push(src.readUnsignedShort());
			edge.vertices.push(src.readUnsignedShort());
			
			this.edges.push(edge);
		}
	}
	
	private function readFaces(src:ByteArray):Void
	{
		src.position=this.header.lumps[BspDef.LUMP_FACES].offset;
		
		this.faces = new Vector<BspFace>();
		
		for(i in 0...Std.int(this.header.lumps[BspDef.LUMP_FACES].length / BspDef.SIZE_OF_BSPFACE))
		{
			var face = new BspFace();
			
			face.plane = src.readUnsignedShort();
			
			face.planeSide = src.readUnsignedShort();
			
			face.firstEdge = src.readUnsignedInt();
			
			face.edges = src.readUnsignedShort();
			
			face.textureInfo = src.readUnsignedShort();
			
			face.styles = new Vector<Int>();
			face.styles.push(src.readUnsignedByte());
			face.styles.push(src.readUnsignedByte());
			face.styles.push(src.readUnsignedByte());
			face.styles.push(src.readUnsignedByte());
			
			face.lightmapOffset = src.readUnsignedInt();
			
			this.faces.push(face);
		}
  
	}
	
	private function readSurfEdges (src:ByteArray):Void
	{
		src.position =this.header.lumps[BspDef.LUMP_SURFEDGES].offset;
		
		this.surfEdges = new Vector<Int>();

		for(i in 0...Std.int(this.header.lumps[BspDef.LUMP_SURFEDGES].length / BspDef.SIZE_OF_BSPSURFEDGE))
		{
			this.surfEdges.push(src.readUnsignedInt());
		}
	}
	
	private function readTextureHeader(src:ByteArray):Void
	{
		src.position=(this.header.lumps[BspDef.LUMP_TEXTURES].offset);
		
		this.textureHeader = new BspTextureHeader();
		
		this.textureHeader.textures = src.readUnsignedInt();
		
		this.textureHeader.offsets = new Vector<Int>();
		for(i in 0...Std.int(this.textureHeader.textures))
			this.textureHeader.offsets.push(src.readInt());
	}

	private function readMipTextures(src:ByteArray):Void
	{
		this.readTextureHeader(src);
		
		this.mipTextures = new Vector<BspMipTexture>();
		
		for(i in 0...Std.int(this.textureHeader.textures))
		{
			src.position=(this.header.lumps[BspDef.LUMP_TEXTURES].offset + this.textureHeader.offsets[i]);
			
			var miptex = new BspMipTexture();
			
			miptex.name = src.readUTFBytes(BspDef.MAXTEXTURENAME);
			
			miptex.width = src.readUnsignedInt();
			
			miptex.height = src.readUnsignedInt();
			
			miptex.offsets = new Vector<Int>();
			for(j in 0... BspDef.MIPLEVELS)
				miptex.offsets.push(src.readUnsignedInt());
			
			this.mipTextures.push(miptex);
		}
	}
	
	private function readTextureInfos(src:ByteArray):Void
	{
		src.position=(this.header.lumps[BspDef.LUMP_TEXINFO].offset);
		
		this.textureInfos = new Vector<BspTextureInfo>();
		
		for(i in 0...Std.int(this.header.lumps[BspDef.LUMP_TEXINFO].length / BspDef.SIZE_OF_BSPTEXTUREINFO))
		{
			var texInfo = new BspTextureInfo();
			
			texInfo.s = new Vector3D();
			texInfo.s.x = src.readFloat();
			texInfo.s.y = src.readFloat();
			texInfo.s.z = src.readFloat();
			
			texInfo.sShift = src.readFloat();
			
			texInfo.t = new Vector3D();
			texInfo.t.x = src.readFloat();
			texInfo.t.y = src.readFloat();
			texInfo.t.z = src.readFloat();
			
			texInfo.tShift = src.readFloat();
			
			texInfo.mipTexture = src.readUnsignedInt();
			
			texInfo.flags = src.readUnsignedInt();
			
			this.textureInfos.push(texInfo);
		}
	}
	
	private function readModels(src:ByteArray):Void
	{
		src.position=(this.header.lumps[BspDef.LUMP_MODELS].offset);
		
		this.models = new Vector<BspModel>();

		for(i in 0...Std.int(this.header.lumps[BspDef.LUMP_MODELS].length / BspDef.SIZE_OF_BSPMODEL))
		{
			var model = new BspModel();
			
			model.mins = new Vector<Float>();
			model.mins.push(src.readFloat());
			model.mins.push(src.readFloat());
			model.mins.push(src.readFloat());
			
			model.maxs = new Vector<Float>();
			model.maxs.push(src.readFloat());
			model.maxs.push(src.readFloat());
			model.maxs.push(src.readFloat());
			
			model.origin = new Vector3D();
			model.origin.x = src.readFloat();
			model.origin.y = src.readFloat();
			model.origin.z = src.readFloat();
			
			model.headNodes = new Vector<Int>();
			for(j in 0...BspDef.MAX_MAP_HULLS)
				model.headNodes.push(src.readInt());
				
			model.visLeafs = src.readInt();
			
			model.firstFace = src.readInt();
			
			model.faces = src.readInt();
			
			this.models.push(model);
		}
	}
	
	private function readClipNodes(src:ByteArray):Void
	{
		src.position=(this.header.lumps[BspDef.LUMP_CLIPNODES].offset);
		
		this.clipNodes = new Vector<BspClipNode>();

		for(i in 0...Std.int(this.header.lumps[BspDef.LUMP_CLIPNODES].length / BspDef.SIZE_OF_BSPCLIPNODE))
		{
			var clipNode = new BspClipNode();
			
			clipNode.plane = src.readInt();
			
			clipNode.children = new Vector<Int>();
			clipNode.children.push(src.readShort());
			clipNode.children.push(src.readShort());
			
			this.clipNodes.push(clipNode);
		}
	}
	
	/**
	 * Returns true if the given entity is a brush entity (an entity, that can be rendered directly as small bsp tree).
	 */
	private function isBrushEntity(entity:Entity):Bool
	{
		if (!entity.properties.exists("model"))
			return false;
			
		if(entity.properties.get("model").substring(0, 1) != '*')
			return false; // external model

		/*var className = entity.classname;
		if (className == "func_door_rotating" ||
			className == "func_door" ||
			className == "func_illusionary" ||
			className == "func_wall" ||
			className == "func_breakable" ||
			className == "func_button")
			return true;
		else
			return false;*/
			
		return true;
	}
	
	/**
	 * Loads and parses the entities from the entity lump.
	 */
	private function loadEntities(src:ByteArray):Void
	{
		src.position=this.header.lumps[BspDef.LUMP_ENTITIES].offset;
		
		var entityData = src.readUTFBytes(this.header.lumps[BspDef.LUMP_ENTITIES].length);
		
		this.entities = new Vector<Entity>();
		this.brushEntities = new Vector<Entity>();
		
		var end = -1;
		while(true)
		{
			var begin = entityData.indexOf('{', end + 1);
			if(begin == -1)
				break;
			
			end = entityData.indexOf('}', begin + 1);
			
			var entityString = entityData.substring(begin + 1, end);
			
			var entity = new Entity(entityString);
			
			if(this.isBrushEntity(entity))
				this.brushEntities.push(entity);
			
			this.entities.push(entity);
		}
		
		//console.log('Read ' + this.entities.length + ' Entities (' + this.brushEntities.length + ' Brush Entities)');
	}
	
	/**
	 * Tries to load the texture identified by name from the loaded wad files.
	 *
	 * @return Returns the texture identifier if the texture has been found, otherwise null.
	 */
	private function loadTextureFromWad(name):TextureSet
	{
		/*var texture = null;
		for(var k = 0; k < loadedWads.length; k++)
		{
			texture = loadedWads[k].loadTexture(name);
			if(texture != null)
				break;
		}
		
		return texture;*/
		return null;
	}
	
	/**
	 * Loads all the texture data from the bsp file and generates texture coordinates.
	 */
	private function loadTextures(src:ByteArray)
	{
		return;
		this.textureCoordinates = new Vector<Vector<Point>>();
		
		//
		// Texture coordinates
		//
		
		for (i in 0...this.faces.length)
		{
			var face = this.faces[i];
			var texInfo = this.textureInfos[face.textureInfo];
			
			var faceCoords = new Vector<Point>();

			for (j in 0...face.edges)
			{
				var edgeIndex = this.surfEdges[face.firstEdge + j];

				var vertexIndex;
				if (edgeIndex > 0)
				{
					var edge = this.edges[edgeIndex];
					vertexIndex = edge.vertices[0];
				}
				else
				{
					edgeIndex *= -1;
					var edge = this.edges[edgeIndex];
					vertexIndex = edge.vertices[1];
				}
				
				var vertex = this.vertices[vertexIndex];
				var mipTexture = this.mipTextures[texInfo.mipTexture];
				
				var coord = new Point(
					/*s : */(vertex.dotProduct(texInfo.s) + texInfo.sShift) / mipTexture.width,
					/*t : */(vertex.dotProduct(texInfo.t) + texInfo.tShift) / mipTexture.height
				);
				
				faceCoords.push(coord);
			}
			
			this.textureCoordinates.push(faceCoords);
		}
		
		//
		// Texture images
		//
		
		// Create white texture
		this.whiteTexture =  new TextureSet();
		var bmd:BitmapData = new BitmapData(128, 128, false);
		bmd.perlinNoise(20, 20, 3, 1, true, true);
		this.whiteTexture.setBmd(bmd, Context3DTextureFormat.BGRA);
		/*pixelsToTexture(new Array(255, 255, 255), 1, 1, 3, function(texture, image)
		{
			gl.bindTexture(gl.TEXTURE_2D, texture);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR_MIPMAP_LINEAR);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
			gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, gl.RGB, gl.UNSIGNED_BYTE, image);
			gl.generateMipmap(gl.TEXTURE_2D);
			gl.bindTexture(gl.TEXTURE_2D, null);
		});*/

		
		this.textureLookup = new Vector<TextureSet>(this.faces.length);
		this.missingTextures = new Vector<TextureSet>();
		
		for(i in 0...this.mipTextures.length)
		{
			var mipTexture = this.mipTextures[i];
			
			if(mipTexture.offsets[0] == 0)
			{
				//
				// External texture
				//
			
				// search texture in loaded wads
				var texture = this.loadTextureFromWad(mipTexture.name);
				
				if(texture != null)
				{
					// the texture has been found in a loaded wad
					this.textureLookup[i] = texture;
					
					//console.log("Texture " + mipTexture.name + " found");
				}
				else
				{
					// bind simple white texture to do not disturb lightmaps
					this.textureLookup[i] = this.whiteTexture;
				
					// store the name and position of this missing texture,
					// so that it can later be loaded to the right position by calling loadMissingTextures()
					//this.missingTextures.push({ name: mipTexture.name, index: i });
					
					//console.log("Texture " + mipTexture.name + " is missing");
				}
				
				continue; 
			}
			else
			{
				//
				// Load internal texture if present
				//
				
				// Calculate offset of the texture in the bsp file
				var offset = this.header.lumps[BspDef.LUMP_TEXTURES].offset + this.textureHeader.offsets[i];
				
				// Use the texture loading procedure from the Wad class
				this.textureLookup[i] = null;//Wad.prototype.fetchTextureAtOffset(src, offset);
				
				//console.log("Fetched interal texture " + mipTexture.name);
			}
		}
		
		// Now that all dummy texture unit IDs have been created, alert the user to select wads for them
		//this.showMissingWads();
	}
	
	/**
	 * Runs through all faces and generates the OpenGL buffers required for rendering.
	 */
	private function preRender()
	{
		var ixs = new Vector<UInt>();
		for (i in 0...faces.length) {
			var face = faces[i];
			var sixs = new Vector<UInt>();
			for (j in 2...face.edges) {
				var edgeIndex = surfEdges[face.firstEdge + j];
				var vertexIndex;
				if (edgeIndex>0) {
					var edge = edges[edgeIndex];
					vertexIndex = edge.vertices[0];
				}else {
					edgeIndex *= -1;
					var edge = edges[edgeIndex];
					vertexIndex = edge.vertices[1];
				}
				sixs.push(vertexIndex);
			}
			for (j in 2...sixs.length) {
				ixs.push(sixs[j]);
				ixs.push(sixs[j-1]);
				ixs.push(sixs[0]);
			}
		}
		
		var vs = new Vector<Float>();
		for (v in vertices) {
			vs.push(v.x);
			vs.push(v.y);
			vs.push(v.z);
		}
		drawAble = new DrawAble3D();
		drawAble.xyz = new VertexBufferSet(untyped vs.length / 3, 3, vs, 0);
		drawAble.indexBufferSet = new IndexBufferSet(ixs.length, ixs, 0);
		MeshUtils.computeNorm(drawAble);
		
		/*var vertices = new Array();
		var texCoords = new Array();
		var lightmapCoords = new Array();
		var normals = new Array();
		
		this.faceBufferRegions = new Array(this.faces.length);
		var elements = 0;

		// for each face
		for(var i = 0; i < this.faces.length; i++)
		{
			var face = this.faces[i];
		
			this.faceBufferRegions[i] = {
				start : elements,
				count : face.edges
			};
			
			var texInfo = this.textureInfos[face.textureInfo];
			var plane = this.planes[face.plane];
			
			var normal = plane.normal;
			
			var faceTexCoords = this.textureCoordinates[i];
			var faceLightmapCoords = this.lightmapCoordinates[i];
			
			for (var j = 0; j < face.edges; j++)
			{
				var edgeIndex = this.surfEdges[face.firstEdge + j]; // This gives the index into the edge lump

				var vertexIndex;
				if (edgeIndex > 0)
				{
					var edge = this.edges[edgeIndex];
					vertexIndex = edge.vertices[0];
				}
				else
				{
					edgeIndex *= -1;
					var edge = this.edges[edgeIndex];
					vertexIndex = edge.vertices[1];
				}
				
				var vertex = this.vertices[vertexIndex];
				
				var texCoord = faceTexCoords[j];
				var lightmapCoord = faceLightmapCoords[j];
				
				// Write to buffers
				vertices.push(vertex.x);
				vertices.push(vertex.y);
				vertices.push(vertex.z);
				
				texCoords.push(texCoord.s);
				texCoords.push(texCoord.t);
				
				lightmapCoords.push(lightmapCoord.s);
				lightmapCoords.push(lightmapCoord.t);
				
				normals.push(normal.x);
				normals.push(normal.y);
				normals.push(normal.z);
				
				elements += 1;
			}
		}

		// Create ALL the buffers !!!
		this.vertexBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, this.vertexBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(vertices), gl.STATIC_DRAW); 
		
		this.texCoordBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, this.texCoordBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(texCoords), gl.STATIC_DRAW); 
		
		this.lightmapCoordBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, this.lightmapCoordBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(lightmapCoords), gl.STATIC_DRAW); 
		
		this.normalBuffer = gl.createBuffer();
		gl.bindBuffer(gl.ARRAY_BUFFER, this.normalBuffer);
		gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(normals), gl.STATIC_DRAW); */
	}
	
}


class BspDef{
/*
 * bspdef.js
 * 
 * Copyright (c) 2012, Bernhard Manfred Gruber. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */

/**
 * Contains the standard BSP v30 file definitions.
 * For closer information visit my hlbsp project:
 * http://hlbsp.sourceforge.net/index.php?content=bspdef
 */

public static var MAX_MAP_HULLS        = 4;

public static var MAX_MAP_MODELS       = 400;
public static var MAX_MAP_BRUSHES      = 4096;
public static var MAX_MAP_ENTITIES     = 1024;
public static var MAX_MAP_ENTSTRING    = (128*1024);

public static var MAX_MAP_PLANES       = 32767;
public static var MAX_MAP_NODES        = 32767; // because negative shorts are leaves
public static var MAX_MAP_CLIPNODES    = 32767; //
public static var MAX_MAP_LEAFS        = 8192;
public static var MAX_MAP_VERTS        = 65535;
public static var MAX_MAP_FACES        = 65535;
public static var MAX_MAP_MARKSURFACES = 65535;
public static var MAX_MAP_TEXINFO      = 8192;
public static var MAX_MAP_EDGES        = 256000;
public static var MAX_MAP_SURFEDGES    = 512000;
public static var MAX_MAP_TEXTURES     = 512;
public static var MAX_MAP_MIPTEX       = 0x200000;
public static var MAX_MAP_LIGHTING     = 0x200000;
public static var MAX_MAP_VISIBILITY   = 0x200000;

public static var MAX_MAP_PORTALS      = 65536;

public static var MAX_KEY              = 32;
public static var MAX_VALUE            = 1024;

// BSP-30 files contain these lumps
public static var LUMP_ENTITIES     = 0;
public static var LUMP_PLANES       = 1;
public static var LUMP_TEXTURES     = 2;
public static var LUMP_VERTICES     = 3;
public static var LUMP_VISIBILITY   = 4;
public static var LUMP_NODES        = 5;
public static var LUMP_TEXINFO      = 6;
public static var LUMP_FACES        = 7;
public static var LUMP_LIGHTING     = 8;
public static var LUMP_CLIPNODES    = 9;
public static var LUMP_LEAVES       = 10;
public static var LUMP_MARKSURFACES = 11;
public static var LUMP_EDGES        = 12;
public static var LUMP_SURFEDGES    = 13;
public static var LUMP_MODELS       = 14;
public static var HEADER_LUMPS      = 15;

// Leaf content values
public static var CONTENTS_EMPTY        = -1;
public static var CONTENTS_SOLID        = -2;
public static var CONTENTS_WATER        = -3;
public static var CONTENTS_SLIME        = -4;
public static var CONTENTS_LAVA         = -5;
public static var CONTENTS_SKY          = -6;
public static var CONTENTS_ORIGIN       = -7;
public static var CONTENTS_CLIP         = -8;
public static var CONTENTS_CURRENT_0    = -9;
public static var CONTENTS_CURRENT_90   = -10;
public static var CONTENTS_CURRENT_180  = -11;
public static var CONTENTS_CURRENT_270  = -12;
public static var CONTENTS_CURRENT_UP   = -13;
public static var CONTENTS_CURRENT_DOWN = -14;
public static var CONTENTS_TRANSLUCENT  = -15;

//Plane types
public static var PLANE_X    = 0; // Plane is perpendicular to given axis
public static var PLANE_Y    = 1;
public static var PLANE_Z    = 2;
public static var PLANE_ANYX = 3; // Non-axial plane is snapped to the nearest
public static var PLANE_ANYY = 4;
public static var PLANE_ANYZ = 5;

// Render modes
public static var RENDER_MODE_NORMAL   = 0;
public static var RENDER_MODE_COLOR    = 1;
public static var RENDER_MODE_TEXTURE  = 2;
public static var RENDER_MODE_GLOW     = 3;
public static var RENDER_MODE_SOLID    = 4;
public static var RENDER_MODE_ADDITIVE = 5;



	public static var SIZE_OF_BSPNODE = 24;
	public static var SIZE_OF_BSPLEAF = 28;
// Leaves index into marksurfaces, which index into pFaces
/*
typedef #if flash UInt #else Int #end16_t BSPMARKSURFACE;
*/
public static var SIZE_OF_BSPMARKSURFACE  = 2;


public static var SIZE_OF_BSPPLANE = 20;

// Vertex lump is an array of float triples (VECTOR3D)
/*
typedef VECTOR3D BSPVERTEX;
*/
public static var SIZE_OF_BSPVERTEX = 12;


public static var SIZE_OF_BSPEDGE = 4;


public static var SIZE_OF_BSPFACE = 20;


// Surfedges lump is an array of signed int indices into the edge lump, where a negative index indicates
// using the referenced edge in the opposite direction. Faces index into surfEdges, which index
// into edges, which finally index into vertices.
/*
typedef int32_t BSPSURFEDGE;
*/
public static var SIZE_OF_BSPSURFEDGE = 4;

// 32-bit offsets (within texture lump) to (nMipTextures) BSPMIPTEX structures
/*
typedef int32_t BSPMIPTEXOFFSET;
*/
public static var SIZE_OF_BSPMIPTEXOFFSET = 4;

// BSPMIPTEX structures which defines a texture
public static var MAXTEXTURENAME = 16;
public static var MIPLEVELS = 4;

public static var SIZE_OF_BSPTEXTUREINFO = 40;
public static var SIZE_OF_BSPMODEL = 64;
public static var SIZE_OF_BSPCLIPNODE = 8;
}
/*
typedef struct _VECTOR3D
{
	float x, y, z;
} VECTOR3D;
*/
// @see mathlib.js Vector3D

// Describes a lump in the BSP file
/*
typedef struct _BSPLUMP
{
	int32_t nOffset;
	int32_t nLength;
} BSPLUMP;
*/
class BspLump
{
    public var offset:Int; // File offset to data
    public var length:Int; // Length of data
	public function new(){}
}

// The BSP file header
/*
typedef struct _BSPHEADER
{
	int32_t nVersion;		
	BSPLUMP lump[HEADER_LUMPS];
} BSPHEADER;
*/
class BspHeader
{
    public var version:Int; // Version number, must be 30 for a valid HL BSP file
    public var lumps:Vector<BspLump>;   // Stores the directory of lumps as array of BspLump (HEADER_LUMPS elements)
	public function new(){}
}

// Describes a node of the BSP Tree
/*
typedef struct _BSPNODE
{
	#if flash UInt #else Int #end32_t iPlane;			 
	int16_t  iChildren[2];		 
	int16_t  nMins[3], nMaxs[3]; 
	#if flash UInt #else Int #end16_t iFirstFace, nFaces;  
} BSPNODE;
*/
class BspNode
{
    public var plane:Int;     // Index into pPlanes lump
    public var children:Vector<Int>;  // If > 0, then indices into Nodes otherwise bitwise inverse indices into Leafs
	public var mins:Vector<Int>;      // Bounding box
	public var maxs:Vector<Int>;
	public var firstFace:Int; // Index and count into BSPFACES array
	public var faces:Int;
	public function new(){}
}


// Leafs lump contains leaf structures
/*
typedef struct _BSPLEAF
{
	int32_t  nContents;			              
	int32_t  nVisOffset;		              
	int16_t  nMins[3], nMaxs[3];             
	#if flash UInt #else Int #end16_t iFirstMarkSurface, nMarkSurfaces;
	#if flash UInt #else Int #end8_t  nAmbientLevels[4];	        
} BSPLEAF;
*/
class BspLeaf
{
    public var content:Int;          // Contents enumeration, see vars
   public var visOffset:Int;        // Offset into the compressed visibility lump
	public	var mins:Vector<Int>;             // Bounding box
	public var maxs:Vector<Int>;
	public var firstMarkSurface:Int; // Index and count into BSPMARKSURFACE array
	public var markSurfaces:Int;
	public var ambientLevels:Vector<#if flash UInt #else Int #end>;    // Ambient sound levels  
	public function new(){}
}

// Planes lump contains plane structures
/*
typedef struct _BSPPLANE
{
	VECTOR3D vNormal; 
	float    fDist;  
	int32_t  nType; 
} BSPPLANE;
*/
class BspPlane
{
    public var normal:Vector3D; // The planes normal vector
    public var dist:Float;   // Plane equation is: vNormal * X = fDist
   public  var type:Int;   // Plane type, see vars
	public function new(){}
}
// Edge struct contains the begining and end vertex for each edge
/*
typedef struct _BSPEDGE
{
    #if flash UInt #else Int #end16_t iVertex[2];        
};
*/
class BspEdge
{
	public var vertices:Vector<Int>; // Indices into vertex array
	public function new(){}
}
// Faces are equal to the polygons that make up the world
/*
typedef struct _BSPFACE
{
    #if flash UInt #else Int #end16_t iPlane;                // Index of the plane the face is parallel to
    #if flash UInt #else Int #end16_t nPlaneSide;            // Set if different normals orientation
    #if flash UInt #else Int #end32_t iFirstEdge;            // Index of the first edge (in the surfedge array)
    #if flash UInt #else Int #end16_t nEdges;                // Number of consecutive surfedges
    #if flash UInt #else Int #end16_t iTextureInfo;          // Index of the texture info structure
    #if flash UInt #else Int #end8_t  nStyles[4];            // Specify lighting styles
    //       nStyles[0]             // type of lighting, for the face
    //       nStyles[1]             // from 0xFF (dark) to 0 (bright)
    //       nStyles[2], nStyles[3] // two additional light models
    #if flash UInt #else Int #end32_t nLightmapOffset;    // Offsets into the raw lightmap data
};
*/
class BspFace
{
   public  var plane:Int;               // Index of the plane the face is parallel to
   public  var planeSide:Int;           // Set if different normals orientation
   public  var firstEdge:Int;           // Index of the first edge (in the surfedge array)
   public  var edges:Int;               // Number of consecutive surfedges
    public var textureInfo:Int;         // Index of the texture info structure
    public var styles:Vector<Int>;           // Specify lighting styles
    //  styles[0]            // type of lighting, for the face
    //  styles[1]            // from 0xFF (dark) to 0 (bright)
    //  styles[2], styles[3] // two additional light models
    public var lightmapOffset:Int;      // Offsets into the raw lightmap data
	public function new(){}
}

// Textures lump begins with a header, followed by offsets to BSPMIPTEX structures, then BSPMIPTEX structures
/*
typedef struct _BSPTEXTUREHEADER
{
    #if flash UInt #else Int #end32_t nMipTextures;
};
*/
class BspTextureHeader
{
	public var textures:Int; // Number of BSPMIPTEX structures
	public var offsets:Vector<Int>;  // Array of offsets to the textures
	public function new(){}
}

/*
typedef struct _BSPMIPTEX
{
    char     szName[MAXTEXTURENAME]; 
    #if flash UInt #else Int #end32_t nWidth, nHeight;        
    #if flash UInt #else Int #end32_t nOffsets[MIPLEVELS];
};
*/
class BspMipTexture
{
	public var name:String;    // Name of texture, for reference from external WAD file
	public var width:Int;   // Extends of the texture
	public var height:Int; 
	public var offsets:Vector<Int>; // Offsets to MIPLEVELS texture mipmaps, if 0 texture data is stored in an external WAD file
	public function new(){}
}

// Texinfo lump contains information about how textures are applied to surfaces
/*
typedef struct _BSPTEXTUREINFO
{
    VECTOR3D vS;      
    float    fSShift; 
    VECTOR3D vT;      
    float    fTShift; 
    #if flash UInt #else Int #end32_t iMiptex; 
    #if flash UInt #else Int #end32_t nFlags; 
};
*/
class BspTextureInfo
{
	public var s:Vector3D;          // 1st row of texture matrix
	public var sShift:Float;     // Texture shift in s direction
	public var t:Vector3D;          // 2nd row of texture matrix - multiply 1st and 2nd by vertex to get texture coordinates
	public var tShift:Float;     // Texture shift in t direction
	public var mipTexture:Int; // Index into mipTextures array
	public var flags:Int;      // Texture flags, seems to always be 0
	public function new(){}
}

// Smaller bsp models inside the world. Mostly brush entities.
/*
typedef struct _BSPMODEL
{
    float    nMins[3], nMaxs[3];    
    VECTOR3D vOrigin;                  
    int32_t  iHeadNodes[MAX_MAP_HULLS];
    int32_t  nVisLeafs;                 
    int32_t  iFirstFace, nFaces;        
};
*/
class BspModel
{
	public var mins:Vector<Float>;      // Defines bounding box
	public var maxs:Vector<Float>; 
	public var origin:Vector3D;    // Coordinates to move the coordinate system before drawing the model
	public var headNodes:Vector<Int>; // Indexes into nodes (first into world nodes, remaining into clip nodes)
	public var visLeafs:Int;  // No idea
	public var firstFace:Int; // Index and count into face array
	public var faces:Int;
	public function new(){}
}

// Clip nodes are used for collision detection and make up the clipping hull.
/*
typedef struct _BSPCLIPNODE
{
    int32_t iPlane;
    int16_t iChildren[2]; 
};
*/
class BspClipNode
{
	public var plane:Int;    // Index into planes
	public var children:Vector<Int>; // negative numbers are contents behind and in front of the plane
	public function new(){}
}

/*
 * entity.js
 * 
 * Copyright (c) 2012, Bernhard Manfred Gruber. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301  USA
 */


/**
 * Represents an entity in the bsp file.
 */
class Entity
{
public	var properties:Map<String,String>;
public function new (entityString:String):Void
{
	this.parseProperties(entityString);
}

/**
 * Parses the string representation of an entity into an associative array.
 * @see Bsp.loadEntities().
 */
public function parseProperties(entityString):Void
{
	this.properties = new Map<String,String>();

	var end = -1;
	while(true)
	{
		var begin = entityString.indexOf('"', end + 1);
		if(begin == -1)
			break;
		end = entityString.indexOf('"', begin + 1);
		
		var key = entityString.substring(begin + 1, end);
		
		begin = entityString.indexOf('"', end + 1);
		end = entityString.indexOf('"', begin + 1);
		
		var value = entityString.substring(begin + 1, end);
		
		properties.set(key,value);
	}
}
}