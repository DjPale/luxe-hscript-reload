import luxe.States;
import luxe.Text;
import luxe.Input;
import luxe.Entity;
import luxe.Sprite;
import luxe.Input;
import luxe.Text;
import luxe.Vector;

import luxe.collision.Collision;
import luxe.collision.shapes.Polygon;

import tween.Delta;

import scripting.ScriptClassLibrary;
import scripting.ScriptManager;
import scripting.luxe.ScriptClassLibraryLuxe;
import scripting.luxe.ScriptComponent;

import Main;

/*
    In the test view (which is really the main game state) we do the following main tasks
        - Setup entities and attach components
        - Initiate checking of collision events between entities
        - Check and forward input events to entities
        - Trigger script reloads for entities
        
    We assume that all resources are loaded during Main
*/
class TestView extends State
{
	var batcher : phoenix.Batcher;
	var global : GlobalData;

    var boss : Sprite;
    var boss_script : ScriptComponent;
    var boss_weapons : BossWeapons;
    var boss_hull : EntityHull;
    var boss_bar : Text;

    var player : Sprite;
    var player_script : ScriptComponent;
    var player_hull : EntityHull;
    var player_bar : Text;
    var player_weapon : PlayerWeapon;

    var background : Sprite;

    var event_ids : Array<String>;

#if debug
    var shape_drawer = new luxe.collision.ShapeDrawerLuxe();
#end

	public function new(_global:GlobalData, _batcher:phoenix.Batcher)
	{
		super({ name: 'TestView' });

		batcher = _batcher;
		global = _global;

        event_ids = new Array<String>();
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

        var ratio = Luxe.screen.w / Luxe.screen.h;

        background = new Sprite({
            name: 'background',
            texture: Luxe.resources.texture('assets/sprites/background.png'),
            size: new Vector(Luxe.screen.w, Luxe.screen.w / ratio),
            centered: false,
            depth: -1
            });

        background.color.a = 0.75;
        background.texture.clamp_t = phoenix.Texture.ClampType.repeat;

        event_ids.push(Luxe.events.listen('Luxe.reload', reload_script));
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
        player_hull = player.add(new EntityHull(2, {name: 'EntityHull'}));
        player_hull.body = Polygon.rectangle(player.pos.x, player.pos.y, 24, 32);
        player_weapon = player.add(new PlayerWeapon({name: 'PlayerWeapon'}));

        var script = Luxe.resources.text('assets/scripts/Player.hx').asset.text;
        player_script = player.add(new ScriptComponent(script, { name: 'ScriptComponent' }));

        Luxe.input.bind_key('left', Key.left);
        Luxe.input.bind_key('right', Key.right);
        Luxe.input.bind_key('up', Key.up);
        Luxe.input.bind_key('down', Key.down);
        Luxe.input.bind_key('fire', Key.space);

        player_bar = new Text({
            name: 'player_bar',
            pos: new Vector(10, 10),
            });
    }

    function create_boss()
    {
        boss = new Sprite({
            name: 'Boss',
            texture: Luxe.resources.texture('assets/sprites/boss.png')
            });
        boss_weapons = boss.add(new BossWeapons({name: 'BossWeapons'}));
        boss_hull = boss.add(new EntityHull(10, {name: 'EntityHull'}));
        boss_hull.body = Polygon.rectangle(boss.pos.x, boss.pos.y, 80, 120);

        var script = Luxe.resources.text('assets/scripts/Boss.hx').asset.text;
        boss_script = boss.add(new ScriptComponent(script, { name: 'ScriptComponent' }));

        boss_script.manager.register_variable('player', player);

        boss_bar = new Text({
            name: 'boss_bar',
            pos: new Vector(Luxe.screen.w - 150, 10),
            });
    }

    function update_bars()
    {
        boss_bar.text = 'BOSS: ' + boss_hull.health;
        player_bar.text = 'P1: ' + player_hull.health;
    }

    override function onenter<T>(ignored:T) 
    {
        trace('enter TestView');

        setup();
    } //onenter


    override function onleave<T>(ignored:T)
    {
    	trace('leave TestView');

        while (event_ids.length > 0)
        {
            Luxe.events.unlisten(event_ids.pop());
        }
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

    // I prefer to keep all input checking in states to easier control enabling/disabling
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

    // sorry, a bit cheap collision system, It wouldn't work for a full-scale SHMUP since we are selecting specific entities for collisions
    function check_collisions()
    {
        if (boss_weapons != null) boss_weapons.run_hull_collision(player_hull, true);
        if (player_weapon != null) player_weapon.run_hull_collision(boss_hull, true);

        // check body collision as well
        if (player_hull.body != null && boss_hull.body != null)
        {
            var hull_coll = Collision.shapeWithShape(player_hull.body, boss_hull.body);
            if (hull_coll != null)
            {
                player.pos.add(hull_coll.separation);
                player_hull.damage(1);
            }
        }    
    }

#if debug
    function draw_shapes()
    {
        if (player_hull.body != null) shape_drawer.drawShape(player_hull.body);
        if (boss_hull.body != null) shape_drawer.drawShape(boss_hull.body);
        if (boss_weapons.bullet_shape != null) shape_drawer.drawShape(boss_weapons.bullet_shape);
        if (boss_weapons.beam_shape != null) shape_drawer.drawShape(boss_weapons.beam_shape);
    }
#end

    override function update(dt:Float)
    {
        background.uv.y += -150 * dt;

        Delta.step(dt);
        check_input();
        check_collisions();
#if debug
        draw_shapes();
#end
        update_bars();
    }
}