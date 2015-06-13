import luxe.Sprite;

import tween.Delta;
import tween.easing.Quad;
import tween.easing.Sine;

import scripting.ScriptSequencer;

import BossWeapons;

class Test1
{
	var entity : Sprite = entity;
	var seq : ScriptSequencer;
	var weapons : BossWeapons;

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
	}

	function init()
	{
		weapons = entity.get('BossWeapons');

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

	function swipe()
	{
		weapons.stop_beam();
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