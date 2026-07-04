namespace NebulaShell {

/**
 * Defines keyboard interaction modes for layer shell surfaces.
 *
 * Keyboard mode determines how a window handles keyboard input
 * and focus.
 *
 * Example:
 *   popup.keyboard_mode = KeyboardMode.ON_DEMAND;
 */
public enum KeyboardMode {

    /**
     * No keyboard interaction. Window does not receive keyboard focus.
     * Use for panels and static widgets that do not need input.
     */
    NONE = 0,

    /**
     * Exclusive keyboard mode. When focused, all keyboard input
     * is directed to this window. Other surfaces cannot receive
     * keyboard events.
     * Use for lock screens and modal dialogs.
     */
    EXCLUSIVE = 1,

    /**
     * On-demand keyboard mode. Window can receive keyboard focus
     * when explicitly requested, but does not block other surfaces.
     * Use for launchers, search bars, and popups.
     */
    ON_DEMAND = 2;

}

}
