package main
import . "make_dbus"


func main() {
    DBusCall(
        SystemDBUS("com.deepin.dde.lock"),
        FLAGS_NONE,
        Method("dbus_add_nopwdlogin",
            Callback("AddNoPwdLogin"), Arg("username:char*")),
        Method("dbus_remove_nopwdlogin",
            Callback("RemoveNoPwdLogin"), Arg("username:char*")),
    )

    OUTPUT_END()
}
