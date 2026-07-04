namespace NebulaShell {

/**
 * Event for hover interactions.
 *
 * HoverEvent carries data about the pointer entering or leaving
 * a widget's bounds. It includes the current pointer coordinates.
 *
 * HoverEvent is emitted by widgets when the pointer enters or
 * leaves their bounds.
 *
 * Example:
 *   widget.event_received.connect ((event) => {
 *       if (event is HoverEvent) {
 *           var hover = (HoverEvent) event;
 *           if (hover.entering) {
 *               print ("Pointer entered at: " + hover.x.to_string () + ", " + hover.y.to_string () + "\n");
 *           }
 *       }
 *   });
 */
public class HoverEvent : Event {

    private double _x;
    private double _y;
    private bool _entering;

    /**
     * The x coordinate of the pointer.
     */
    public double x {
        get { return _x; }
    }

    /**
     * The y coordinate of the pointer.
     */
    public double y {
        get { return _y; }
    }

    /**
     * Whether the pointer entered (true) or left (false) the widget.
     */
    public bool entering {
        get { return _entering; }
    }

    /**
     * Create a new hover event.
     *
     * @param source the widget that detected the hover
     * @param x the x coordinate of the pointer
     * @param y the y coordinate of the pointer
     * @param entering whether the pointer is entering or leaving
     */
    public HoverEvent (Widget source, double x, double y, bool entering) {
        base (EventType.HOVER, source);
        _x = x;
        _y = y;
        _entering = entering;
    }

}

}