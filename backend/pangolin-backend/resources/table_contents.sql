-------- COPY OVER FROM THE CSVS ------

\copy account (id, username) FROM 'account.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');

\copy profile (id, accountid, name, location, bio, wallbackgroundhexargb, profileimageurl, age) FROM 'profile.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');

\copy wallImage (id, profileid, url, x, y, rotation, aspectratio, scale) FROM 'wallImage.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');

\copy wallTextbox(id, profileid, title, body, font, fontargb, backgroundargb, x, y, rotation, aspectratio, scale) FROM 'wallTextbox.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');

\copy wallSticker(id, profileid, name, x, y, rotation, aspectratio, scale) FROM 'wallSticker.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');

\copy userHobbyInfo(id, accountid, hobby, passionlevel, subinterests, otherinterests) FROM 'userHobbyInfo.csv' WITH(FORMAT csv, DELIMITER ',', HEADER, ENCODING 'UTF8', QUOTE '"', ESCAPE '''');




------- SET THE NEXT INDEX VALUE FOR CORRECT AUTO INCREMENT OF ID -----

SELECT setval(
    pg_get_serial_sequence('account', 'id'),
    COALESCE((SELECT MAX(id) FROM account), 0) + 1,
    false
);

SELECT setval(
    pg_get_serial_sequence('profile', 'id'),
    COALESCE((SELECT MAX(id) FROM profile), 0) + 1,
    false
);

SELECT setval(
    pg_get_serial_sequence('wallImage', 'id'),
    COALESCE((SELECT MAX(id) FROM wallImage), 0) + 1,
    false
);

SELECT setval(
    pg_get_serial_sequence('wallTextbox', 'id'),
    COALESCE((SELECT MAX(id) FROM wallTextbox), 0) + 1,
    false
);

SELECT setval(
    pg_get_serial_sequence('wallSticker', 'id'),
    COALESCE((SELECT MAX(id) FROM wallSticker), 0) + 1,
    false
);

SELECT setval(
    pg_get_serial_sequence('userHobbyInfo', 'id'),
    COALESCE((SELECT MAX(id) FROM userHobbyInfo), 0) + 1,
    false
);


