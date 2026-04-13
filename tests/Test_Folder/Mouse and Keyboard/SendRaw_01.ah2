^q::
{ ; V1toV2: Added opening brace for [^q]
global ; V1toV2: Made function global
Send("{Raw}`;")
Send("{Raw}" 123)
Send("{Raw}456")
Send("{Raw}" SubStr(CreateString(), 1, 5)) ; Seven
return
} ; V1toV2: Added closing brace for [^q]

CreateString() {
  return "Seven Eight Nine"
}