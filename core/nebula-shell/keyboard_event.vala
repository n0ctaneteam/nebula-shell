namespace NebulaShell {

/**
 * Event for keyboard interactions.
 *
 * KeyboardEvent carries data about a key press or release on a widget.
 * It includes the key value, raw keycode, and modifier state.
 *
 * KeyboardEvent is emitted by widgets when the user presses or
 * releases a key while the widget has focus.
 *
 * Example:
 *   widget.event_received.connect ((event) => {
 *       if (event is KeyboardEvent) {
 *           var key = (KeyboardEvent) event;
 *           if (key.pressed && key.keyval == 0xff1b) {
 *               key.stop_propagation ();
 *           }
 *       }
 *   });
 */
public class KeyboardEvent : Event {

    private uint _keyval;
    private uint _keycode;
    private ModifierState _modifiers;
    private bool _pressed;

    /**
     * The key value (Unicode character or GDK_KEY_* constant).
     */
    public uint keyval {
        get { return _keyval; }
    }

    /**
     * The raw hardware keycode.
     */
    public uint keycode {
        get { return _keycode; }
    }

    /**
     * Modifier keys held during the event.
     */
    public ModifierState modifiers {
        get { return _modifiers; }
    }

    /**
     * Whether the key was pressed (true) or released (false).
     */
    public bool pressed {
        get { return _pressed; }
    }

    /**
     * Create a new keyboard event.
     *
     * @param source the widget that received the key event
     * @param keyval the key value
     * @param keycode the raw keycode
     * @param modifiers modifier keys held
     * @param pressed whether the key was pressed or released
     */
    public KeyboardEvent (Widget source, uint keyval, uint keycode,
                          ModifierState modifiers, bool pressed) {
        base (EventType.KEYBOARD, source);
        _keyval = keyval;
        _keycode = keycode;
        _modifiers = modifiers;
        _pressed = pressed;
    }

    /**
     * Check if a specific modifier is active.
     *
     * @param modifier the modifier to check
     * @return true if the modifier is active
     */
    public bool has_modifier (ModifierState modifier) {
        return (_modifiers & modifier) != 0;
    }

    /**
     * Check if Ctrl is held.
     */
    public bool ctrl {
        get { return has_modifier (ModifierState.CTRL); }
    }

    /**
     * Check if Shift is held.
     */
    public bool shift {
        get { return has_modifier (ModifierState.SHIFT); }
    }

    /**
     * Check if Alt is held.
     */
    public bool alt {
        get { return has_modifier (ModifierState.ALT); }
    }

    /**
     * Check if Super is held.
     */
    public bool super_key {
        get { return has_modifier (ModifierState.SUPER); }
    }

}

}