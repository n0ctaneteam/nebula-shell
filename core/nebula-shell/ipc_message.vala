namespace NebulaShell {

/**
 * Message types for IPC communication.
 *
 * Defines the protocol used between IPC clients and servers.
 * Transport is abstracted — these types are independent of socket implementation.
 */
public enum IpcMessageType {
    REQUEST,
    RESPONSE,
    EVENT,
    ERROR;

    public string to_string () {
        switch (this) {
            case REQUEST:  return "request";
            case RESPONSE: return "response";
            case EVENT:    return "event";
            case ERROR:    return "error";
            default:       return "unknown";
        }
    }

    public static IpcMessageType from_string (string value) {
        switch (value) {
            case "request":  return REQUEST;
            case "response": return RESPONSE;
            case "event":    return EVENT;
            case "error":    return ERROR;
            default:         return REQUEST;
        }
    }
}

/**
 * Represents a single IPC message.
 *
 * Messages are the unit of communication in the IPC protocol.
 * Each message has a type, an identifier, and a JSON payload.
 *
 * Example:
 *   var msg = new IpcMessage(IpcMessageType.REQUEST, "get-volume", null);
 *   var json = msg.to_json();
 *   var parsed = IpcMessage.from_json(json);
 */
public class IpcMessage : GLib.Object {

    private IpcMessageType _type;
    private string _id;
    private string? _method;
    private string? _payload;
    private int _status;

    /**
     * Create a new IPC message.
     *
     * @param type the message type
     * @param id unique identifier for correlation
     * @param method optional method name for requests
     * @param payload optional JSON payload
     */
    public IpcMessage (IpcMessageType type, string id, string? method, string? payload) {
        _type = type;
        _id = id;
        _method = method;
        _payload = payload;
        _status = 0;
    }

    /**
     * The message type (request, response, event, error).
     */
    public IpcMessageType message_type {
        get { return _type; }
    }

    /**
     * Unique identifier for correlating requests with responses.
     */
    public string id {
        get { return _id; }
    }

    /**
     * Method name for request messages.
     */
    public string? method {
        get { return _method; }
    }

    /**
     * JSON-encoded payload.
     */
    public string? payload {
        get { return _payload; }
    }

    /**
     * Status code for response/error messages.
     *
     * 0 indicates success.
     * Non-zero indicates an error condition.
     */
    public int status {
        get { return _status; }
        set { _status = value; }
    }

    /**
     * Serialize this message to a JSON string.
     *
     * @return JSON representation of the message
     */
    public string to_json () {
        var builder = new GLib.StringBuilder ();
        builder.append ("{");

        builder.append ("\"type\":\"");
        builder.append (_type.to_string ());
        builder.append ("\"");

        builder.append (",\"id\":\"");
        builder.append (_id);
        builder.append ("\"");

        if (_method != null) {
            builder.append (",\"method\":\"");
            builder.append (_method);
            builder.append ("\"");
        }

        if (_payload != null) {
            builder.append (",\"payload\":");
            builder.append (_payload);
        }

        builder.append (",\"status\":");
        builder.append_printf ("%d", _status);

        builder.append ("}");
        return builder.str;
    }

    /**
     * Deserialize a JSON string into an IpcMessage.
     *
     * @param json the JSON string to parse
     * @return the parsed message, or null on parse error
     */
    public static IpcMessage? from_json (string json) {
        try {
            var parser = new Json.Parser ();
            parser.load_from_data (json, -1);
            var root = parser.get_root ();
            var obj = root.get_object ();

            var type_str = obj.get_string_member ("type");
            var type = IpcMessageType.from_string (type_str);
            var id = obj.get_string_member ("id");

            string? method = null;
            if (obj.has_member ("method"))
                method = obj.get_string_member ("method");

            string? payload = null;
            if (obj.has_member ("payload")) {
                var payload_node = obj.get_member ("payload");
                var gen = new Json.Generator ();
                gen.root = payload_node;
                payload = gen.to_data (null);
            }

            int status = 0;
            if (obj.has_member ("status"))
                status = (int) obj.get_int_member ("status");

            var msg = new IpcMessage (type, id, method, payload);
            msg.status = status;
            return msg;
        } catch (Error e) {
            Logger.warning ("IPC: failed to parse message: " + e.message);
            return null;
        }
    }

}

}
