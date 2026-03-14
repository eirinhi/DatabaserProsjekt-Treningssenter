import sqlite3

def book_gruppetime(epost, aktivitet, tidspunkt):
    try:
        con = sqlite3.connect("trening.db")
        con.execute("PRAGMA foreign_keys = ON;")
        cur = con.cursor()

        # finner brukerID basert på epost
        cur.execute("SELECT brukerID FROM bruker WHERE epost = ?", (epost,))
        bruker = cur.fetchone()
        if not bruker:
            print(f"Feil: Fant ingen bruker med e-post '{epost}'.")
            return
        brukerID = bruker[0]
        
        # sjekker om gruppetimen finnes og henter sal_navn
        cur.execute("""
                    SELECT senter_navn, sal_navn
                    FROM gruppetime
                    WHERE aktivitet_navn = ?
                        AND start_tid = ?
        """, (aktivitet, tidspunkt))
        mulige_gruppetimer = cur.fetchall()

        if not mulige_gruppetimer:
            print(f"Feil: Gruppetimen '{aktivitet}' kl. {tidspunkt} ble ikke funnet.")
            return
        
        if len(mulige_gruppetimer) == 1:
            senter, sal_navn = mulige_gruppetimer[0]
        else:
            print(f"Det finnes flere '{aktivitet}'-timer samtidig: ")
            for i, (senter, sal) in enumerate(mulige_gruppetimer):
                print(f"{i+1}. Senter: {senter} | Sal: {sal}")

            valg = int(input(f"Velg hvilken time du vil booke (1-{len(mulige_gruppetimer)}): "))
            senter, sal_navn = mulige_gruppetimer[valg-1]

        # utfører booking
        cur.execute("""
                    INSERT INTO booking (senter_navn, sal_navn, start_tid, brukerID)
                    VALUES (?, ?, ?, ?)
        """, (senter, sal_navn, tidspunkt, brukerID))

        con.commit()
        print(f"\nSuksess! Booking opprettet for {epost} på {aktivitet}.")


    except sqlite3.Error as e:
        print(f"\nFeil: kunne ikke booke [{e}]")

    finally:
        con.close()