#Requires AutoHotkey v2.0

; autohotkey.com/boards/viewtopic.php?f=82&t=94114&p=418207
class OrderedMap extends Map {
  __New(KVPairs*) {
    super.__New(KVPairs*)

    KeyArray := []
    keyCount := KVPairs.Length // 2
    KeyArray.Length := keyCount

    Loop keyCount
      KeyArray[A_Index] := KVPairs[(A_Index << 1) - 1]

    this.KeyArray := KeyArray
  }

  __Item[key] {
    set {
      if !this.Has(key)
        this.KeyArray.Push(key)

      return super[key] := value
    }
  }

  Clear() {
    super.Clear()
    this.KeyArray := []
  }

  Clone() {
    Other := super.Clone()
    Other.KeyArray := this.KeyArray.Clone()
    return Other
  }

  Delete(key) {
    try {
      RemovedValue := super.Delete(key)

      CaseSense := this.CaseSense
      for i, Element in this.KeyArray {
        areSame := (Element is String)
          ? !StrCompare(Element, key, CaseSense)
          : (Element = key)

        if areSame {
          this.KeyArray.RemoveAt(i)
          break
        }
      }

      return RemovedValue
    }
    catch Error as Err
      throw Error(Err.Message, -1, Err.Extra)
  }

  Set(KVPairs*) {
    if (KVPairs.Length & 1)
      throw ValueError('Invalid number of parameters.', -1)

    KeyArray := this.KeyArray
    keyCount := KVPairs.Length // 2
    KeyArray.Capacity += keyCount

    Loop keyCount {
      key := KVPairs[(A_Index << 1) - 1]

      if !this.Has(key)
        KeyArray.Push(key)
    }

    super.Set(KVPairs*)

    return this
  }

  __Enum(*) {
    keyEnum := this.KeyArray.__Enum(1)

    keyValEnum(&key := unset, &val := unset) {
      if keyEnum(&key) {
        val := this[key]
        return true
      }
      else{
        return false
      }
    }

    return keyValEnum
  }
}
