--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

CREATE OR REPLACE FUNCTION pgtap_version()
RETURNS NUMERIC AS 'SELECT 0.91;'
LANGUAGE SQL IMMUTABLE;

CREATE OR REPLACE FUNCTION has_tablespace( NAME, TEXT, TEXT )
RETURNS TEXT AS $$
BEGIN
    IF pg_version_num() >= 90200 THEN
        RETURN ok(
            EXISTS(
                SELECT true
                  FROM pg_catalog.pg_tablespace
                 WHERE spcname = $1
                   AND pg_tablespace_location(oid) = $2
            ), $3
        );
    ELSE
        RETURN ok(
            EXISTS(
                SELECT true
                  FROM pg_catalog.pg_tablespace
                 WHERE spcname = $1
                   AND spclocation = $2
            ), $3
        );
    END IF;
END;
$$ LANGUAGE plpgsql;

