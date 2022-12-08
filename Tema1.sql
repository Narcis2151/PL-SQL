--6 Afi?a?i urm?toarele informa?ii: titlul filmului, num?rul exemplarului, statusul setat ?i statusul corect
SELECT t.title Title, t_c.copy_id Copy_ID, t_c.status Status,
       CASE WHEN (t.title_id, t_c.copy_id) NOT IN (SELECT title_id, copy_id FROM rental WHERE act_ret_date IS NULL) 
       THEN 'AVAILABLE' 
       ELSE 'RENTED'
       END AS "STATUS_CORECT"
FROM (title t JOIN title_copy t_c ON t.title_id = t_c.title_id);

--7.a. Câte exemplare au statusul eronat? 
SELECT COUNT(*)
FROM (SELECT t.title Title, t_c.copy_id Copy_ID, t_c.status Status,
       CASE WHEN (t.title_id, t_c.copy_id) NOT IN (SELECT title_id, copy_id FROM rental WHERE act_ret_date IS NULL) 
       THEN 'AVAILABLE' 
       ELSE 'RENTED'
       END AS "STATUS_CORECT"
FROM (title t JOIN title_copy t_c ON t.title_id = t_c.title_id))
WHERE STATUS != STATUS_CORECT;

--7.b. Seta?i statusul corect pentru toate exemplarele care au statusul eronat. Salva?i actualiz?rile realizate.
CREATE TABLE title_copy_nfa AS SELECT * FROM title_copy;

UPDATE title_copy_nfa SET status = (CASE WHEN (title_id, copy_id) NOT IN (SELECT title_id, copy_id FROM rental WHERE act_ret_date IS NULL) 
                                   THEN 'AVAILABLE' 
                                   ELSE 'RENTED'
                                   END );
                        
--8 Toate filmele rezervate au fost împrumutate la data rezerv?rii? Afi?a?i textul “Da” sau ”Nu” în func?ie de situa?ie.
SELECT CASE
       WHEN (SELECT COUNT(*)
             FROM reservation join rental ON reservation.title_id=rental.title_id AND reservation.member_id=rental.member_id
             WHERE rental.book_date != reservation.res_date) > 0
      THEN 'NU'
      ELSE 'DA'
      END AS "RASPUNS"
FROM dual;
        
--9 De câte ori a împrumutat un membru (nume ?i prenume) fiecare film (titlu)?
SELECT last_name || ' ' || first_name AS "Nume", title_id, COUNT(*)
FROM member NATURAL JOIN rental NATURAL JOIN title_copy
GROUP BY last_name, first_name, title_id;

--10 De câte ori a împrumutat un membru (nume ?i prenume) fiecare exemplar (cod) al unui film (titlu)? 
SELECT last_name || ' ' || first_name AS "Nume", title_id, copy_id, COUNT(*)
FROM member NATURAL JOIN rental NATURAL JOIN title_copy
GROUP BY last_name, first_name, title_id, copy_id;

