package lz.native3d.materials ;
//{
	//import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.Vector;
	import lz.native3d.core.BasicPass3D;
	//import lz.native3d.core.Instance3D;
	import lz.native3d.core.Node3D;
	import flash.display3D.Context3DCompareMode;
	/**
	 * 材质不可以共享 但可以公用progrom
	 * @author lizhi http://matrix3d.github.io/
	 */
	 class MaterialBase 
	{
		public var vertex:Vector<Float>;
		public var fragment:Vector<Float>;
		//public static var libp:Object = { };
		public var progrom:Program3D;
		public var sourceFactor:Context3DBlendFactor;// = Context3DBlendFactor.ONE; 
		public var destinationFactor:Context3DBlendFactor;// = Context3DBlendFactor.ZERO;
		
		public var passCompareMode:Context3DCompareMode;// = Context3DCompareMode.LESS;
		public function new() 
		{
			#if flash
			sourceFactor = Context3DBlendFactor.ONE;
			destinationFactor = Context3DBlendFactor.ZERO;
			passCompareMode = Context3DCompareMode.LESS;
			#end
		}
		
		public function draw(node:Node3D,pass:BasicPass3D):Void {
			
		}
		
		public function init(node:Node3D):Void {
			
		}
		
		public function createProgram(vc:String, fc:String):Program3D {
			/*var p:Program3D = Instance3D.instance.c3d.createProgram();
			if (libp[vc + "-" + fc]) {
				p = libp[vc + "-" + fc];
			}else {
				var va:AGALMiniAssembler = new AGALMiniAssembler;
				va.assemble(Context3DProgramType.VERTEX,vc );
				var fa:AGALMiniAssembler = new AGALMiniAssembler;
				fa.assemble(Context3DProgramType.FRAGMENT,fc );
				p.upload(va.agalcode, fa.agalcode);
				libp[vc + "-" + fc] = p;
			}
			return p;*/
			return null;
		}
		
	}

//}