package lz.native3d.core ;
//{
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.Vector;
	using OpenFLStage3D;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	class BasicView extends Sprite
	{
		//private var c3d:Context3D;
		public var instance3Ds:Vector<Instance3D>;
		private var _autoSize:Bool;
		private var width3d:Int;
		private var height3d:Int;
		public var numInstance3d:Int;
		public function new(width:Int=400,height:Int=400,autoSize:Bool=false,numInstance3d:Int=1) 
		{
			super();
			this.numInstance3d = numInstance3d;
			instance3Ds = new Vector<Instance3D>();
			for (i in 0...numInstance3d) {
				if (i>=Instance3D._instances.length) {
					Instance3D._instances.push(new Instance3D());
				}
				instance3Ds.push(Instance3D.getInstance(i));
			}
			
			resize(width, height);
			this.autoSize = autoSize;
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(e:Event):Void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			for (i in 0...numInstance3d) {
				var stage3d = getStage3d(i);
				stage3d.addEventListener(Event.CONTEXT3D_CREATE, stage3Ds_context3dCreate);
				stage3d.requestContext3D();
			}
			
			this.autoSize = autoSize;
		}
		
		inline private function getStage3d(i:Int):Stage3D {
			return #if flash stage.stage3Ds[i] #else stage.getStage3D(i) #end;
		}
		
		private function stage3Ds_context3dCreate(e:Event):Void 
		{
			for (i in 0...numInstance3d) {
				var stage3d = getStage3d(i);
				if (stage3d.context3D==null) {
					return;
				}
			}
			for (i in 0...numInstance3d) {
				var stage3d = getStage3d(i);
				var i3d:Instance3D = instance3Ds[i];
				i3d.init(stage3d.context3D);
				i3d.resize(width3d, height3d);
			}
		}
		
		private function get_autoSize():Bool 
		{
			return _autoSize;
		}
		
		private function set_autoSize(value:Bool):Bool 
		{
			if(stage!=null){
				if (autoSize) {
					stage.addEventListener(Event.RESIZE, stage_resize);
					stage.align = StageAlign.TOP_LEFT;
					stage.scaleMode = StageScaleMode.NO_SCALE;
					resize(untyped(stage.stageWidth), untyped(stage.stageHeight));
				}else {
					stage.removeEventListener(Event.RESIZE, stage_resize);
				}
			}
			return _autoSize = value;
		}
		
		private function stage_resize(e:Event):Void 
		{
			resize(stage.stageWidth, stage.stageHeight);
		}
		
		public function resize(width:Int,height:Int):Void {
			width3d = width;
			height3d = height;
			for (i3d in instance3Ds) {
				i3d.resize(width3d, height3d);
			}
		}
		
		public var autoSize(get_autoSize, set_autoSize):Bool;
		
	}

//}