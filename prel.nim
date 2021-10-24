import jester, db_sqlite
from strutils import parseInt
from strutils import multireplace

func pageTemplate(title: string, body: string): string =
    const tmpl = staticRead "html/template.html"
    tmpl.multireplace(("<@@ TITLE @@>", title), ("<@@ BODY @@>", body))

proc addTea(name: string, buy: bool, rating: int, str: int, cmt: string) =
    let db = open("test.db", "", "", "")
    const q = """INSERT INTO teas (name, buy, rating, strength, comment)
                 VALUES (?, ?, ?, ?, ?)"""
    db.exec(sql q, name, int(buy), rating, str, cmt)
    db.close()

proc delTea(id: string) =
    let db = open("test.db", "", "", "")
    const q = """DELETE FROM teas WHERE teaid = ?"""
    db.exec(sql q, id)
    db.close()

func getStrength(s: string): string =
    case s
    of "1":
        "Weak"
    of "2":
        "Mild"
    of "3":
        "Average"
    of "4":
        "Strong"
    of "5":
        "Very strong"
    else:
        "???"

func delForm(id: string): string =
    result = "<form method=\"post\" action=\"/\" enctype=\"multipart/form-data\">" &
             "<input type=\"hidden\" name=\"id\" value=\"" & id & "\" />" &
             "<input type=\"submit\" value=\"x\"></form>"

proc index(): string =
    let db = open("test.db", "", "", "")
    const q = """SELECT * FROM teas"""

    result = "<table>"
    for row in db.fastRows(sql q):
        result.add("<tr>")
        let name = row[1]
        let buy = if row[2] == "1": "buy" else: "nope"
        let rating = row[3]
        let strength = getStrength(row[4])
        let comment = row[5]
        result.add("<td>" & delForm(row[0]) & "</td>")
        result.add("<td>" & name & "</td>")
        result.add("<td>" & buy & "</td>")
        result.add("<td>" & rating & "/5</td>")
        result.add("<td>" & strength & "</td>")
        result.add("<td>" & comment & "</td>")
        result.add("</tr>\n")
    result.add("</table>")
    db.close()

routes:
    get "/":
        #resp Http200, [("Content-Type", "text/html")], "hello world"
        var body = index()
        body.add("<p><a href=\"/add\">add</a><p>")
        let html = pageTemplate("Teas", body)
        resp html
    post "/":
        let teaid = request.formData.getOrDefault("id").body
        delTea(teaid)
        var body = index()
        body.add("<p>removed item <em>" & teaid & "</em></p>")
        body.add("<p><a href=\"/add\">add</a><p>")
        let html = pageTemplate("Teas", body)
        resp html
    get "/add":
        const form = staticRead "html/add.html"
        let html = pageTemplate("Add tea", form)
        resp html

    post "/add":
        const form = staticRead "html/add.html"
        let tname = request.formData.getOrDefault("name").body
        let tbuy = request.formData.getOrDefault("buy").body
        let trating = request.formData.getOrDefault("rating").body
        let tstrength = request.formData.getOrDefault("strength").body
        let tcomment = request.formData.getOrDefault("comment").body
        var msg : string

        let buy = if tbuy == "true": true else: false
        let str = parseInt(tstrength)
        let rat = parseInt(trating)

        if tname == "":
            msg = "<h2>Could not add entry; missing name</h2>"
        else:
            addTea(tname, buy, rat, str, tcomment)
            msg = "<h2>New entry <em>" & tname & "</em> added</h2>"
        let html = pageTemplate("Add tea", msg & form)
        resp html
