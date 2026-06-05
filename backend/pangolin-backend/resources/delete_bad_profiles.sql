DELETE FROM profile
WHERE id IN (SELECT profile.id AS nitems FROM profile
LEFT JOIN profileimage ON profile.id = profileimage.userid
LEFT JOIN profiletextbox ON profile.id = profiletextbox.userid
GROUP BY profile.id
HAVING COUNT(*) <= 2)
