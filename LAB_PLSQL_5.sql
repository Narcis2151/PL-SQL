--1. Pachet ce contine 2 functii
CREATE OR REPLACE PACKAGE pachet1_fna AS 
   FUNCTION  f_numar(v_dept departments.department_id%TYPE)  
        RETURN NUMBER; 
   FUNCTION  f_suma(v_dept departments.department_id%TYPE)  
        RETURN NUMBER; 
END pachet1_fna; 
/ 
CREATE OR REPLACE PACKAGE BODY pachet1_fna AS 
   FUNCTION  f_numar(v_dept  departments.department_id%TYPE)  
      RETURN NUMBER IS numar NUMBER; 
   BEGIN 
      SELECT COUNT(*)INTO numar 
      FROM   employees 
      WHERE  department_id =v_dept; 
   RETURN numar; 
   END f_numar; 

   FUNCTION  f_suma (v_dept  departments.department_id%TYPE)  
      RETURN NUMBER IS 
      suma NUMBER; 
   BEGIN 
      SELECT SUM(salary+salary*NVL(commission_pct,0)) 
      INTO suma 
      FROM employees 
      WHERE department_id =v_dept; 
   RETURN suma; 
   END f_suma; 
END pachet1_fna; 
/

--Apelare in SQL
SELECT pachet1_fna.f_numar(80) 
FROM DUAL; 
SELECT pachet1_fna.f_suma(80) 
FROM DUAL; 

--Apelare in PL/SQL
BEGIN 
  DBMS_OUTPUT.PUT_LINE('numarul de salariati este '|| 
                        pachet1_fna.f_numar(80)); 
  DBMS_OUTPUT.PUT_LINE('suma alocata este '|| 
                        pachet1_fna.f_suma(80)); 
END; 
/

--2 Pachet cu 2 proceduri si o functie
CREATE OR REPLACE PACKAGE pachet2_fna AS 
   PROCEDURE p_dept (v_codd dept_fna.department_id%TYPE, 
                     v_nume dept_fna.department_name%TYPE, 
                     v_manager dept_fna.manager_id%TYPE, 
                     v_loc dept_fna.location_id%TYPE); 
   PROCEDURE p_emp (v_first_name emp_fna.first_name%TYPE, 
                 v_last_name emp_fna.last_name%TYPE, 
                 v_email emp_fna.email%TYPE, 
                 v_phone_number emp_fna.phone_number%TYPE:=NULL,  
                 v_hire_date emp_fna.hire_date%TYPE :=SYSDATE,      
                 v_job_id emp_fna.job_id%TYPE,         
                 v_salary   emp_fna.salary%TYPE :=0,       
                 v_commission_pct emp_fna.commission_pct%TYPE:=0, 
                 v_manager_id emp_fna.manager_id%TYPE,    
                 v_department_id emp_fna.department_id%TYPE); 
 
FUNCTION exista (cod_loc dept_fna.location_id%TYPE,  
                   manager dept_fna.manager_id%TYPE)  
  RETURN NUMBER; 
END pachet2_fna; 
/ 
 
CREATE OR REPLACE PACKAGE BODY pachet2_fna AS 
 
FUNCTION exista(cod_loc dept_fna.location_id%TYPE,  
                manager dept_fna.manager_id%TYPE) 
 RETURN NUMBER  IS  
      rezultat NUMBER:=1; 
      rez_cod_loc NUMBER; 
      rez_manager NUMBER; 
 BEGIN 
    SELECT count(*) INTO   rez_cod_loc 
    FROM   locations 
    WHERE  location_id = cod_loc; 
     
    SELECT count(*) INTO   rez_manager 
    FROM   emp_fna 
    WHERE  employee_id = manager; 
     
    IF rez_cod_loc=0 OR rez_manager=0 THEN  
         rezultat:=0;      
    END IF; 
RETURN rezultat; 
END; 
 
PROCEDURE p_dept(v_codd dept_fna.department_id%TYPE, 
                 v_nume dept_fna.department_name%TYPE, 
                 v_manager dept_fna.manager_id%TYPE, 
                 v_loc dept_fna. location_id%TYPE) IS 
