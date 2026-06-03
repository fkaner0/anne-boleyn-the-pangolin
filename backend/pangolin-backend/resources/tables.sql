CREATE TABLE profile (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  name text NOT NULL,
  location text NOT NULL,
  profileImageUrl text NOT NULL,
);

CREATE TABLE profileImage (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  userId integer NOT NULL REFERENCES profile (id) ON DELETE CASCADE,
  url text NOT NULL,
  x integer NOT NULL,
  y integer NOT NULL,
  rotation integer NOT NULL,
  aspectRatio double precision NOT NULL,
  scale double precision NOT NULL,
);

CREATE TABLE profileTextbox (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  userId integer NOT NULL REFERENCES profile (id) ON DELETE CASCADE,
  title text NOT NULL,
  body text NOT NULL,
  x integer NOT NULL,
  y integer NOT NULL,
  rotation integer NOT NULL,
  aspectRatio double precision NOT NULL,
  scale double precision NOT NULL,
);

CREATE TABLE profileSticker (
  id integer PRIMARY KEY NOT NULL GENERATED ALWAYS AS IDENTITY,
  userId integer NOT NULL REFERENCES profile (id) ON DELETE CASCADE,
  stickerName text NOT NULL,
  x integer NOT NULL,
  y integer NOT NULL,
  rotation integer NOT NULL,
  aspectRatio double precision NOT NULL,
  scale double precision NOT NULL,
);

COPY profileImage
FROM 'profileImage.csv'
WITH (
    FORMAT csv,
    HEADER true
);

COPY profileTextbox
FROM 'profileTextbox.csv'
WITH (
    FORMAT csv,
    HEADER true
);

COPY profileSticker
FROM 'profileSticker.csv'
WITH (
    FORMAT csv,
    HEADER true
);
