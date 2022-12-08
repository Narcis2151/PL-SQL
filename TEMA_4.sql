--1
--a. Cursoare clasice
DECLARE
 titlu JOBS.JOB_TITLE%TYPE;
 id JOBS.JOB_ID%TYPE;
 nr NUMBER;
 salariu EMPLOYEES.SALARY%TYPE;
 nume EMPLOYEES.LAST_NAME%TYPE;
 CURSOR c IS 
  SELECT J.JOB_ID, J.JOB_TITLE, COUNT(E.employee_id)
  FROM JOBS J, EMPLOYEES E
  WHERE J.JOB_ID = E.JOB_ID (+)
  GROUP BY J.JOB_ID, J.JOB_TITLE;
 CURSOR d (parametru jobs.JOB_ID%TYPE) IS
  SELECT LAST_NAME, SALARY
  FROM EMPLOYEES
  WHERE JOB_ID = parametru;
BEGIN
 OPEN c;
 LOOP
  FETCH c INTO id, titlu, nr;
  EXIT WHEN c%NOTFOUND;
  DBMS_OUTPUT.PUT_LINE('------------');
  DBMS_OUTPUT.PUT_LINE('JOB '|| titlu);
  DBMS_OUTPUT.PUT_LINE('------------');
  IF nr = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu acest job');
  ELSE
    OPEN d(id);
    LOOP
    FETCH d into nume, salariu;
    EXIT WHEN d%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(nume || ' ' || salariu);
    END LOOP;
    CLOSE d;
  END IF;
 END LOOP;
 CLOSE c;
END;
/

--b. Ciclu cursoare
DECLARE
 CURSOR c IS 
  SELECT J.JOB_ID, J.JOB_TITLE, COUNT(E.employee_id) nr
  FROM JOBS J, EMPLOYEES E
  WHERE J.JOB_ID = E.JOB_ID (+)
  GROUP BY J.JOB_ID, J.JOB_TITLE;
 CURSOR d (parametru jobs.JOB_ID%TYPE) IS
  SELECT LAST_NAME, SALARY
  FROM EMPLOYEES
  WHERE JOB_ID = parametru;
BEGIN
 FOR line in c LOOP
  DBMS_OUTPUT.PUT_LINE('------------');
  DBMS_OUTPUT.PUT_LINE('JOB '|| line.JOB_TITLE);
  DBMS_OUTPUT.PUT_LINE('------------');
  IF line.nr = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu acest job');
  ELSE
   FOR x in d(line.JOB_ID) LOOP
    DBMS_OUTPUT.PUT_LINE(x.LAST_NAME || ' ' || x.SALARY);
   END LOOP;
  END IF;
 END LOOP;
END;
/

--c. Ciclu cursoare cu subcereri
BEGIN
 FOR line in 
 (SELECT J.JOB_ID, J.JOB_TITLE, COUNT(E.employee_id) nr
  FROM JOBS J, EMPLOYEES E
  WHERE J.JOB_ID = E.JOB_ID (+)
  GROUP BY J.JOB_ID, J.JOB_TITLE) LOOP
    DBMS_OUTPUT.PUT_LINE('------------');
    DBMS_OUTPUT.PUT_LINE('JOB '|| line.JOB_TITLE);
    DBMS_OUTPUT.PUT_LINE('------------');
  IF line.nr = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu acest job');
  ELSE
   FOR x in 
   (SELECT LAST_NAME, SALARY
   FROM EMPLOYEES
   WHERE JOB_ID = line.JOB_ID) LOOP
    DBMS_OUTPUT.PUT_LINE(x.LAST_NAME || ' ' || x.SALARY);
   END LOOP;
  END IF;
 END LOOP;
END;
/

--d. Expresii cursor
DECLARE 
 TYPE refcursor IS REF CURSOR;
 titlu JOBS.JOB_TITLE%TYPE;
 nr NUMBER;
 salariu EMPLOYEES.SALARY%TYPE;
 nume EMPLOYEES.LAST_NAME%TYPE;
 CURSOR c IS 
  SELECT JOB_TITLE,
         CURSOR (SELECT LAST_NAME, SALARY
                 FROM EMPLOYEES
                 WHERE EMPLOYEES.JOB_ID = JOBS.JOB_ID)
  FROM JOBS;
  v_cursor refcursor;      
