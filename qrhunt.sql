PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE codes(id int, code varchar(32), point smallint);
CREATE TABLE users(id int, name varchar(32));
CREATE UNIQUE INDEX codes_id on codes ( id );
CREATE UNIQUE INDEX codes_code on codes ( code );
CREATE UNIQUE INDEX users_id on users (id);
CREATE UNIQUE INDEX users_name on users (name );
COMMIT;
