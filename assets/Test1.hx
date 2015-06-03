class Test1
{

	function init()
	{
		ScriptInterface.trace('init called!');
	}

	function main()
	{
		ScriptInterface.trace('main called');
		ScriptInterface.label.text = 'main thru indirection';

		ScriptInterface.label.pos = new luxe.Vector();
	}
}