namespace NebulaShell {

/**
 * A container that displays one child at a time.
 *
 * Stack overlaps all its children on top of each other.
 * Only the active child is visible. Use transition_type
 * to control how switches between children are animated.
 *
 * Children are identified by name or index.
 * The active child can be set by name or position.
 *
 * Example:
 *   var stack = new Stack ();
 *   stack.append (new Label ("Page 1"));
 *   stack.append (new Label ("Page 2"));
 *   stack.visible_child_name = "Page 1";
 *
 * Example:
 *   var stack = new Stack ();
 *   stack.append (page1);
 *   stack.append (page2);
 *   stack.visible_child_index = 1;
 */
public class Stack : NebulaShell.Container {

    private int _visible_child_index = 0;
    private string _visible_child_name = "";
    private bool _animate_transitions = true;

    /**
     * Emitted when the visible child changes.
     *
     * @param index the index of the new visible child
     */
    public signal void visible_child_changed (int index);

    /**
     * Index of the currently visible child.
     *
     * Changing this property switches the visible child.
     * Out-of-range values are ignored.
     * Default is 0.
     */
    public int visible_child_index {
        get { return _visible_child_index; }
        set {
            if (value < 0 || value >= child_count) return;
            if (_visible_child_index == value) return;
            _visible_child_index = value;
            visible_child_changed (value);
        }
    }

    /**
     * Name of the currently visible child.
     *
     * Changing this property switches to the child with
     * the matching name. Empty string means no match.
     * Default is empty.
     */
    public string visible_child_name {
        get { return _visible_child_name; }
        set {
            _visible_child_name = value;
            var children = get_children ();
            for (int i = 0; i < children.length; i++) {
                if (children[i].name == value) {
                    visible_child_index = i;
                    return;
                }
            }
        }
    }

    /**
     * Whether transitions between children are animated.
     *
     * When true, switching children uses a visual transition.
     * Default is true.
     */
    public bool animate_transitions {
        get { return _animate_transitions; }
        set { _animate_transitions = value; }
    }

    /**
     * Get the currently visible child widget.
     *
     * @return the visible child, or null if empty
     */
    public Widget? get_visible_child () {
        return get_child_at (_visible_child_index);
    }

    /**
     * Set the visible child by widget reference.
     *
     * @param child the widget to make visible
     */
    public void set_visible_child (Widget child) {
        int idx = index_of (child);
        if (idx >= 0) {
            visible_child_index = idx;
        }
    }

    /**
     * Add a named child to the stack.
     *
     * Convenience method that sets the child name
     * before appending.
     *
     * @param name the name to assign to the child
     * @param child the widget to add
     */
    public void add_named (string name, Widget child) {
        child.name = name;
        append (child);
    }

    /**
     * Create a new stack.
     */
    public Stack () {
        base ();
    }

    /**
     * Create a new stack with a name.
     *
     * @param name human-readable identifier
     */
    public Stack.with_name (string name) {
        base.with_name (name);
    }

}

}
