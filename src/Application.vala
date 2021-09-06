/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Marcelo Vilas Boas Correa Filho <marcelovbcfilho@gmail.com>
 */

public class Dockerly.Application : Gtk.Application {
    public Application () {
        Object (
            application_id: "com.github.marcelovbcfilho.dockerly",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        // this command convert the docker ps into a json array of container name and id
        string docker_ps = "flatpak-spawn --host docker ps -a --format '{{json .}}'";
        string docker_ps_stdout = "";
        string docker_ps_stderr = "";
        int docker_ps_status = 0;
        GLib.List<Dockerly.ContainerDTO> containers = new GLib.List<Dockerly.ContainerDTO>();

        try {
            GLib.Process.spawn_command_line_sync (docker_ps, 
                out docker_ps_stdout, 
                out docker_ps_stderr, 
                out docker_ps_status);
            
            string containers_string = "";
            string[] docker_ps_stdout_splited = docker_ps_stdout.split ("\n");

            for (int i = 0; i < docker_ps_stdout_splited.length; i++) {
                containers_string += docker_ps_stdout_splited[i] + ",";
            }

            containers_string = containers_string.substring (0, containers_string.length - 2);

            containers_string = "[" + containers_string + "]";


            Json.Parser parser = new Json.Parser ();
            try {
                print("Docker stdout: %s", containers_string);
                parser.load_from_data (containers_string);

                Json.Array containers_json_array = parser.get_root ().get_array ();
                foreach (Json.Node container_json_node in containers_json_array.get_elements ()) {
                    containers.append (new Dockerly.ContainerDTO (container_json_node.get_object ()));
                }
            } catch (GLib.Error e) {
                printerr ("Error formatting json: %s", e.message);
            }
        } catch (SpawnError e) {
            printerr ("%s", e.message);
        }

        var quit_action = new SimpleAction ("quit", null);

        add_action (quit_action);
        set_accels_for_action ("app.quit",  {"<Control>q"});

        var main_window = new Gtk.ApplicationWindow (this) {
            default_height = 300,
            default_width = 300,
            title = _("First gtk app")
        };

        var grid = new Gtk.Grid () {
            column_spacing = 6,
            row_spacing = 6
        };
    
        var headerbar = new Gtk.HeaderBar () {
            has_subtitle = false,
            show_close_button = true
        };

        var button = new Gtk.Button.from_icon_name ("process-stop", Gtk.IconSize.LARGE_TOOLBAR) {
            action_name = "app.quit",
            tooltip_markup = Granite.markup_accel_tooltip (
                get_accels_for_action ("app.quit"),
                "Quit"
            )
        };
        
        headerbar.add (button);

        // adding all containers to screen
        for (int i = 0; i < containers.length (); i++) {
            grid.attach (new Gtk.Label(containers.nth_data (i).id), 0, i + 3);
            grid.attach (new Gtk.Label(containers.nth_data (i).names), 1, i + 3);
        }

        main_window.add (grid);
        main_window.set_titlebar (headerbar);

        // Dock badge
        Granite.Services.Application.set_badge_visible.begin (true);
        Granite.Services.Application.set_badge.begin (100);

        // Charging bar
        Granite.Services.Application.set_progress_visible.begin (true);
        Granite.Services.Application.set_progress.begin (0.2f);

        main_window.show_all ();

        quit_action.activate.connect (() => {
            main_window.destroy ();
        });
    }

    public static int main (string[] args) {
        return new Dockerly.Application ().run (args);
    }
}
