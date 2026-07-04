namespace NebulaShell {

/**
 * Defines layer shell surface layers.
 *
 * Layers determine the stacking order of windows on screen.
 * Higher layers are rendered above lower layers.
 * The layer also affects how windows interact with input.
 *
 * Example:
 *   panel.layer = Layer.TOP;
 *   notification.layer = Layer.OVERLAY;
 */
public enum Layer {

    /**
     * Background layer. Below all other surfaces.
     * Used for wallpapers and desktop backgrounds.
     */
    BACKGROUND = 0,

    /**
     * Bottom layer. Above background, below top.
     * Used for desktop widgets that sit behind panels.
     */
    BOTTOM = 1,

    /**
     * Top layer. Above bottom, below overlay.
     * Used for panels, bars, and taskbars.
     */
    TOP = 2,

    /**
     * Overlay layer. Above all other layers.
     * Used for notifications, OSD, and lock screens.
     */
    OVERLAY = 3;

}

}
