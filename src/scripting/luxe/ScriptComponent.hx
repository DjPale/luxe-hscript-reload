package scripting.luxe;

import scripting.ScriptManager;

import luxe.Component;

class ScriptComponent extends Component
{
	public var manager(default,null) : ScriptManager;

	var _script : String;

	public function new(script:String, ?_options:luxe.options.ComponentOptions)
	{
		super(_options);

        manager = new ScriptManager();
		manager.register_variable('Luxe', Luxe);

        _script = script;
	}

	override function init()
	{
		manager.register_variable('entity', entity);

		load(_script);
	}

	override function ondestroy()
	{
		manager.run_function('destroy');
	}

	function load(script:String)
	{
		manager.load_script(script);
		manager.run_function('init');
		manager.run_function('main');		
	}

	public function reload(script:String)
	{
		manager.run_function('destroy');
		load(script);
	}
}