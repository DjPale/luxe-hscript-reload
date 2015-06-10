import luxe.Sprite;
import luxe.Vector;
import tween.Delta;

class Test1
{
	var entity : Sprite = entity;

	function init()
	{
		entity.pos = Luxe.screen.mid;
	}

	function main()
	{
		sequence1();
	}

	function sequence1()
	{
		Delta.tween(entity.pos)
			.propMultiple({x: 100, y: 100}, 1.0)
			.wait(1.0)
			.propMultiple({x: 300, y: 300}, 1.0)
			.onComplete(sequence1);
	}

	function destroy()
	{
		Delta.removeTweensOf(entity.pos);
	}
}