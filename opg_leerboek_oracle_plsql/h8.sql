-- opgave 1
    create or replace package pck_pz as
        -- function afdeling_van(p_mnr in number) return number;
        procedure ontsla_med (p_mnr in number);
        procedure ontsla_med(p_naam in varchar2);
        procedure neem_med_aan (  p_naam varchar2
                                , p_voorl varchar2
                                , p_gbdatum varchar2
                                , p_maandsal pls_integer
                                , p_afd pls_integer
                                , p_functie varchar2 default null
                                , p_chef pls_integer default null );
        procedure wijzig_init_comm(p_comm in number);
        g_initieel_commissie_ratio number;
    end pck_pz;
    /

    create or replace package body pck_pz as
        

        function afdeling_van(p_mnr in number) return number is
            cursor c_med_afd is select afd from medewerkers where mnr = p_mnr;
            v_medewerker_afd medewerkers.afd%type;
        begin
            open c_med_afd;
            fetch c_med_afd into v_medewerker_afd;
            close c_med_afd;
            return v_medewerker_afd;
        end afdeling_van;

        procedure ontsla_med(p_mnr in number) is
            v_is_chef pls_integer;
            v_is_afdhoofd pls_integer;
            v_bestaat_mnr pls_integer;
            v_bestaat_mnr_uitv pls_integer;
            v_bestaat_mnr_inschr pls_integer;
        begin
            select count(distinct mnr), count(distinct uitvoeringen.begindatum), count(distinct inschrijvingen.begindatum) 
            into v_bestaat_mnr, v_bestaat_mnr_uitv, v_bestaat_mnr_inschr
            from medewerkers 
                left join uitvoeringen on mnr=docent
                left join inschrijvingen on mnr=cursist
            where mnr = p_mnr;

            select count(chef), count(hoofd)
            into v_is_chef, v_is_afdhoofd
            from medewerkers left join afdelingen on chef=hoofd 
            where chef = p_mnr;

            if v_bestaat_mnr = 0 then 
                raise_application_error(-20000, 'Medewerker bestaat niet');
            else
                if v_is_afdhoofd > 0 then 
                    raise_application_error(-20001, 'Medewerker is afdelingshoofd, wordt niet verwijderd');
                elsif v_is_chef > 0 then
                    raise_application_error(-20002, 'Medewerker is chef van andere medewerker(s), wordt niet verwijderd');
                else
                    if v_bestaat_mnr_uitv > 0 then
                        update uitvoeringen
                        set docent = null
                        where docent = p_mnr;
                    end if;
                    
                    if v_bestaat_mnr_inschr > 0 then 
                        delete inschrijvingen
                        where cursist = p_mnr;
                    end if;

                    delete medewerkers
                    where mnr = p_mnr;
                end if;
            end if;
        end ontsla_med;

        procedure ontsla_med(p_naam in varchar2) is
            v_is_chef pls_integer;
            v_is_afdhoofd pls_integer;
            v_bestaat_mnr pls_integer;
            v_bestaat_mnr_uitv pls_integer;
            v_bestaat_mnr_inschr pls_integer;
            v_mnr pls_integer;
        begin
            select count(distinct mnr), count(distinct uitvoeringen.begindatum), count(distinct inschrijvingen.begindatum) 
            into v_bestaat_mnr, v_bestaat_mnr_uitv, v_bestaat_mnr_inschr
            from medewerkers 
                left join uitvoeringen on mnr=docent
                left join inschrijvingen on mnr=cursist
            where naam = upper(p_naam);

            select count(m.chef), count(distinct hoofd)
            into v_is_chef, v_is_afdhoofd
            from medewerkers m left join afdelingen on m.chef=hoofd left join medewerkers mn on m.chef = mn.mnr
            where mn.naam = upper(p_naam);

            if v_bestaat_mnr = 0 then 
                raise_application_error(-20000, 'Medewerker bestaat niet');
            elsif v_bestaat_mnr = 1 then
                select mnr into v_mnr from medewerkers where naam = upper(p_naam);
                
                if v_is_afdhoofd > 0 then 
                    raise_application_error(-20001, 'Medewerker is afdelingshoofd, wordt niet verwijderd');
                elsif v_is_chef > 0 then
                    raise_application_error(-20002, 'Medewerker is chef van andere medewerker(s), wordt niet verwijderd');
                else
                    if v_bestaat_mnr_uitv > 0 then
                        update uitvoeringen
                        set docent = null
                        where docent = v_mnr;
                    end if;
                    
                    if v_bestaat_mnr_inschr > 0 then 
                        delete inschrijvingen
                        where cursist = v_mnr;
                    end if;

                    delete medewerkers
                    where mnr = v_mnr;
                end if;
            else
                raise_application_error(-20003, 'Er is meer dan 1 medewerker met die naam');
            end if;
        end ontsla_med;

        procedure neem_med_aan ( p_naam varchar2
                                , p_voorl varchar2
                                , p_gbdatum varchar2
                                , p_maandsal pls_integer
                                , p_afd pls_integer
                                , p_functie varchar2 default null
                                , p_chef pls_integer default null )
        is
            v_bepaal_mnr pls_integer;
        begin
            select max(mnr) into v_bepaal_mnr from medewerkers;
            if p_chef is not null and p_afd <> afdeling_van(p_chef) then
                raise_application_error(-20100, 'Medewerker werkt niet op dezelfde afdeling als zijn chef, check afdeling of chefnummer nader');
            else
                if months_between(sysdate, add_months(to_date(p_gbdatum, 'dd-mm-yyyy'), 18*12)) < 0 then
                    raise_application_error(-20101, 'Deze medewerker is jonger dan 18 jaar, check of de geboortedatum juist is');
                else
                    insert into medewerkers(mnr, naam, voorl, functie, chef, gbdatum, maandsal, comm, afd)
                    values(
                        v_bepaal_mnr + 1,
                        upper(p_naam),
                        upper(p_voorl),
                        upper(p_functie),
                        p_chef,
                        to_date(p_gbdatum, 'dd-mm-yyyy'),
                        p_maandsal,
                        case when upper(p_functie) = 'VERKOPER' then g_initieel_commissie_ratio*p_maandsal else null end,
                        p_afd
                    );
                end if;
            end if;
        end neem_med_aan;

        procedure wijzig_init_comm(p_comm in number) is
            cursor c_max_comm_ratio is
                select max(comm/maandsal) max_comm_ratio
                from medewerkers;
            v_check_comm number;
        begin
            open c_max_comm_ratio;
            fetch c_max_comm_ratio into v_check_comm;
            if p_comm <= v_check_comm then 
                g_initieel_commissie_ratio := p_comm;
            else
                raise_application_error(-20200, 'Ingevoerde commissieratio hoger dan max commissieratio van medewerkers');
            end if;
            close c_max_comm_ratio;
        end;
    begin
        select sum(comm / maandsal) / count(comm)
        into g_initieel_commissie_ratio
        from medewerkers;
    end pck_pz;
    /

