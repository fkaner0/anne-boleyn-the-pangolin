\copy account (id, username) FROM 'account.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');

\copy profile (id, accountid, name, location, bio, wallbackgroundhexargb, profileimageurl, age) FROM 'profile.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');

\copy wallImage (id, profileid, url, x, y, rotation, aspectratio, scale) FROM 'wallImage.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');

\copy wallTextbox(id, profileid, title, body, font, fontargb, backgroundargb, x, y, rotation, aspectratio, scale) FROM 'wallTextbox.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');

\copy wallSticker(id, profileid, name, x, y, rotation, aspectratio, scale) FROM 'wallSticker.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');

