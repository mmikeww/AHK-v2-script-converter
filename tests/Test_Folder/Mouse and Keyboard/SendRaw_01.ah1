^q::
sendraw, `;
sendraw, 123
sendraw, % "456"
sendraw, % subStr(CreateString(), 1,5) ; Seven
return

CreateString() {
  return "Seven Eight Nine"
}