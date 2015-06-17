import luxe.Sprite;
import phoenix.Color;
import tween.Delta;

import EntityHull;
import PlayerWeapon;

class Player
{
	var entity : Sprite = entity;
	var hull : EntityHull;
	var weapon : PlayerWeapon;

	var drive_in : Bool;
	var last_time : Float;

	var vert : Float;
	var horiz : Float;
	var speed : Float = 200;

	var event_ids;

	function init()
	{
		event_ids = new Array();

		hull = entity.get('EntityHull');
		hull.auto_immune_timer = 1;
		drive_in = false;

		weapon = entity.get('PlayerWeapon');

		vert = 0;
		horiz = 0;

		entity.color.a = 1;
		entity.pos.x = Luxe.screen.mid.x;
		entity.pos.y = 400;

		event_ids.push(entity.events.listen('EntityHull.damage', damage));
		event_ids.push(entity.events.listen('EntityHull.death', death));

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

	function flicker(time:Float)
	{
		entity.color.a = 1;
		entity.color.tween(0.25, { a: 0.25 }).reflect().repeat((time / 0.25) + 1);
	}

	function damage(amount:Int)
	{
		flicker(hull.auto_immune_timer);
		Luxe.camera.shake(30);
	}

	function death()
	{
		entity.color.a = 0;
		drive_in = true;
		entity.pos.y = Luxe.screen.h + 64;

		hull.immune_timer(hull.auto_immune_timer * 3);
		hull.heal(-1);
		flicker(hull.auto_immune_timer * 3);

		Delta.tween(entity.pos)
			.wait(hull.auto_immune_timer)
			.prop('y', Luxe.screen.h - 128, hull.auto_immune_timer)
			.onComplete(function()
			{
				drive_in = false;
			});
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
		if (!drive_in)
		{
			weapon.fire();
		}
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

		if (!drive_in)
		{
			var dx = horiz * speed * dt;
			var dy = vert * speed * dt;

			if (dx != 0) entity.pos.x += dx;
			if (dy != 0) entity.pos.y += dy;

			clamp_entity();
		}

		vert = 0;
		horiz = 0;

		last_time = Luxe.time;
	}
}