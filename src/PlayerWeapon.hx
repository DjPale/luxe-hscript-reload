import luxe.Component;
import luxe.Sprite;
import luxe.structural.Pool;
import luxe.Vector;

import luxe.collision.shapes.Circle;

/*
	Should probably be merged with the BossWeapons since the bullet logic is largely similar. 
	Either split EnemeyWeapons in two components (bullet,beam) - or generalize EnemyWeapons to cover PlayerWeapons
*/
class PlayerWeapon extends Component
{
	public var bullet_damage(default,default) : Int = 1;
	public var bullet_rof(default,default) : Float = 0.5;
	public var bullet_speed(default,default) : Float = 300;
	public var bullet_shape(default,null) : Circle;

	var bullet_cur_cnt : Float;

	var bullets : Pool<Sprite>;

	public function new(?_options:luxe.options.ComponentOptions = null)
	{
		super(_options);
	}

	override function init()
	{
		bullets = new Pool<Sprite>(20, create_bullet);

		bullet_shape = new Circle(0, 0, 4);
	}

	function create_bullet(i:Int, len:Int) : Sprite
	{
		var ret = new Sprite({
			name: 'PlayerWeapon.bullet.$i',
			visible: false,
			size: new Vector(4, 4)
			});

		return ret;
	}

	function hide_bullet(b:Sprite)
	{
		entity.events.fire('PlayerWeapon.bullet.disappear', b);
		b.visible = false;
	}

	public function fire()
	{
		if (bullet_cur_cnt <= 0)
		{
			var b = bullets.get();
			b.pos = entity.pos.clone();
			bullet_cur_cnt = bullet_rof;
			b.visible = true;

			entity.events.fire('PlayerWeapon.bullet.fire', b);
		}
	}

	inline function bullet_tick(dt:Float)
	{		
		for (b in bullets.items)
		{
			if (b.visible)
			{
				b.pos.y -= dt * bullet_speed;

				if (b.pos.y > Luxe.screen.height)
				{
					hide_bullet(b);
				}
			}
		}

		if (bullet_cur_cnt > 0)
		{
			bullet_cur_cnt -= dt;

			if (bullet_cur_cnt <= 0)
			{
				bullet_cur_cnt = 0;
			}
		}
	}

	public function run_hull_collision(hull:EntityHull, ?_remove_on_hit : Bool = false) : Bool
	{
		var ret = false;

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

		return ret;
	}

	override function update(dt:Float)
	{
		bullet_tick(dt);
	}

}