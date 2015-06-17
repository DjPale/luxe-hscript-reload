import luxe.Component;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;
import luxe.structural.Pool;

import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Circle;


/*
	This component takes care of logic related to boss weapons, and also helps with collision checking.
	In order to ease customization from scripts, it emits events and sends Sprite references that can be used to tweak the weapon look/behavior directly.
	Another solution would be to attach projectile behavior Component to each bullet and the beam, but the scope of this example is becoming too bloated anyway. :P
*/
class BossWeapons extends Component
{
	public var bullet_damage(default,default) : Int = 1;
	public var beam_damage(default,default) : Int = 2;

	var bullets : Pool<Sprite>;
	var beam : Sprite;

	var bullet_rof : Float;
	var bullet_speed : Float;
	var bullet_cur_cnt : Float;

	public var bullet_shape(default,null) : Circle;
	public var beam_shape(default,null) : Polygon;

	public function new(?_options:luxe.options.ComponentOptions = null)
	{
		super(_options);
	}

	override function init()
	{
		bullets = new Pool<Sprite>(30, create_bullet);

		beam = new Sprite({
			name: 'BossWeapons.beam',
			visible: false,
			parent: entity,
			});

		bullet_shape = new Circle(0, 0, 8);
		beam_shape = Polygon.rectangle(0, 0, 0, 0);
	}

	function create_bullet(i:Int, len:Int) : Sprite
	{
		var ret = new Sprite({
			name: 'BossWeapons.bullet.$i',
			visible: false,
			texture: Luxe.resources.texture('assets/sprites/boss-bullet.png')
			});

		return ret;
	}

	public function start_bullets(rate:Float, speed:Float)
	{
		if (bullet_rof > 0)
		{
			return;
		}

		bullet_rof = rate;
		bullet_speed = speed;
		bullet_cur_cnt = bullet_rof;
	}

	public function stop_bullets()
	{
		bullet_rof = 0;
	}

	public function start_beam(width:Float, height:Float)
	{
		beam.size = new Vector(width, height);
		beam.pos = new Vector(0, 64);

		beam.visible = true;
		entity.events.fire('BossWeapons.beam.fire', beam);

		beam_shape = Polygon.rectangle(0, 0, width * (entity.scale.x - 0.5), height * (entity.scale.y));
	}

	public function stop_beam(?set_invisible:Bool = true)
	{
		entity.events.fire('BossWeapons.beam.disappear', beam);

		if (set_invisible)
		{
			beam.visible = false;
		}
	}

	function hide_bullet(b:Sprite)
	{
		entity.events.fire('BossWeapons.bullet.disappear', b);
		b.visible = false;
	}

	inline function bullet_tick(dt:Float)
	{
		if (bullet_rof > 0)
		{
			bullet_cur_cnt -= dt;

			if (bullet_cur_cnt <= 0)
			{
				var b = bullets.get();
				b.pos = entity.pos.clone();
				bullet_cur_cnt = bullet_rof;
				b.visible = true;

				entity.events.fire('BossWeapons.bullet.fire', b);
			}
		}

		// lazy solution, 
		// alternative: create separate bullet component etc. we could even script it ;)
		for (b in bullets.items)
		{
			if (b.visible)
			{
				b.pos.y += dt * bullet_speed;

				if (b.pos.y > Luxe.screen.height)
				{
					hide_bullet(b);
				}
			}
		}
	}

	// utility function, not 100% sure where it is right to put this atm
	public function run_hull_collision(hull:EntityHull, ?_remove_on_hit : Bool = false) : Bool
	{
		var ret = false;

		// we don't need any physics, the standard luxe collision routines is sufficent
		for (bullet in bullets.items)
		{
			if (bullet.visible)
			{
				bullet_shape.position = bullet.pos.clone();

				if (hull.body.testCircle(bullet_shape) != null)
				{
					hull.damage(bullet_damage);

					if (_remove_on_hit)
					{
						hide_bullet(bullet);
					}

					ret = true;
				}
			}
		}

		if (beam.visible && beam.color.a > 0.5)
		{
			beam.transform.world.decompose();
			var v = beam.transform.world.pos.clone();
			v.add(Vector.MultiplyVector(beam.origin, new Vector(entity.scale.x - 0.5, entity.scale.y)));

			beam_shape.position = v;

			if (hull.body.testPolygon(beam_shape) != null)
			{
				hull.damage(beam_damage);
				ret = true;
			}
		}

		return ret;
	}

	override function update(dt:Float)
	{
		bullet_tick(dt);
	}
}