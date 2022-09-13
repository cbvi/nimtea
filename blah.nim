import std/[asyncdispatch, httpclient]

var filetxt = readFile("file.txt")

proc asyncProc(): Future[string] {.async.} =
    var client = newAsyncHttpClient()
    return await client.getContent("http://example.com")

proc asyncPost(): Future[string] {.async.} =
    var client = newAsyncHttpClient()
    var mp = newMultipartData()
    mp["file1"] = ("file.txt", "text/txt", filetxt)
    return await client.postContent("https://httpbin.org/post", multipart=mp)

#echo waitFor asyncProc()

#echo waitFor asyncPost()

type FutureArray = array[0..5, Future[string]]

var ts : FutureArray

for i in low(ts) .. high(ts):
    ts[i] = asyncPost()

#var a = asyncPost()
#var b = asyncPost()
#var c = asyncPost()

#echo waitFor a
#echo waitFor b
#echo waitFor c

for i in low(ts) .. high(ts):
    echo waitFor ts[i]
