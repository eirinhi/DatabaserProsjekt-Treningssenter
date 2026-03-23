import brukstilfelle1
import brukstilfelle2
import brukstilfelle3
import brukstilfelle4
import brukstilfelle5
import brukstilfelle6
import brukstilfelle7
import brukstilfelle8

def vis_meny():
    print("\n------------------------------------------------------")
    print("--------------------- TRENING DB ---------------------")
    print("Brukstilfeller: ")
    print("2. Booking av gruppetime ")
    print("3. Registrer oppmøte for gruppetime ")
    print("4. Ukeplan for en gitt uke ")
    print("5. Personlig besøkshistorie for en gitt bruker")
    print("6. Simulering av svartelisting ")
    print("7. Flest deltakelser for en gitt måned ")
    print("8. Finn treningspartnere ")
    print("0. Avslutt ")
    print("======================================================\n")


def main():
    brukstilfelle1.setup_db()

    while True:
        vis_meny()
        valg = input("Velg et brukstilfelle (2-8, eller 0 for å avslutte): ")

        if valg == "2":
            print("\nBOOKING AV GRUPPETIME ")
            print("-----------------------------------------------------")
            print("Oppgi følgende informasjon for å booke en gruppetime:")
            epost = input("E-post (trykk Enter for johnny@stud.ntnu.no): ") or "johnny@stud.ntnu.no"
            aktivitet = input("Aktivitet (trykk Enter for Spin60): ") or "Spin60"
            tidspunkt = input("Starttid (YYYY-MM-DD HH:MM:SS, trykk Enter for 2026-03-17 18:30:00): ") or "2026-03-17 18:30:00"

            brukstilfelle2.book_gruppetime(epost, aktivitet, tidspunkt)


        elif valg == "3":
            print("\nREGISTRER OPPMØTE FOR GRUPPETIME ")
            print("-------------------------------------------------------------------")
            print("Oppgi e-post for å finne planlagte bookinger og registrere oppmøte:")
            epost = input("E-post (trykk Enter for johnny@stud.ntnu.no): ") or "johnny@stud.ntnu.no"

            bookinger = brukstilfelle3.hent_dagens_bookinger(epost)
            if not bookinger:
                print(f"Ingen bookinger funnet for {epost} i dag.")
            else:
                if len(bookinger) == 1:
                    valgt_trening = bookinger[0]
                else:
                    print(f"\nVelg hvilken booking du vil registrere oppmøte for: ")
                    for i, (senter, sal, tid, aktivitet) in enumerate(bookinger):
                        print(f"{i+1}. {aktivitet} kl. {tid} ({senter})")
                    
                    valg = int(input(f"Velg booking: "))
                    valgt_trening = bookinger[valg - 1]

                brukstilfelle3.registrer_oppmøte(epost, valgt_trening)


        elif valg == "4":
            print("\nUKEPLAN FOR EN GITT UKE ")
            print("------------------------------------")
            print("Oppgi ukenummer for å hente ukeplan: ")
            uke = int(input("Skriv inn ukenummer (1-52, trykk Enter for 12): ") or 12)
            start_dag = brukstilfelle4.finn_startdag_i_uke(uke)
            brukstilfelle4.hent_ukeplan(start_dag, uke)


        elif valg == "5":
            print("\nPERSONLIG BESØKSHISTORIKK FOR EN GITT BRUKER ")
            print("---------------------------------------------------")
            print("Oppgi e-post for å hente personlig besøkshistorikk:")
            epost = input("E-post (trykk Enter for johnny@stud.ntnu.no): ") or "johnny@stud.ntnu.no"
            brukstilfelle5.personlig_besøkshistorikk(epost)


        elif valg == "6":
            print("\nSIMULERING AV SVARTELISTING ")
            print("---------------------------------------------------------------")
            brukstilfelle6.simuler_svartelisting()


        elif valg == "7":
            print("\nFinn månedens medlem: ")
            måned = input("Oppgi en måned (1-12, trykk Enter for 3): ") or 3
            brukstilfelle7.finn_månedens_medlem(måned)


        elif valg == "8":
            brukstilfelle8.finn_felles_treninger()


        elif valg == "0":
            print("Avslutter programmet.")
            break
        else:
            print("Ugyldig valg, prøv igjen.")

if __name__ == "__main__":
    main()
