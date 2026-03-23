import sqlite3

# funksjon for å hente dagens bookinger for en bruker. Treningene er bare treninger
# med status 'Booket' for å sørge for at de ikke allerede har registrert oppmøte,
# og det er disse som brukes som parameter 'trening' i registrer_oppmøte(), altså
# er treningene hentet gjennom denne funksjonen
def hent_dagens_bookinger(epost):
    con = sqlite3.connect("trening.db")
    con.execute("PRAGMA foreign_keys = ON;")
    cur = con.cursor()

    cur.execute("""
                SELECT b.senter_navn, b.sal_navn, b.start_tid, g.aktivitet_navn
                FROM booking b
                JOIN gruppetime g 
                    ON b.senter_navn = g.senter_navn 
                    AND b.sal_navn = g.sal_navn 
                    AND b.start_tid = g.start_tid
                CROSS JOIN system_tid s
                WHERE b.brukerID = (
                    SELECT brukerID
                    FROM bruker
                    WHERE epost = ?
                )
                AND b.status = 'Booket'
                AND date(b.start_tid) = date(s.simulert_nåtid)
    """, (epost,))
    treninger = cur.fetchall()
    con.close()
    return treninger


# ====================================================================================
# ============================== BRUKSTILFELLE 3 =====================================
# ========================== Registrering av oppmøte =================================
def registrer_oppmøte(epost, trening):
    senter = trening[0]
    sal = trening[1]
    tidspunkt = trening[2]
    aktivitet = trening[3]

    try:
        con = sqlite3.connect("trening.db")
        con.execute("PRAGMA foreign_keys = ON;")
        cur = con.cursor()

        # oppdaterer status til 'Møtt' for riktig booking for å registrere oppmøte
        cur.execute("""
                    UPDATE booking
                    SET status = 'Møtt'
                    WHERE brukerID = (
                        SELECT brukerID
                        FROM bruker
                        WHERE epost = ?
                    )
                        AND senter_navn = ?
                        AND sal_navn = ?
                        AND start_tid = ?
        """, (epost, senter, sal, tidspunkt))

        con.commit()
        if cur.rowcount > 0:
            print(f"\nSuksess! Oppmøte registrert for {epost} på {aktivitet}.")
        else:
            print(f"\nFeil: Kunne ikke registrere oppmøte. Sjekk tidsbegrensninger.")

    
    except sqlite3.Error as e:
        print(f"\nFeil: kunne ikke registrere oppmøte [{e}]")

    finally:
        con.close()
# ====================================================================================