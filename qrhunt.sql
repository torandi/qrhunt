PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE tags(id int, code varchar(32), points smallint, name varchar(128));
CREATE TABLE users(id int, name varchar(32));
CREATE UNIQUE INDEX tags_id on tags ( id );
CREATE UNIQUE INDEX tags_code on tags ( code );
CREATE UNIQUE INDEX users_id on users (id);
CREATE UNIQUE INDEX users_name on users (name );
COMMIT;
