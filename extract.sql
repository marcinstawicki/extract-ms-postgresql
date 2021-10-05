CREATE SCHEMA s01_time_series;
CREATE TABLE s01_time_series.type_id (
id        UUID DEFAULT gen_random_uuid(),
type_id   SMALLINT NOT NULL,
PRIMARY KEY (id),
FOREIGN KEY (type_id) REFERENCES s01_time_series_type.identifier (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE s01_time_series.date_time (
id        UUID NOT NULL,
date_time   TIMESTAMP NOT NULL,
PRIMARY KEY (id),
FOREIGN KEY (id) REFERENCES s01_time_series.type_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE s01_time_series.open (
id        UUID NOT NULL,
open      DECIMAL(12,5) NOT NULL,
PRIMARY KEY (id),
FOREIGN KEY (id) REFERENCES s01_time_series.type_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE s01_time_series.close (
id        UUID NOT NULL,
close      DECIMAL(12,5) NOT NULL,
PRIMARY KEY (id),
FOREIGN KEY (id) REFERENCES s01_time_series.type_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE s01_time_series.low (
id        UUID NOT NULL,
low      DECIMAL(12,5) NOT NULL,
PRIMARY KEY (id),
FOREIGN KEY (id) REFERENCES s01_time_series.type_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE s01_time_series.high (
id        UUID NOT NULL,
high      DECIMAL(12,5) NOT NULL,
PRIMARY KEY (id),
FOREIGN KEY (id) REFERENCES s01_time_series.type_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE s01_time_series.volume (
id        UUID NOT NULL,
volume      DECIMAL(15,3) NOT NULL,
PRIMARY KEY (id),
FOREIGN KEY (id) REFERENCES s01_time_series.type_id (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);
--------------------------------------------------------------------
SELECT *
FROM (
         SELECT t01.type_id,
                t02.date_time,
                t03.open,
                t04.close,
                t05.low,
                t06.high,
                t07.volume
            FROM s01_time_series.type_id       AS t01
      INNER JOIN s01_time_series.date_time     AS t02 USING (id)
      INNER JOIN s01_time_series.open          AS t03 USING (id)
      INNER JOIN s01_time_series.close         AS t04 USING (id)
      INNER JOIN s01_time_series.low           AS t05 USING (id)
      INNER JOIN s01_time_series.high          AS t06 USING (id)
      INNER JOIN s01_time_series.volume        AS t07 USING (id)
      INNER JOIN s01_instrument.time_series_id AS t08 ON t07.id=t08.time_series_id
           WHERE t01.type_id=1
             AND t08.id=1
        ORDER BY t02.date_time DESC
           LIMIT 1000
     ) AS tt
ORDER BY tt.date_time ASC;
---------------------------------------------------------------------
SELECT t01.speech_sound,
           t02.parent_id,
           t03.path,
           t04.description,
           array_to_json(ARRAY(SELECT image FROM s08_en_ipa.image WHERE id=t01.id)) AS images,
           array_to_json(ARRAY(SELECT audio FROM s08_en_ipa.audio WHERE id=t01.id)) AS audios,
           array_to_json(ARRAY(SELECT video FROM s08_en_ipa.video WHERE id=t01.id)) AS videos,
           t05.rule_id,
           t06.content AS rule,
           array_to_json(ARRAY(
                   SELECT DISTINCT ON (s01.contents)
                       row_to_json(row(s01.id,
                           s01.contents,
                           s03.transcription,
                           s04.audio))
                   FROM s01_en_item.contents        AS s01
                              INNER JOIN s01_en_item.sense_id        AS s02 USING (id)
                              INNER JOIN s01_en_sense.transcription  AS s03 ON s02.sense_id=s03.id
                              INNER JOIN s01_en_sense.audio          AS s04 ON s03.id=s04.id
                              INNER JOIN s08_en_rule.s01_en_item_id     AS s05 ON s01.id=s05.s01_en_item_id
                                   WHERE s05.id=t05.rule_id
                                ORDER BY s01.contents
                            )) AS items
          FROM s08_en_ipa.speech_sound AS t01
    INNER JOIN s08_en_ipa.parent_id    AS t02 USING (id)
    INNER JOIN s08_en_ipa.path         AS t03 USING (id)
     LEFT JOIN s08_en_ipa.description  AS t04 USING (id)
    INNER JOIN s08_en_ipa.rule_id      AS t05 USING (id)
    INNER JOIN s08_en_rule.content     AS t06 ON t05.rule_id=t06.id
         WHERE t01.id
       BETWEEN 1
           AND 100;