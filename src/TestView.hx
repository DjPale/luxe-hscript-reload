import luxe.States;
import luxe.Text;
import luxe.Input;
import luxe.Vector;

import hscript.Parser;
import hscript.Expr;

import Main;

class TestView extends State
{
	var batcher : phoenix.Batcher;
	var global : GlobalData;

    var scr_parser : Parser;
    var scr_interp : MyInterp;
    var scr_program : Expr;

    var scr_init : Void->Void;
    var scr_main : Void->Void;

	public function new(_global:GlobalData, _batcher:phoenix.Batcher)
	{
		super({ name: 'TestView' });

		batcher = _batcher;
		global = _global;

        scr_parser = new Parser();
        scr_parser.allowTypes = true;      

        scr_program = scr_parser.parseString(global.script);

        scr_interp = new MyInterp();
        scr_interp.variables.set('ScriptInterface', ScriptInterface);
        scr_interp.variables.set('luxe.Vector', luxe.Vector);

        scr_interp.execute(scr_program);

        scr_init = cast scr_interp.variables.get('init');
        scr_main = cast scr_interp.variables.get('main');

        scr_init();

        ScriptInterface.label = new Text({
            name: 'label',
            pos: Luxe.screen.mid,
            point_size: 30,
            text: 'label'
            });
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

        run_script();
    } //onenter

    override function onleave<T>(ignored:T)
    {
    	trace('leave TestView');
    }

    override function onkeyup(e:luxe.KeyEvent)
    {
        run_script();
    }

    function run_script()
    {
       scr_main();
    }
}