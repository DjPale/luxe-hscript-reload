package scripting;

// Workaround based on https://github.com/HaxeFoundation/hscript/issues/10 to allow object property access
class MyInterp extends hscript.Interp
{
	override function get(o : Dynamic, f : String ) : Dynamic {
	    if (o == null)
	    {
	    	#if debug
	    	trace('Null error when doing get "$f"');
	    	#end
	    	error(EInvalidAccess(f));
	    }

	    return Reflect.getProperty(o,f);
	}

	override function set( o : Dynamic, f : String, v : Dynamic ) : Dynamic {
	    if (o == null)
	    {
	    	#if debug
	    	trace('Null error when doing set "$f"');
	    	#end
	    	error(EInvalidAccess(f));
	    }

	    Reflect.setProperty(o,f,v);
	    return v;
	}
}