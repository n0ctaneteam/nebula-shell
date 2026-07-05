namespace NebulaShell {

/**
 * Interactive theme selector CLI command.
 *
 * Provides an interactive terminal UI for selecting a CSS theme.
 * Lists available themes from ~/.config/nebula-shell/themes/ and
 * applies the selected theme by updating shell.py.
 *
 * Usage:
 *   nebula-shell theme
 *   nebula-shell theme list
 *   nebula-shell theme set <name>
 *
 * Example:
 *   $ nebula-shell theme
 *   ? Select a theme: (Use arrow keys)
 *   > n0ctos
 *     dracula
 *     gruvbox
 *     catppuccin
 *     Tokyo Night
 */
public class CliTheme : GLib.Object {

    private string _themes_dir;

    public CliTheme () {
        string home = GLib.Environment.get_variable ("HOME") ?? "";
        _themes_dir = GLib.Path.build_filename (home, ".config", "nebula-shell", "themes");
    }

    public int run (string[] args) {
        if (args.length > 0) {
            switch (args[0]) {
                case "list":
                    return list_themes ();
                case "set":
                    if (args.length < 2) {
                        GLib.stderr.printf ("Usage: nebula-shell theme set <name>\n");
                        return 1;
                    }
                    return set_theme (args[1]);
                case "--help":
                case "-h":
                    print_help ();
                    return 0;
            }
        }
        return interactive_select ();
    }

    private void print_help () {
        print ("Usage: nebula-shell theme [command]\n");
        print ("\n");
        print ("Commands:\n");
        print ("  (none)      Interactive theme selector\n");
        print ("  list        List available themes\n");
        print ("  set <name>  Set the active theme\n");
        print ("\n");
        print ("Options:\n");
        print ("  --help, -h  Show this help message\n");
        print ("\n");
        print ("Themes are stored in ~/.config/nebula-shell/themes/\n");
    }

    private string[] discover_themes () {
        string[] themes = {};
        if (!GLib.FileUtils.test (_themes_dir, GLib.FileTest.IS_DIR))
            return themes;

        try {
            var dir = GLib.Dir.open (_themes_dir);
            string? name;
            while ((name = dir.read_name ()) != null) {
                if (name.has_suffix (".css")) {
                    themes += name.substring (0, name.length - 4);
                }
            }
        } catch (GLib.Error e) {
            GLib.stderr.printf ("Error: %s\n", e.message);
        }

        // Sort
        string[] sorted = {};
        for (int i = 0; i < themes.length; i++) {
            sorted += themes[i];
        }
        for (int i = 0; i < sorted.length - 1; i++) {
            for (int j = i + 1; j < sorted.length; j++) {
                if (strcmp (sorted[i], sorted[j]) > 0) {
                    string tmp = sorted[i];
                    sorted[i] = sorted[j];
                    sorted[j] = tmp;
                }
            }
        }
        return sorted;
    }

    private int interactive_select () {
        string[] themes = discover_themes ();
        if (themes.length == 0) {
            print ("No themes found.\n");
            print ("Create a theme in: %s\n", _themes_dir);
            return 1;
        }

        // Find current theme
        string current = get_current_theme_name ();
        int selected = 0;
        for (int i = 0; i < themes.length; i++) {
            if (themes[i] == current) {
                selected = i;
                break;
            }
        }

        print ("? Select a theme:\n");

        // Display menu
        display_menu (themes, selected);

        var input_channel = new GLib.IOChannel.unix_new (0);

        while (true) {
            char[] buf = new char[1];
            size_t bytes_read;
            try {
                var status = input_channel.read_chars (buf, out bytes_read);
                if (status == GLib.IOStatus.NORMAL && bytes_read > 0) {
                    if (buf[0] == '\x1b') {
                        GLib.Thread.usleep (20000);
                        char[] seq = new char[2];
                        size_t br1, br2;
                        input_channel.read_chars (seq, out br1);
                        if (br1 >= 2 && seq[0] == '[') {
                            if (seq[1] == 'A') {
                                if (selected > 0) {
                                    selected--;
                                    stdout.printf ("\x1b[%dA", themes.length);
                                    display_menu (themes, selected);
                                }
                            } else if (seq[1] == 'B') {
                                if (selected < themes.length - 1) {
                                    selected++;
                                    stdout.printf ("\x1b[%dA", themes.length);
                                    display_menu (themes, selected);
                                }
                            }
                        }
                    } else if (buf[0] == '\n' || buf[0] == '\r') {
                        stdout.printf ("\x1b[%dB", themes.length - selected);
                        print ("\nSelected: %s\n", themes[selected]);
                        return set_theme (themes[selected]);
                    } else if (buf[0] == 'q' || buf[0] == '\x03') {
                        stdout.printf ("\x1b[%dB", themes.length - selected);
                        print ("\nCancelled.\n");
                        return 0;
                    }
                }
                GLib.Thread.usleep (10000);
            } catch (GLib.Error e) {
                GLib.stderr.printf ("Input error: %s\n", e.message);
                return 1;
            }
        }
    }

    private void display_menu (string[] themes, int selected) {
        for (int i = 0; i < themes.length; i++) {
            if (i == selected) {
                stdout.printf ("  \x1b[1m> %s\x1b[0m\n", themes[i]);
            } else {
                stdout.printf ("    %s\n", themes[i]);
            }
        }
    }

    private int list_themes () {
        string[] themes = discover_themes ();
        if (themes.length == 0) {
            print ("No themes found.\n");
            return 0;
        }

        string current = get_current_theme_name ();
        print ("Available themes:\n");
        for (int i = 0; i < themes.length; i++) {
            if (themes[i] == current) {
                print ("  * %s (active)\n", themes[i]);
            } else {
                print ("    %s\n", themes[i]);
            }
        }
        return 0;
    }

    private int set_theme (string name) {
        string theme_path = GLib.Path.build_filename (_themes_dir, name + ".css");
        if (!GLib.FileUtils.test (theme_path, GLib.FileTest.EXISTS)) {
            GLib.stderr.printf ("Theme '%s' not found: %s\n", name, theme_path);
            return 1;
        }

        // Find and update shell.py
        string shell_py_path = find_shell_py ();
        if (shell_py_path == null) {
            GLib.stderr.printf ("shell.py not found. Run this from a NebulaShell project.\n");
            return 1;
        }

        if (!update_shell_py_theme (shell_py_path, name)) {
            GLib.stderr.printf ("Failed to update shell.py\n");
            return 1;
        }

        print ("Theme set to: %s\n", name);
        print ("Shell will reload with the new theme.\n");
        return 0;
    }

    private string? find_shell_py () {
        if (GLib.FileUtils.test ("shell.py", GLib.FileTest.EXISTS)) {
            return "shell.py";
        }
        return null;
    }

    private string get_current_theme_name () {
        string? shell_py = find_shell_py ();
        if (shell_py == null)
            return "";

        try {
            string content;
            GLib.FileUtils.get_contents (shell_py, out content);

            string[] lines = content.split ("\n");
            foreach (string line in lines) {
                string trimmed = line.strip ();
                if (trimmed.has_prefix ("theme")) {
                    int eq_pos = index_of_char (trimmed, '=');
                    if (eq_pos > 0) {
                        string value = trimmed.substring (eq_pos + 1).strip ();
                        if (value.has_prefix ("\"")) {
                            int end = index_of_char (value.substring (1), '"');
                            if (end > 0) {
                                return value.substring (1, end);
                            }
                        } else if (value.has_prefix ("'")) {
                            int end = index_of_char (value.substring (1), '\'');
                            if (end > 0) {
                                return value.substring (1, end);
                            }
                        }
                    }
                }
            }
        } catch (GLib.Error e) {
            // Ignore
        }
        return "";
    }

    private int index_of_char (string str, char c) {
        for (int i = 0; i < str.length; i++) {
            if (str[i] == c)
                return i;
        }
        return -1;
    }

    private bool update_shell_py_theme (string path, string name) {
        try {
            string content;
            GLib.FileUtils.get_contents (path, out content);

            string[] lines = content.split ("\n");
            bool found = false;
            string result = "";

            foreach (string line in lines) {
                string trimmed = line.strip ();
                if (trimmed.has_prefix ("theme")) {
                    int eq_pos = index_of_char (trimmed, '=');
                    if (eq_pos > 0) {
                        string prefix = line.substring (0, line.index_of ("theme"));
                        result += prefix + "theme = \"" + name + "\"\n";
                        found = true;
                        continue;
                    }
                }
                result += line + "\n";
            }

            if (!found) {
                result = insert_theme_variable (result, name);
            }

            GLib.FileUtils.set_contents (path, result);
            return true;
        } catch (GLib.Error e) {
            GLib.stderr.printf ("Error: %s\n", e.message);
            return false;
        }
    }

    private string insert_theme_variable (string content, string name) {
        string[] lines = content.split ("\n");
        string result = "";
        bool inserted = false;

        for (int i = 0; i < lines.length; i++) {
            result += lines[i] + "\n";
            if (!inserted && lines[i].has_prefix ("\"\"\"")) {
                int count = 0;
                for (int j = 0; j < lines[i].length; j++) {
                    if (lines[i][j] == '"') count++;
                }
                if (count >= 6 || (count >= 3 && i > 0)) {
                    inserted = true;
                    result += "\ntheme = \"" + name + "\"\n";
                }
            }
        }

        if (!inserted) {
            result = "theme = \"" + name + "\"\n\n" + content;
        }

        return result;
    }

}

}
