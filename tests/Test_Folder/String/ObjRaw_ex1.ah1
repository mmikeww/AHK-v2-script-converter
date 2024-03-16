MyObj := {Key: "Hello World"}

ObjRawSet(MyObj, "Key", "Value")

MyValue := ObjRawGet(MyObj, "Key")

MsgBox % MyValue