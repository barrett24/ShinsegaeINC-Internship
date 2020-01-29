-----DDL
CREATE TABLE TABLE_NAME AS SUBQUERY;
-- NOT NULL
CREATE TABLE TEST_TBL(
	ID	VARCHAR2(20) NOT NULL , -- 컬럼레벨의 제약조건
	PWD	VARCHAR2(20) 
);

SELECT * FROM TEST_TBL;
DROP TABLE TEST_TBL;

CREATE TABLE TEST_TBL(
	ID	VARCHAR(20) ,
	PWD	VARCHAR(20) ,
	NOT NULL (ID)		-- 테이블 레벨의 제약조건 / NOT NULL은 테이블레벨의 제약이 불가능하다
);

CREATE TABLE TEST_TBL(
	ID	VARCHAR(20) CONSTRAINT TEST_TBL_NN NOT NULL,	-- FULL 문법
	PWD	VARCHAR(20) 
);

--PRIMARY KEY : NOT NULL 과 UNIQUE 동시만족

------DML
-- INSERT 
:::: INSERT INTO TABLE_NAME([COLUMN, COLUMN]) VALUES(VALUE, VALUE);
:::: INSERT INTO TABLE_NAME AS SUBQUERY;
:::: CREATE TABLE TABLE_NAME AS SUBQUERY; (변수 선언과 초기화 같은 스타일)

INSERT INTO TEST_TBL VALUES('SYCHOI', 'SIYOUNG');
INSERT INTO TEST_TBL(PWD) VALUES('TEST');

CREATE TABLE TEST_DEPT(
	DEPT_ID		NUMBER PRIMARY KEY,
	DEPT_NAME	VARCHAR2(20) NOT NULL
);
SELECT * FROM TEST_DEPT;
DROP TABLE TEST_DEPT CASCADE CONSTRAINT ; -- 관계가 있는 테이블이랑은 관계가 끊어짐, CASCADE로 부모삭제가능

CREATE TABLE TEST_EMP(
	EMP_ID		NUMBER PRIMARY KEY,
	SALARY		NUMBER,
	DEPT_ID		NUMBER REFERENCES TEST_DEPT(DEPT_ID)
);
SELECT * FROM TEST_EMP;
DROP TABLE TEST_EMP CASCADE CONSTRAINT ;
CREATE TABLE TEST_EMP(
	EMP_ID		NUMBER PRIMARY KEY,
	SALARY		NUMBER,
	DEPT_ID		NUMBER,
	FOREIGN KEY (DEPT_ID) REFERENCES TEST_DEPT(DEPT_ID)
);

-- COMPOSIT PRIMARY KEY, REFERENCES
CREATE TABLE TEST_ORDERS(
	ORDERNO		VARCHAR2(50) PRIMARY KEY,
	ADDRESS		VARCHAR2(50),
	STATUS		VARCHAR2(50) CHECK (STATUS IN ('상품준비중', '배송중', '배송완료')) -- 연산자, 범위 등을 지정하여 값을 한정지을 수 있다
);

CREATE TABLE TEST_PRODUCTS(
	PNO		VARCHAR2(50) PRIMARY KEY,
	PNAME	VARCHAR2(50) NOT NULL,
	COST	NUMBER		 CHECK (COST > 100)
);

CREATE TABLE TEST_ORDERDETAIL(
	ORDERNO		VARCHAR2(50) REFERENCES TEST_ORDERS(ORDERNO),
	PNO			VARCHAR2(50) REFERENCES TEST_PRODUCTS(PNO),
	QTY			NUMBER,
	PRIMARY KEY (ORDERNO, PNO) -- 두개이상의 기본키를 정의할 때는 테이블 영역에서 
);
CREATE TABLE TEST_ORDERDETAIL(
	ORDERNO		VARCHAR2(50),
	PNO			VARCHAR2(50),
	QTY			NUMBER,
	PRIMARY KEY (ORDERNO, PNO), -- 두개이상의 기본키를 정의할 때는 테이블 영역에서 
	FOREIGN KEY (ORDERNO) REFERENCES TEST_ORDERS(ORDERNO),
	FOREIGN KEY (PNO) REFERENCES TEST_PRODUCTS(PNO)
);
SELECT * FROM TEST_ORDERDETAIL;
DROP TABLE TEST_ORDERDETAIL;

CREATE TABLE TEST_ODD(
	NUM			NUMBER PRIMARY KEY,
	ORDERNO		VARCHAR2(50),
	PNO			VARCHAR2(50),
	FOREIGN KEY (ORDERNO, PNO) REFERENCES TEST_ORDERDETAIL(ORDERNO, PNO) -- 같은테이블로부터 전이된 외래키들은 데이블레벨에서 한번에 지정해주어야한다
);


-- 제약조건 모음집
CREATE TABLE CONSTRAINT_EMP (
	EID			CHAR(3) 		CONSTRAINT PKEID 	PRIMARY KEY,
	ENAME		VARCHAR2(20) 	CONSTRAINT NENAME 	NOT NULL,
	ENO			CHAR(14) 		CONSTRAINT NENO 	NOT NULL CONSTRAINT UENO UNIQUE,
	EMAIL		VARCHAR2(25) 	CONSTRAINT UEMAIL 	UNIQUE,
	PHONE		VARCHAR2(12),
	HIRE_DATE	DATE 			DEFAULT SYSDATE,
	JID			CHAR(2) 		CONSTRAINT FKJID 	REFERENCES JOB ON DELETE SET NULL,
	SALARY		NUMBER,
	BONUS_PCT	NUMBER,
	MARRIAGE	CHAR(1) 		DEFAULT 'N' CONSTRAINT CHK CHECK (MARRIAGE IN ('Y', 'N')),
	MID			CHAR(3) 		CONSTRAINT FKMID REFERENCES CONSTRAINT_EMP ON DELETE SET NULL,
	DID			CHAR(2),
	CONSTRAINT KFDID FOREIGN KEY (DID) REFERENCES DEPARTMENT ON DELETE CASCADE
);


