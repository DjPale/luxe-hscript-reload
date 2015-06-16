import luxe.Input;
import luxe.States;
import luxe.Parcel;

using StringTools;

typedef GlobalData = {
    views: States,
}

class Main extends luxe.Game 
{
    var global : GlobalData = { views: null };

    var asset_path : String = 'assets/';

    override function config(config:luxe.AppConfig) : luxe.AppConfig
    {
        config.window.title = 'luxe hscript live reload demo!';
        config.window.resizable = false;

        config.preload.texts.push({id: 'assets/Boss.hx'});
        config.preload.textures.push({id: 'assets/sprites/player.png'});
        config.preload.textures.push({id: 'assets/sprites/boss.png'});
        config.preload.textures.push({id: 'assets/sprites/boss-bullet.png'});

        return config;
    }

    function setup()
    {
        // Set up batchers, states etc.
        global.views = new States({ name: 'views' });
        global.views.add(new TestView(global, Luxe.renderer.batcher));
        global.views.set('TestView');
    }

    function load_complete(_)
    {
        #if desktop
        Luxe.snow.io.module.watch_add(asset_path);
        #end

        setup();
    }

    function notify_reload(d:luxe.resource.Resource.TextResource)
    {
        Luxe.events.fire('reload', d);
        trace('fire reload with $d');
    }

    override function ready()
    {
        load_complete(true);
    } //ready

    override function onkeyup( e:KeyEvent ) 
    {
        if (e.keycode == Key.escape) 
        {
            Luxe.shutdown();
        }

    } //onkeyup

    override function onevent( e:snow.types.Types.SystemEvent ) 
    {
        if (e.type == snow.types.Types.SystemEventType.file) 
        {
            var pos = e.file.path.indexOf(asset_path);
            if (pos >= 0)
            {
                var asset_key = e.file.path.substr(pos);
                asset_key = asset_key.replace('\\', '/');

                //trace('Trying to find asset with key "$asset_key" from ' + e.file.path);

                var resource = Luxe.resources.get(asset_key);

                if (resource != null && asset_key.endsWith('.hx')) 
                {
                    resource.reload().then(notify_reload);
                }
                else
                {
                    trace('Ignoring asset with key "$asset_key"');
                }
            }
            else
            {
                trace('Non-asset file reload ignored (${e.file.path})');
            }
        }
    } //onevent

    override function update(dt:Float) 
    {
    } //update
    
} //Main
