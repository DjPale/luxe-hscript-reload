import luxe.Component;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;
import luxe.structural.Pool;

class BossWeapons extends Component
{
	var bullets : Pool<Sprite>;

	var beam : Sprite;

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
			name: 'beam',
			visible: false,
			color: new Color().rgb(0xf8822ff),
			parent: entity,
			centered: false
			});
	}

	function create_bullet(i:Int, len:Int) : Sprite
	{
		return new Sprite({
			name: 'bullet-$i',
			visible: false,
			size: new Vector(4, 4),
			color: new Color().rgb(0xff2288)
			});
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
	}

	public function stop_beam()
	{
		beam.visible = false;
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
				b.visible = true;
				bullet_cur_cnt = bullet_rof;
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
					b.visible = false;
				}
			}
		}
	}

	override function update(dt:Float)
	{
		bullet_tick(dt);
	}
}