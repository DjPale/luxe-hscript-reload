import luxe.Input;
import luxe.States;
import luxe.Parcel;

typedef GlobalData = {
    views: States,
    script: String,
}

class Main extends luxe.Game 
{
    var global : GlobalData = { views: null, script: null };

    override function config(config:luxe.AppConfig) : luxe.AppConfig
    {
        config.window.title = 'hscript test in luxe!';

        config.preload.texts.push({id: 'assets/Test1.hx'});

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
        setup();
    }

    override function ready()
    {
        // var preload = new Parcel();
        // preload.from_json(Luxe.resources.json('assets/parcel.json').asset.json);

        // new CustomProgress(preload, load_complete);

        // preload.load();

        global.script = Luxe.resources.text('assets/Test1.hx').asset.text; 

        load_complete(true);
    } //ready

    override function onkeyup( e:KeyEvent ) 
    {
        if (e.keycode == Key.escape) 
        {
            Luxe.shutdown();
        }

    } //onkeyup

    override function update(dt:Float) 
    {
    } //update
    
} //Main
