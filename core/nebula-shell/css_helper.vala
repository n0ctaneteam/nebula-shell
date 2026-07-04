namespace NebulaShell {

/**
 * Helper class for parsing and applying CSS styles.
 *
 * CssHelper provides utilities for working with GTK CSS:
 * - Parsing inline CSS strings
 * - Generating CSS from style properties
 * - Validating CSS syntax
 * - Building CSS selectors
 * - Managing CSS provider operations
 *
 * CssHelper is a static utility class and should not be instantiated.
 *
 * GTK CSS is the official theme language. CssHelper assists with
 * CSS manipulation without exposing GTK implementation details.
 *
 * Example:
 *   var css = CssHelper.build_selector("button", {"primary", "large"});
 *   // Returns: button.primary.large
 *
 *   var inline = CssHelper.generate_inline_css({"color": "red", "font-size": "14px"});
 *   // Returns: color: red; font-size: 14px;
 */
public class CssHelper {

    /**
     * Parse an inline CSS string into a map of property-value pairs.
     *
     * The input format is "property: value; property: value;".
     * Whitespace around properties and values is trimmed.
     *
     * @param css the inline CSS string
     * @return a map of property names to values
     */
    public static Gee.Map<string, string> parse_inline_css (string css) {
        var result = new Gee.HashMap<string, string> ();

        if (css.length == 0)
            return result;

        string[] declarations = css.split (";");
        foreach (string decl in declarations) {
            string trimmed = decl.strip ();
            if (trimmed.length == 0)
                continue;

            int colon_pos = trimmed.index_of (":");
            if (colon_pos < 0)
                continue;

            string property = trimmed.substring (0, colon_pos).strip ();
            string value = trimmed.substring (colon_pos + 1).strip ();

            if (property.length > 0 && value.length > 0) {
                result.set (property, value);
            }
        }

        return result;
    }

    /**
     * Generate an inline CSS string from a map of property-value pairs.
     *
     * @param properties the CSS properties
     * @return the formatted CSS string
     */
    public static string generate_inline_css (Gee.Map<string, string> properties) {
        var sb = new GLib.StringBuilder ();

        foreach (var entry in properties.entries) {
            sb.append (entry.key);
            sb.append (": ");
            sb.append (entry.value);
            sb.append ("; ");
        }

        return sb.str.strip ();
    }

    /**
     * Build a CSS selector from a base name and class names.
     *
     * @param base_name the element name (e.g., "button")
     * @param classes optional class names to append
     * @return the formatted CSS selector
     */
    public static string build_selector (string base_name, string[]? classes = null) {
        var sb = new GLib.StringBuilder ();
        sb.append (base_name);

        if (classes != null) {
            foreach (string cls in classes) {
                if (cls.length > 0) {
                    sb.append (".");
                    sb.append (cls);
                }
            }
        }

        return sb.str;
    }

    /**
     * Build a CSS selector with an ID.
     *
     * @param base_name the element name
     * @param id the element ID
     * @param classes optional class names
     * @return the formatted CSS selector
     */
    public static string build_id_selector (string base_name, string id, string[]? classes = null) {
        var sb = new GLib.StringBuilder ();
        sb.append (base_name);

        if (id.length > 0) {
            sb.append ("#");
            sb.append (id);
        }

        if (classes != null) {
            foreach (string cls in classes) {
                if (cls.length > 0) {
                    sb.append (".");
                    sb.append (cls);
                }
            }
        }

        return sb.str;
    }

    /**
     * Build a CSS rule block.
     *
     * @param selector the CSS selector
     * @param properties the CSS properties
     * @return the formatted CSS rule
     */
    public static string build_rule (string selector, Gee.Map<string, string> properties) {
        if (properties.size == 0)
            return "";

        var sb = new GLib.StringBuilder ();
        sb.append (selector);
        sb.append (" {\n");

        foreach (var entry in properties.entries) {
            sb.append ("  ");
            sb.append (entry.key);
            sb.append (": ");
            sb.append (entry.value);
            sb.append (";\n");
        }

        sb.append ("}\n");
        return sb.str;
    }

    /**
     * Merge two inline CSS strings.
     *
     * Properties from the second string override those from the first.
     *
     * @param base_css the base CSS
     * @param override_css the overriding CSS
     * @return the merged CSS
     */
    public static string merge_inline_css (string base_css, string override_css) {
        var base_props = parse_inline_css (base_css);
        var override_props = parse_inline_css (override_css);

        foreach (var entry in override_props.entries) {
            base_props.set (entry.key, entry.value);
        }

        return generate_inline_css (base_props);
    }

    /**
     * Validate a CSS class name.
     *
     * CSS class names must start with a letter or underscore,
     * and contain only letters, digits, hyphens, and underscores.
     *
     * @param class_name the class name to validate
     * @return true if the class name is valid
     */
    public static bool validate_class_name (string class_name) {
        if (class_name.length == 0)
            return false;

        unichar first = class_name.get_char (0);
        if (!first.isalpha () && first != '_')
            return false;

        for (int i = 0; i < class_name.length; i++) {
            unichar c = class_name.get_char (i);
            if (!c.isalnum () && c != '-' && c != '_')
                return false;
        }

        return true;
    }

    /**
     * Validate a CSS ID.
     *
     * CSS IDs follow the same rules as class names.
     *
     * @param id the ID to validate
     * @return true if the ID is valid
     */
    public static bool validate_id (string id) {
        return validate_class_name (id);
    }

    /**
     * Escape a string for use in CSS.
     *
     * @param str the string to escape
     * @return the escaped string
     */
    public static string escape_css (string str) {
        var sb = new GLib.StringBuilder ();

        for (int i = 0; i < str.length; i++) {
            unichar c = str.get_char (i);

            if (c == '\\' || c == '"' || c == '\'' || c == '\n' || c == '\r') {
                sb.append_c ('\\');
                sb.append_unichar (c);
            } else {
                sb.append_unichar (c);
            }
        }

        return sb.str;
    }

    /**
     * Generate a complete CSS stylesheet from rules.
     *
     * @param rules the CSS rules
     * @return the formatted stylesheet
     */
    public static string generate_stylesheet (Gee.Map<string, Gee.Map<string, string>> rules) {
        var sb = new GLib.StringBuilder ();

        foreach (var entry in rules.entries) {
            string rule = build_rule (entry.key, entry.value);
            if (rule.length > 0) {
                sb.append (rule);
                sb.append ("\n");
            }
        }

        return sb.str;
    }

    /**
     * Load CSS into a GTK CSS provider.
     *
     * @param provider the CSS provider
     * @param css the CSS content
     * @return true if loaded successfully
     */
    public static bool load_css (Gtk.CssProvider provider, string css) {
        try {
            unowned uint8[] css_bytes = css.make_valid ().data;
            provider.load_from_data (css_bytes);
            return true;
        } catch (GLib.Error e) {
            Logger.error ("CssHelper: failed to load CSS: " + e.message);
            return false;
        }
    }

    /**
     * Apply a CSS provider to the default display.
     *
     * @param provider the CSS provider
     * @param priority the priority (higher values override lower)
     */
    public static void apply_provider (Gtk.CssProvider provider, uint priority = Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION) {
        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (),
            provider,
            priority
        );
    }

    /**
     * Remove a CSS provider from the default display.
     *
     * @param provider the CSS provider to remove
     */
    public static void remove_provider (Gtk.CssProvider provider) {
        Gtk.StyleContext.remove_provider_for_display (
            Gdk.Display.get_default (),
            provider
        );
    }

}

}