BEGIN 
   IF exista(v_loc, v_manager)=0 THEN  
       DBMS_OUTPUT.PUT_LINE('Nu s-au introdus date coerente pentru 
tabelul dept_fna'); 
   ELSE 
     INSERT INTO dept_fna 
          (department_id,department_name,manager_id,location_id) 
     VALUES (v_codd, v_nume, v_manager, v_loc); 
   END IF; 
 END p_dept; 
 
PROCEDURE p_emp 
(v_first_name emp_fna.first_name%TYPE, 
 v_last_name emp_fna.last_name%TYPE, 
 v_email emp_fna.email%TYPE, 
 v_phone_number emp_fna.phone_number%TYPE:=null,  
 v_hire_date emp_fna.hire_date%TYPE :=SYSDATE,      
 v_job_id emp_fna.job_id%TYPE,         
 v_salary emp_fna.salary %TYPE :=0,       
 v_commission_pct emp_fna.commission_pct%TYPE:=0, 
 v_manager_id emp_fna.manager_id%TYPE,    
 v_department_id  emp_fna.department_id%TYPE) 
AS 
 BEGIN 
     INSERT INTO emp_fna 
     VALUES (sec_fna.NEXTVAL, v_first_name, v_last_name, v_email, 
            v_phone_number,v_hire_date, v_job_id, v_salary, 
            v_commission_pct, v_manager_id,v_department_id); 
END p_emp; 
END pachet2_fna; 
/ 

--Apelare in SQL
EXECUTE pachet2_fna.p_dept(50,'Economic',200,2000); 
 
SELECT * FROM dept_fna WHERE department_id=50; 
 
EXECUTE pachet2_fna.p_emp('f','l','e',v_job_id=>'j', v_manager_id=>200,v_department_id=>50); 
 
SELECT * FROM emp_fna WHERE job_id='j'; 
 
ROLLBACK;

--Apelare in PL/SQL
BEGIN 
   pachet2_fna.p_dept(50,'Economic',99,2000); 
   pachet2_fna.p_emp('f','l','e',v_job_id=>'j',v_manager_id=>200, 
                     v_department_id=>50); 
END; 
/ 
 
SELECT * FROM emp_fna WHERE job_id='j'; 
ROLLBACK;

--3. Pachet cu cursor si functie
CREATE  OR REPLACE PACKAGE pachet3_fna AS 
   CURSOR c_emp(nr NUMBER) RETURN employees%ROWTYPE;  
   FUNCTION  f_max  (v_oras  locations.city%TYPE) RETURN NUMBER; 
END pachet3_fna; 
/ 
CREATE OR REPLACE PACKAGE BODY pachet3_fna AS 
 
CURSOR c_emp(nr NUMBER) RETURN employees%ROWTYPE   
      IS 
      SELECT *  
      FROM employees  
      WHERE salary >= nr;  
 
FUNCTION  f_max (v_oras  locations.city%TYPE) RETURN NUMBER  IS 
      maxim  NUMBER; 
BEGIN 
     SELECT  MAX(salary)  
     INTO    maxim   
     FROM    employees e, departments d, locations l 
     WHERE   e.department_id=d.department_id  
             AND d.location_id=l.location_id  
             AND UPPER(city)=UPPER(v_oras); 
    RETURN  maxim; 
END f_max; 
END pachet3_fna; 
/ 
 
DECLARE 
  oras    locations.city%TYPE:= 'Toronto'; 
  val_max NUMBER; 
  lista   employees%ROWTYPE; 
BEGIN 
   val_max:=  pachet3_fna.f_max(oras); 
   FOR v_cursor IN pachet3_fna.c_emp(val_max) LOOP 
      DBMS_OUTPUT.PUT_LINE(v_cursor.last_name||' '|| 
                           v_cursor.salary);    
   END LOOP; 
END; 
/

--4.Pachet cu functie si cursor
CREATE OR REPLACE  PACKAGE pachet4_fna IS 
  PROCEDURE p_verific  
      (v_cod employees.employee_id%TYPE, 
       v_job   employees.job_id%TYPE); 
  CURSOR c_emp RETURN employees%ROWTYPE;   
END pachet4_fna; 
/ 
CREATE OR REPLACE PACKAGE BODY pachet4_fna IS 
   CURSOR c_emp  RETURN employees%ROWTYPE  IS 
         SELECT * 
         FROM   employees; 
   PROCEDURE p_verific(v_cod   employees.employee_id%TYPE, 
                     v_job   employees.job_id%TYPE) 
   IS 
   gasit BOOLEAN:=FALSE; 
   lista employees%ROWTYPE; 
   BEGIN 
   OPEN c_emp; 
   LOOP 
      FETCH c_emp INTO lista; 
      EXIT WHEN c_emp%NOTFOUND; 
      IF lista.employee_id=v_cod  AND lista.job_id=v_job    
         THEN  gasit:=TRUE; 
      END IF; 
   END LOOP; 
   CLOSE c_emp; 
   IF gasit=TRUE THEN  
      DBMS_OUTPUT.PUT_LINE('combinatia data exista'); 
   ELSE   
      DBMS_OUTPUT.PUT_LINE('combinatia data nu exista'); 
   END IF; 
   END p_verific; 
END pachet4_fna; 
/ 
  
EXECUTE pachet4_fna.p_verific(200,'AD_ASST'); 

