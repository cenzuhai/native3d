package lz.native3d.core.particle;

import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class ParticleWrapper extends Node3D
{
	public var initer:ParticleIniter;
	public var updater:ParticleUpdater;
	public var particles:Array<Particle>;
	public function new(i3d:Instance3D) 
	{
		super();
		initer = new ParticleIniter(i3d);
		updater = new ParticleUpdater();
		particles = new Array<Particle>();
	}
	
	public function init():Void {
		initer.init(this);
	}
	
	public function update():Void {
		updater.update(this);
	}
	
}