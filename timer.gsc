#include maps\mp\_utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;

init()
{
    level.eet_version = "V1.1";
    level.eet_active_color = (0.82, 0.97, 0.97);
    level.eet_complete_color = (0.01, 0.62, 0.74);

    solo = level.is_forever_solo_game;

    if(is_map("zm_transit"))
    {
        if(solo)    level thread timer( strtok("Jetgun|Tower|EMP", "|"), 15);
        //else tranzit branching timer timer
    }
    else if(is_map("zm_highrise"))
    {
        //Die rise timer
    }
    else if(is_map("zm_prison"))
    {
        if(solo)    level thread timer( strtok("Dryer|Gondola1|Plane1|Gondola2|Plane2|Gondola3|Plane3|Codes|Done", "|"), 65);
        else        level thread timer( strtok("Plane1|Plane2|Plane3|Codes|End", "|"), 65);
    }
    else if(is_map("zm_buried"))
    {
        //Buried timer  
    }
    else if(is_map("zm_tomb"))
    {
        if(solo)    level thread timer( strtok("NML|Boxes|Staff 1|Staff 2|Staff 3|Staff 4|AFD|End", "|"), 125);
        else        level thread timer( strtok("Boxes|AFD|End", "|"), 125 );
    }
    else
    {
        return;
    }

    level thread on_player_connect();
    if(upgrades_active()) level thread upgrade_dvars();      
}

on_player_connect()
{
    level endon( "game_ended" );
    while(true)
    {
        level waittill( "connected", player );
        player thread on_player_spawned();
    }
}

on_player_spawned()
{
    self waittill( "spawned_player" );
    if(upgrades_active()) self thread upgrades_bank();
    wait 2.5;
    self iPrintLn("^6GSC EE Autotimer ^5" + level.eet_version + " ^8| ^3github.com/HuthTV/BO2-Easter-Egg-GSC-timer");
}

timer( split_list, y_offset )
{
    level endon( "game_ended" );
    
    foreach(split in split_list)
        create_new_split(split, y_offset); 

    flag_wait("initial_blackscreen_passed");
    level.eet_start_time = gettime();
    for(i = 0; i < split_list.size; i++)
    {
        unhide(split_list[i]);
        split(split_list[i], wait_split(split_list[i]));
    } 
}

create_new_split(split_name, y_offset)
{
    y = y_offset;
    y += (level.eet_splits.size - 1) * 16;
    level.eet_splits[split_name] = newhudelem();
    level.eet_splits[split_name].alignx = "left";
    level.eet_splits[split_name].aligny = "center";
    level.eet_splits[split_name].horzalign = "left";
    level.eet_splits[split_name].vertalign = "top";
    level.eet_splits[split_name].x = -62;
    level.eet_splits[split_name].y = -34 + y;
    level.eet_splits[split_name].fontscale = 1.4;
    level.eet_splits[split_name].hidewheninmenu = 1;
    level.eet_splits[split_name].alpha = 0;
    level.eet_splits[split_name].color = level.eet_active_color;
    level thread split_start_thread(split_name);
    set_split_label(split_name);
}

split_start_thread(split_name)
{
    flag_wait("initial_blackscreen_passed");
    level.eet_splits[split_name] settenthstimerup(0.05);
}

set_split_label(split_name)
{
    switch (split_name) 
    {
        case "Jetgun": level.eet_splits[split_name].label = &"^3Jetgun ^7"; break;
        case "Tower": level.eet_splits[split_name].label = &"^3Tower ^7"; break;
        case "NML": level.eet_splits[split_name].label = &"^3NML ^7"; break;
        case "Boxes": level.eet_splits[split_name].label = &"^3Boxes ^7"; break;
        case "Staff 1": level.eet_splits[split_name].label = &"^3Staff I ^7"; break;
        case "Staff 2": level.eet_splits[split_name].label = &"^3Staff II ^7"; break;
        case "Staff 3": level.eet_splits[split_name].label = &"^3Staff III ^7"; break;
        case "Staff 4": level.eet_splits[split_name].label = &"^3Staff IV ^7"; break;
        case "AFD": level.eet_splits[split_name].label = &"^3AFD ^7"; break;
        case "Dryer": level.eet_splits[split_name].label = &"^3Dryer ^7"; break;
        case "Gondola1": level.eet_splits[split_name].label = &"^3Gondola I ^7"; break;
        case "Gondola2": level.eet_splits[split_name].label = &"^3Gondola II ^7"; break;
        case "Gondola3": level.eet_splits[split_name].label = &"^3Gondola III ^7"; break;
        case "Plane1": level.eet_splits[split_name].label = &"^3Plane I ^7"; break;
        case "Plane2": level.eet_splits[split_name].label = &"^3Plane II ^7"; break;
        case "Plane3": level.eet_splits[split_name].label = &"^3Plane III ^7"; break;
        case "Codes": level.eet_splits[split_name].label = &"^3Codes ^7"; break;
        case "Fight":
        case "End": 
        case "EMP":
        case "Done":
            level.eet_splits[split_name].label = &"^3End ^7"; break;
    }
}

