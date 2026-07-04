namespace NebulaShell {

/**
 * Format command implementation.
 *
 * Formats NebulaShell configuration files using a consistent
 * style. Supports Python config files and CSS style files.
 *
 * Usage:
 *   nebula-shell format
 *   nebula-shell format --config /path/to/config.py
 *   nebula-shell format --check
 *
 * Example:
 *   $ nebula-shell format
 *   Formatting configuration files...
 *   Formatted: config.py
 *   Formatted: style.css
 *   Done!
 */
public class CliFormat : GLib.Object {

    private string? _config_path = null;
    private bool _check = false;

    /**
     * Run the format command.
     *
     * @param args command arguments
     * @return 0 on success, non-zero on failure
     */
    public int run (string[] args) {
        var context = new GLib.OptionContext ("- format configuration files");
        var options = new GLib.OptionEntry[] {
            { "config", 'c', 0, GLib.OptionArg.STRING, ref _config_path, "Configuration file path", "PATH" },
            { "check", 'k', 0, GLib.OptionArg.NONE, ref _check, "Check formatting without modifying files", null },
            { null }
        };

        context.add_main_entries (options, null);

        try {
            context.parse (ref args);
        } catch (GLib.Error e) {
            GLib.stderr.printf ("Error: %s\n", e.message);
            return 1;
        }

        return run_format ();
    }

    /**
     * Run the formatting.
     *
     * @return 0 on success, non-zero on failure
     */
    private int run_format () {
        if (_check) {
            print ("Checking formatting...\n\n");
        } else {
            print ("Formatting configuration files...\n\n");
        }

        int files_formatted = 0;
        int files_with_errors = 0;

        // Find files to format
        string[] files = find_files_to_format ();

        foreach (string file in files) {
            if (format_file (file)) {
                files_formatted++;
            } else {
                files_with_errors++;
            }
        }

        print ("\n");

        if (files_formatted == 0 && files_with_errors == 0) {
            print ("No files to format\n");
        } else if (_check && files_formatted > 0) {
            GLib.stderr.printf ("Files need formatting\n");
            return 1;
        } else {
            print ("Formatted %d file(s)\n", files_formatted);
        }

        return 0;
    }

    /**
     * Find files to format.
     *
     * @return array of file paths
     */
    private string[] find_files_to_format () {
        string[] files = {};

        if (_config_path != null) {
            files += _config_path;
            return files;
        }

        // Search for config files in current directory
        string cwd = GLib.Path.get_dirname (GLib.Path.get_basename ("."));

        // Check for common config file names
        string[] candidates = {
            "config.py",
            "style.css",
            "theme.css"
        };

        foreach (string candidate in candidates) {
            if (GLib.FileUtils.test (candidate, GLib.FileTest.EXISTS)) {
                files += candidate;
            }
        }

        return files;
    }

    /**
     * Format a single file.
     *
     * @param file_path the file to format
     * @return true on success
     */
    private bool format_file (string file_path) {
        if (!GLib.FileUtils.test (file_path, GLib.FileTest.EXISTS)) {
            GLib.stderr.printf ("Error: File not found: %s\n", file_path);
            return false;
        }

        string? contents;
        try {
            GLib.FileUtils.get_contents (file_path, out contents);
        } catch (GLib.Error e) {
            GLib.stderr.printf ("Error reading %s: %s\n", file_path, e.message);
            return false;
        }

        if (contents == null) {
            return false;
        }

        string formatted;
        if (file_path.has_suffix (".py")) {
            formatted = format_python (contents);
        } else if (file_path.has_suffix (".css")) {
            formatted = format_css (contents);
        } else {
            Logger.debug ("Format: skipping unknown file type " + file_path);
            return true;
        }

        if (formatted == contents) {
            Logger.debug ("Format: " + file_path + " is already formatted");
            return true;
        }

        if (_check) {
            GLib.stderr.printf ("  %s needs formatting\n", file_path);
            return false;
        }

        try {
            GLib.FileUtils.set_contents (file_path, formatted);
            print ("  Formatted: %s\n", file_path);
            return true;
        } catch (GLib.Error e) {
            GLib.stderr.printf ("Error writing %s: %s\n", file_path, e.message);
            return false;
        }
    }

    /**
     * Format Python code.
     *
     * Basic formatting: normalize indentation and trailing whitespace.
     *
     * @param code the Python code to format
     * @return the formatted code
     */
    private string format_python (string code) {
        var result = new GLib.StringBuilder ();
        string[] lines = code.split ("\n");

        foreach (string line in lines) {
            // Remove trailing whitespace
            string trimmed = line.strip ();
            result.append (trimmed);
            result.append_c ('\n');
        }

        string formatted = result.str;

        // Ensure file ends with newline
        if (!formatted.has_suffix ("\n")) {
            formatted += "\n";
        }

        return formatted;
    }

    /**
     * Format CSS code.
     *
     * Basic formatting: normalize indentation and trailing whitespace.
     *
     * @param code the CSS code to format
     * @return the formatted code
     */
    private string format_css (string code) {
        var result = new GLib.StringBuilder ();
        string[] lines = code.split ("\n");

        foreach (string line in lines) {
            // Remove trailing whitespace
            string trimmed = line.strip ();
            result.append (trimmed);
            result.append_c ('\n');
        }

        string formatted = result.str;

        // Ensure file ends with newline
        if (!formatted.has_suffix ("\n")) {
            formatted += "\n";
        }

        return formatted;
    }

}

}
