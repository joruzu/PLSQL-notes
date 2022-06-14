set serveroutput on;
-- opgave 1
    create or replace procedure print(p_printvalue in varchar2) is
    begin
        dbms_output.put_line(p_printvalue);
    end;
    /
    -- example usage
    declare
        v_result pls_integer;
    begin
        v_result := 1/0;
    exception 
        when zero_divide then
            print('Error: cannot divide by zero');
    end;
    /
-- opgave 2
    create or replace function revstr(p_inputstr in varchar2)
    return varchar2 is
        type t_arraystring_type is table of char index by pls_integer; 
        t_splitstr t_arraystring_type;
        v_outputstr varchar2(4000) := '';
    begin
        for i in 1 .. length(p_inputstr) loop
            t_splitstr(i) := substr(p_inputstr, i, 1);
        end loop;
        for i in reverse 1 .. length(p_inputstr) loop
            v_outputstr := v_outputstr||t_splitstr(i);
        end loop;
        return v_outputstr;
    end;
    /
    -- example usage
    begin
        dbms_output.put_line(revstr('hello world!'));
    end;
    /
-- opgave 3
    declare
        v_afd number;

        function afdeling_van(p_mnr in pls_integer) return pls_integer is
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
                        case when upper(p_functie) = 'VERKOPER' then 0.1*p_maandsal else null end,
                        p_afd
                    );
                end if;
            end if;
        end neem_med_aan;
    begin
        ontsla_med(p_mnr => 7900);
        v_afd := afdeling_van(p_mnr => 7369);
        dbms_output.put_line(v_afd);
        neem_med_aan( p_naam => 'vermeulen'
                    , p_voorl => 't'
                    , p_gbdatum => '15-02-1961'
                    , p_maandsal => 2000
                    , p_afd => 10 );
        neem_med_aan( p_naam => 'derks'
                    , p_voorl => 'm'
                    , p_gbdatum => '05-aug-61'
                    , p_maandsal => 2500
                    , p_afd => 30 
                    , p_functie => 'Verkoper'
                    , p_chef => 7698);
        neem_med_aan( p_naam => 'martens'
                    , p_voorl => 'i'
                    , p_gbdatum => '11-06-1956'
                    , p_maandsal => 2100
                    , p_afd => 20 
                    , p_functie => 'TRAINER');
        neem_med_aan( p_naam => 'verbeek'
                    , p_voorl => 'j'
                    , p_gbdatum => '12-09-1950'
                    , p_maandsal => 2600
                    , p_afd => 30 
                    , p_functie => 'verkoper'
                    , p_chef => 7782); -- levert als het goed is een fout op
    end;
    /
-- opgave 4
    declare
        v_rekeningnummer varchar2(20) := '123456789';
        function geldig_bankrek(p_banknr in varchar2) return boolean is
            v_check_banknr pls_integer := 0;
        begin
            if length(p_banknr) = 9 then 
                for i in 1 .. 9 loop
                    v_check_banknr := v_check_banknr + substr(p_banknr, i, 1)*(10-i);
                end loop;
                if mod(v_check_banknr, 11) = 0 then 
                    return true;
                else
                    return false;
                end if;
            else
                return false;
            end if;
        end geldig_bankrek;
    begin
        case 
        when geldig_bankrek(v_rekeningnummer) then 
            dbms_output.put_line('Bankrekeningnummer ' || v_rekeningnummer || ' is geldig');
        else
            dbms_output.put_line('Ongeldig bankrekeningnummer ' || v_rekeningnummer);
        end case;
    end;
    /
-- opgave 5
    drop table test_child purge;
    drop table test_parent purge;
    create table test_parent(id number primary key, val varchar2(50));
    create table test_child(id number primary key, id_parent number references test_parent(id), val varchar2(50));
    insert into test_parent values (1, 'a');
    insert into test_child values (1, 1, 'aa');
    insert into test_child values (2, 1, 'ab');

    create or replace procedure drop_tabel(p_tabelnaam varchar2, p_cascade_mode varchar2 default 'no_cascade') is
        dynsql_drop varchar2(1000);
    begin
        case p_cascade_mode
            when 'no_cascade' then
                dynsql_drop := 'drop table '||p_tabelnaam||' purge';
            when 'cascade' then
                dynsql_drop := 'drop table '||p_tabelnaam||' cascade constraints purge';
            else
                dbms_output.put_line('specify "cascade" or "no_cascade" for 2nd parameter');
        end case;
        execute immediate dynsql_drop;
    end drop_tabel;
    /

    begin
        drop_tabel('test_parent', 'cascade');
        drop_tabel('test_child');
    end;
    /

drop procedure print;
drop function revstr;
drop procedure drop_tabel;