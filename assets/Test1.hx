import luxe.Sprite;
import luxe.Entity;

import tween.Delta;
import tween.easing.Quad;
import tween.easing.Sine;
import phoenix.Vector;

import luxe.tween.Actuate;

import scripting.ScriptSequencer;

import BossWeapons;

class Test1
{
	var entity : Sprite = entity;
	//var player : Entity = player;
	var seq : ScriptSequencer;
	var weapons : BossWeapons;

	var event_ids;

	function complete_action()
	{
		seq.complete();
	}

	function stop_actions()
	{
		Delta.removeTweensOf(entity.pos);
	}

	function destroy()
	{
		stop_actions();
		weapons.stop_beam();
		weapons.stop_bullets();

		while (event_ids.length > 0)
		{
			entity.events.unlisten(event_ids.pop());
		}

		entity = null;
		//player = null;
	}

	function init()
	{
		event_ids = new Array();

		weapons = entity.get('BossWeapons');

		event_ids.push(entity.events.listen('BossWeapons.bullet.fire', bullet_fire));
		event_ids.push(entity.events.listen('BossWeapons.bullet.disappear', bullet_disappear));
		event_ids.push(entity.events.listen('BossWeapons.beam.fire', beam_fire));
		event_ids.push(entity.events.listen('BossWeapons.beam.disappear', beam_disappear));

		entity.events.listen('EntityHealth.change');

		entity.pos = Luxe.screen.mid;
		entity.pos.y = -32;

		seq = new ScriptSequencer();
		seq.loop = 1;
		seq.abort_function = stop_actions;
		seq.add({ name: 'intro', func: intro, num: 1 });
		seq.add({ name: 'swipe', func: swipe, num: 2 });
		seq.add({ name: 'approach', func: approach, num: 1 });
	}

	function main()
	{
		seq.start();
	}

	function bullet_fire(bullet:Sprite)
	{
		//trace('bullet=' + bullet.name);
		bullet.scale.x = 1;
		bullet.scale.y = 1;
		bullet.color.rgb(0xFF2288);
		Actuate.tween(bullet.scale, 0.5, { x: 5, y: 5 }).reflect().repeat();
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
		beam.pos = new Vector(64 / 2, 64 + beam.size.y / 2);
		beam.color.rgb(0x8822FF);
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

	function swipe()
	{
		weapons.stop_beam(false);
		weapons.start_bullets(0.5, 300);

		Delta.tween(entity.pos)
			.propMultiple({x: 100, y: 100}, 2)
			.ease(Sine.easeIn)
			.wait(1.0)
			.propMultiple({x: 800, y: 100}, 2)
			.ease(Sine.easeIn)
			.wait(1.0)
			.onComplete(complete_action);
	}

	function approach()
	{
		weapons.stop_bullets();
		weapons.start_beam(64, 200);

		var rx = Luxe.utils.random.float(100, 800);

		Delta.tween(entity.pos)
			.propMultiple({x: rx, y: 200}, 1)
			.wait(2)
			.prop('y', 400, 2)
			.wait(1)
			.prop('y', 200, 1)
			.wait(1)
			.onComplete(complete_action);
	}


	function intro()
	{
		Delta.tween(entity.pos)
			.prop('y', 50, 3)
			.ease(Quad.easeIn)
			.wait(1.0)
			.onComplete(complete_action);
	}

}