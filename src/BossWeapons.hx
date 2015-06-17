import luxe.Component;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;
import luxe.structural.Pool;

class BossWeapons extends Component
{
	public var bullets : Pool<Sprite>;

	public var beam : Sprite;

	var bullet_rof : Float;
	var bullet_speed : Float;
	var bullet_cur_cnt : Float;

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
	}

	public function stop_beam(?set_invisible:Bool = true)
	{
		entity.events.fire('BossWeapons.beam.disappear', beam);

		if (set_invisible)
		{
			beam.visible = false;
		}
	}

	public function hide_bullet(b:Sprite)
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

	override function update(dt:Float)
	{
		bullet_tick(dt);
	}
}