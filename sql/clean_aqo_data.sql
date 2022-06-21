CREATE EXTENSION aqo;
SET aqo.join_threshold = 0;
SET aqo.mode = 'learn';

DROP TABLE IF EXISTS a;
DROP TABLE IF EXISTS b;
CREATE TABLE a();
SELECT * FROM a;
SELECT 'a'::regclass::oid AS a_oid \gset
SELECT aqo_cleanup();

/*
 * lines with a_oid in aqo_data,
 * lines with fspace_hash corresponding to a_oid in aqo_queries,
 * lines with queryid corresponding to a_oid's fspace_hash in aqo_query_texts,
 * lines with queryid corresponding to a_oid's fspace_hash in aqo_query_stat
 * should remain
 */
SELECT count(*) FROM aqo_data WHERE :a_oid=ANY(oids);
SELECT count(*) FROM aqo_queries WHERE
    aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :a_oid=ANY(oids));
SELECT count(*) FROM aqo_query_texts WHERE
    aqo_query_texts.queryid = ANY(SELECT aqo_queries.queryid FROM aqo_queries WHERE
        aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :a_oid=ANY(oids)));
SELECT count(*) FROM aqo_query_stat WHERE
    aqo_query_stat.queryid = ANY(SELECT aqo_queries.queryid FROM aqo_queries WHERE
        aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :a_oid=ANY(oids)));

DROP TABLE a;
SELECT aqo_cleanup();

/*
 * lines with a_oid in aqo_data,
 * lines with a_oid's fspace_hash EQUAL TO queryid in aqo_queries,
 * lines with queryid corresponding to a_oid's fspace_hash in aqo_query_texts,
 * lines with queryid corresponding to a_oid's fspace_hash in aqo_query_stat,
 * should be deleted
*/
SELECT count(*) FROM aqo_data WHERE :a_oid=ANY(oids);
SELECT count(*) FROM aqo_queries WHERE
    aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :a_oid=ANY(oids)) AND
        aqo_queries.fspace_hash = aqo_queries.queryid;
SELECT count(*) FROM aqo_query_texts WHERE
    aqo_query_texts.queryid = ANY(SELECT aqo_queries.queryid FROM aqo_queries WHERE
        aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :a_oid=ANY(oids)) AND
            aqo_queries.fspace_hash = aqo_queries.queryid);
SELECT count(*) FROM aqo_query_stat WHERE
    aqo_query_stat.queryid = ANY(SELECT aqo_queries.queryid FROM aqo_queries WHERE
        aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :a_oid=ANY(oids)) AND
            aqo_queries.fspace_hash = aqo_queries.queryid);

CREATE TABLE a();
SELECT * FROM a;
SELECT 'a'::regclass::oid AS a_oid \gset
-- add manually line with different fspace_hash and queryid to aqo_queries
INSERT INTO aqo_queries VALUES (:a_oid + 1, 't', 't', :a_oid, 'f');
DROP TABLE a;
SELECT aqo_cleanup();
-- this line should remain
SELECT count(*) FROM aqo_queries WHERE (fspace_hash = :a_oid AND queryid = :a_oid + 1);

CREATE TABLE a();
CREATE TABLE b();
SELECT * FROM a;
SELECT * FROM b;
SELECT * FROM b CROSS JOIN a;
SELECT 'a'::regclass::oid AS a_oid \gset
SELECT 'b'::regclass::oid AS b_oid \gset

-- new lines added to aqo_data
SELECT count(*) FROM aqo_data WHERE :a_oid=ANY(oids);
SELECT count(*) FROM aqo_queries WHERE
    aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :a_oid=ANY(oids));
SELECT count(*) FROM aqo_query_texts WHERE
    aqo_query_texts.queryid = ANY(SELECT aqo_queries.queryid FROM aqo_queries WHERE
        aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :a_oid=ANY(oids)));
SELECT count(*) FROM aqo_query_stat WHERE
    aqo_query_stat.queryid = ANY(SELECT aqo_queries.queryid FROM aqo_queries WHERE
        aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :a_oid=ANY(oids)));

