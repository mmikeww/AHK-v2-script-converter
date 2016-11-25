/**
 * Credits: Coco
 * URL: http://ahkscript.org/boards/viewtopic.php?f=6&t=5714&p=33532#p33531
 */
class FileObject
{
	__New(fspec, flags, encoding:="CP0")
	{
		this.__Ptr := FileOpen(fspec, flags, encoding)
	}

	__Get(key, args*)
	{
		if (key ~= "i)^__Handle|AtEOF|Encoding|Length|Pos(ition)?$")
			return (this.__Ptr)[key, args*]
	}

	__Set(key, value, args*)
	{
		if (key ~= "i)^Encoding|Length|Pos(ition)?$")
			return (this.__Ptr)[key] := value
	}

	__Call(method, args*)
	{
		if (method ~= "i)^(Read|Write)(Line|U?(Char|Short|Int)|Double|Float|Int64)?|Seek|Tell|Close$")
			return (this.__Ptr)[method](args*)
	}

	RawRead(bytes, Advanced=0)
	{
		Count := this.__Ptr.RawRead(VarOrAddress, bytes)
		if (Advanced) {
			return JS.Object("Data",VarOrAddress, "Count",Count)
		} else {
			return VarOrAddress
		}
	}
	RawWrite(VarOrAddress, bytes)
	{
		return this.__Ptr.RawWrite(VarOrAddress, bytes)
	}
}