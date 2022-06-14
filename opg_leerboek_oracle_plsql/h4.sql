-- opgave 1
    declare
        type t_namen_type is table of varchar2(50);
        t_mwr_namen t_namen_type;
        i number;
    begin
        select naam
        bulk collect into t_mwr_namen
        from medewerkers
        order by naam;

        dbms_output.put_line('Medewerker namen die een A bevatten:');
        i := t_mwr_namen.first;
        loop 
            if instr(t_mwr_namen(i), 'A') > 0 then 
                dbms_output.put_line(t_mwr_namen(i));
            end if;

            exit when not t_mwr_namen.exists(t_mwr_namen.next(i));
            i := t_mwr_namen.next(i);
        end loop;

        dbms_output.new_line;
        dbms_output.put_line('Medewerker namen die langer zijn dan zes tekens:');
        i := t_mwr_namen.first;
        loop
            if length(t_mwr_namen(i)) > 6 then
                dbms_output.put_line(t_mwr_namen(i));
            end if;

            exit when not t_mwr_namen.exists(t_mwr_namen.next(i));
            i := t_mwr_namen.next(i);
        end loop;
    end;
    /
-- opgave 2
    declare
        type r_mwr_gegevens_type is record (naam medewerkers.naam%type,
                                            gbdatum medewerkers.gbdatum%type);
        type t_mwr_gegevens_type is table of r_mwr_gegevens_type;
        t_oudste_mwrs t_mwr_gegevens_type;
        i number;
    begin
        select naam, gbdatum
        bulk collect into t_oudste_mwrs
        from medewerkers
        order by gbdatum
        fetch first 4 rows only;
        dbms_output.put_line('Hieronder de gegevens van de 4 oudste medewerkers:');
        dbms_output.put_line('NAAM          GBDATUM     ');
        dbms_output.put_line('------------  ------------');
        i := t_oudste_mwrs.first;
        loop
            dbms_output.put_line(rpad(t_oudste_mwrs(i).naam, 12, ' ')||'  '||rpad(t_oudste_mwrs(i).gbdatum, 12, ' '));

            exit when not t_oudste_mwrs.exists(t_oudste_mwrs.next(i));
            i := t_oudste_mwrs.next(i);
        end loop;
    end;
    /
-- opgave 3
    declare
        type r_mwr_sal_type is record (naam medewerkers.naam%type,
                                        functie medewerkers.functie%type,
                                        maandsal medewerkers.maandsal%type,
                                        cumulatief_msal number);
        type t_mwr_salarissen_type is table of r_mwr_sal_type;
        t_msal t_mwr_salarissen_type;
        i number;
    begin
        select naam, functie, maandsal, 0
        bulk collect into t_msal -- t_msal.naam, t_msal.functie, t_msal.maandsal
        from medewerkers
        order by mnr;

        -- m.b.v. analytische functie:
            -- select naam, functie, maandsal, sum(maandsal) over (order by mnr)
            -- bulk collect into t_msal
            -- from medewerkers;

        i := t_msal.first;
        loop
            if i = t_msal.first then
                t_msal(i).cumulatief_msal := t_msal(i).maandsal;
                dbms_output.put_line(rpad('NAAM', 16, ' ')||
                                rpad('FUNCTIE', 16, ' ')||
                                rpad('MAANDSAL', 16, ' ')||
                                rpad('CUMULATIEF SAL', 16, ' '));
                dbms_output.put_line(rpad('-',15,'-')||' '||rpad('-',15,'-')||' '||rpad('-',15,'-')||' '||rpad('-',15,'-'));
                dbms_output.put_line(rpad(t_msal(i).naam, 16, ' ')||
                                    rpad(t_msal(i).functie, 16, ' ')||
                                    rpad(t_msal(i).maandsal, 16, ' ')||
                                    rpad(t_msal(i).cumulatief_msal, 16, ' '));
            else
                t_msal(i).cumulatief_msal := t_msal(t_msal.prior(i)).cumulatief_msal + t_msal(i).maandsal;
                dbms_output.put_line(rpad(t_msal(i).naam, 16, ' ')||
                                    rpad(t_msal(i).functie, 16, ' ')||
                                    rpad(t_msal(i).maandsal, 16, ' ')||
                                    rpad(t_msal(i).cumulatief_msal, 16, ' '));
            end if;
            
            exit when not t_msal.exists(t_msal.next(i));
            i := t_msal.next(i);
        end loop;
    end;
    /
-- opgave 4
    declare
        l_totaal_budget number := 1500;
        l_verhoging_pct number := 0.1;
        type r_mwr_sal_type is record (mnr medewerkers.mnr%type, maandsal medewerkers.maandsal%type);
        type t_mwr_sal_type is table of r_mwr_sal_type;
        t_mwr_verhoging t_mwr_sal_type;
        i number;
        l_verhoging_waarde number;
    begin
        select mnr, maandsal
        bulk collect into t_mwr_verhoging
        from medewerkers
        order by maandsal;

        dbms_output.put_line('Salaris verhoogd voor de volgende medewerkers:');
        i := t_mwr_verhoging.first;
        loop
            l_verhoging_waarde := t_mwr_verhoging(i).maandsal * l_verhoging_pct;
            l_totaal_budget := l_totaal_budget - l_verhoging_waarde;
            if l_totaal_budget < 0 or not t_mwr_verhoging.exists(t_mwr_verhoging.next(i)) then
                l_totaal_budget := l_totaal_budget + l_verhoging_waarde;
                exit;
            end if;

            update medewerkers
            set maandsal = maandsal + l_verhoging_waarde
            where mnr = t_mwr_verhoging(i).mnr;
            dbms_output.put_line(t_mwr_verhoging(i).mnr||' '||'verhoging: '||l_verhoging_waarde);
            i := t_mwr_verhoging.next(i);
        end loop;
        dbms_output.put_line('Resterend budget: ' || l_totaal_budget);
    end;
    /
    select * from medewerkers order by maandsal;
    rollback;
    
-- opgave 5
    declare
        type r_medewerkers_type is record (mnr medewerkers.mnr%type,
                                        gbdatum medewerkers.gbdatum%type,
                                        verhoging_pct medewerkers.maandsal%type);
        type t_medewerkers_type is table of r_medewerkers_type;
        t_verhogingen t_medewerkers_type;
        l_max_budget number := 55000;
        l_totaal_uitgave number;
        l_verhogings_budget number;
        l_som_verhoging number := 0;
        i number;
    begin
        select sum(maandsal) into l_totaal_uitgave from medewerkers;
        l_verhogings_budget := l_max_budget - l_totaal_uitgave;
        select mnr, gbdatum, maandsal*0.1 verhoging_pct
        bulk collect into t_verhogingen
        from medewerkers
        order by gbdatum desc;
        dbms_output.put_line('Oud totaal uitgave: '||l_totaal_uitgave);
        i := t_verhogingen.first;
        loop 
            l_som_verhoging := l_som_verhoging + t_verhogingen(i).verhoging_pct;

            if l_som_verhoging > l_verhogings_budget then
                exit;
            end if;

            update medewerkers
            set maandsal = maandsal + t_verhogingen(i).verhoging_pct
            where mnr = t_verhogingen(i).mnr;

            if not t_verhogingen.exists(t_verhogingen.next(i)) then
                i := t_verhogingen.first;
            else
                i := t_verhogingen.next(i);
            end if;
        end loop;
        select sum(maandsal) into l_totaal_uitgave from medewerkers;
        dbms_output.put_line('Nieuw totaal uitgave: '||l_totaal_uitgave); 
    end;
    /
    select * from medewerkers order by gbdatum desc;
    rollback;