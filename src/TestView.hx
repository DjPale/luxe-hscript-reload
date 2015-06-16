import luxe.States;
import luxe.Text;
import luxe.Input;
import luxe.Sprite;

import tween.Delta;

import scripting.ScriptClassLibrary;
import scripting.ScriptManager;
import scripting.luxe.ScriptClassLibraryLuxe;
import scripting.luxe.ScriptComponent;

import Main;

class TestView extends State
{
	var batcher : phoenix.Batcher;
	var global : GlobalData;

    var enemy : Sprite;
    var player : Sprite;
    var boss_script : ScriptComponent;

	public function new(_global:GlobalData, _batcher:phoenix.Batcher)
	{
		super({ name: 'TestView' });

		batcher = _batcher;
		global = _global;
    }

	override function onenabled<T>(ignored:T)
    {
    	trace('enable TestView');
    } //onenabled

    override function ondisabled<T>(ignored:T)
    {
    	trace('disable TestView');
    } //ondisabled

    function setup()
    {
        player = new Sprite({
            name: 'Player',
            pos: new luxe.Vector(Luxe.screen.mid.x, 500),
            texture: Luxe.resources.texture('assets/sprites/player.png'),
            scale: new luxe.Vector(1.5, 1.5)
            });

        enemy = new Sprite({
            name: 'Boss',
            texture: Luxe.resources.texture('assets/sprites/boss.png')
            });
        enemy.add(new BossWeapons({name: 'BossWeapons'}));

        var script = Luxe.resources.text('assets/Boss.hx').asset.text;
        boss_script = enemy.add(new ScriptComponent(script, { name: 'ScriptComponent' }));

        boss_script.manager.register_variable('player', player);

        Luxe.events.listen('reload', reload_script);
    }
    
    override function onenter<T>(ignored:T) 
    {
        trace('enter TestView');

        setup();
        /*
        seq = new ScriptSequencer();
        seq.loop = false;
        //seq.abort_function = stop_actions;
        seq.add({ name: 'intro', func: test_func, num: 1 });
        seq.add({ name: 'next', func: test_func2, num: 3 });
        seq.start();
        */
    } //onenter

    /*
    var seq : ScriptSequencer;
    var ii = 0;

    function test_func()
    {
        trace('test_func - $ii');

        ii++;

        Delta.tween(this)
            .wait(1.0)
            .onComplete(seq.complete);
    }

    function test_func2()
    {
        trace('test_func2 - $ii');

        ii++;

        Delta.tween(this)
            .wait(1.0)
            .onComplete(seq.complete);
    }
    */

    override function onleave<T>(ignored:T)
    {
    	trace('leave TestView');

        Luxe.events.unlisten('reload');
    }

    function reload_script(resource:luxe.resource.Resource.TextResource)
    {
        if (boss_script != null)
        {
            boss_script.reload(resource.asset.text);
        }
    }

    override function onkeyup(e:luxe.KeyEvent)
    {
    }


    override function update(dt:Float)
    {
        Delta.step(dt);
    }
}