/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Marcelo Vilas Boas Correa Filho <marcelovbcfilho@gmail.com>
 */

public class Dockerly.Application : Gtk.Application {

    GLib.List<Dockerly.ContainerDTO> containers = new GLib.List<Dockerly.ContainerDTO>();

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
                    this.containers.append (new Dockerly.ContainerDTO (container_json_node.get_object ()));
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
            default_height = 500,
            default_width = 800,
            title = _("Dockerly")
        };

        var grid = new Gtk.Grid () {
            column_spacing = 12,
            row_spacing = 12
        };
    
        var headerbar = new Gtk.HeaderBar () {
            has_subtitle = false,
            show_close_button = true
        };

        Gtk.ListBox left_list_box = new Gtk.ListBox ();

        grid.attach (left_list_box, 0, 0);

        Gtk.Grid right_grid = new Gtk.Grid () {
            column_spacing = 6
        };

        grid.attach (right_grid, 1, 0);

        // adding all containers to screen
        for (int i = 0; i < this.containers.length (); i++) {
            Dockerly.Widgets.SourceRow row = new Dockerly.Widgets.SourceRow (this.containers.nth_data (i));
            left_list_box.prepend (row);
        }

        main_window.add (grid);
        main_window.set_titlebar (headerbar);

        // Dock badge
        Granite.Services.Application.set_badge_visible.begin (true);
        Granite.Services.Application.set_badge.begin (100);

        // Charging bar
        Granite.Services.Application.set_progress_visible.begin (true);
        Granite.Services.Application.set_progress.begin (0.2f);

        left_list_box.row_selected.connect ((row) => {
            if (row != null) {
                if ( row is Dockerly.Widgets.SourceRow) {
                    var source_row = (Dockerly.Widgets.SourceRow) row;
                    print("Chegou na alteracao da right grid: %s", source_row.container.id);
                    right_grid.remove_column (0);
                    var title = new Gtk.Label ("Id do container");
                    title.show ();
                    right_grid.attach (title, 0, 0);
                    var content = new Gtk.Label (source_row.container.id);
                    content.show ();
                    right_grid.attach (content, 0, 1);
                }
            }
        });

        main_window.show_all ();

        quit_action.activate.connect (() => {
            main_window.destroy ();
        });
    }

    public static int main (string[] args) {
        return new Dockerly.Application ().run (args);
    }
}
