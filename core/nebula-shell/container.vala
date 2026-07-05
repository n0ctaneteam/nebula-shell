namespace NebulaShell {

/**
 * Base class for widgets that contain child widgets.
 *
 * Container extends Widget to provide child management.
 * It manages the lifecycle of child widgets: append, prepend,
 * remove, and clear.
 *
 * Containers own their children. When a container is destroyed,
 * all its children are destroyed as well.
 *
 * Example:
 *   var box = new Box ();
 *   box.append (new Label ("First"));
 *   box.append (new Label ("Second"));
 *   box.remove (child);
 *   box.clear ();
 */
public class Container : NebulaShell.Widget {

    private Widget[] _children = {};

    /**
     * Emitted when a child is added.
     *
     * @param child the widget that was added
     */
    public signal void child_added (Widget child);

    /**
     * Emitted when a child is removed.
     *
     * @param child the widget that was removed
     */
    public signal void child_removed (Widget child);

    /**
     * Emitted when all children are cleared.
     */
    public signal void children_cleared ();

    /**
     * The number of children in this container.
     */
    public int child_count {
        get { return _children.length; }
    }

    /**
     * Create a new container.
     */
    public Container () {
        base ();
    }

    /**
     * Create a new container with a name.
     *
     * @param name human-readable identifier
     */
    public Container.with_name (string name) {
        base.with_name (name);
    }

    /**
     * Append a child widget to the end.
     *
     * The child is added after all existing children.
     * If the child already has a parent, it is removed first.
     *
     * @param child the widget to append
     */
    public virtual void append (Widget child) {
        if (child.parent != null) {
            var old_parent = child.parent as Container;
            if (old_parent != null) {
                old_parent.remove (child);
            }
        }

        child.parent = this;
        _children += child;
        on_child_added (child);
        child_added (child);
    }

    /**
     * Prepend a child widget to the beginning.
     *
     * The child is added before all existing children.
     * If the child already has a parent, it is removed first.
     *
     * @param child the widget to prepend
     */
    public virtual void prepend (Widget child) {
        if (child.parent != null) {
            var old_parent = child.parent as Container;
            if (old_parent != null) {
                old_parent.remove (child);
            }
        }

        child.parent = this;
        Widget[] new_children = { child };
        foreach (var c in _children) {
            new_children += c;
        }
        _children = new_children;
        on_child_added (child);
        child_added (child);
    }

    /**
     * Remove a child widget from this container.
     *
     * The child is detached and its parent is cleared.
     * Does nothing if the child is not in this container.
     *
     * @param child the widget to remove
     */
    public virtual void remove (Widget child) {
        Widget[] new_children = {};
        bool found = false;

        foreach (var c in _children) {
            if (c == child) {
                found = true;
                child.parent = null;
                on_child_removed (child);
                child_removed (child);
            } else {
                new_children += c;
            }
        }

        if (found) {
            _children = new_children;
        }
    }

    /**
     * Remove all children from this container.
     *
     * Each child's parent is cleared.
     * Emits `children_cleared` signal.
     */
    public virtual void clear () {
        foreach (var child in _children) {
            child.parent = null;
            on_child_removed (child);
        }

        _children = {};
        children_cleared ();
    }

    /**
     * Get all children in this container.
     *
     * @return array of child widgets
     */
    public Widget[] get_children () {
        return _children;
    }

    /**
     * Get a child at a specific index.
     *
     * @param index the zero-based index
     * @return the child widget, or null if out of bounds
     */
    public Widget? get_child_at (int index) {
        if (index < 0 || index >= _children.length) return null;
        return _children[index];
    }

    /**
     * Find the index of a child widget.
     *
     * @param child the widget to find
     * @return the index, or -1 if not found
     */
    public int index_of (Widget child) {
        for (int i = 0; i < _children.length; i++) {
            if (_children[i] == child) return i;
        }
        return -1;
    }

    /**
     * Destroy the container and all its children.
     *
     * Children are destroyed in reverse order.
     * Emits `destroyed` signal.
     */
    public override void destroy () {
        // Snapshot children to avoid out-of-bounds if destroy handlers modify the list
        var children_snapshot = _children;
        _children = {};
        for (int i = children_snapshot.length - 1; i >= 0; i--) {
            children_snapshot[i].destroy ();
        }
        base.destroy ();
    }

    /**
     * Called when a child is added.
     *
     * Subclasses override to perform layout updates.
     *
     * @param child the widget that was added
     */
    protected virtual void on_child_added (Widget child) {
    }

    /**
     * Called when a child is removed.
     *
     * Subclasses override to perform layout updates.
     *
     * @param child the widget that was removed
     */
    protected virtual void on_child_removed (Widget child) {
    }

}

}
