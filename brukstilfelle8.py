import sqlite3

def finn_felles_treninger():
    try:
        con = sqlite3.connect("trening.db")
        con.execute("PRAGMA foreign_keys = ON;")
        cur = con.cursor()

# ====================================================================================
# ============================== BRUKSTILFELLE 8 =====================================
# ========================== Felles treninger mellom brukere =========================
        cur.execute("""
                    WITH alle_deltakelser AS (
                        SELECT brukerID, senter_navn, sal_navn, start_tid
                        FROM booking
                        WHERE status = 'Møtt'
                    
                        UNION ALL
                    
                        SELECT d.brukerID, l.senter_navn, l.sal_navn, l.start_tid
                        FROM deltar_på_lagtrening d
                        JOIN lagtrening l
                            ON d.idrettslag_navn = l.idrettslag_navn
                            AND d.gruppe_navn = l.gruppe_navn
                            AND d.start_tid = l.start_tid
                    )
                    SELECT
                        u1.epost AS epost1,
                        u2.epost AS epost2,
                        COUNT(*) AS antall_felles_treninger
                    FROM alle_deltakelser d1
                    JOIN alle_deltakelser d2
                        ON d1.senter_navn = d2.senter_navn
                        AND d1.sal_navn = d2.sal_navn
                        AND d1.start_tid = d2.start_tid
                    JOIN bruker u1
                        ON d1.brukerID = u1.brukerID
                    JOIN bruker u2
                        ON d2.brukerID = u2.brukerID
                    WHERE d1.brukerID < d2.brukerID
                    GROUP BY epost1, epost2
                    HAVING antall_felles_treninger >= 1
                    ORDER BY antall_felles_treninger DESC
        """)
# ===================================================================================

        felles_treninger = cur.fetchall()
        if not felles_treninger:
            print("Fant ingen felles treninger. ")
            return
        
        print("\nFELLES TRENINGER MELLOM TO BRUKERE: ")
        print("---------------------------------------------------------------------")
        print("E-post bruker 1      | E-post bruker 2      | Antall felles treninger")
        print("---------------------------------------------------------------------")
        for bruker1, bruker2, antall in felles_treninger:
            print(f"{bruker1:<20} | {bruker2:<20} |          {antall}")

    except sqlite3.Error as e:
        print(f"\nFeil under henting av felles treninger [{e}]")

    finally:
        con.close()