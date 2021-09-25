public class Dockerly.Widgets.SourceRow : Gtk.ListBoxRow {
    // ***********************************************************************

    public Dockerly.ContainerDTO container { get; construct; }

    // ***********************************************************************

    public SourceRow (Dockerly.ContainerDTO container) {
        Object (container: container);
    }

    construct {
        var main_grid = new Gtk.Grid () {
            valign = Gtk.Align.CENTER,
            column_spacing = 6
        };

        var display_name_label = new Gtk.Label (this.container.names) {
            halign = Gtk.Align.START,
            hexpand = false,
            margin_end = 9,
            margin_start = 9
        };

        main_grid.attach (display_name_label, 0, 0);

        add (main_grid);
    }

    // ***********************************************************************
}