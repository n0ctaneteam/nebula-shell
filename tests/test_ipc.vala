using NebulaShell;

public void test_ipc_message_type_to_string () {
    assert (IpcMessageType.REQUEST.to_string () == "request");
    assert (IpcMessageType.RESPONSE.to_string () == "response");
    assert (IpcMessageType.EVENT.to_string () == "event");
    assert (IpcMessageType.ERROR.to_string () == "error");
}

public void test_ipc_message_type_from_string () {
    assert (IpcMessageType.from_string ("request") == IpcMessageType.REQUEST);
    assert (IpcMessageType.from_string ("response") == IpcMessageType.RESPONSE);
    assert (IpcMessageType.from_string ("event") == IpcMessageType.EVENT);
    assert (IpcMessageType.from_string ("error") == IpcMessageType.ERROR);
    assert (IpcMessageType.from_string ("unknown") == IpcMessageType.REQUEST);
}

public void test_ipc_message_creation () {
    var msg = new IpcMessage (IpcMessageType.REQUEST, "id-1", "get-volume", null);
    assert (msg.message_type == IpcMessageType.REQUEST);
    assert (msg.id == "id-1");
    assert (msg.method == "get-volume");
    assert (msg.payload == null);
    assert (msg.status == 0);
}

public void test_ipc_message_to_json () {
    var msg = new IpcMessage (IpcMessageType.REQUEST, "id-1", "get-volume", null);
    string json = msg.to_json ();
    assert (json.contains ("\"type\":\"request\""));
    assert (json.contains ("\"id\":\"id-1\""));
    assert (json.contains ("\"method\":\"get-volume\""));
}

public void test_ipc_message_from_json () {
    string json = "{\"type\":\"request\",\"id\":\"id-1\",\"method\":\"get-volume\",\"status\":0}";
    var msg = IpcMessage.from_json (json);
    assert (msg != null);
    assert (msg.message_type == IpcMessageType.REQUEST);
    assert (msg.id == "id-1");
    assert (msg.method == "get-volume");
    assert (msg.status == 0);
}

public void test_ipc_message_from_json_with_payload () {
    string json = "{\"type\":\"response\",\"id\":\"id-1\",\"payload\":{\"volume\":80},\"status\":0}";
    var msg = IpcMessage.from_json (json);
    assert (msg != null);
    assert (msg.message_type == IpcMessageType.RESPONSE);
    assert (msg.payload != null);
    assert (msg.payload.contains ("volume"));
}

public void test_ipc_message_from_json_invalid () {
    string json = "invalid json";
    var msg = IpcMessage.from_json (json);
    assert (msg == null);
}

public int main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/ipc/message_type_to_string", test_ipc_message_type_to_string);
    Test.add_func ("/ipc/message_type_from_string", test_ipc_message_type_from_string);
    Test.add_func ("/ipc/message_creation", test_ipc_message_creation);
    Test.add_func ("/ipc/message_to_json", test_ipc_message_to_json);
    Test.add_func ("/ipc/message_from_json", test_ipc_message_from_json);
    Test.add_func ("/ipc/message_from_json_with_payload", test_ipc_message_from_json_with_payload);
    Test.add_func ("/ipc/message_from_json_invalid", test_ipc_message_from_json_invalid);

    return Test.run ();
}