import luxe.States;
import luxe.Text;
import luxe.Input;
import luxe.Entity;
import luxe.Sprite;
import luxe.Input;

import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Circle;

import tween.Delta;

import scripting.ScriptClassLibrary;
import scripting.ScriptManager;
import scripting.luxe.ScriptClassLibraryLuxe;
import scripting.luxe.ScriptComponent;

import Main;

class TestView extends State
{
	var batcher : phoenix.Batcher;
	var global : GlobalData;

    var enemy : Sprite;
    var player : Sprite;
    var boss_script : ScriptComponent;
    var player_script : ScriptComponent;
    var boss_weapons : BossWeapons;
    var player_hull : EntityHull;

    var reload_id : String;

	public function new(_global:GlobalData, _batcher:phoenix.Batcher)
	{
		super({ name: 'TestView' });

		batcher = _batcher;
		global = _global;
    }

	override function onenabled<T>(ignored:T)
    {
    	trace('enable TestView');
    } //onenabled

    override function ondisabled<T>(ignored:T)
    {
    	trace('disable TestView');
    } //ondisabled

    function setup()
    {
        create_player();
        create_boss();

        reload_id = Luxe.events.listen('Luxe.reload', reload_script);
    }
    
    function create_player()
    {
        player = new Sprite({
            name: 'Player',
            pos: new luxe.Vector(Luxe.screen.mid.x, 400),
            texture: Luxe.resources.texture('assets/sprites/player.png'),
            scale: new luxe.Vector(1.5, 1.5)
            });

        //player.add(new PlayerWeapon({name: 'PlayerWeapon'}));
        player_hull = player.add(new EntityHull(3, {name: 'EntityHull'}));
        player_hull.body = Polygon.rectangle(player.pos.x, player.pos.y, 24, 32);

        var script = Luxe.resources.text('assets/Player.hx').asset.text;
        player_script = player.add(new ScriptComponent(script, { name: 'ScriptComponent' }));

        Luxe.input.bind_key('left', Key.left);
        Luxe.input.bind_key('right', Key.right);
        Luxe.input.bind_key('up', Key.up);
        Luxe.input.bind_key('down', Key.down);
        Luxe.input.bind_key('fire', Key.space);
    }

    function create_boss()
    {
        enemy = new Sprite({
            name: 'Boss',
            texture: Luxe.resources.texture('assets/sprites/boss.png')
            });
        boss_weapons = enemy.add(new BossWeapons({name: 'BossWeapons'}));
        enemy.add(new EntityHull(10, {name: 'EntityHull'}));

        var script = Luxe.resources.text('assets/Boss.hx').asset.text;
        boss_script = enemy.add(new ScriptComponent(script, { name: 'ScriptComponent' }));

        boss_script.manager.register_variable('player', player);
    }

    override function onenter<T>(ignored:T) 
    {
        trace('enter TestView');

        setup();
    } //onenter


    override function onleave<T>(ignored:T)
    {
    	trace('leave TestView');

        Luxe.events.unlisten(reload_id);
    }

    function reload_script(resource:luxe.resource.Resource.TextResource)
    {
        if (resource.id.indexOf('Boss') != -1)
        {
            if (boss_script != null)
            {
                trace('reload Boss');
                boss_script.reload(resource.asset.text);
            }
        }
        else if (resource.id.indexOf('Player') != -1)
        {
            if (player_script != null)
            {
                trace('reload Player');
                player_script.reload(resource.asset.text);
            }          
        }
    }

    function check_input()
    {
        if (player_script == null)
        {
            return;
        }

        if (Luxe.input.inputdown('left'))
        {
            player_script.manager.run_function('move_left');
        }
        else if (Luxe.input.inputdown('right'))
        {
            player_script.manager.run_function('move_right');
        }

        if (Luxe.input.inputdown('up'))
        {
            player_script.manager.run_function('move_up');
        }
        else if (Luxe.input.inputdown('down'))
        {
            player_script.manager.run_function('move_down');
        }

        if (Luxe.input.inputdown('fire'))
        {
            player_script.manager.run_function('fire');           
        }
    }

    // sorry, a bit cheap
    function check_collisions()
    {
        if (boss_weapons == null) return;

        for (b in boss_weapons.bullets.items)
        {
            if (b.visible)
            {
                if (player_hull.body.testCircle(new Circle(b.pos.x, b.pos.y, 8)) != null)
                {
                    boss_weapons.hide_bullet(b);
                    player_hull.damage(1);
                }
            }
        }

        var beam = boss_weapons.beam;

        // TODO: doesn't work currently
        if (beam.visible)
        {
            if (player_hull.body.testPolygon(Polygon.rectangle(beam.pos.x, beam.pos.y, beam.size.x, beam.size.y)) != null)
            {
                player_hull.damage(2);
            }
        }
    }

    override function update(dt:Float)
    {
        Delta.step(dt);
        check_input();
        check_collisions();
    }
}