// ================================================================================
//
//	ADOBE SYSTEMS INCORPORATED
//	Copyright 2011 Adobe Systems Incorporated
//	All Rights Reserved.
//
//	NOTICE: Adobe permits you to use, modify, and distribute this file
//	in accordance with the terms of the license agreement accompanying it.
//
// ================================================================================
package
{
	// ===========================================================================
	//	Imports
	// ---------------------------------------------------------------------------
	
	import flash.display.*;
	import flash.display3D.*;
	import flash.events.*;
	import flash.geom.*;
	import lz.native3d.core.BasicLight3D;
	import lz.native3d.core.BasicView;
	import lz.native3d.core.DrawAble3D;
	import lz.native3d.core.Node3D;
	import lz.native3d.materials.MaterialBase;
	import lz.native3d.materials.PhongMaterial;
	import lz.native3d.meshs.MeshUtils;
	import net.hires.debug.Stats;
	import pe.PelletManager;
	
	// ===========================================================================
	//	Class
	// ---------------------------------------------------------------------------
	public class PelletTest extends Sprite
	{
		// ======================================================================
		//	Properties
		// ----------------------------------------------------------------------
		protected var mSim:PelletManager;
		private var bv:BasicView;
		private var cubeDA:DrawAble3D;
		private var light:BasicLight3D;

		// ======================================================================
		//	Constructor
		// ----------------------------------------------------------------------
		public function PelletTest()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// ======================================================================
		//	Methods
		// ----------------------------------------------------------------------
		protected function init(e:Event=null):void
		{
			bv = new BasicView();
			addChild(bv);
			bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, instance3Ds_context3dCreate);
			addChild(new Stats);
		}
		
		private function instance3Ds_context3dCreate(e:Event):void 
		{
			cubeDA = MeshUtils.createCube(1, bv.instance3Ds[0]);
			light = new BasicLight3D;
			bv.instance3Ds[0].root.add(light);
			light.x = 100;
			light.y = 50;
			light.z = -100;
			bv.instance3Ds[0].camera.z = -100;
			bv.instance3Ds[0].camera.y = 30;
			
			createWorld();
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function createWorld():void 
		{
			//
			mSim = new PelletManager;
			spawnCube(-50, 0, 0, 0, 5, 5, 100)
			spawnCube(50, 0, 0, 0, 5, 5, 100)
			spawnCube(0, 0, 50, 0, 100, 5, 5)
			spawnCube(0, 0, -50, 0, 100, 5, 5)
			spawnCube(0, -1, 0, 0, 100, 0.1, 100)
			
			var numCols:int = 6;
			var w:Number = 2.0;
			var s:Number = 4.0;
			
			for(var i:int=0; i<40; i++) {
				spawnCube(((i%numCols)) * 10  - 30, 10.0 + ((i/numCols) * s), 0, 10, w*2, w*2, w*2)
			}
			// create a plane and add it to the scene
			//var plane:Node3D = mSim.createStaticInfinitePlane( 1000, 1000, 2, 2, material, "plane" );
			//plane.appendTranslation( 0, -2, 0 );
			//scene.addChild( plane );
			
			// create cubes and add it to the scene
			//var cube0:Node3D = mSim.createBox( 5, 5, 5 );
			//cube0.appendRotation( 40, Vector3D.X_AXIS );
			//cube0.appendTranslation( 0, 6, 0 );
			//scene.addChild( cube0 );

			//var cube1:Node3D = mSim.createBox( 12, 1, 4 );
			//cube1.appendRotation( 30, Vector3D.Z_AXIS );
			//cube1.appendTranslation( -2, 15, 0 );
			//scene.addChild( cube1 );
			
			// create a sphere and add it to the scene
			//var sphere:Node3D = mSim.createSphere( 3, 32, 16 );
			//sphere.setPosition( -10, 2, 0 );
			//scene.addChild( sphere );		
		}
		private function spawnCube(x:Number, y:Number, z:Number, mass:Number, w:Number, h:Number, d:Number):void
	    {
			var mater:MaterialBase=new PhongMaterial(bv.instance3Ds[0], light,
			new Vector3D(.2,.2,.2),
			new Vector3D(Math.random()/2+.5,Math.random()/2+.5,Math.random()/2+.5),
			new Vector3D(.8,.8,.8),
			200);
			if (mass==0) {
				var node:Node3D = mSim.createStaticInfinitePlane(w, h, 2, 2, mater,cubeDA);
			}else {
				node= mSim.createBox( w, h, d ,mater,cubeDA);
			}
			node.frustumCulling = null;
	    	node.setScale(w / 2, h / 2, d / 2);
			node.setPosition(x, y, z);
			bv.instance3Ds[0].root.add(node);
	    }
		
		private function enterFrame(e:Event):void 
		{
			mSim.stepWithSubsteps( 1/60, 2 );
			bv.instance3Ds[0].render();
		}
	}
}