unhide(split_name)
{
    level.eet_splits[split_name].alpha = 0.8;
}

split(split_name, time)
{
    level.eet_splits[split_name].color = level.eet_complete_color;
    level.eet_splits[split_name] settext(game_time_string(time - level.eet_start_time)); 
}

wait_split(split)
{
    switch (split) 
    {
        //Origins splits
        case "NML": 
        flag_wait("activate_zone_nml");
        break;

        case "Boxes":
            while(level.n_soul_boxes_completed < 4) wait 0.05;
            wait 4.3;
            break;
            
        case "Staff 1":
        case "Staff 2":
        case "Staff 3":
        case "Staff 4":
            curr = level.n_staffs_crafted;
            while(curr == level.n_staffs_crafted && level.n_staffs_crafted < 4) wait 0.05;
            //Change staff label?
            break;

        case "AFD":
            flag_wait("ee_all_staffs_placed");
            break;

        //Mob splits
        case "Dryer": 
            flag_wait("dryer_cycle_active");
            break;  

        case "Gondola1":
            flag_wait("fueltanks_found");
            flag_wait("gondola_in_motion");
            break;  
            
        case "Plane1":
        case "Plane2":
        case "Plane3":
            flag_wait("plane_boarded");
            break;  

        case "Gondola2":
        case "Gondola3":
            flag_wait("gondola_in_motion");
            break;  

        case "Codes":
            level waittill_multiple( "nixie_final_" + 386, "nixie_final_" + 481, "nixie_final_" + 101, "nixie_final_" + 872 );
            break;  

        case "Done":
            wait 10;
            while( isdefined(level.m_headphones) ) wait 0.05;
            break;  

        //Tranzit splits
        case "Jetgun": 
            while(level.sq_progress["rich"]["A_jetgun_built"] == 0) wait 0.05;
            break;

        case "Tower":
            while(level.sq_progress["rich"]["A_jetgun_tower"] == 0) wait 0.05;
            break;
            
        case "EMP":
            while(level.sq_progress["rich"]["FINISHED"] == 0) wait 0.05;
            break;

        //General split
        case "End":
            level waittill("end_game");
            break;  
    }

    return gettime(); 
}

upgrade_dvars()
{
    foreach(upgrade in level.pers_upgrades)
    {
        foreach(stat_name in upgrade.stat_names)
            level.eet_upgrades[level.eet_upgrades.size] = stat_name;
    }
  
    create_bool_dvar("full_bank", 1);
    create_bool_dvar("pers_insta_kill", !is_map("zm_transit"));
    
    foreach(pers_perk in level.eet_upgrades)
        create_bool_dvar(pers_perk, 1);
}

upgrades_bank()
{
    foreach(upgrade in level.pers_upgrades)
    {
        for(i = 0; i < upgrade.stat_names.size; i++)
        {
            val = (getdvarint(upgrade.stat_names[i]) > 0) * upgrade.stat_desired_values[i];
            self maps\mp\zombies\_zm_stats::set_client_stat(upgrade.stat_names[i], val);
        }
    }

	if(getdvarint("full_bank"))
	{
		self maps\mp\zombies\_zm_stats::set_map_stat("depositBox", 250, level.banking_map);
		self.account_value = 250;
	}
}

game_time_string(duration)
{
        total_sec = int(duration / 1000);
        total_min = int(total_sec / 60);
        remaining_ms = (duration % 1000) / 10;
		remaining_sec = total_sec % 60;
        time_string = ""; 

        if(total_min > 9)       { time_string += total_min + ":"; }
        else                    { time_string += "0" + total_min + ":"; }
        if(remaining_sec > 9)   { time_string += remaining_sec + "."; }
        else                    { time_string += "0" + remaining_sec + "."; }
        if(remaining_ms > 9)    { time_string += remaining_ms; }
        else                    { time_string += "0" + remaining_ms; } 

        return time_string;
}

upgrades_active()
{
    return maps\mp\zombies\_zm_pers_upgrades::is_pers_system_active();
}

create_bool_dvar( dvar, start_val )
{
    if(getdvar(dvar) == "") setdvar(dvar, start_val);
}

is_map(map)
{
    if(!(map == "zm_transit")) return level.script == map;
    return level.script == map && level.scr_zm_ui_gametype_group == "zclassic";   
}