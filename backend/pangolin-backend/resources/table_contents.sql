\copy profile (id, name, location, bio, wallbackgroundhexargb, profileimageurl) FROM 'profile.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');

\copy profileImage (id, userid, url, x, y, rotation, aspectratio, scale) FROM 'profileImage.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');

\copy profileTextbox(id, userid, title, body, font, fontargb, backgroundargb, x, y, rotation, aspectratio, scale) FROM 'profileTextbox.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');

\copy profileSticker(id, userid, name, x, y, rotation, aspectratio, scale) FROM 'profileSticker.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');

