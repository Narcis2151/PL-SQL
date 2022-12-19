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

VARIABLE nr NUMBER 
EXECUTE :nr := f2_fna('Bell'); 
PRINT nr;

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


--Ex5 -> Procedura stocata ce primeste codul unui angajat si intoarce prin acelasi parametru
-- managerul acestuia

VARIABLE ang_man NUMBER 
BEGIN 
 :ang_man:=200; 
END; 
/ 

CREATE OR REPLACE PROCEDURE p5_fna  (nr IN OUT NUMBER) IS  
BEGIN 
 SELECT manager_id INTO nr 
 FROM employees 
 WHERE employee_id=nr; 
END p5_fna; 
/ 

EXECUTE p5_fna (:ang_man) 
PRINT ang_man

--Ex6 -> Procedura locala cu 3 parametri -> result (OUT), comision(IN) default NULL, cod(IN) default null
--Se returneaza in result numele angajatului cu comisionul respectiv daca este dat, altfel angajatul cu codul dat

DECLARE 
nume employees.last_name%TYPE; 
PROCEDURE p6 (rezultat OUT employees.last_name%TYPE, 
              comision IN  employees.commission_pct%TYPE:=NULL, --parametri cu valori default
              cod      IN  employees.employee_id%TYPE:=NULL)  
 IS 
 BEGIN 
 IF (comision IS NOT NULL) THEN 
    SELECT last_name  
    INTO rezultat 
    FROM employees 
    WHERE commission_pct= comision; 
    DBMS_OUTPUT.PUT_LINE('numele salariatului care are  
                comisionul '||comision||' este '||rezultat); 
 ELSE  
    SELECT last_name  
    INTO rezultat 
    FROM employees 
    WHERE employee_id =cod; 
    DBMS_OUTPUT.PUT_LINE('numele salariatului avand codul '|| 
                          cod ||' este '||rezultat); 
 END IF; 
END p6; 
 
BEGIN 
  p6(nume,0.4); 
  p6(nume,cod=>200); --Specificarea parametrilor cand apelam procedura
END; 
/

--Ex7 -> Overload pe functii -> 2 functii locale cu acelasi nume 
--prima returneaza suma salariilor pentru un departament dat
--a doua returneaza suma salariilor pentru un departament si job dat

DECLARE 
  medie1 NUMBER(10,2); 
  medie2 NUMBER(10,2);  
  FUNCTION medie (v_dept employees.department_id%TYPE)  
    RETURN NUMBER IS 
    rezultat NUMBER(10,2); 
  BEGIN 
    SELECT AVG(salary)  
    INTO   rezultat  
    FROM   employees 
    WHERE  department_id = v_dept; 
    RETURN rezultat; 
  END; 
   
  FUNCTION medie (v_dept employees.department_id%TYPE, 
                  v_job employees.job_id %TYPE)  
    RETURN NUMBER IS 
    rezultat NUMBER(10,2); 
  BEGIN 
    SELECT AVG(salary)  
    INTO   rezultat  
    FROM   employees 
    WHERE  department_id = v_dept AND job_id = v_job; 
    RETURN rezultat; 
  END; 
 
BEGIN 
  medie1:=medie(80); 
  DBMS_OUTPUT.PUT_LINE('Media salariilor din departamentul 80'  
      || ' este ' || medie1); 
  medie2 := medie(80,'SA_MAN'); 
  DBMS_OUTPUT.PUT_LINE('Media salariilor managerilor din' 
      || ' departamentul 80 este ' || medie2); 
END; 
/

--Ex 8 -> recursivitate -> factorial

CREATE OR REPLACE FUNCTION factorial_fna(n NUMBER)  
 RETURN INTEGER IS 
 BEGIN 
  IF (n=0) THEN RETURN 1; 
  ELSE RETURN n*factorial_fna(n-1); 
  END IF; 
END factorial_fna; 
/

SELECT factorial_fna(7) FROM DUAL;

--Ex 9 -> Selectarea angajatilor ce au salariul mai mare decat salariul mediu
--Salariu mediu aflat printr-o functie stocata

CREATE OR REPLACE FUNCTION medie_fna
RETURN NUMBER  
IS  
rezultat NUMBER; 
BEGIN 
  SELECT AVG(salary) INTO   rezultat 
  FROM   employees; 
  RETURN rezultat; 
END; 
/ 
SELECT last_name,salary 
FROM   employees 
WHERE  salary >= medie_fna;



