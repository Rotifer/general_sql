-- Taken from an old Oracle tutorial on Window Functions and adapted for PostgreSQL (9.5).
-- Uses the old scott schema
-- Link: http://www.orafaq.com/node/55
-- Note Some of the examples do not work in PostgreSQL.
SET search_path = scott;
-- example 1
SELECT
  deptno,
  COUNT(*) DEPT_COUNT
FROM
  emp
WHERE
  deptno IN (20, 30)
GROUP BY
  deptno;

-- example 2
SELECT
  empno, 
  deptno, 
  COUNT(*) OVER (PARTITION BY deptno) DEPT_COUNT
FROM
  emp
WHERE
  deptno IN (20, 30);

--example 3
SELECT
  empno, 
  deptno, 
  COUNT(*) OVER ( ) CNT
FROM
  emp
WHERE
  deptno IN (10, 20)
ORDER BY 
  2,
  1;

-- example 4
SELECT 
  empno, 
  deptno, 
  hiredate,
  ROW_NUMBER( ) OVER (PARTITION BY deptno ORDER BY hiredate NULLS LAST) SRLNO
FROM
  emp
WHERE
  deptno IN (10, 20)
ORDER BY 
  deptno, 
  SRLNO;

-- example 5
SELECT 
  empno, 
  deptno, 
  sal,
  RANK() OVER (PARTITION BY deptno ORDER BY sal DESC NULLS LAST) RANK,
  DENSE_RANK() OVER (PARTITION BY deptno ORDER BY sal DESC NULLS LAST) DENSE_RANK
FROM
  emp
WHERE
  deptno IN (10, 20)
ORDER BY 
  2,
  RANK;

-- example 6
SELECT
  deptno, 
  empno, 
  sal,
  LEAD(sal, 1, 0) OVER (PARTITION BY deptno ORDER BY sal DESC NULLS LAST) NEXT_LOWER_SAL,
  LAG(sal, 1, 0) OVER (PARTITION BY deptno ORDER BY sal DESC NULLS LAST) PREV_HIGHER_SAL
FROM
  emp
WHERE
  deptno IN (10, 20)
ORDER BY 
  deptno, 
  sal DESC;

-- example 7
-- How many days after the first hire of each department were the next
-- employees hired?
SELECT 
  empno, 
  deptno, 
  hiredate, 
  FIRST_VALUE(hiredate) OVER (PARTITION BY deptno ORDER BY hiredate) DAY_GAP
FROM
  emp
WHERE
  deptno IN (20, 30)
ORDER BY
  deptno, 
  DAY_GAP;

-- example 8
-- How each employee's salary compare with the average salary of the first
-- year hires of their department?
-- Not working!!
SELECT
  empno, 
  deptno, 
  TO_CHAR(hiredate,'YYYY') HIRE_YR, 
  sal
FROM emp
WHERE deptno IN (20, 10)
ORDER BY deptno, empno, HIRE_YR;

-- example 9
-- The query below has no apparent real life description (except 
-- column FROM_PU_C) but is remarkable in illustrating the various windowing
-- clause by a COUNT(*) function.
 
SELECT 
  empno, 
  deptno, 
  TO_CHAR(hiredate, 'YYYY') THE_YEAR,
  COUNT(*) OVER (PARTITION BY TO_CHAR(hiredate, 'YYYY') ORDER BY hiredate ROWS BETWEEN 3 PRECEDING AND 1 FOLLOWING) FROM_P3_TO_F1,
  COUNT(*) OVER (PARTITION BY TO_CHAR(hiredate, 'YYYY') ORDER BY hiredate ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) FROM_PU_TO_C,
  COUNT(*) OVER (PARTITION BY TO_CHAR(hiredate, 'YYYY') ORDER BY hiredate ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) FROM_P2_TO_P1,
  COUNT(*) OVER (PARTITION BY TO_CHAR(hiredate, 'YYYY') ORDER BY hiredate ROWS BETWEEN 1 FOLLOWING AND 3 FOLLOWING) FROM_F1_TO_F3
FROM
  emp
ORDER BY
  hiredate;

-- example 10
-- For each employee give the count of employees getting half more that their 
-- salary and also the count of employees in the departments 20 and 30 getting half 
-- less than their salary.
-- Does not work
/*
Oracle Version throws error
ERROR:  RANGE PRECEDING is only supported with UNBOUNDED
LINE 5:   COUNT(*) OVER (PARTITION BY deptno ORDER BY sal RANGE BETW...
*/
SELECT
  deptno, 
  empno, 
  sal,
  COUNT(*) OVER (PARTITION BY deptno ORDER BY sal RANGE BETWEEN UNBOUNDED PRECEDING AND (sal/2) PRECEDING) CNT_LT_HALF,
  COUNT(*) OVER (PARTITION BY deptno ORDER BY sal RANGE BETWEEN (sal/2) FOLLOWING AND UNBOUNDED FOLLOWING) CNT_MT_HALF
FROM
  emp
WHERE
  deptno IN (20, 30)
ORDER BY
  deptno, 
  sal;
  
