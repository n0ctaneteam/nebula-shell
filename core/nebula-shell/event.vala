namespace NebulaShell {

/**
 * Enumeration of event types.
 *
 * Used for event filtering and identification.
 */
public enum EventType {
    CLICK,
    HOVER,
    KEYBOARD,
    SCROLL,
    DRAG,
    FOCUS
}

/**
 * Modifier key state for input events.
 *
 * Represents which modifier keys are held during an interaction.
 * Values can be combined with bitwise OR.
 */
[Flags]
public enum ModifierState {
    NONE    = 0,
    SHIFT   = 1 << 0,
    CTRL    = 1 << 1,
    ALT     = 1 << 2,
    SUPER   = 1 << 3
}

/**
 * Button identifier for click events.
 */
public enum MouseButton {
    NONE    = 0,
    LEFT    = 1,
    MIDDLE  = 2,
    RIGHT   = 3
}

/**
 * Scroll direction for scroll events.
 */
public enum ScrollDirection {
    NONE,
    UP,
    DOWN,
    LEFT,
    RIGHT,
    SMOOTH
}

/**
 * Base class for all user interaction events.
 *
 * Event provides a common abstraction for user input events
 * in NebulaShell. Each event type carries specific data about
 * the interaction (position, key, state, etc.).
 *
 * Events are emitted by widgets when user interactions occur.
 * Widgets should never emit events every frame - only on actual
 * user interactions.
 *
 * Properties describe event state.
 * Methods perform actions on the event.
 *
 * Example:
 *   widget.event_received.connect ((event) => {
 *       if (event is ClickEvent) {
 *           var click = (ClickEvent) event;
 *           print ("Click at: " + click.x.to_string () + ", " + click.y.to_string () + "\n");
 *       }
 *   });
 */
public class Event : GLib.Object {

    private EventType _event_type;
    private int64 _timestamp;
    private Widget _source;

    /**
     * The type of this event.
     */
    public EventType event_type {
        get { return _event_type; }
    }

    /**
     * The timestamp when the event occurred.
     *
     * Monotonic time in milliseconds since framework start.
     */
    public int64 timestamp {
        get { return _timestamp; }
    }

    /**
     * The source widget that emitted this event.
     */
    public Widget source {
        get { return _source; }
    }

    /**
     * Whether this event has been handled.
     *
     * When true, the event will not propagate to parent widgets.
     * Handlers can set this to stop propagation.
     */
    public bool handled { get; set; default = false; }

    /**
     * Create a new event.
     *
     * @param event_type the type of event
     * @param source the widget that emitted the event
     */
    public Event (EventType event_type, Widget source) {
        _event_type = event_type;
        _source = source;
        _timestamp = GLib.get_monotonic_time () / 1000;
    }

    /**
     * Stop event propagation to parent widgets.
     *
     * Sets the handled flag to true.
     */
    public void stop_propagation () {
        handled = true;
    }

}

}