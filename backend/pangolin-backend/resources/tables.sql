-- create uint4 for colour storage (as ARGB value)
CREATE DOMAIN uint4 AS int8
  CHECK(VALUE >= 0 AND VALUE < 4294967296);

CREATE TABLE account (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  username text NOT NULL
);

CREATE TABLE profile (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  accountId integer NOT NULL REFERENCES account (id) ON DELETE CASCADE,
  name text NOT NULL,
  location text NOT NULL,
  bio text NOT NULL,
  wallBackgroundHexARGB uint4 NOT NULL,
  profileImageUrl text NOT NULL
);

CREATE TABLE wallImage (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  profileId integer NOT NULL REFERENCES profile (id) ON DELETE CASCADE,
  url text NOT NULL,
  x integer NOT NULL,
  y integer NOT NULL,
  rotation double precision NOT NULL,
  aspectRatio double precision NOT NULL,
  scale double precision NOT NULL
);

CREATE TABLE wallTextbox (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  profileId integer NOT NULL REFERENCES profile (id) ON DELETE CASCADE,
  title text NOT NULL,
  body text NOT NULL,
  font text, -- NB: this is nullable. may want to change.
  fontARGB uint4 NOT NULL,
  backgroundARGB uint4 NOT NULL,
  x integer NOT NULL,
  y integer NOT NULL,
  rotation double precision NOT NULL,
  aspectRatio double precision NOT NULL,
  scale double precision NOT NULL
);

CREATE TABLE wallSticker (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  profileId integer NOT NULL REFERENCES profile (id) ON DELETE CASCADE,
  name text NOT NULL,
  x integer NOT NULL,
  y integer NOT NULL,
  rotation double precision NOT NULL,
  aspectRatio double precision NOT NULL,
  scale double precision NOT NULL
);