-- opgave 2
    create or replace package timer as
        procedure aanzetten;
        procedure stopzetten;
        function verstreken_msecs return number;
    end timer;
    /
    create or replace package body timer as
        g_starttime number;
        g_stoptime number;

        procedure aanzetten is
        begin
            g_starttime := dbms_utility.get_time;
        end;

        procedure stopzetten is
        begin
            g_stoptime := dbms_utility.get_time;
        end;

        function verstreken_msecs return number is
        begin
            return g_stoptime - g_starttime;
        end;
    end timer;
    /
    -- test usage
    declare
        v_aantal pls_integer;
    begin
        timer.aanzetten;
        select count(*)
        into v_aantal
        from all_objects;
        timer.stopzetten;
        dbms_output.put_line('Aantal records '||v_aantal);
        dbms_output.put_line('Milliseconden '||timer.verstreken_msecs);

        timer.aanzetten;
        select count(*)
        into v_aantal
        from all_tables;
        timer.stopzetten;
        dbms_output.put_line('Aantal records '||v_aantal);
        dbms_output.put_line('Milliseconden '||timer.verstreken_msecs);
    end;
    /
-- opgave 3
    declare
        t_afdelingsnamen dbms_utility.lname_array;
        cursor c_afd_namen is
            select naam
            from afdelingen;
        v_afdelingsnamen_kommalijst varchar2(1000);
        v_aantal number;
    begin
        open c_afd_namen;
        fetch c_afd_namen bulk collect into t_afdelingsnamen;
        dbms_utility.table_to_comma(t_afdelingsnamen, v_aantal, v_afdelingsnamen_kommalijst);
        dbms_output.put_line(v_afdelingsnamen_kommalijst);
        close c_afd_namen;
    end;
    /


drop package timer;
drop package pck_pz;
-- If you drop package spec, then package body is also dropped
--drop package body timer;
--drop package body pck_pz;