import sqlite3
from datetime import date, timedelta

def finn_startdag_i_uke(uke):
    år = 2026
    mandag = date.fromisocalendar(år, uke, 1)
    return mandag

def hent_ukeplan(start_dag, uke):
    slutt_dag = start_dag + timedelta(days=7)

    try:
        con = sqlite3.connect("trening.db")
        cur = con.cursor()

        cur.execute("""
                    SELECT
                        datetime(start_tid) AS tid,
                        aktivitet_navn as aktivitet,
                        senter_navn,
                        sal_navn,
                        'Gruppetime' AS type
                    FROM gruppetime
                    WHERE date(start_tid) >= ?
                        AND date(start_tid) < ?
                    
                    UNION ALL

                    SELECT
                        datetime(start_tid) AS tid,
                        (idrettslag_navn || ':' || gruppe_navn) as aktivitet,
                        senter_navn,
                        sal_navn,
                        'Lagtrening' AS type
                    FROM lagtrening
                    WHERE date(start_tid) >= ?
                        AND date(start_tid) < ?
                    
                    ORDER BY tid;
        """, (start_dag, slutt_dag, start_dag, slutt_dag))
        ukeplan = cur.fetchall()

        print(f"\nUKEPLAN FOR UKE {uke} (Starter {start_dag})")
        if not ukeplan:
            print("Ingen treninger funnet i denne uken.")
            return

        for rad in ukeplan:
            print(f"{rad[0]} - {rad[1]} ({rad[2]}, {rad[3]}) [{rad[4]}]")

    except sqlite3.Error as e:
        print(f"\nFeil: Kunne ikke hente ukeplan [{e}]")
    
    finally:
        con.close()