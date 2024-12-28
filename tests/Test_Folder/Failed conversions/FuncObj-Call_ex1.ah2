mFunc(msg) {
MsgBox(msg)
}

fn := mFunc

fn.Call("Call")
fn.Call("Legacy Call")