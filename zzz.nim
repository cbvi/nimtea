import db_sqlite
from htmlgen as html import nil

type
    Strength = enum
        Weak = 1, Mild, Average, Strong, VeryStrong



func whatStrength(s: string): Strength =
    case s
    of "5":
        VeryStrong
    of "4":
        Strong
    of "3":
        Average
    of "2":
        Mild
    of "1":
        Weak
    else:
        raise newException(RangeError, "Strength out of range")

func strengthToString(s: string): string =
    let s = whatStrength(s)
    case s
    of VeryStrong:
        "Very Strong"
    of Strong:
        "Strong"
    of Average:
        "Average"
    of Mild:
        "Mild"
    of Weak:
        "Weak"

func shouldBuy(s: string): string =
    case s
    of "0":
        "No"
    of "1":
        "Yes"
    else:
        raise newException(RangeError, "Buy out of range")

let db = open("test.db", "", "", "")

const schema = staticRead "schema.sql"
db.exec(sql schema)

proc addTea(name:string, buy:bool, rating:int,  str:Strength, cmt:string) =
    const q = """INSERT INTO teas (name, buy, rating, strength, comment)
                 VALUES (?, ?, ?, ?, ?)"""
    db.exec(sql q, name, int(buy), rating, int(str), cmt)

func teaColumn(row: Row): string =
    html.tr(
        html.td(row[1]),
        html.td(shouldBuy(row[2])),
        html.td(row[3]),
        html.td(strengthToString(row[4])),
        html.td(row[5])
    )

#addTea("Dunedin dawn", false, 2, VeryStrong, "Tastes like tea")
#addTea("Earl Grey Blue Star", false, 3, Mild, "Very flowery")
#addTea("Traditional English Blend", true, 5, Mild, "The teaist tea")

for row in db.fastRows(sql"SELECT * FROM teas"):
    echo teaColumn(row)

db.close()
