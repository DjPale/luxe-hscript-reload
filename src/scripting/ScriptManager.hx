package scripting;

import hscript.Parser;
import hscript.Expr;
import scripting.MyInterp;

using StringTools;

typedef ScriptFunction = Void->Void;

class ScriptManager
{
	var scr_parser : Parser;
	var scr_interp : MyInterp;
	var scr_program : Expr;

	var functions : Map<String,ScriptFunction>;

	public function new()
	{
		scr_parser = new Parser();
		scr_parser.allowTypes = true; 

		scr_interp = new MyInterp();
	}

	function setup_script() : Bool
	{
	    trace('setup_script');

	    if (scr_program == null)
	    {
	    	trace('no script loaded, call load_script first!');
	    	return false;
	    }
   
	    try
	    {
	        scr_interp.execute(scr_program);
	    }
	    catch(e:Dynamic)
	    {
	        trace('Script runtime error: ' + #if hscriptPos e.e #else e #end);
	        return false;
	    }

	    if (functions != null)
	    {
		   	for (key in functions.keys())
		   	{
		   		functions.set(key, null);
		   	}

	    	functions = null;
		}

		return true;
	}

	public inline function register_variable(name:String, value:Dynamic)
	{
		scr_interp.variables.set(name, value);
	}

	public function load_script(script:String) : Bool
	{
	    trace('load_script');

	    var import_re = ~/\s*import\s+([^;]+);/;
	    // TODO: allow extends
	    var class_re = ~/\s*class\s+([a-zA-Z0-9]+)\s*({?)/;
	    // TODO: allow package

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
	    	else if (class_re.match(line))
	    	{
	    		// include bracket if it is on the same line to have a valid expression block for the parser
	    		var bracket = class_re.matched(1);
	    		if (bracket != null && bracket == '{')
	    		{
	    			lines[idx] = '{';
	    			ofs = idx;
	    		}
	    		else
	    		{
		    		ofs = idx + 1;
		    	}

	    		// stop processing if we encounter 'class'
	    		break;
	    	}

	    	idx++;
	    }

	    if (ofs >= lines.length)
	    {
	    	trace('Script parse error - premature ending after stripping import/class statements');
	    	return false;
	    }

	    var final_script = script;

	    // re-create script without "heading" if needed
	    if (ofs > 0 || includes.length > 0)
	    {
		    var string_buf = new StringBuf();
		    for (i in ofs...lines.length)
		    {
		    	string_buf.add(lines[i]);
		    }

		    final_script = string_buf.toString();
		}

		trace(final_script);

	    try
	    {
	        scr_program = scr_parser.parseString(final_script.toString());
	    }
	    catch(e:Dynamic)
	    {
	        trace('Script parse error: ' + #if hscriptPos e.e #else e #end);
	        return false;
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

	    	if (class_type == null)
	    	{
		    	trace('failed to resolve $inc = $cname = $class_type');
		    	return false;
		    }
	    }

	    return setup_script();
	}

	public function has_function(func:String) : Bool
	{
		return (scr_interp.variables.get(func) != null);
	}

	public function run_function(func:String) : Bool
	{
	    //trace('run_function = $func');
  	    if (scr_program == null)
	    {
	    	trace('no script loaded, call load_script first!');
	    	return false;
	    }  

	    if (functions == null)
	    {
	    	functions = new Map<String,ScriptFunction>();
	    }

	    var fun_ptr : ScriptFunction = functions.get(func);

	    if (fun_ptr == null)
	    {
	    	trace('run_function $func not in cache, trying to locate it');
	    	fun_ptr = cast scr_interp.variables.get(func);

	    	if (fun_ptr == null)
	    	{
	    		trace('run_function $func not found!');
	    		return false;
	    	}

		    functions.set(func, fun_ptr);
	    }

	    //trace('run_function $func found, trying to execute!');

        try
        {
            fun_ptr();
        }
        catch(e:Dynamic)
        {
            trace('Script runtime error for $func: ' + #if hscriptPos e.e #else e #end);
            return false;
        }

        return true;
	}
}