BEGIN
 OPEN c;
 LOOP
  FETCH c INTO titlu, v_cursor;
  EXIT WHEN c%NOTFOUND;
  DBMS_OUTPUT.PUT_LINE('------------');
  DBMS_OUTPUT.PUT_LINE('JOB '|| titlu);
  DBMS_OUTPUT.PUT_LINE('------------');
  SELECT COUNT(employee_id)
  INTO nr
  FROM JOBS J, EMPLOYEES E
  WHERE J.JOB_TITLE = titlu AND J.JOB_ID = E.JOB_ID(+) ;
  IF nr = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu acest job');
  ELSE
    LOOP
    FETCH v_cursor INTO nume, salariu;
    EXIT WHEN v_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(nume || ' ' || salariu);
    END LOOP;
  END IF;
 END LOOP;
 CLOSE c;
END;
/

--2
DECLARE
 numar_de_ordine NUMBER := 0;
 numar_total_angajati NUMBER := 0;
 salariu_total NUMBER := 0;
 salariu_mediu NUMBER :=0;
 salariu_mediu_job NUMBER := 0;
 salariu_total_job NUMBER := 0;
 CURSOR c IS 
  SELECT J.JOB_ID, J.JOB_TITLE, COUNT(E.employee_id) numar_de_angajati
  FROM JOBS J, EMPLOYEES E
  WHERE J.JOB_ID = E.JOB_ID (+)
  GROUP BY J.JOB_ID, J.JOB_TITLE;
 CURSOR d (parametru jobs.JOB_ID%TYPE) IS
  SELECT LAST_NAME, SALARY
  FROM EMPLOYEES
  WHERE JOB_ID = parametru;
BEGIN
 FOR line in c LOOP
  numar_de_ordine := 0;
  salariu_mediu_job := 0;
  salariu_total_job := 0;
  numar_total_angajati := numar_total_angajati + line.numar_de_angajati;
  DBMS_OUTPUT.PUT_LINE('------------');
  DBMS_OUTPUT.PUT_LINE('JOB '|| line.JOB_TITLE);
  DBMS_OUTPUT.PUT_LINE('NUMAR DE ANGAJATI: ' || line.numar_de_angajati);
  IF line.numar_de_angajati = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu acest job');
  ELSE
   FOR x in d(line.JOB_ID) LOOP
    numar_de_ordine := numar_de_ordine + 1;
    DBMS_OUTPUT.PUT_LINE(numar_de_ordine || '. ' || x.LAST_NAME || ' ' || x.SALARY);
    salariu_total_job := salariu_total_job + x.SALARY;
   END LOOP;
   salariu_mediu_job := salariu_total_job / line.numar_de_angajati;
  END IF;
  DBMS_OUTPUT.PUT_LINE('Salariul total pentru job: ' || salariu_total_job);
  DBMS_OUTPUT.PUT_LINE('Salariul mediu pentru job: ' || salariu_mediu_job);
  DBMS_OUTPUT.PUT_LINE('------------');
  salariu_total := salariu_total + salariu_total_job;
 END LOOP;
 salariu_mediu := salariu_total / numar_total_angajati;
 DBMS_OUTPUT.PUT_LINE('------------');
 DBMS_OUTPUT.PUT_LINE('Numar total de angajati: ' || numar_total_angajati);
 DBMS_OUTPUT.PUT_LINE('Salariul total pentru firma: ' || salariu_total);
 DBMS_OUTPUT.PUT_LINE('Salariul mediu pentru firma: ' || salariu_mediu);
 DBMS_OUTPUT.PUT_LINE('------------');
END;
/

--3
DECLARE
 suma_totala NUMBER := 0;
 procentaj_din_total VARCHAR2(6);
 numar_de_ordine NUMBER := 0;
 CURSOR c IS 
  SELECT J.JOB_ID, J.JOB_TITLE, COUNT(E.employee_id) numar_de_angajati
  FROM JOBS J, EMPLOYEES E
  WHERE J.JOB_ID = E.JOB_ID (+)
  GROUP BY J.JOB_ID, J.JOB_TITLE;
 CURSOR d (parametru jobs.JOB_ID%TYPE) IS
  SELECT LAST_NAME, SALARY, NVL(COMMISSION_PCT, 0) Comision
  FROM EMPLOYEES
  WHERE JOB_ID = parametru;
