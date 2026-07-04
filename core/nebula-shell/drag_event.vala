namespace NebulaShell {

/**
 * Enumeration of drag event subtypes.
 */
public enum DragEventType {
    BEGIN,
    UPDATE,
    END
}

/**
 * Event for drag interactions.
 *
 * DragEvent carries data about a drag operation on a widget.
 * It includes the current coordinates and the drag event type
 * (begin, update, or end).
 *
 * DragEvent is emitted by widgets when the user initiates,
 * moves, or ends a drag operation.
 *
 * Example:
 *   widget.event_received.connect ((event) => {
 *       if (event is DragEvent) {
 *           var drag = (DragEvent) event;
 *           switch (drag.drag_type) {
 *               case DragEventType.BEGIN:
 *                   print ("Drag started\n");
 *                   break;
 *               case DragEventType.UPDATE:
 *                   print ("Dragging to: " + drag.x.to_string () + ", " + drag.y.to_string () + "\n");
 *                   break;
 *               case DragEventType.END:
 *                   print ("Drag ended\n");
 *                   break;
 *           }
 *       }
 *   });
 */
public class DragEvent : Event {

    private DragEventType _drag_type;
    private double _x;
    private double _y;
    private double _start_x = 0;
    private double _start_y = 0;

    /**
     * The subtype of this drag event.
     */
    public DragEventType drag_type {
        get { return _drag_type; }
    }

    /**
     * The current x coordinate of the pointer.
     */
    public double x {
        get { return _x; }
    }

    /**
     * The current y coordinate of the pointer.
     */
    public double y {
        get { return _y; }
    }

    /**
     * The x coordinate where the drag started.
     *
     * Only meaningful for UPDATE and END events.
     * Defaults to 0 for BEGIN events.
     */
    public double start_x {
        get { return _start_x; }
        set { _start_x = value; }
    }

    /**
     * The y coordinate where the drag started.
     *
     * Only meaningful for UPDATE and END events.
     * Defaults to 0 for BEGIN events.
     */
    public double start_y {
        get { return _start_y; }
        set { _start_y = value; }
    }

    /**
     * Horizontal distance from the drag start point.
     */
    public double delta_x {
        get { return _x - _start_x; }
    }

    /**
     * Vertical distance from the drag start point.
     */
    public double delta_y {
        get { return _y - _start_y; }
    }

    /**
     * Create a new drag event.
     *
     * @param source the widget being dragged
     * @param drag_type the drag event subtype
     * @param x the current x coordinate
     * @param y the current y coordinate
     */
    public DragEvent (Widget source, DragEventType drag_type, double x, double y) {
        base (EventType.DRAG, source);
        _drag_type = drag_type;
        _x = x;
        _y = y;
    }

}

}