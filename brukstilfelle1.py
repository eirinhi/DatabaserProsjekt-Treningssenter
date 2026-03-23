import sqlite3

def setup_db():
    try:
        print("\nBrukstilfelle 1: Initialiserer og legger til data i database... ")

        con = sqlite3.connect("trening.db")
        con.execute("PRAGMA foreign_keys = ON;")
        cur = con.cursor()

        with open("trening.sql", "r", encoding="utf-8") as f:
            sql_trening = f.read()
        cur.executescript(sql_trening)

        with open("triggere.sql", "r", encoding="utf-8") as f:
            sql_triggere = f.read()
        cur.executescript(sql_triggere)

# ====================================================================================
# ============================== BRUKSTILFELLE 1 =====================================
# =================== Leser og legger inn testdata i databasen =======================
    
        # testdata.sql inneholder selve løsningen på brukstilfelle 1, men det er her
        # i denne python-funksjonen at vi faktisk legger inn data i databasen
        with open("testdata.sql", "r", encoding="utf-8") as f:
            sql_testdata = f.read()
        cur.executescript(sql_testdata)

        con.commit()
# ====================================================================================
        print("Suksess: Database er satt opp med tabeller, triggere og testdata!")


    except sqlite3.Error as e:
        print(f"Feil: {e}")

    finally:
        con.close()