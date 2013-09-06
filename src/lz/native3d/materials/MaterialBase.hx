package lz.native3d.materials ;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.Vector;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.Node3D;
import flash.display3D.Context3DCompareMode;
/**
 * @author lizhi http://matrix3d.github.io/
 */
 class MaterialBase 
{
	public var vertex:Vector<Float>;
	public var fragment:Vector<Float>;
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
	
}