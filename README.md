## Abstract / TLDR;
_I have made a proof-of-concept which uses **hscript** together with **luxe** and the new **automatic reloading** functionality to provide a very quick way of tweaking entity behavior. With some workarounds which I have provided, I think this is a viable way doing prototyping. A big bonus with my solution is that scripts will behave as a normal Haxe-files. This makes the default **code completion work out-of-the-box** for most IDE's / text editors - which I think is absolutely necessary when scripting._

**Check out the [snõwkit post](http://snowkit.org/2015/06/20/using-hscript-to-program-entity-behaviors-in-luxe-with-auto-reload/) for more details, or a bloated [animated gif](https://dl.dropboxusercontent.com/u/541553/Misc/boss2.gif) or even play a [web version](https://dl.dropboxusercontent.com/u/541553/luxe-hscript-reload/index.html)!**

![key-visual](https://dl.dropboxusercontent.com/u/541553/Misc/boss-script.png)

## My Requirements
* Code completion in IDE's have to work like normal! (I currently use Sublime Text 3).
* Short tweaking cycle
* Be able to code complex behavior, access to Haxe-like language
* Easily use tweening libraries in scripts for quickly coding animations and movements
* Little overhead
* Easily pluggable to Entity, should ideally be an Entity Component

## Prerequisites to run this code
* A working snowkit / luxe setup (see [guide here](http://luxeengine.com/docs/setup.html)).
* The hscript library (`haxelib git hscript https://github.com/HaxeFoundation/hscript.git`) - note that we need the latest development version, **2.0.4 will not work**
* The Delta tweening library, currently only on git (`haxelib git delta https://github.com/furusystems/Delta.git`)
* Latest version of hxcpp (`haxelib install hxcpp`)
* I have tested using **Haxe 3.2.0**, **hxcpp 3.2.102**, latest git versions of **luxe**, **snow**, **hscript** and **Delta** as of **20.06.15**
* Since we are using the reloading functionality - only Windows, Mac and Linux are supported. Web target should work, but will not reload.

### Limits of hscript
It is important to understand that hscript is a parser built on top of Haxe and does not have the full feature set of Haxe. This is stated on the hscript [README](https://github.com/HaxeFoundation/hscript/blob/master/README.md#limitations), but in addition beware of the following:

* In general, you will lose your type safety. hscript uses reflection and doesn't really care about types. This is to some degree alleviated by subjecting the script to completion rules when coding. I don't think I would have pursued this path without proper completion as described earlier.
* hscript doesn't handle generics, so it will give an error on any variable declarations like `new Array<String>`, but it is possible to instance it like this: `new Array()`.
* Another minor detail - you cannot use variable substitutions in strings (like `trace('idx = $i'));`

### Script format
In general, the code completion topic and the extra "features" that I allow as an "extension" to hscript leads to that the file format needs to adhere to a couple of rules. (Also note that I haven't done extensive testing to find faults of the formats, please let me know if you find any border cases that breaks it).

##### Minimal script
In principle, we can use any minimal script as normal hscript allows as follows:
```
var nothing = 0;
```
##### Class-based script
This script is not connected to the luxe component. If you go this route, you can define one and only **one class without extensions** in your file. Optionally, you can include import statements that will be auto-assigned like `luxe.Sprite` in the following example:
```
import luxe.Sprite;

class Dummy
{
	var entity : Sprite = entity; // assumes entity is assigned to script manager

	function a_function()
	{
		entity.color.a = 0;
	}
}
```

For the above example, after the "stripping", the script will be passed into the hscript parser like this:
```
{
	var entity : Sprite = entity; // assumes entity is assigned to script manager

	function a_function()
	{
		entity.color.a = 0;
	}
}
```

Note that when using classes, all the normal hscript restrictions apply and this means that you cannot use things like:

* typedefs
* using statements
* package statement

###### Standard luxe component script
This script can be utilized directly by the luxe `ScriptComponent` class as a template:
```
import luxe.Sprite;

class EmptyScript
{
	// always defined, this is the entity variable of the component, already cast to Sprite
	var entity : Sprite = entity;

	function init()
	{
		// called when the component is initialized (Component.init)
	}

	function ondestroy()
	{
		// called before reloading and when destroying the component (Component.ondestroy)
	}

	function update()
	{
		// called each update, can be omitted and will not be attempted to call unless defined in the script
		// note that you have to use Luxe.time to calculate your own delta time
	}
}
```

### Debugging
Unfortunately, debugging becomes a lot harder with scripts in general, and also when using a very callback-heavy architecture. Here I have a hard time knowing which part of the script has actually failed. This is one possible area for future improvement.
```
Called from snow.Snow::on_event snow/Snow.hx line 311
Called from snow.Snow::on_snow_update snow/Snow.hx line 263
Called from snow.App::on_internal_update snow/App.hx line 151
Called from snow.Snow::do_internal_update snow/Snow.hx line 233
Called from luxe.Core::update luxe/Core.hx line 415
Called from luxe.Emitter::emit luxe/Emitter.hx line 47
Called from luxe.States::update luxe/States.hx line 407
Called from TestView::update TestView.hx line 121
Called from tween.Delta::step tween/Delta.hx line 334
Called from tween._Delta.TweenSequence::step tween/Delta.hx line 2
Called from tween._Delta.TweenAction::step tween/Delta.hx line 221
Called from *::_Function_3_1 hscript/Interp.hx line 399
Called from hscript.Interp::exprReturn hscript/Interp.hx line 211
```

### Notes about class availability for scripts

* Haxe can't load classes which aren't declared at compile time. Imports that are not used anywhere are by default ignored by the Haxe Dead Code Elimination (DCE). This must therefore be turned on in the flow file under the `build` section like this: `flags: ['-dce no']`.
* Be aware that import statements with asterisk does not work! (For example `import luxe.collision.*`).
* To easier collect all classes needed, I created a separate class to include all avaible classes to the script. This idea was borrowed from [Acadnme](https://github.com/nmehost/acadnme/blob/master/engine/src/AllNme.hx).
* Another important thing to note is that Luxe uses "aliases" (typdefs) to create a consistent luxe namespace, for example `typedef Vector = phoenix.Vector;`. Since we and hscript use `Type.resolveClass` to map classes, this means that we have to use the actual class when importing, both in the scripts and in the `ScriptClassLibrary` class. So, instead of importing `luxe.Vector`, we have to use `phoenix.Vector`.

## Overall architecture
All core script helper classes are framework-independent and resides under the `scripting` source folder. 

#### Scripting
The scripts should primarly control state and values of entities and components - note that I do not create or destroy any components or entities inside scripts themselves. This is of course not an absolute rule or technical limitation, but I think it makes the architecture clearer by setting some overall rules - it also helps deciding where to put some additional logic or feature.

I created a script handler for ease the dealing with script loading and function calling - including catching potential errors without crashing. I created separate classes / files declaring imports to make classes available to the scripts. For convenience, I also created a luxe Component to handle scripts to be attached to entities. 

The `ScriptSequencer` class that specifies functions calls, how many times they will be called and a loop point. It can be used from scripts like this:
```
		seq = new ScriptSequencer();
		seq.loop = 1;
		seq.abort_function = stop_actions;
		seq.add({ name: 'intro', func: intro, num: 1 });
		seq.add({ name: 'swipe', func: swipe, num: 2 });
		seq.add({ name: 'prepare_beam', func: prepare_beam, num: 1 });
		seq.add({ name: 'approach', func: approach, num: 1 });
```

###### Pitfalls
* Runaway event handlers - always clean up your events. In the script I have an array of references which I add to and always empty and `unlisten` in `ondestroy`.
* Be careful when calling the `init` function again from the script itself. You might end up with runaway event handlers. Make a separate `reset` function or similar instead.
* Do small changes in the script before saving and testing. After all - this is what this solution excels at! Also, it is easier to pinpoint errors since debugging is currently very hard.

#### Components
All "hard-coded" components like weapons and health are (mostly) stand-alone, and do not know much about other components. There are some exceptions, but I try to have other components as explicit dependencies and not implicit ones. 

Further, the "core" component classes emit events that can be picked up by other components or scripts. The scripts are generally allowed to access components directly if needed. They also subscribe to events from the generic components.Example to access other components from the script:
```
		hull = entity.get('EntityHull');
		hull.auto_immune_timer = 1;
```

#### Events
For handling bullet / weapon logic, I soon discovered that I also spent time customizing some aspects (especially aestethics) of the weapon sprites themselves, so I had to provide separate events for this as well. As an example, the following event fires when shooting a new bullet: `entity.events.fire('BossWeapons.bullet.fire', b);`. This can be linked up in the script with a custom functions to do a simple animation, for example:
```
function init()
{
	// ...
	event_ids.push(entity.events.listen('BossWeapons.bullet.fire', bullet_fire));
	// ...
}

function bullet_fire(bullet:Sprite)
{
	bullet.scale.x = 1;
	bullet.scale.y = 1;
	Actuate.tween(bullet.scale, 0.5, { x: 2, y: 2 }).reflect().repeat();
}
```
A side-note here is that I save all the event-id's for the registered in an array. This makes the cleanup job much easier and more reliable. The only downside of an event-based and callback-heavy architecture is that it is a lot harder to debug as mentioned previously.

Later, I decided to add the player as a script as well, just for fun! I quickly realized that I would need the update loop to handle some of the logic, so I also support this. The function is optional and no calls are attempted at all if it doesn't exist.

#### Summary
To summarize, this is how I intended to use the scripting architecture:

 * The general scripting classes make no assumptions of what you're trying to do and should be independent.
 * The component makes the assumptions that you are tying it to an entity, so it adds entity and standard functions
 * I place game-specific assignments into a separate state - these are assumptions about the game, for example that there is a player variable that the boss can use for whatever it wants...
 * To make additional classes available for the script to use, you can add custom files for imports, like `ScriptClassLibraryLuxe`.

## Reload functionality in snõw
@underscorediscovery described this in his [alpha-2 wrap-up post](http://snowkit.org/2015/04/30/alpha-2-0010-recap/). Be aware that this only works with desktop targets which have an actual filesystem. Just remember to add `--sync` when running `flow`. Hook on to the reload event, and the rest is automatic. Beware that you will get the full path with the event data. Another important thing to notice is that currently, any single file will generate an event for the watched directory, so there is currently no easy way to distinguish which script was actually reloaded. The result is that all scripts will be reloaded as soon as you save one of them. I'm not sure if this behavior is correct...

## Future
Some of the things that I might look into (or suggestions for others!) include:

* Actually learn to use the luxe log facilities properly instead of throwing `trace`calls around
* Find a better way of pinpointing errors and debugging info from script
* Add compiler flag for conditionally compiling scripts as normal luxe Components (needs some modifications and possibly path tricks).
* Expand the functionality of helper functions for running sequences (like the luxe animation component)
* Explore state machines or a data-driven approach with behavior-trees or similar (as suggested by @underscorediscovery)
* I would like to explore the possibility for creating a `cppia` host for luxe similar to Acadnme :)

## Credits / licenses
* All code (including scripts) are released under the [MIT License](http://choosealicense.com/licenses/mit/) (c) 2015 dj_pale
* The ship sprites and bullet sprite are by @JeromBD and released under [CC-BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/) (c) 2011 JeromBD from [opengameart.org](http://opengameart.org/sites/default/files/JEROM_spaceships0_CC-BY-3.png). They are slightly modified.
* The background sprite is licensed under [CC-BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/) (c) 2015 dj_pale
* For more details on the Haxe libraries used - visit their pages on [GitHub.com](GitHub.com)