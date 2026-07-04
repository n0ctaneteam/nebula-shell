using NebulaShell;

public void test_logger_singleton () {
    var logger1 = Logger.get_default ();
    var logger2 = Logger.get_default ();
    assert (logger1 == logger2);
}

public void test_logger_min_level () {
    var logger = Logger.get_default ();
    logger.min_level = LogLevel.WARNING;
    assert (logger.min_level == LogLevel.WARNING);
}

public void test_logger_debug_mode () {
    var logger = Logger.get_default ();
    logger.debug_mode = true;
    assert (logger.debug_mode);
    assert (logger.min_level == LogLevel.TRACE);

    logger.debug_mode = false;
    assert (!logger.debug_mode);
    assert (logger.min_level == LogLevel.INFO);
}

public void test_logger_color_enabled () {
    var logger = Logger.get_default ();
    logger.color_enabled = false;
    assert (!logger.color_enabled);
}

public void test_logger_log_level_to_string () {
    assert (LogLevel.TRACE.to_string () == "TRACE");
    assert (LogLevel.DEBUG.to_string () == "DEBUG");
    assert (LogLevel.INFO.to_string () == "INFO");
    assert (LogLevel.WARNING.to_string () == "WARNING");
    assert (LogLevel.ERROR.to_string () == "ERROR");
    assert (LogLevel.FATAL.to_string () == "FATAL");
}

public int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/logger/singleton", test_logger_singleton);
    Test.add_func ("/logger/min_level", test_logger_min_level);
    Test.add_func ("/logger/debug_mode", test_logger_debug_mode);
    Test.add_func ("/logger/color_enabled", test_logger_color_enabled);
    Test.add_func ("/logger/log_level_to_string", test_logger_log_level_to_string);

    return Test.run ();
}