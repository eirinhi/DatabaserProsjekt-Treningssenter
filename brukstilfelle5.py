import sqlite3

# Funksjon som utfører SQL-spørring for brukstilfelle 5
def personlig_besøkshistorikk(epost):
    try:
        con = sqlite3.connect("trening.db")
        con.execute("PRAGMA foreign_keys = ON;")
        cur = con.cursor()

        # henter brukerID for gitt e-post for å bruke i spørringen for personlig besøkshistorikk
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

# ====================================================================================
# ============================== BRUKSTILFELLE 5 =====================================
# ========================== Personlig besøkshistorikk ===============================
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
# ====================================================================================
        
        treninger = cur.fetchall()

        print(f"\nPERSONLIG BESØKSHISTORIKK FOR {epost}")
        if not treninger:
            print(f"Ingen treninger funnet for {epost} siden 1. januar 2026.")
            return
        
        print("--------------------------------------------------------------------------------")
        print("Tid              | Aktivitet            | Senter                    | Type")
        print("--------------------------------------------------------------------------------")
        for type, aktivitet, senter, tid in treninger:
            tid = tid[:16]
            print(f"{tid:<16} | {aktivitet:<20} | {senter:<25} | {type}")

    except sqlite3.Error as e:
        print(f"\nFeil: Kunne ikke hente personlig besøkshistorikk [{e}]")
    
    finally:
        con.close()