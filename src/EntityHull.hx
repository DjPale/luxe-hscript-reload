import luxe.Component;
import luxe.collision.shapes.Shape;


class EntityHull extends Component
{
	public var max_health(default,default) : Int;
	public var health(default,null) : Int;
	public var immune(default,default) : Bool;
	public var body(default,default) : Shape;

	public function new(_max_health:Int, _options:luxe.options.ComponentOptions = null)
	{
		super(_options);

		max_health = _max_health;
		health = max_health;
	}

	public function damage(amount:Int)
	{
		if (immune) 
		{
			entity.events.fire('EntityHull.immune');
			return;
		}

		health -= amount;

		entity.events.fire('EntityHull.damage', amount);

		if (health <= 0)
		{
			health = 0;
			entity.events.fire('EntityHull.death');
		}
	}

	public function heal(amount:Int)
	{
		health += amount;

		entity.events.fire('EntityHull.heal', amount);

		if (health > max_health)
		{
			health = max_health;
		}
	}

	override function update(dt:Float)
	{
		if (entity != null && body != null)
		{
			body.position = entity.pos.clone();
		}
	}
}