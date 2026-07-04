namespace NebulaShell {

/**
 * EventHandler manages event dispatch for widgets.
 *
 * Provides a centralized system for translating input events
 * to NebulaShell signals on widgets. Each widget gets its own
 * EventHandler instance that creates NebulaShell event objects
 * and emits the appropriate signals.
 *
 * The EventHandler is internal and not exposed in the public API.
 * Widgets use it internally to set up event handling.
 */
public class EventHandler : GLib.Object {

    private Widget _widget;

    /**
     * Create a new event handler for a widget.
     *
     * @param widget the widget to handle events for
     */
    public EventHandler (Widget widget) {
        _widget = widget;
    }

    /**
     * Emit a click event on the widget.
     *
     * @param x the x coordinate of the click
     * @param y the y coordinate of the click
     * @param button the button that was pressed
     */
    public void emit_click (double x, double y, MouseButton button) {
        var event = new ClickEvent (_widget, x, y, button);
        _widget.on_click (event);
    }

    /**
     * Emit a hover enter event on the widget.
     *
     * @param x the x coordinate of the pointer
     * @param y the y coordinate of the pointer
     */
    public void emit_hover_enter (double x, double y) {
        var event = new HoverEvent (_widget, x, y, true);
        _widget.on_hover_enter (event);
    }

    /**
     * Emit a hover leave event on the widget.
     *
     * @param x the x coordinate of the pointer
     * @param y the y coordinate of the pointer
     */
    public void emit_hover_leave (double x, double y) {
        var event = new HoverEvent (_widget, x, y, false);
        _widget.on_hover_leave (event);
    }

    /**
     * Emit a keyboard event on the widget.
     *
     * @param keyval the key value
     * @param keycode the raw keycode
     * @param state modifier state
     * @param pressed whether the key was pressed or released
     */
    public void emit_keyboard (uint keyval, uint keycode, ModifierState state, bool pressed) {
        var event = new KeyboardEvent (_widget, keyval, keycode, state, pressed);
        _widget.on_keyboard (event);
    }

    /**
     * Emit a scroll event on the widget.
     *
     * @param x the x coordinate of the scroll
     * @param y the y coordinate of the scroll
     * @param delta_x the horizontal scroll delta
     * @param delta_y the vertical scroll delta
     * @param direction the scroll direction
     */
    public void emit_scroll (double x, double y, double delta_x, double delta_y, ScrollDirection direction) {
        var event = new ScrollEvent (_widget, x, y, delta_x, delta_y, direction);
        _widget.on_scroll (event);
    }

    /**
     * Emit a drag begin event on the widget.
     *
     * @param start_x the x coordinate where drag started
     * @param start_y the y coordinate where drag started
     */
    public void emit_drag_begin (double start_x, double start_y) {
        var event = new DragEvent (_widget, DragEventType.BEGIN, start_x, start_y);
        _widget.on_drag (event);
    }

    /**
     * Emit a drag update event on the widget.
     *
     * @param current_x the current x coordinate
     * @param current_y the current y coordinate
     * @param start_x the x coordinate where drag started
     * @param start_y the y coordinate where drag started
     */
    public void emit_drag_update (double current_x, double current_y, double start_x, double start_y) {
        var event = new DragEvent (_widget, DragEventType.UPDATE, current_x, current_y);
        event.start_x = start_x;
        event.start_y = start_y;
        _widget.on_drag (event);
    }

    /**
     * Emit a drag end event on the widget.
     *
     * @param end_x the x coordinate where drag ended
     * @param end_y the y coordinate where drag ended
     */
    public void emit_drag_end (double end_x, double end_y) {
        var event = new DragEvent (_widget, DragEventType.END, end_x, end_y);
        _widget.on_drag (event);
    }

    /**
     * Emit a focus in event on the widget.
     */
    public void emit_focus_in () {
        var event = new FocusEvent (_widget, true);
        _widget.on_focus (event);
    }

    /**
     * Emit a focus out event on the widget.
     */
    public void emit_focus_out () {
        var event = new FocusEvent (_widget, false);
        _widget.on_focus (event);
    }

}

}