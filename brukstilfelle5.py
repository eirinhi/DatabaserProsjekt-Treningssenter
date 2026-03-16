import sqlite3

def personlig_besøkshistorikk(epost):
    try:
        con = sqlite3.connect("trening.db")
        cur = con.cursor()

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

        cur.execute("""
                    SELECT DISTINCT
                        'Gruppetime' AS type,
                        g.aktivitet_navn AS trening,
                        b.senter_navn AS treningssenter,
                        b.start_tid AS dato_tid
                    FROM booking b
                    JOIN gruppetime g
                        ON b.senter_navn = g.senter_navn
                        AND b.sal_navn = g.sal_navn
                        AND b.start_tid = g.start_tid
                    WHERE b.brukerID = ?
                        AND b.status = 'Møtt'
                        AND b.start_tid >= '2026-01-01'

                    UNION

                    SELECT DISTINCT
                        'Lagtrening' AS type,
                        l.idrettslag_navn AS trening,
                        l.senter_navn AS treningssenter,
                        l.start_tid AS dato_tid
                    FROM deltar_på_lagtrening d
                    JOIN lagtrening l
                        ON d.idrettslag_navn = l.idrettslag_navn
                        AND d.gruppe_navn = l.gruppe_navn
                        AND d.start_tid = l.start_tid
                    WHERE d.brukerID = ?
                        AND l.start_tid >= '2026-01-01'

                    ORDER BY dato_tid DESC;
        """, (brukerID, brukerID))
        treninger = cur.fetchall()


        print(f"\n            PERSONLIG BESØKSHISTORIKK FOR {epost}")
        print(f"-----------------------------------------------------------------------")
        if not treninger:
            print(f"Ingen treninger funnet for {epost} siden 1. januar 2026.")
            return
        
        # printer ut aktivitet_navn, treningssenter og dato/tid for treningen
        for rad in treninger:
            print(f"{rad[0]}: {rad[1]}, {rad[2]}, {rad[3]}")


    except sqlite3.Error as e:
        print(f"\nFeil: Kunne ikke hente personlig besøkshistorikk [{e}]")
    
    finally:
        con.close()