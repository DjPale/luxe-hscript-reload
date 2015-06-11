import luxe.States;
import luxe.Text;
import luxe.Input;
import luxe.Vector;
import luxe.Sprite;

import tween.Delta;
import tween.easing.*;

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

        tween.easing.Back.easeIn(0, 0, 0);
        tween.easing.Bounce.easeIn(0, 0, 0);
        tween.easing.Cubic.easeIn(0, 0, 0);
        tween.easing.Elastic.easeIn(0, 0, 0);
        tween.easing.Expo.easeIn(0, 0, 0);
        tween.easing.Quad.easeIn(0, 0, 0);
        tween.easing.Quart.easeIn(0, 0, 0);
        //tween.easing.Quint.easeIn(0, 0, 0);
        tween.easing.Sine.easeIn(0, 0, 0);

        trace(new Vector());
        script = new ScriptManager();

        script.register_variable('Luxe', Luxe);
        script.register_variable('entity', enemy_spr);
        script.register_variable('Vector', luxe.Vector);
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
    } //onenter

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