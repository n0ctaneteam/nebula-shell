namespace NebulaShell {

/**
 * Log levels for NebulaShell logging.
 *
 * Ordered from most verbose to most critical.
 */
public enum LogLevel {
    TRACE,
    DEBUG,
    INFO,
    WARNING,
    ERROR,
    FATAL;

    public string to_string () {
        switch (this) {
            case TRACE:   return "TRACE";
            case DEBUG:   return "DEBUG";
            case INFO:    return "INFO";
            case WARNING: return "WARNING";
            case ERROR:   return "ERROR";
            case FATAL:   return "FATAL";
            default:      return "UNKNOWN";
        }
    }
}

/**
 * Framework-wide logger with colored console output.
 *
 * Logger is a singleton that provides structured logging
 * for NebulaShell internals and extensions.
 *
 * Logging is for developers. Users should not see debug logs.
 * Use debug_mode to control visibility of trace and debug messages.
 *
 * Example:
 *   Logger.info("Application started");
 *   Logger.set_debug_mode(true);
 *   Logger.debug("Loading plugins");
 */
public class Logger : GLib.Object {

    private static Logger? _instance = null;

    private LogLevel _min_level;
    private bool _debug_mode;
    private bool _color_enabled;

    private const string COLOR_RESET  = "\033[0m";
    private const string COLOR_TRACE  = "\033[90m";
    private const string COLOR_DEBUG  = "\033[36m";
    private const string COLOR_INFO   = "\033[32m";
    private const string COLOR_WARN   = "\033[33m";
    private const string COLOR_ERROR  = "\033[31m";
    private const string COLOR_FATAL  = "\033[1;31m";

    /**
     * Get the default logger instance.
     *
     * @return the singleton logger
     */
    public static Logger get_default () {
        if (_instance == null)
            _instance = new Logger ();

        return _instance;
    }

    private Logger () {
        _min_level = LogLevel.INFO;
        _debug_mode = false;
        _color_enabled = true;
    }

    /**
     * Minimum log level to display.
     *
     * Messages below this level are discarded.
     */
    public LogLevel min_level {
        get { return _min_level; }
        set { _min_level = value; }
    }

    /**
     * Debug mode toggle.
     *
     * When enabled, trace and debug messages are visible.
     * When disabled, only info and above are shown.
     */
    public bool debug_mode {
        get { return _debug_mode; }
        set {
            _debug_mode = value;
            if (value)
                _min_level = LogLevel.TRACE;
            else
                _min_level = LogLevel.INFO;
        }
    }

    /**
     * Whether colored output is enabled.
     */
    public bool color_enabled {
        get { return _color_enabled; }
        set { _color_enabled = value; }
    }



    private string get_color (LogLevel level) {
        if (!_color_enabled)
            return "";

        switch (level) {
            case LogLevel.TRACE:   return COLOR_TRACE;
            case LogLevel.DEBUG:   return COLOR_DEBUG;
            case LogLevel.INFO:    return COLOR_INFO;
            case LogLevel.WARNING: return COLOR_WARN;
            case LogLevel.ERROR:   return COLOR_ERROR;
            case LogLevel.FATAL:   return COLOR_FATAL;
            default:               return "";
        }
    }

    private void log (LogLevel level, string message) {
        if (level < _min_level)
            return;

        string color = get_color (level);
        string level_str = level.to_string ();
        string reset = _color_enabled ? COLOR_RESET : "";

        GLib.stdout.printf ("%s[%s]%s %s\n", color, level_str, reset, message);
    }

    /**
     * Log a trace message.
     *
     * @param message the message to log
     */
    public static void trace (string message) {
        get_default ().log (LogLevel.TRACE, message);
    }

    /**
     * Log a debug message.
     *
     * @param message the message to log
     */
    public static void debug (string message) {
        get_default ().log (LogLevel.DEBUG, message);
    }

    /**
     * Log an info message.
     *
     * @param message the message to log
     */
    public static void info (string message) {
        get_default ().log (LogLevel.INFO, message);
    }

    /**
     * Log a warning message.
     *
     * @param message the message to log
     */
    public static void warning (string message) {
        get_default ().log (LogLevel.WARNING, message);
    }

    /**
     * Log an error message.
     *
     * @param message the message to log
     */
    public static void error (string message) {
        get_default ().log (LogLevel.ERROR, message);
    }

    /**
     * Log a fatal message.
     *
     * @param message the message to log
     */
    public static void fatal (string message) {
        get_default ().log (LogLevel.FATAL, message);
    }

}

}
