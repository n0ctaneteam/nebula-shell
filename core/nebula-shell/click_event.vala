namespace NebulaShell {

/**
 * Event for click interactions.
 *
 * ClickEvent carries data about a mouse button press on a widget.
 * It includes the coordinates of the click and which button was pressed.
 *
 * ClickEvent is emitted by widgets when the user clicks on them.
 *
 * Example:
 *   widget.event_received.connect ((event) => {
 *       if (event is ClickEvent) {
 *           var click = (ClickEvent) event;
 *           print ("Clicked at: " + click.x.to_string () + ", " + click.y.to_string () + "\n");
 *       }
 *   });
 */
public class ClickEvent : Event {

    private double _x;
    private double _y;
    private MouseButton _button;

    /**
     * The x coordinate of the click relative to the widget.
     */
    public double x {
        get { return _x; }
    }

    /**
     * The y coordinate of the click relative to the widget.
     */
    public double y {
        get { return _y; }
    }

    /**
     * The mouse button that was pressed.
     */
    public MouseButton button {
        get { return _button; }
    }

    /**
     * Create a new click event.
     *
     * @param source the widget that was clicked
     * @param x the x coordinate of the click
     * @param y the y coordinate of the click
     * @param button the mouse button that was pressed
     */
    public ClickEvent (Widget source, double x, double y, MouseButton button) {
        base (EventType.CLICK, source);
        _x = x;
        _y = y;
        _button = button;
    }

}

}