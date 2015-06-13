import luxe.States;
import luxe.Text;
import luxe.Input;
import luxe.Sprite;

import tween.Delta;

import scripting.ScriptClassLibrary;
import scripting.ScriptManager;

import Main;

class TestView extends State
{
	var batcher : phoenix.Batcher;
	var global : GlobalData;

    var enemy_spr : Sprite;

    var script : ScriptManager;

	public function new(_global:GlobalData, _batcher:phoenix.Batcher)
	{
		super({ name: 'TestView' });

		batcher = _batcher;
		global = _global;

        enemy_spr = new Sprite({name:'enemy'});
        enemy_spr.add(new BossWeapons({name: 'BossWeapons'}));


        script = new ScriptManager();

        script.register_variable('Luxe', Luxe);
        script.register_variable('entity', enemy_spr);
    }

	override function onenabled<T>(ignored:T)
    {
    	trace('enable TestView');
    } //onenabled

    override function ondisabled<T>(ignored:T)
    {
    	trace('disable TestView');
    } //ondisabled

    
    override function onenter<T>(ignored:T) 
    {
        trace('enter TestView');

        load_script(Luxe.resources.text('assets/Test1.hx'));
        Luxe.events.listen('reload', reload_script);

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

    function load_script(resource:luxe.resource.Resource.TextResource)
    {
        script.load_script(resource.asset.text);
        script.run_function('init');
        script.run_function('main');
    }

    function reload_script(resource:luxe.resource.Resource.TextResource)
    {
        script.run_function('destroy');
        load_script(resource);
    }

    override function onkeyup(e:luxe.KeyEvent)
    {
    }


    override function update(dt:Float)
    {
        Delta.step(dt);
    }
}