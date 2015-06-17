import luxe.Component;
import luxe.collision.shapes.Shape;

/*
	This component keeps track of health and emits various events
	It also has basic collision information
*/
class EntityHull extends Component
{
	public var max_health(default,default) : Int;
	public var health(default,null) : Int;
	public var immune(default,default) : Bool;
	public var body(default,default) : Shape;
	public var auto_immune_timer(default,default) : Float = 0;

	var immune_cnt : Float;

	public function new(_max_health:Int, _options:luxe.options.ComponentOptions = null)
	{
		super(_options);

		max_health = _max_health;
		health = max_health;
	}

	public function damage(amount:Int)
	{
		if (health == 0)
		{
			return;
		}

		if (immune) 
		{
			//entity.events.fire('EntityHull.immune');
			return;
		}

		health -= amount;

		entity.events.fire('EntityHull.damage', amount);

		if (health <= 0)
		{
			health = 0;
			entity.events.fire('EntityHull.death');
			return;
		}

		if (auto_immune_timer > 0)
		{
			immune_timer(auto_immune_timer);
		}
	}

	public function heal(amount:Int)
	{
		if (amount <= 0)
		{
			amount = max_health;
		}

		health += amount;

		entity.events.fire('EntityHull.heal', amount);

		if (health > max_health)
		{
			health = max_health;
		}
	}

	public function immune_timer(secs:Float)
	{
		immune = true;
		immune_cnt = secs;
	}

	override function update(dt:Float)
	{
		if (entity != null && body != null)
		{
			body.position = entity.pos.clone();
		}

		if (immune_cnt > 0)
		{
			immune_cnt -= dt;

			if (immune_cnt <= 0)
			{
				immune = false;
				immune_cnt = 0;
			}
		}
	}
}