SELECT count(*) FROM aqo_data WHERE :b_oid=ANY(oids);
SELECT count(*) FROM aqo_queries WHERE
    aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :b_oid=ANY(oids));
SELECT count(*) FROM aqo_query_texts WHERE
    aqo_query_texts.queryid = ANY(SELECT aqo_queries.queryid FROM aqo_queries WHERE
        aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :b_oid=ANY(oids)));
SELECT count(*) FROM aqo_query_stat WHERE
    aqo_query_stat.queryid = ANY(SELECT aqo_queries.queryid FROM aqo_queries WHERE
        aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :b_oid=ANY(oids)));

DROP TABLE a;
SELECT aqo_cleanup();

/*
 * lines corresponding to a_oid and both a_oid's fspace_hash deleted in aqo_data,
 * lines with fspace_hash corresponding to a_oid deleted in aqo_queries,
 * lines with queryid corresponding to a_oid's fspace_hash deleted in aqo_query_texts,
 * lines with queryid corresponding to a_oid's fspace_hash deleted in aqo_query_stat,
 */
SELECT count(*) FROM aqo_data WHERE :a_oid=ANY(oids);
SELECT count(*) FROM aqo_queries WHERE
    aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :a_oid=ANY(oids)) AND
        aqo_queries.fspace_hash = aqo_queries.queryid;
SELECT count(*) FROM aqo_query_texts WHERE
    aqo_query_texts.queryid = ANY(SELECT aqo_queries.queryid FROM aqo_queries WHERE
        aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :a_oid=ANY(oids)) AND
            aqo_queries.fspace_hash = aqo_queries.queryid);
SELECT count(*) FROM aqo_query_stat WHERE
    aqo_query_stat.queryid = ANY(SELECT aqo_queries.queryid FROM aqo_queries WHERE
        aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :a_oid=ANY(oids)) AND
            aqo_queries.fspace_hash = aqo_queries.queryid);

-- lines corresponding to b_oid in all theese tables should remain
SELECT count(*) FROM aqo_data WHERE :b_oid=ANY(oids);
SELECT count(*) FROM aqo_queries WHERE
    aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :b_oid=ANY(oids)) AND
        aqo_queries.fspace_hash = aqo_queries.queryid;
SELECT count(*) FROM aqo_query_texts WHERE
    aqo_query_texts.queryid = ANY(SELECT aqo_queries.queryid FROM aqo_queries WHERE
        aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :b_oid=ANY(oids)) AND
            aqo_queries.fspace_hash = aqo_queries.queryid);
SELECT count(*) FROM aqo_query_stat WHERE
    aqo_query_stat.queryid = ANY(SELECT aqo_queries.queryid FROM aqo_queries WHERE
        aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :b_oid=ANY(oids)) AND
            aqo_queries.fspace_hash = aqo_queries.queryid);

DROP TABLE b;
SELECT aqo_cleanup();

-- lines corresponding to b_oid in theese tables deleted
SELECT count(*) FROM aqo_data WHERE :b_oid=ANY(oids);
SELECT count(*) FROM aqo_queries WHERE
    aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :b_oid=ANY(oids)) AND
        aqo_queries.fspace_hash = aqo_queries.queryid;
SELECT count(*) FROM aqo_query_texts WHERE
    aqo_query_texts.queryid = ANY(SELECT aqo_queries.queryid FROM aqo_queries WHERE
        aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :b_oid=ANY(oids)) AND
            aqo_queries.fspace_hash = aqo_queries.queryid);
SELECT count(*) FROM aqo_query_stat WHERE
    aqo_query_stat.queryid = ANY(SELECT aqo_queries.queryid FROM aqo_queries WHERE
        aqo_queries.fspace_hash = ANY(SELECT aqo_data.fs FROM aqo_data WHERE :b_oid=ANY(oids)) AND
            aqo_queries.fspace_hash = aqo_queries.queryid);

DROP EXTENSION aqo;