import luxe.Sprite;
import luxe.Entity;
import phoenix.Color;

import tween.Delta;
import tween.easing.Quad;
import tween.easing.Sine;
import tween.easing.Back;

import phoenix.Vector;

import luxe.tween.Actuate;

import scripting.ScriptSequencer;

import BossWeapons;
import EntityHull;

class Boss
{
	// help out our completion by self-assignment
	var entity : Sprite = entity;
	var player : Entity = player;

	var seq : ScriptSequencer;
	var weapons : BossWeapons;
	var health : EntityHull;
	var moveMin : Int = 150;
	var moveMax : Int = Luxe.screen.width - 150;
	var moveMid : Int = Luxe.screen.mid.x;

	var event_ids;

	function complete_action()
	{
		seq.complete();
	}

	function stop_actions()
	{
		Delta.removeTweensOf(entity.pos);
	}

	function ondestroy()
	{
		stop_actions();
		weapons.stop_beam();
		weapons.stop_bullets();

		// clear and unsubscribe for all events
		while (event_ids.length > 0)
		{
			entity.events.unlisten(event_ids.pop());
		}

		entity = null;
		player = null;
	}

	function init()
	{
		event_ids = new Array();

		weapons = entity.get('BossWeapons');
		health = entity.get('EntityHull');

		// make sure to set properties to an initial stete in case we are reloading
		entity.scale = new Vector(2, 2);
		entity.color = new Color();

		// save all event handlers - it's important we unsubscibe to avoid dangling events
		event_ids.push(entity.events.listen('BossWeapons.bullet.fire', bullet_fire));
		event_ids.push(entity.events.listen('BossWeapons.bullet.disappear', bullet_disappear));
		event_ids.push(entity.events.listen('BossWeapons.beam.fire', beam_fire));
		event_ids.push(entity.events.listen('BossWeapons.beam.disappear', beam_disappear));

		event_ids.push(entity.events.listen('EntityHull.damage', damage));

		entity.pos = Luxe.screen.mid;
		entity.pos.y = -100;

		seq = new ScriptSequencer();
		seq.loop = 1;
		seq.abort_function = stop_actions;
		seq.add({ name: 'intro', func: intro, num: 1 });
		seq.add({ name: 'swipe', func: swipe, num: 2 });
		seq.add({ name: 'prepare_beam', func: prepare_beam, num: 1 });
		seq.add({ name: 'approach', func: approach, num: 1 });

		seq.start();
	}

	function bullet_fire(bullet:Sprite)
	{
		bullet.scale.x = 1;
		bullet.scale.y = 1;
		Actuate.tween(bullet.scale, 0.5, { x: 2, y: 2 }).reflect().repeat();
	}

	function bullet_disappear(bullet:Sprite)
	{
		Actuate.stop(bullet.scale);
	}

	function beam_fire(beam:Sprite)
	{
		beam.scale.x = 1;
		beam.color.a = 0;
		beam.color.tween(2, { a: 1 });
		beam.pos = new Vector(128 / 2, 64 + beam.size.y / 2);
		beam.color.rgb(0xF6D2D4);
		Actuate.tween(beam.scale, 0.1, { x: 0.5 }).reflect().repeat();
	}

	function beam_disappear(beam:Sprite)
	{
		beam.color.a = 1;
		beam.color.tween(1, { a: 0 }).onComplete(
		function() { 
			Actuate.stop(beam.scale); 
			beam.visible = false;
		});
	}

	function damage(amount:Int)
	{
		entity.color.tween(0.5, { g: 0.5, b: 0.5 } ).reflect().repeat(1); 
	}

	function swipe()
	{
		health.immune = false;

		weapons.stop_beam(false);
		weapons.start_bullets(0.5, 300);

		Delta.tween(entity.pos)
			.propMultiple({x: moveMin, y: 100}, 2)
			.ease(Back.easeInOut)
			.wait(2.0)
			.propMultiple({x: moveMax, y: 100}, 2)
			.ease(Back.easeInOut)
			.wait(2.0)
			.onComplete(complete_action);
	}

	function prepare_beam()
	{
		health.immune = true;

		weapons.stop_bullets();
		weapons.stop_beam(false);

	 	entity.color.tween(0.5, { r: 0 }).repeat(5).reflect();

		var rx = player.pos.x;

	 	Delta.tween(entity.pos)
	 	 .prop('x', moveMid, 1)
	 	 .ease(Quad.easeInOut)
	 	 .wait(1)
	 	 .propMultiple({x: rx, y: 200}, 1)
	 	 .onComplete(complete_action);
	}

	function approach()
	{
		health.immune = true;

		weapons.stop_bullets();
		weapons.start_beam(38, 250);

		Delta.tween(entity.pos)
			.prop('y', 400, 2)
			.wait(1)
			.prop('y', 200, 1)
			.wait(1)
			.onComplete(complete_action);
	}

	function intro()
	{
		health.immune = true;

		Delta.tween(entity.pos)
			.prop('y', 100, 3)
			.ease(Quad.easeInOut)
			.wait(2.0)
			.onComplete(complete_action);
	}
}