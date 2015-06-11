import hscript.Parser;
import hscript.Expr;
import hscript.Interp;

typedef ScriptFunction = Void->Void;

class ScriptManager
{
	var scr_parser : Parser;
	var scr_interp : Interp;
	var scr_program : Expr;

	var functions : Map<String,ScriptFunction>;

	public function new()
	{
		scr_parser = new Parser();
		scr_parser.allowTypes = true; 

		scr_interp = new Interp();

		functions = new Map<String,ScriptFunction>();
	}


	function setup_script()
	{
	    trace('setup_script');

	    if (scr_program == null)
	    {
	    	trace('no script loaded, call load_script first!');
	    	return;
	    }
   
	    try
	    {
	        scr_interp.execute(scr_program);
	    }
	    catch(e:Dynamic)
	    {
	        trace('Script runtime error: ${e.e}');
	        return;
	    }
	}

	public inline function register_variable(name:String, value:Dynamic)
	{
		scr_interp.variables.set(name, value);
	}

	public function load_script(script:String)
	{
	    trace('load_script');

	    var import_re = ~/\s*import\s+([^;]+);/;
	    var class_re = ~/\s*class\s+([a-zA-Z0-9]+)\s*({?)/;

	    var includes = new Array<String>();

	    var lines = script.split('\n');

	    var idx = 0;
	    var ofs = 0;
	    for (line in lines)
	    {
	    	if (import_re.match(line))
	    	{
	    		includes.push(import_re.matched(1));
	    		ofs = idx + 1;
	    	}

	    	idx++;
	    }

	    try
	    {
	        scr_program = scr_parser.parseString(script.toString());
	    }
	    catch(e:Dynamic)
	    {
	        trace('Script parse error: ${e.e}');
	        return;
	    }

	    for (inc in includes)
	    {
	    	var cname = inc;
	    	var ldot = cname.lastIndexOf('.');
	    	if (ldot != -1)
	    	{
	    		cname = cname.substr(ldot + 1);
	    	}

	    	var class_type = Type.resolveClass(inc);
	    	register_variable(cname, class_type);
		    trace('resolve $inc = $cname = $class_type');
	    }

	    setup_script();
	}


	public function run_function(func:String) : Bool
	{
	    trace('run_function = $func');

  	    if (scr_program == null)
	    {
	    	trace('no script loaded, call load_script first!');
	    	return false;
	    }  

	    var fun_ptr : ScriptFunction = functions.get(func);

	    if (fun_ptr == null)
	    {
	    	trace('run_function $func not in cache, trying to locate it');
	    	fun_ptr = cast scr_interp.variables.get(func);
	    }

	    if (fun_ptr == null)
	    {
	    	trace('run_function $func not found!');
	    	return false;
	    }

	    trace('run_function $func found, trying to execute!');

        try
        {
            fun_ptr();
        }
        catch(e:Dynamic)
        {
            trace('Script runtime error for $func: ${e.e}');
            return false;
        }

        return true;
	}
}