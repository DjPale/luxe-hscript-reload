package scripting;

typedef SequenceAction = {  
	name: String,
	func: Void->Void,
	num: Int
};

class ScriptSequencer
{
	var actions : Array<SequenceAction>;

	var queue_name : String;
	var current_idx : Int;
	var current_num : Int;

	public var abort_function(default,default) : Void->Void;
	public var loop(default,default) : Int = -1;
	public var running(default,null) : Bool;

	public function new()
	{
		actions = new Array<SequenceAction>();
	}

	public function add(s:SequenceAction)
	{
		actions.push(s);
	}

	public function complete()
	{
		if (queue_name != null)
		{
			var idx = find_sequence(queue_name);
			if (idx != -1)
			{
				current_idx = idx;
				current_num = 0;
			}
		}
		else
		{
			current_num++;

			#if debug
			trace('sequence idx=$current_idx num=$current_num');
			#end

			if (current_num >= actions[current_idx].num)
			{
				current_idx++;
				current_num = 0;
			}

			if (current_idx >= actions.length)
			{
				current_idx = 0;
				current_num = 0;

				if (loop == -1)
				{
					running = false;
				}
				else
				{
					current_idx = loop;
					current_num = 0;
				}
			}
		}

		if (running)
		{
			actions[current_idx].func();
		}
	}

	inline function find_sequence(name:String) : Int
	{
		var idx = 0;
		for (s in actions)
		{
			if (s.name == name)
			{
				break;
			}

			idx++;
		}

		return -1;
	}

	public function abort()
	{
		if (abort_function != null)
		{
			abort_function();
		}

		running = false;
		current_idx = 0;
		current_num = -1;
	}

	public function start(?name:String = null, ?abort_current:Bool = false)
	{
		if (name != null)
		{
			queue_name = name;
		}
		else
		{
			current_idx = 0;
			current_num = -1;
		}

		if (running)
		{
			if (abort_current)
			{
				if (abort_function != null)
				{
					abort_function();
				}

				complete();
			}
		}
		else
		{
			running = true;
			complete();
		}
	}
}