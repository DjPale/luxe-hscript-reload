import luxe.States;
import luxe.Text;
import luxe.Input;
import luxe.Vector;
import luxe.Sprite;

import tween.Delta;

import hscript.Parser;
import hscript.Expr;
import hscript.Interp;

import Main;

class TestView extends State
{
	var batcher : phoenix.Batcher;
	var global : GlobalData;

    var scr_parser : Parser;
    var scr_interp : Interp;
    var scr_program : Expr;

    var scr_init : Void->Void;
    var scr_main : Void->Void;
    var scr_destroy : Void->Void;

    var enemy_spr : Sprite;

	public function new(_global:GlobalData, _batcher:phoenix.Batcher)
	{
		super({ name: 'TestView' });

		batcher = _batcher;
		global = _global;

        enemy_spr = new Sprite({name:'enemy'});

        scr_parser = new Parser();
        scr_parser.allowTypes = true; 

        scr_interp = new Interp();
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

        setup_script();
        run_script();

        Luxe.events.listen('reload', reload_script);
    } //onenter

    override function onleave<T>(ignored:T)
    {
    	trace('leave TestView');

        Luxe.events.unlisten('reload');
    }

    override function onkeyup(e:luxe.KeyEvent)
    {
        scr_destroy();
        scr_init();
        scr_main();
    }

    function reload_script(_)
    {
        scr_destroy();

        setup_script();
        run_script();
    }

    function load_script()
    {
        trace('load_script');

        scr_interp.variables.set('Luxe', Luxe);
        scr_interp.variables.set('Delta', Delta);
        scr_interp.variables.set('Vector', luxe.Vector);
        scr_interp.variables.set('Sprite', luxe.Sprite);
        scr_interp.variables.set('entity', enemy_spr);
        
        try
        {
            scr_interp.execute(scr_program);
        }
        catch(e:Dynamic)
        {
            trace('Script runtime error: $e');
            return;
        }

        scr_init = cast scr_interp.variables.get('init');
        scr_main = cast scr_interp.variables.get('main');
        scr_destroy = cast scr_interp.variables.get('destroy');

        if (scr_init != null)
        {
            scr_init();
        }
    }

    function setup_script()
    {
        trace('setup_script');

        try
        {
            scr_program = scr_parser.parseString(global.script);
            load_script();
        }
        catch(e:Dynamic)
        {
            trace('Script parse error: $e');
        }
    }


    function run_script()
    {
        trace('run_script');

        if (scr_main != null)
        {
            try
            {
                scr_main();
            }
            catch(e:Dynamic)
            {
                trace('Script runtime error: ${e.e}');
                return;
            }
        }
    }

    override function update(dt:Float)
    {
        Delta.step(dt);
    }
}