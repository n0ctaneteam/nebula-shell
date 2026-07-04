"""
IPC abstraction for Nebula Shell.

Ipc defines the interface for inter-process communication
independent of the underlying transport.
"""

from typing import Optional, Callable


class Ipc:
    """Transport-independent IPC abstraction.

    Ipc defines the interface for inter-process communication
    independent of the underlying transport (Unix sockets, TCP, etc.).

    Example:
        ipc = Ipc()
        ipc.register_handler("get-volume", handle_volume)
        ipc.start()
    """

    def __init__(self) -> None:
        """Create a new IPC instance."""
        self._running = False
        self._handlers: dict[str, Callable] = {}
        self._event_handlers: dict[str, Callable] = {}

    def start(self) -> None:
        """Start the IPC transport."""
        self._running = True

    def stop(self) -> None:
        """Stop the IPC transport and release resources."""
        self._running = False

    def register_handler(self, method: str, handler: Callable) -> None:
        """Register a request handler for a given method.

        Args:
            method: The method name to handle.
            handler: The handler to call.
        """
        self._handlers[method] = handler

    def unregister_handler(self, method: str) -> None:
        """Unregister a previously registered request handler.

        Args:
            method: The method name to unregister.
        """
        self._handlers.pop(method, None)

    def register_event_handler(self, event_name: str, handler: Callable) -> None:
        """Register an event handler for a given event name.

        Args:
            event_name: The event name to listen for.
            handler: The handler to call.
        """
        self._event_handlers[event_name] = handler

    def unregister_event_handler(self, event_name: str) -> None:
        """Unregister a previously registered event handler.

        Args:
            event_name: The event name to unregister.
        """
        self._event_handlers.pop(event_name, None)

    def send_request(self, method: str, payload: Optional[str] = None) -> Optional[str]:
        """Send a request and wait for a response.

        Args:
            method: The method to call.
            payload: The request payload (JSON), or None.

        Returns:
            The response payload (JSON), or None on failure.
        """
        handler = self._handlers.get(method)
        if handler:
            return handler(method, payload)
        return None

    def broadcast_event(self, event_name: str, payload: Optional[str] = None) -> None:
        """Broadcast an event to all connected clients.

        Args:
            event_name: The event name.
            payload: The event payload (JSON), or None.
        """
        handler = self._event_handlers.get(event_name)
        if handler:
            handler(event_name, payload)

    @property
    def is_running(self) -> bool:
        """Whether the IPC transport is currently running."""
        return self._running
