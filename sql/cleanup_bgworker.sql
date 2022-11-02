CREATE TABLE aqo_test0(a int, b int, c int, d int);
WITH RECURSIVE t(a, b, c, d)
AS (
   VALUES (0, 0, 0, 0)
   UNION ALL
   SELECT t.a + 1, t.b + 1, t.c + 1, t.d + 1 FROM t WHERE t.a < 2000
) INSERT INTO aqo_test0 (SELECT * FROM t);
CREATE INDEX aqo_test0_idx_a ON aqo_test0 (a);
ANALYZE aqo_test0;

CREATE EXTENSION aqo;
SET aqo.join_threshold = 0;
SET aqo.mode = 'learn';
SET aqo.cleanup_bgworker = 'true';

EXPLAIN SELECT t1.a, t2.b FROM aqo_test0 AS t1, aqo_test0 AS t2
WHERE t1.a < 1 AND t1.b < 1 AND t2.c < 1 AND t2.d < 1;

-- Test 1 : delete 1 out of 1 entry
SELECT count(*) FROM aqo_queries;
DROP TABLE aqo_test0;

CREATE TABLE IF NOT EXISTS aqo_test0(a int, b int, c int, d int);
WITH RECURSIVE t(a, b, c, d)
AS (
   VALUES (0, 0, 0, 0)
   UNION ALL
   SELECT t.a + 1, t.b + 1, t.c + 1, t.d + 1 FROM t WHERE t.a < 2000
) INSERT INTO aqo_test0 (SELECT * FROM t);
CREATE INDEX aqo_test0_idx_a ON aqo_test0 (a);
ANALYZE aqo_test0;

CREATE TABLE aqo_test1(a int, b int);
WITH RECURSIVE t(a, b)
AS (
   VALUES (1, 2)
   UNION ALL
   SELECT t.a + 1, t.b + 1 FROM t WHERE t.a < 20
) INSERT INTO aqo_test1 (SELECT * FROM t);
CREATE INDEX aqo_test1_idx_a ON aqo_test1 (a);
ANALYZE aqo_test1;

SELECT count(*) FROM aqo_queries;

EXPLAIN SELECT * FROM aqo_test0
WHERE a < 3 AND b < 3 AND c < 3 AND d < 3;

EXPLAIN SELECT * FROM aqo_test1
WHERE a < 4 AND b < 4;

-- Test2: Must delete 1 out of 2 entries
SELECT count(*) FROM aqo_queries;
DROP TABLE aqo_test1;

CREATE TABLE IF NOT EXISTS aqo_test1(a int, b int);
WITH RECURSIVE t(a, b)
AS (
   VALUES (1, 2)
   UNION ALL
   SELECT t.a + 1, t.b + 1 FROM t WHERE t.a < 20
) INSERT INTO aqo_test1 (SELECT * FROM t);
CREATE INDEX aqo_test1_idx_a ON aqo_test1 (a);
ANALYZE aqo_test1;

SELECT count(*) FROM aqo_queries;

EXPLAIN SELECT * FROM aqo_test0
WHERE a < 3 AND b < 3 AND c < 3 AND d < 3;

EXPLAIN SELECT * FROM aqo_test1
WHERE a < 4 AND b < 4;

-- Test3: delete 2 out of 2 entries
SELECT count(*) FROM aqo_queries;
DROP TABLE aqo_test0;
DROP TABLE aqo_test1;
SELECT count(*) FROM aqo_queries;

SET aqo.cleanup_bgworker = 'false';
DROP EXTENSION aqo;
