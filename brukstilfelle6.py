import sqlite3

# ====================================================================================
# ============================== BRUKSTILFELLE 6 =====================================
# ========================== Simulering av svartelisting =============================
def simuler_svartelisting():
    con = None
    cur = None
    brukerID = None

    try:
        print(f"Starter simulering av svartelisting for johnny@stud.ntnu.no ...")

        con = sqlite3.connect("trening.db")
        cur = con.cursor()
        con.execute("PRAGMA foreign_keys = ON;")

        # henter brukerID for gitt e-post for å bruke i opprettelse av 'test-prikker'
        cur.execute("""
                    SELECT brukerID
                    FROM bruker
                    WHERE epost = 'johnny@stud.ntnu.no'
        """)
        bruker = cur.fetchone()
        if not bruker:
            print(f"Feil: Fant ingen bruker med e-post johnny@stud.ntnu.no.")
            return
        brukerID = bruker[0]

        # henter simulert nåtid for å bruke som referanse for opprettelse av 'test-prikker'
        cur.execute("SELECT simulert_nåtid FROM system_tid")
        simulert_nåtid = cur.fetchone()[0]

        print(f"Oppretter tre prikker for johnny@stud.ntnu.no ... ")

        # oppretter tre 'test-prikker' for å simulere at brukeren skal svartelistes
        cur.execute("""
                    INSERT INTO prikk (brukerID, dato_og_tid)
                    VALUES
                            (?, ?),
                            (?, datetime(?, '-5 minutes')),
                            (?, datetime(?, '-10 minutes'))
        """, (brukerID, simulert_nåtid, brukerID, simulert_nåtid, brukerID, simulert_nåtid))
        con.commit()

        # henter og viser alle prikker for brukeren for å verifisere at de er opprettet
        cur.execute("""
                    SELECT *
                    FROM prikk
                    WHERE brukerID = ?
        """, (brukerID, ))
        prikker = cur.fetchall()

        print(f"\nPrikker registrert for johnny@stud.ntnu.no med brukerID {brukerID}: ")
        print("------------------------------")
        print("BrukerID |        Tid")
        print("------------------------------")
        for brukerid, tid in prikker:
            print(f"   {brukerid}    | {tid}")

        print(f"\nForsøker å booke en gruppetime for å sjekke om svartelisting fungerer... ")
        print("------------------------------------------------------------------------")
        try:
            # forsøker å opprette en booking for å sjekke om triggeren som håndterer svartelisting fungerer
            cur.execute("""
                        INSERT INTO booking (senter_navn, sal_navn, start_tid, brukerID)
                        VALUES ('Øya treningssenter', 'Sykkelsal', '2026-03-18 20:30:00', ?)
            """, (brukerID, ))
            con.commit()
            print(f"Uventet suksess: Bookingen gitt gjennom (triggeren feilet).")
        
        # hvis det oppstår en feil, antar vi at det er triggeren som håndterer svartelisting som har forhindret
        # bookingen, og vi viser feilmeldingen fra triggeren
        except sqlite3.Error as e:
            print(f"Suksess: Bookingen ble blokkert!")
            print(f"Feilmelding fra trigger: {e}")

    except sqlite3.Error as e:
        print(f"\nFeil under simulering av svartelisting [{e}]")

    finally:
        if con and cur and brukerID is not None:
            # sletter 'test-prikkene' for å rydde opp etter simuleringen
            cur.execute("""
                        DELETE FROM prikk
                        WHERE brukerID = ?
            """, (brukerID, ))
            con.commit()
            print(f"\nOppryddning: 'Test-prikkene' for johnny@stud.ntnu.no er slettet. ")

        if con:
            con.close()
# ====================================================================================