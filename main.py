import brukstilfelle1, brukstilfelle2
import sqlite3
import os

def vis_meny():
    print("\n------------------ TRENING DB ------------------")
    print("Brukstilfeller: ")
    print("2. Booking av gruppetime ")
    print("3. Registrering av oppmøte ")
    print("4. Ukeplan for alle treninger registrrert i uke 12 ")
    print("5. Personlig besøkshistorie ")
    print("6. Svartelisting ")
    print("7. Flest treninger ")
    print("8. Trene samme ")
    print("0. Avslutt ")
    print("------------------------------------------------\n")


def main():
    brukstilfelle1.setup_db()

    while True:
        vis_meny()
        valg = input("Velg et brukstilfelle (0-8): ")

        if valg == "2":
            print("\nBooking av trening: ")
            epost = input("E-post (trykk Enter for johnny@stud.ntnu.no): ") or "johnny@stud.ntnu.no"
            aktivitet = input("Aktivitet (trykk Enter for Spin60): ") or "Spin60"
            tidspunkt = input("Starttid (YYYY-MM-DD HH:MM:SS, trykk Enter for 2026-03-17 18:30:00): ") or "2026-03-17 18:30:00"

            brukstilfelle2.book_gruppetime(epost, aktivitet, tidspunkt)

        elif valg == "3":
            print("\n[Logikk for BT 3 kommer her]")
        elif valg == "4":
            print("\n[Logikk for BT 4 kommer her]")
        elif valg == "5":
            print("\n[Logikk for BT 5 kommer her]")
        elif valg == "6":
            print("\n[Logikk for BT 6 kommer her]")
        elif valg == "7":
            print("\n[Logikk for BT 7 kommer her]")
        elif valg == "8":
            print("\n[Logikk for BT 8 kommer her]")
        elif valg == "0":
            print("Avslutter programmet.")
            break
        else:
            print("Ugyldig valg, prøv igjen.")

if __name__ == "__main__":
    main()
