namespace NebulaShell {

/**
 * Event for focus changes.
 *
 * FocusEvent carries data about a widget gaining or losing focus.
 * It indicates whether the widget is gaining (entering) or losing
 * (leaving) keyboard focus.
 *
 * FocusEvent is emitted by widgets when they gain or lose focus.
 *
 * Example:
 *   widget.event_received.connect ((event) => {
 *       if (event is FocusEvent) {
 *           var focus = (FocusEvent) event;
 *           if (focus.focusing) {
 *               print ("Widget gained focus\n");
 *           } else {
 *               print ("Widget lost focus\n");
 *           }
 *       }
 *   });
 */
public class FocusEvent : Event {

    private bool _focusing;

    /**
     * Whether the widget is gaining focus (true) or losing focus (false).
     */
    public bool focusing {
        get { return _focusing; }
    }

    /**
     * Create a new focus event.
     *
     * @param source the widget that gained or lost focus
     * @param focusing whether the widget is gaining or losing focus
     */
    public FocusEvent (Widget source, bool focusing) {
        base (EventType.FOCUS, source);
        _focusing = focusing;
    }

}

}