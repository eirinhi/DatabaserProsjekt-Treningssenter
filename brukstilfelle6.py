import sqlite3

def simuler_svartelisting(epost):
    try:
        print(f"\nSTARTER SIMULERING AV SVARTELISTING FOR {epost}...")

        con = sqlite3.connect("trening.db")
        cur = con.cursor()
        con.execute("PRAGMA foreign_keys = ON;")

        cur.execute("""
                    SELECT brukerID
                    FROM bruker
                    WHERE epost = ?
        """, (epost,))
        bruker = cur.fetchone()
        if not bruker:
            print(f"Fant ingen bruker med e-post {epost}.")
            return
        brukerID = bruker[0]

        cur.execute("SELECT simulert_nåtid FROM system_tid")
        simulert_nåtid = cur.fetchone()[0]

        print(f"Oppretter tre prikker for {epost}... ")
        cur.execute("""
                    INSERT INTO prikk (brukerID, dato_og_tid)
                    VALUES
                            (?, ?),
                            (?, datetime(?, '-5 minutes')),
                            (?, datetime(?, '-10 minutes'))
        """, (brukerID, simulert_nåtid, brukerID, simulert_nåtid, brukerID, simulert_nåtid))

        cur.execute("""
                    SELECT *
                    FROM prikk
                    WHERE brukerID = ?
        """, (brukerID, ))
        prikker = cur.fetchall()

        print(f"\nPrikker registrert for {epost} med brukerID {brukerID}: ")
        for rad in prikker:
            print(f"BrukerID: {rad[0]}, Tid: {rad[1]}")

        print(f"\nForsøker å booke en gruppetime for å sjekke om svartelisting fungerer... ")
        try:
            cur.execute("""
                        INSERT INTO booking (senter_navn, sal_navn, start_tid, brukerID)
                        VALUES ('Øya treningssenter', 'Sykkelsal', '2026-03-18 20:30:00', ?)
            """, (brukerID, ))
            con.commit()
            print(f"\nUventet suksess: Bookingen gitt gjennom (triggeren feilet).")
        
        except sqlite3.Error as e:
            print(f"\nSuksess: Bookingen ble blokkert!")
            print(f"Feilmelding fra trigger: {e}")

    except sqlite3.Error as e:
        print(f"\nFeil under simulering av svartelisting [{e}]")

    finally:
        if con:
            cur.execute("""
                        DELETE FROM prikk
                        WHERE brukerID = ?
            """, (brukerID, ))
            con.commit()
            print(f"\nOppryddning: 'Test-prikkene' for {epost} er slettet. ")
            con.close()
