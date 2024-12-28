mFunc(msg) {
MsgBox % msg
}

fn := Func("mFunc")

fn.Call("Call")
fn.("Legacy Call")