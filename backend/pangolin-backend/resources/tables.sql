-- create uint4 for colour storage (as ARGB value)
CREATE DOMAIN uint4 AS int8
  CHECK(VALUE >= 0 AND VALUE < 4294967296);

CREATE TABLE account (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  username text NOT NULL UNIQUE
);

CREATE TABLE profile (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  accountId integer NOT NULL UNIQUE REFERENCES account (id) ON DELETE CASCADE,
  name text NOT NULL,
  location text NOT NULL,
  bio text NOT NULL,
  wallBackgroundHexARGB uint4 NOT NULL,
  profileImageUrl text NOT NULL,
  age integer NOT NULL
);

CREATE TABLE userHobbyInfo(
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  accountId integer NOT NULL UNIQUE REFERENCES account (id) ON DELETE CASCADE,
  hobby text NOT NULL,
  passionlevel double precision NOT NULL,
  subinterests text[] NOT NULL,
  otherinterests text[] NOT NULL
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

CREATE TABLE buttonLog (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  userId integer NOT NULL,
  buttonId text NOT NULL,
  pressTimestamp bigint NOT NULL
);

CREATE TABLE sharedBoard (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  user1Id integer NOT NULL REFERENCES account (id) ON DELETE CASCADE,
  user2Id integer NOT NULL REFERENCES account (id) ON DELETE CASCADE,
  CONSTRAINT different_users CHECK (user1Id <> user2Id)
);

CREATE TABLE sharedBoardElement (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  boardId integer NOT NULL REFERENCES sharedBoard (id) ON DELETE CASCADE,
  url text,
  text text,
  timestamp bigint NOT NULL,
  senderId integer NOT NULL REFERENCES account (id) ON DELETE CASCADE,
  read boolean NOT NULL,
  CONSTRAINT image_xor_text CHECK ((url IS NULL AND text IS NOT NULL) OR (url IS NOT NULL and text IS NULL))
);

CREATE TABLE sharedBoardReply (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  sharedBoardElementId integer NOT NULL REFERENCES sharedBoardElement (id) ON DELETE CASCADE,
  text text NOT NULL,
  timestamp bigint NOT NULL,
  senderId integer NOT NULL REFERENCES account (id) ON DELETE CASCADE,
  read boolean
);
