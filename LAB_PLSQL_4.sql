--Tipuri de subprograme :
--1.Functii (trebuie sa returneze ceva)
--2.Proceduri
--Subprogramele sunt de 2 tipuri:
--1.Locale -> declarate intr-un bloc PL/SQL
--2.Stocate -> in baza de date

--Ex1 -> Salariul unui angajat cu un nume dat

DECLARE 
  v_nume employees.last_name%TYPE := Initcap('&p_nume');    
 
  FUNCTION f1 RETURN NUMBER IS 
    salariu employees.salary%type;  
  BEGIN     
    SELECT salary INTO salariu  
    FROM   employees 
    WHERE  last_name = v_nume; 
    RETURN salariu; 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
       DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu numele dat'); 
    WHEN TOO_MANY_ROWS THEN 
       DBMS_OUTPUT.PUT_LINE('Exista mai multi angajati '||  
                            'cu numele dat'); 
    WHEN OTHERS THEN 
       DBMS_OUTPUT.PUT_LINE('Alta eroare!'); 
  END f1; 
BEGIN
 DBMS_OUTPUT.PUT_LINE('Salariul este '|| f1);
 EXCEPTION
 WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE('Eroarea are codul = '||SQLCODE || ' si mesajul = ' || SQLERRM);
END;
/

--Ex2 -> 1 dar cu functie stocate
CREATE OR REPLACE FUNCTION f2_fna
 (v_nume employees.last_name%TYPE DEFAULT 'Bell')
RETURN NUMBER IS
 salariu employees.salary%type;
 BEGIN
 SELECT salary INTO salariu
 FROM employees
 WHERE last_name = v_nume;
 RETURN salariu;
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
 RAISE_APPLICATION_ERROR(-20000,
 'Nu exista angajati cu numele dat');
 WHEN TOO_MANY_ROWS THEN
 RAISE_APPLICATION_ERROR(-20001,
 'Exista mai multi angajati cu numele dat');
 WHEN OTHERS THEN
 RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
END f2_fna;
/

BEGIN
 DBMS_OUTPUT.PUT_LINE('Salariul este '|| f2_fna);
END;
/
--BEGIN
 --DBMS_OUTPUT.PUT_LINE('Salariul este '|| f2_fna('King'));
--END;
--/

SELECT f2_fna FROM DUAL;
--SELECT f2_fna('King') FROM DUAL;

--Ex3 -> 1 dar cu procedura locala (nu intoarce dar poate avea parametri de tip OUT)
-- varianta 1
DECLARE
 v_nume employees.last_name%TYPE := Initcap('&p_nume');

 PROCEDURE p3
 IS
 salariu employees.salary%TYPE;
 BEGIN
 SELECT salary INTO salariu
 FROM employees
 WHERE last_name = v_nume;
 DBMS_OUTPUT.PUT_LINE('Salariul este '|| salariu);

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
 DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu numele dat');
 WHEN TOO_MANY_ROWS THEN
 DBMS_OUTPUT.PUT_LINE('Exista mai multi angajati '||
 'cu numele dat');
 WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE('Alta eroare!');
 END p3;
BEGIN
 p3;
END;
/

-- varianta 2 -> parametru de tip OUT cu care apelam functia -> ne va intoarce parametru respectiv modificat
DECLARE
 v_nume employees.last_name%TYPE := Initcap('&p_nume');
 v_salariu employees.salary%type;
 PROCEDURE p3(salariu OUT employees.salary%type) IS
 BEGIN
 SELECT salary INTO salariu
 FROM employees
 WHERE last_name = v_nume;
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
 RAISE_APPLICATION_ERROR(-20000,
 'Nu exista angajati cu numele dat');
 WHEN TOO_MANY_ROWS THEN
 RAISE_APPLICATION_ERROR(-20001,
 'Exista mai multi angajati cu numele dat');
 WHEN OTHERS THEN
 RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
 END p3;
BEGIN
 p3(v_salariu);
 DBMS_OUTPUT.PUT_LINE('Salariul este '|| v_salariu);
END;
/

--Ex4 -> 1 dar cu procedura stocata
-- varianta 1
CREATE OR REPLACE PROCEDURE p4_fna
 (v_nume employees.last_name%TYPE)
 IS
 salariu employees.salary%TYPE;
 BEGIN
 SELECT salary INTO salariu
 FROM employees
 WHERE last_name = v_nume;
 DBMS_OUTPUT.PUT_LINE('Salariul este '|| salariu);

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
 RAISE_APPLICATION_ERROR(-20000,
 'Nu exista angajati cu numele dat');
 WHEN TOO_MANY_ROWS THEN
 RAISE_APPLICATION_ERROR(-20001,
 'Exista mai multi angajati cu numele dat');
 WHEN OTHERS THEN
 RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
 END p4_fna;
/
-- metode apelare
-- 1. Bloc PLSQL
BEGIN
 p4_fna('Bell');
END;
/
-- 2. SQL*PLUS
EXECUTE p4_fna('Bell');
EXECUTE p4_fna('King');
EXECUTE p4_fna('Kimball');


-- varianta 2
CREATE OR REPLACE PROCEDURE
 p4_fna(v_nume IN employees.last_name%TYPE,
 salariu OUT employees.salary%type) IS
 BEGIN
 SELECT salary INTO salariu
 FROM employees
 WHERE last_name = v_nume;
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
 RAISE_APPLICATION_ERROR(-20000,
 'Nu exista angajati cu numele dat');
 WHEN TOO_MANY_ROWS THEN
 RAISE_APPLICATION_ERROR(-20001,
 'Exista mai multi angajati cu numele dat');
 WHEN OTHERS THEN
 RAISE_APPLICATION_ERROR(-20002,'Alta eroare!');
 END p4_fna;
/
-- metode apelare
-- 1. Bloc PLSQL
DECLARE
 v_salariu employees.salary%type;
BEGIN
 p4_fna('Bell',v_salariu);
 DBMS_OUTPUT.PUT_LINE('Salariul este '|| v_salariu);
END;
/
-- 2. SQL*PLUS
VARIABLE v_sal NUMBER
EXECUTE p4_fna ('Bell',:v_sal)
PRINT v_sal


