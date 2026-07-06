namespace NebulaShell {
    public enum LogLevel {
        DEBUG,
        INFO,
        WARNING,
        ERROR;

        public string prefix() {
            switch (this) {
                case DEBUG:   return "[DEBUG]";
                case INFO:    return "[INFO]";
                case WARNING: return "[WARN]";
                case ERROR:   return "[ERROR]";
                default:      return "[?]";
            }
        }
    }

    public class Logger : Object {
        private static LogLevel min_level = LogLevel.INFO;
        private static bool initialized = false;

        public static void init() {
            if (initialized) return;
            string? env = Environment.get_variable("NEBULA_LOG");
            if (env != null) {
                switch (env.down()) {
                    case "debug":   min_level = LogLevel.DEBUG; break;
                    case "info":    min_level = LogLevel.INFO; break;
                    case "warning":
                    case "warn":    min_level = LogLevel.WARNING; break;
                    case "error":   min_level = LogLevel.ERROR; break;
                }
            }
            initialized = true;
        }

        private static void log(LogLevel level, string msg) {
            if (!initialized) init();
            if (level < min_level) return;

            string timestamp = new DateTime.now_local().format("%H:%M:%S");
            string prefix_color = "";
            string reset_color = "\x1b[0m";

            switch (level) {
                case LogLevel.DEBUG:   prefix_color = "\x1b[36m"; break;
                case LogLevel.INFO:    prefix_color = "\x1b[32m"; break;
                case LogLevel.WARNING: prefix_color = "\x1b[33m"; break;
                case LogLevel.ERROR:   prefix_color = "\x1b[31m"; break;
            }

            stderr.printf("%s %s%s%s %s\n",
                          timestamp,
                          prefix_color, level.prefix(), reset_color,
                          msg);
        }

        public static void debug(string msg) {
            log(LogLevel.DEBUG, msg);
        }

        public static void info(string msg) {
            log(LogLevel.INFO, msg);
        }

        public static void warning(string msg) {
            log(LogLevel.WARNING, msg);
        }

        public static void error(string msg) {
            log(LogLevel.ERROR, msg);
        }
    }
}
