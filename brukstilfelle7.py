import sqlite3

def finn_månedens_medlem(måned):
    try:
        con = sqlite3.connect("trening.db")
        cur = con.cursor()

        år = "2026"
        måned_tekst = str(måned).strip()
        if not måned_tekst.isdigit():
            print("Ugyldig måned. Måned må være et tall fra 1 til 12.")
            return

        måned_tall = int(måned_tekst)
        if måned_tall < 1 or måned_tall > 12:
            print("Ugyldig måned. Måned må være et tall fra 1 til 12.")
            return

        mnd = f"{måned_tall:02d}"

        cur.execute("""
                    WITH treninger AS (
                        SELECT u.fornavn, u.etternavn, u.epost, COUNT(*) as antall
                        FROM booking b
                        JOIN bruker u
                            ON b.brukerID = u.brukerID
                        WHERE b.status = 'Møtt'
                            AND strftime('%m', b.start_tid) = ?
                            AND strftime('%Y', b.start_tid) = ?
                        GROUP BY u.brukerID
                    )
                    SELECT fornavn, etternavn, epost, antall
                    FROM treninger
                    WHERE antall = (SELECT MAX(antall) FROM treninger)
        """, (mnd, år))
        vinnere = cur.fetchall()

        if not vinnere:
            print("Ingen treninger funnet denne måneden.")
            return
        
        print(f"\nMÅNEDENS MEDLEM(MER) FOR MÅNED {mnd}. I {år}: ")
        for rad in vinnere:
            print(f"{rad[0]} {rad[1]} ({rad[2]}) - Antall økter: {rad[3]}")

    except sqlite3.Error as e:
        print(f"\nFeil under henting av månedens medlem(er) [{e}]")

    finally:
        con.close()