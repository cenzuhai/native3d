package lz.native3d.core;
import flash.utils.ByteArray;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class ByteArraySet
{
	public var numRegisters : Int=0;
	public var data : ByteArray; 
	public var byteArrayOffset : #if flash UInt #else Int #end = 0;
	public function new() 
	{
		
	}
	
}