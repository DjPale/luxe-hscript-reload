import luxe.Sprite;

class Player
{
	var entity : Sprite = entity;
	var last_time : Float;

	var vert : Float;
	var horiz : Float;
	var speed : Float = 200;

	var event_ids;

	function init()
	{
		event_ids = new Array();

		vert = 0;
		horiz = 0;

		entity.pos.x = Luxe.screen.mid.x;
		entity.pos.y = 400;

		event_ids.push(entity.events.listen('EntityHull.damage', damage));

		last_time = Luxe.time;
	}

	function ondestroy()
	{
		// clear and unsubscribe for all events
		while (event_ids.length > 0)
		{
			entity.events.unlisten(event_ids.pop());
		}
	}

	function damage(amount:Int)
	{
		trace('ouch! took ' + amount + ' damage');
	}

	function move_up()
	{
		vert = -1;
	}

	function move_down()
	{
		vert = 1;
	}

	function move_left()
	{
		horiz = -1;
	}

	function move_right()
	{
		horiz = 1;
	}

	function fire()
	{

	}

	function clamp_entity()
	{
		if (entity.pos.x < 32) entity.pos.x = 32;
		else if (entity.pos.x > Luxe.screen.w - 32) entity.pos.x = Luxe.screen.w - 32;

		if (entity.pos.y < 32) entity.pos.y = 32;
		else if (entity.pos.y > Luxe.screen.h - 32) entity.pos.y = Luxe.screen.h - 32;	
	}

	// I didn't pass in dt here because of laziness :P
	function update()
	{
		var dt = Luxe.time - last_time;

		var dx = horiz * speed * dt;
		var dy = vert * speed * dt;

		if (dx != 0) entity.pos.x += dx;
		if (dy != 0) entity.pos.y += dy;

		clamp_entity();

		last_time = Luxe.time;

		vert = 0;
		horiz = 0;
	}
}