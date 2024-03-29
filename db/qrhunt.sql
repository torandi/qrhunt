PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE tags(id INTEGER PRIMARY KEY AUTOINCREMENT, code varchar(32), points smallint, name varchar(128));
CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name varchar(32), key varchar(32));
CREATE TABLE tags_users (tag_id INTEGER, user_id INTEGER);
CREATE UNIQUE INDEX tags_code on tags ( code );
CREATE UNIQUE INDEX users_name on users (name );
COMMIT;
