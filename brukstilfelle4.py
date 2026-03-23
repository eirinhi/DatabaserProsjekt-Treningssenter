import sqlite3
from datetime import date, timedelta

# Funksjon for å finne startdagen (mandag) i en gitt uke i 2026.
# Denne funksjonen er implementert for å sikre at start_dag i hent_ukeplan() alltid er en mandag,
# og funksjonen skal ta inn riktige parametere etter beskrivelsen av brukstilfelle 4:
#       'Startdag og uke skal være parametere som settes før du kjører queriet.'
def finn_startdag_i_uke(uke):
    år = 2026
    mandag = date.fromisocalendar(år, uke, 1)
    return mandag

# ====================================================================================
# ============================== BRUKSTILFELLE 4 =====================================
# ========================== Ukeplan for en gitt uke =================================
def hent_ukeplan(start_dag, uke):
    slutt_dag = start_dag + timedelta(days=7)

    try:
        con = sqlite3.connect("trening.db")
        con.execute("PRAGMA foreign_keys = ON;")
        cur = con.cursor()

        # henter alle treninger (både gruppetimer og lagtreninger) for den gitte uken sortet på tid
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

        print(f"\nUKEPLAN FOR UKE {uke} (Starter {start_dag}, Slutter {slutt_dag})")

        if not ukeplan:
            print("Ingen treninger funnet i denne uken.")
            return

        print("------------------------------------------------------------------------------------------------------------")
        print("Tid              | Aktivitet                      | Senter                    | Sal             | Type")
        print("------------------------------------------------------------------------------------------------------------")
        for tid, aktivitet, senter, sal, type in ukeplan:
            tid = tid[:16]
            print(f"{tid:<16} | {aktivitet:<30} | {senter:<25} | {sal:<15} | {type}")

    except sqlite3.Error as e:
        print(f"\nFeil: Kunne ikke hente ukeplan [{e}]")
    
    finally:
        con.close()
# ====================================================================================