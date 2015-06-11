import luxe.Sprite;
import tween.Delta;
import tween.easing.Quad;
import tween.easing.Sine;

class Test1
{
	var entity : Sprite = entity;
	var loop_cnt : Int = 0;

	function sequence1()
	{
		loop_cnt--;
		if (loop_cnt <= 0)
		{
			loop_cnt = 2;
			sequence2();
			return;
		}

		Delta.tween(entity.pos)
			.propMultiple({x: 100, y: 100}, 2)
			.ease(Sine.easeIn)
			.wait(1.0)
			.propMultiple({x: 800, y: 100}, 2)
			.ease(Sine.easeIn)
			.wait(1.0)
			.onComplete(sequence1);
	}

	function sequence2()
	{
		loop_cnt--;
		if (loop_cnt <= 0)
		{
			loop_cnt = 3;
			sequence3();
			return;
		}

		Delta.tween(entity.pos)
			.propMultiple({x: 300, y: 300}, 0.5)
			.wait(0.5)
			.propMultiple({x: 50, y: 50}, 0.5)
			.onComplete(sequence2);
	}

	function sequence3()
	{
		loop_cnt = 3;

		Delta.tween(entity.pos)
			.propMultiple({x: 300, y: 200}, 1)
			.wait(2)
			.prop('y', 400, 5)
			.wait(5)
			.prop('y', 200, 2.5)
			.wait(4)
			.onComplete(sequence1);
	}


	function intro()
	{
		loop_cnt = 3;

		Delta.tween(entity.pos)
			.prop('y', 50, 3)
			.ease(Quad.easeIn)
			.wait(1.0)
			.onComplete(sequence1);
	}

	function destroy()
	{
		Delta.removeTweensOf(entity.pos);
	}

	function init()
	{
		entity.pos = Luxe.screen.mid;
		entity.pos.y = -32;
	}

	function main()
	{
		intro();
	}
}