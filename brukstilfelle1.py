import sqlite3

def setup_db():
    try:
        print("\nBrukstilfelle 1: Initialiserer og legger til data i database... ")

        con = sqlite3.connect("trening.db")
        cur = con.cursor()

        with open("trening.sql", "r", encoding="utf-8") as f:
            sql_trening = f.read()
        cur.executescript(sql_trening)

        with open("triggere.sql", "r", encoding="utf-8") as f:
            sql_triggere = f.read()
        cur.executescript(sql_triggere)

        with open("testdata.sql", "r", encoding="utf-8") as f:
            sql_testdata = f.read()
        cur.executescript(sql_testdata)

        con.commit()
        print("--------------------------------------------------------")
        print("Database er satt opp med tabeller, triggere og testdata!")


    except sqlite3.Error as e:
        print(f"Feil: {e}")

    finally:
        con.close()