BEGIN
 FOR i in 
 (SELECT SALARY, NVL(COMMISSION_PCT,0) Com
 FROM EMPLOYEES) LOOP
  suma_totala := suma_totala + i.SALARY + i.Com*i.SALARY;
 END LOOP;
 DBMS_OUTPUT.PUT_LINE('SUMA TOTALA DE PLATA: ' || suma_totala);
 FOR line in c LOOP
  numar_de_ordine := 0;
  DBMS_OUTPUT.PUT_LINE('------------');
  DBMS_OUTPUT.PUT_LINE('JOB '|| line.JOB_TITLE);
  IF line.numar_de_angajati = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu acest job');
  ELSE
   FOR x in d(line.JOB_ID) LOOP
    numar_de_ordine := numar_de_ordine + 1;
    procentaj_din_total := TO_CHAR(((x.SALARY + x.SALARY * x.Comision) / suma_totala) * 100, '0.00');
    DBMS_OUTPUT.PUT_LINE(numar_de_ordine || '. ' || x.LAST_NAME || ' ' || x.SALARY || ' ' || procentaj_din_total || '% din suma totala alocata');
   END LOOP;
  END IF;
 END LOOP;
END;
/

--4
DECLARE
 numar_de_ordine NUMBER := 0;
 CURSOR c IS 
  SELECT J.JOB_ID, J.JOB_TITLE, COUNT(E.employee_id) numar_de_angajati
  FROM JOBS J, EMPLOYEES E
  WHERE J.JOB_ID = E.JOB_ID (+)
  GROUP BY J.JOB_ID, J.JOB_TITLE;
 CURSOR d (parametru jobs.JOB_ID%TYPE) IS
  SELECT LAST_NAME, SALARY, NVL(COMMISSION_PCT, 0) Comision
  FROM EMPLOYEES
  WHERE JOB_ID = parametru
  ORDER BY SALARY DESC;
BEGIN
 FOR line in c LOOP
  numar_de_ordine := 0;
  DBMS_OUTPUT.PUT_LINE('------------');
  DBMS_OUTPUT.PUT_LINE('JOB '|| line.JOB_TITLE);
  IF line.numar_de_angajati = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu acest job');
  ELSE
    IF line.numar_de_angajati < 5 THEN
    DBMS_OUTPUT.PUT_LINE('Exista mai putin de 5 angajati cu acest job');
    END IF;
   FOR x in d(line.JOB_ID) LOOP
    EXIT WHEN d%ROWCOUNT>5 or d%NOTFOUND;
    numar_de_ordine := numar_de_ordine + 1;
    DBMS_OUTPUT.PUT_LINE(numar_de_ordine || '. ' || x.LAST_NAME || ' ' || x.SALARY);
   END LOOP;
  END IF;
 END LOOP;
END;
/

--5
DECLARE
 numar_de_ordine NUMBER := 0;
 CURSOR c IS 
  SELECT J.JOB_ID, J.JOB_TITLE, COUNT(E.employee_id) numar_de_angajati
  FROM JOBS J, EMPLOYEES E
  WHERE J.JOB_ID = E.JOB_ID (+)
  GROUP BY J.JOB_ID, J.JOB_TITLE;
  CURSOR x (parametru EMPLOYEES.JOB_ID%TYPE) IS
  SELECT SALARY, COUNT(*) numar_cu_salariul
  FROM EMPLOYEES
  WHERE JOB_ID = parametru
  GROUP BY SALARY
  ORDER BY SALARY DESC;
 CURSOR d (parametru1 EMPLOYEES.SALARY%TYPE, parametru2 EMPLOYEES.JOB_ID%TYPE) IS
  SELECT LAST_NAME
  FROM EMPLOYEES
  WHERE SALARY = parametru1 AND JOB_ID = parametru2
  ORDER BY LAST_NAME;
BEGIN
 FOR line in c LOOP
  numar_de_ordine := 0;
  DBMS_OUTPUT.PUT_LINE('------------');
  DBMS_OUTPUT.PUT_LINE('JOB '|| line.JOB_TITLE);
  IF line.numar_de_angajati = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu acest job');
  ELSE
   FOR salariu IN x(line.JOB_ID) LOOP
    EXIT WHEN x%ROWCOUNT > 5 OR x%NOTFOUND;
    FOR i in d(salariu.SALARY, line.JOB_ID) LOOP
     DBMS_OUTPUT.PUT(i.LAST_NAME || ', ');
    END LOOP;
    DBMS_OUTPUT.PUT(salariu.salary);
    DBMS_OUTPUT.PUT_LINE('');
   END LOOP;
  END IF;
  DBMS_OUTPUT.PUT_LINE('------------');
 END LOOP;
END;
/