-- 서브쿼리를 사용한 테이블 생성
CREATE TABLE TABLE_SUBQUERY2 (EID, ENAME, SALARY DNAME, JTITLE)
AS	SELECT 	EMP_ID, EMP_NAME, SALARY, DEPT_NAME, JOB_TITLE
	FROM	EMPLOYEE
	LEFT JOIN	DEPARTMENT USING (DEPT_ID)
	LEFT JOIN 	JOB USING (JOB_ID);

CREATE TABLE TABLE_SUBQUERY3
(	EID PRIMARY KEY,
	ENAME,
	SALARY CHECK (SALARY >= 1500000), -- 테이블 생성 시점에 제약을 걸어줄 수 있다 단, 서브쿼리에서 범위를 위반하는 값이 있다면 오류
	DNAME,
	JTITLE )
AS	SELECT 	EMP_ID, EMP_NAME, SALARY, DEPT_NAME, JOB_TITLE
	FROM	EMPLOYEE
	LEFT JOIN	DEPARTMENT USING (DEPT_ID)
	LEFT JOIN 	JOB USING (JOB_ID);

SELECT * FROM TABLE_SUBQUERY3;

CREATE TABLE EMP3 AS SELECT * FROM EMPLOYEE;

ALTER TABLE EMP3
ADD PRIMARY KEY (EMP_ID)
ADD UNIQUE (EMP_NO)
MODIFY HIRE_DATE NOT NULL; -- 모디파이를 통해 NOT NULL 설정 (ADD로는 불가)

SELECT * FROM EMP3;

SELECT ROWNUM, EMP_NAME, SALARY
FROM	(	SELECT	NVL(DEPT_ID, 'N\A') AS "Did",
					ROUND(AVG(SALARY), -3) AS "Davg"
			FROM	EMPLOYEE
			GROUP BY DEPT_ID) INLV
JOIN	EMPLOYEE ON (NVL(DEPT_ID, 'N/A') = INLV."Did")
WHERE	SALARY > INLV."Davg";

SELECT ROWNUM, EMP_NAME, SALARY
FROM	(	SELECT	NVL(DEPT_ID, 'N\A') AS "Did",
					ROUND(AVG(SALARY), -3) AS "Davg"
			FROM	EMPLOYEE
			GROUP BY DEPT_ID) INLV
JOIN	EMPLOYEE ON (NVL(DEPT_ID, 'N/A') = INLV."Did")
WHERE	SALARY > INLV."Davg"
ORDER BY 3 DESC; -- ROWNUM이 흐트러지면 TOP N 분석이 안된다

SELECT ROWNUM, EMP_NAME, SALARY
FROM	(	SELECT	NVL(DEPT_ID, 'N\A') AS "Did",
					ROUND(AVG(SALARY), -3) AS "Davg"
			FROM	EMPLOYEE
			GROUP BY DEPT_ID) INLV
JOIN	EMPLOYEE ON (NVL(DEPT_ID, 'N/A') = INLV."Did")
WHERE	SALARY > INLV."Davg"
AND		ROWNUM = 1; 

SELECT ROWNUM, EMP_NAME, SALARY
FROM	(	SELECT	NVL(DEPT_ID, 'N\A') AS "Did",
					ROUND(AVG(SALARY), -3) AS "Davg"
			FROM	EMPLOYEE
			GROUP BY DEPT_ID) INLV
JOIN	EMPLOYEE ON (NVL(DEPT_ID, 'N/A') = INLV."Did")
WHERE	SALARY > INLV."Davg"
AND		ROWNUM = 1; 


SELECT	ROWNUM, EMP_NAME, SALARY
FROM ( SELECT ROWNUM, EMP_NAME, SALARY
		FROM	(	SELECT	NVL(DEPT_ID, 'N\A') AS "Did",
					ROUND(AVG(SALARY), -3) AS "Davg"
					FROM	EMPLOYEE
					GROUP BY DEPT_ID) INLV
		JOIN	EMPLOYEE ON (NVL(DEPT_ID, 'N/A') = INLV."Did")
		WHERE	SALARY > INLV."Davg"
		ORDER BY 3 DESC)
WHERE	ROWNUM <= 5;

SELECT	RANK(2300000) WITHIN GROUP (ORDER BY SALARY DESC) AS RANK
FROM	EMPLOYEE;

SELECT	EMP_NAME, SALARY,
		RANK() OVER (ORDER BY SALARY DESC) AS RANK
FROM	EMPLOYEE;

CREATE	SEQUENCE SEQ_EMP_ID
START WITH 300
INCREMENT BY 5
MAXVALUE 310
NOCYCLE
NOCACHE;	-- 미리 메모리에 생성하지 않음

SELECT SEQ_EMP_ID.NEXTVAL FROM DUAL;


















