package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import lz.native3d.core.BasicLight3D;
	import lz.native3d.core.BasicView;
	import lz.native3d.core.DrawAble3D;
	import lz.native3d.core.Node3D;
	import lz.native3d.materials.PhongMaterial;
	import lz.native3d.meshs.MeshUtils;
	import net.hires.debug.Stats;
	import org.bulletphysics.btAxisSweep3;
	import org.bulletphysics.btBoxShape;
	import org.bulletphysics.btCollisionDispatcher;
	import org.bulletphysics.btDbvtBroadphase;
	import org.bulletphysics.btDefaultCollisionConfiguration;
	import org.bulletphysics.btDefaultCollisionConstructionInfo;
	import org.bulletphysics.btDefaultMotionState;
	import org.bulletphysics.btDiscreteDynamicsWorld;
	import org.bulletphysics.btRigidBody;
	import org.bulletphysics.btRigidBodyConstructionInfo;
	import org.bulletphysics.btSequentialImpulseConstraintSolver;
	import org.bulletphysics.btTransform;
	import org.bulletphysics.btVector3;
	import org.bulletphysics.CModule;
	import org.bulletphysics.positionAndRotateMesh;
	
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	[SWF(width = "400",height="400" )]
	public class BulletTest extends Sprite
	{
		private var bv:BasicView;
		private var cubeDA:DrawAble3D;
		private var light:BasicLight3D;
		private var broadphase:btDbvtBroadphase;
		private var defCollisionInfo:btDefaultCollisionConstructionInfo;
		private var collisionConfig:btDefaultCollisionConfiguration;
		private var dispatcher:btCollisionDispatcher;
		private var solver:btSequentialImpulseConstraintSolver;
		private var world:btDiscreteDynamicsWorld;
		private var trans:btTransform;

		private var bods:Vector.<btRigidBody>;
		private var meshes:Vector.<Node3D>;
		
		
		public function BulletTest():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			CModule.rootSprite = this;
			if (CModule.runningAsWorker()) {
				return;
			}
			CModule.startAsync(this);
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
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
			
			//new FirstPersonCtrl(stage, bv.instance3Ds[0].camera);
			createWorld();
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function createWorld():void
		{
			bods = new Vector.<btRigidBody>()
			meshes = new Vector.<Node3D>()

			var maxNumOutstandingTasks:int = 2;

			defCollisionInfo = btDefaultCollisionConstructionInfo.create()
			//defCollisionInfo.m_defaultMaxPersistentManifoldPoolSize = 32768;
			defCollisionInfo.m_defaultMaxPersistentManifoldPoolSize = 1024;
			collisionConfig = btDefaultCollisionConfiguration.create(defCollisionInfo.swigCPtr)

			dispatcher = btCollisionDispatcher.create(collisionConfig.swigCPtr)
			solver = btSequentialImpulseConstraintSolver.create()

			broadphase =  btDbvtBroadphase.create(0)
			world = btDiscreteDynamicsWorld.create(dispatcher.swigCPtr, broadphase.swigCPtr, solver.swigCPtr, collisionConfig.swigCPtr)
			world.setGravity(vector(0, -20, 0))

			//world.getDispatchInfo().m_enableSPU = true;

			// Create some massless (static) cubes
			spawnCube(-50, 0, 0, 0, 5, 5, 100)
			spawnCube(50, 0, 0, 0, 5, 5, 100)
			spawnCube(0, 0, 50, 0, 100, 5, 5)
			spawnCube(0, 0, -50, 0, 100, 5, 5)
			spawnCube(0, -1, 0, 0, 100, 0.1, 100)

			var numCols:int = 6;
			var w:Number = 2.0;
			var s:Number = 4.0;
			
			var boxShape:btBoxShape = btBoxShape.create(vector(w , w, w));
			for(var i:int=0; i<400; i++) {
				//spawnCube(((i%numCols)) * 10  - 30, 10.0 + ((i/numCols) * s), 0, 10, w*2, w*2, w*2)
				spawnRigidBody(
					boxShape,
					w*2,w*2,w*2,
					10,
					((i%numCols)) * 10  - 30, 10.0 + ((i/numCols) * s), 0
				)
			}
		}
		
		private function spawnCube(x:Number, y:Number, z:Number, mass:Number, w:Number, h:Number, d:Number):btRigidBody
	    {
	    	return spawnRigidBody(
	    		btBoxShape.create(vector(w/2,h/2,d/2)),
	    		w,h,d,
	    		mass,
	    		x, y, z
			);
	    }
		
		private function spawnRigidBody(shape:*, w:Number,h:Number,d:Number, mass:Number, x:Number, y:Number, z:Number):btRigidBody
	    {
			var inertia:btVector3 = btVector3.create()
			if(mass != 0)
				shape.calculateLocalInertia(mass, inertia.swigCPtr);
			trans = btTransform.create()
			trans.setIdentity()
			trans.setOrigin(vector(x, y, z))
			var ms:btDefaultMotionState = btDefaultMotionState.create(trans.swigCPtr, btTransform.getIdentity())

			var rbci:btRigidBodyConstructionInfo = btRigidBodyConstructionInfo.create(mass, ms.swigCPtr, shape.swigCPtr, inertia.swigCPtr)
			rbci.m_restitution = 0.1;
			rbci.m_friction = 1.0;

			var rb:btRigidBody = btRigidBody.create(rbci.swigCPtr)
			world.addRigidBody(rb.swigCPtr)

			meshes.push(addCube(w,h,d, x, y, z));

			bods.push(rb)

			return rb
	    }
		
		private static function vector(x:Number, y:Number, z:Number):int {
	      var vec:btVector3 = btVector3.create()
	      vec.setX(x)
	      vec.setY(y)
	      vec.setZ(z)
	      return vec.swigCPtr
	    }
		
		private function enterFrame(e:Event):void 
		{
			CModule.serviceUIRequests();	
			var i:int

			for(i=0; i<1; i++)
				world.stepSimulation(1/60.0, 0, 0)

	        for (i = 0; i < meshes.length; i++) {
	        	positionAndRotateMesh(meshes[i], bods[i])
	        }
			bv.instance3Ds[0].render();
		}
		private function addCube(w:Number,h:Number,d:Number, x:Number, y:Number, z:Number):Node3D {
			var node:Node3D = new Node3D;
			node.frustumCulling = null;
			node.drawAble = cubeDA;
			node.setScale(w/2, h/2, d/2);
			node.set_material( new PhongMaterial(bv.instance3Ds[0], light,
			new Vector3D(.2,.2,.2),
			new Vector3D(Math.random()/2+.5,Math.random()/2+.5,Math.random()/2+.5),
			new Vector3D(.8,.8,.8),
			200));
			bv.instance3Ds[0].root.add(node);
			return node;
		}
		
	}
	
}