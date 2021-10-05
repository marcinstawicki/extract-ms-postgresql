<?php
/**
 * the variables need to be validated/transformed before being passed into the query
 */
$sql = <<<QUERY
        WITH q1 AS (INSERT INTO s00_person.gender_type_id   (gender_type_id) VALUES($genderTypeID) RETURNING id),
             q2 AS (INSERT INTO s00_person.forename         SELECT id, '$forename'      FROM q1 RETURNING id),
             q3 AS (INSERT INTO s00_person.surname          SELECT id, '$surname'       FROM q2 RETURNING id),
             q4 AS (INSERT INTO s00_person.email_address    SELECT id, '$emailAddress'  FROM q3 RETURNING id)
                    INSERT INTO s00_person.role_id          SELECT id,  $roleID         FROM q4 RETURNING id;
QUERY;
