-- __/\\\\\\\\\\\__/\\\\\_____/\\\__/\\\\\\\\\\\\\\\_____/\\\\\_________/\\\\\\\\\_________/\\\\\\\________/\\\\\\\________/\\\\\\\________/\\\\\\\\\\________________/\\\\\\\\\_______/\\\\\\\\\_____        
--  _\/////\\\///__\/\\\\\\___\/\\\_\/\\\///////////____/\\\///\\\_____/\\\///////\\\_____/\\\/////\\\____/\\\/////\\\____/\\\/////\\\____/\\\///////\\\_____________/\\\\\\\\\\\\\___/\\\///////\\\___       
--   _____\/\\\_____\/\\\/\\\__\/\\\_\/\\\_____________/\\\/__\///\\\__\///______\//\\\___/\\\____\//\\\__/\\\____\//\\\__/\\\____\//\\\__\///______/\\\_____________/\\\/////////\\\_\///______\//\\\__      
--    _____\/\\\_____\/\\\//\\\_\/\\\_\/\\\\\\\\\\\____/\\\______\//\\\___________/\\\/___\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\_________/\\\//_____________\/\\\_______\/\\\___________/\\\/___     
--     _____\/\\\_____\/\\\\//\\\\/\\\_\/\\\///////____\/\\\_______\/\\\________/\\\//_____\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\________\////\\\____________\/\\\\\\\\\\\\\\\________/\\\//_____    
--      _____\/\\\_____\/\\\_\//\\\/\\\_\/\\\___________\//\\\______/\\\______/\\\//________\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\___________\//\\\___________\/\\\/////////\\\_____/\\\//________   
--       _____\/\\\_____\/\\\__\//\\\\\\_\/\\\____________\///\\\__/\\\______/\\\/___________\//\\\____/\\\__\//\\\____/\\\__\//\\\____/\\\___/\\\______/\\\____________\/\\\_______\/\\\___/\\\/___________  
--        __/\\\\\\\\\\\_\/\\\___\//\\\\\_\/\\\______________\///\\\\\/______/\\\\\\\\\\\\\\\__\///\\\\\\\/____\///\\\\\\\/____\///\\\\\\\/___\///\\\\\\\\\/_____________\/\\\_______\/\\\__/\\\\\\\\\\\\\\\_ 
--         _\///////////__\///_____\/////__\///_________________\/////_______\///////////////_____\///////________\///////________\///////_______\/////////_______________\///________\///__\///////////////__

-- Your Name: Jack Sopher
-- Your Student Number: 1080325
-- By submitting, you declare that this work was completed entirely by yourself.

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1

SELECT forum.ID as forumID,topic,CreatedBY AS LecturerID
FROM forum
WHERE CreatedBy = ClosedBy;


-- END Q1
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2
SELECT lecturer.ID AS LecturerID,CONCAT(firstname,' ',lastname)
AS FullName,COUNT(forum.CreatedBy) AS NumOfForums
FROM user NATURAL JOIN lecturer
LEFT JOIN forum ON lecturer.ID = forum.CreatedBy
GROUP BY lecturer.ID;




-- END Q2
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3
	
    SELECT user.id AS UserID,username
	FROM user
	WHERE user.id NOT IN (SELECT user.id
		FROM user INNER JOIN post ON user.ID = post.PostedBy
        WHERE post.forum IS NOT null);



-- END Q3
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q4

SELECT post.id as PostID
FROM post
WHERE post.forum is not null AND post.id NOT IN (SELECT topPost.id
					  FROM post as topPost INNER JOIN
                      post as CommentPost on 
                      topPost.ID = CommentPost.ParentPost
                      UNION
                      SELECT post.id
                      FROM post INNER JOIN likepost
                      ON post.id=likepost.post);

-- END Q4
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q5
SELECT ID AS PostID,post.content AS Content,count(*) AS NumOfLikes
FROM post INNER JOIN likepost
ON post.id=likepost.post
GROUP BY post.id
HAVING COUNT(*) = (SELECT COUNT(*)
					FROM post INNER JOIN likepost
					ON post.id=likepost.post
					GROUP BY post.id
                    ORDER BY COUNT(*) DESC
                    LIMIT 1);
-- END Q5
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q6
SELECT LENGTH(post.Content) AS PostLength,Content,forum.Topic as ForumTopic,
CONCAT(FirstName,' ',LastName) AS FullName
FROM post INNER JOIN forum ON post.Forum = forum.ID
INNER JOIN user ON post.PostedBy = user.ID AND 
LENGTH(post.content) = (SELECT MAX(LENGTH(content))
							FROM post
                            WHERE post.forum IS NOT null
                            );


-- END Q6
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q7

SELECT student1 AS Student1ID,student2 AS Student2ID,
TIMESTAMPDIFF(DAY,WhenConfirmed,WhenUnfriended) AS NumOfDays
FROM friendof
WHERE TIMESTAMPDIFF(DAY,WhenConfirmed,WhenUnfriended) = 
(SELECT MIN(TIMESTAMPDIFF(DAY,WhenConfirmed,WhenUnfriended))
FROM friendof
);
										




-- END Q7
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q8


SELECT userlike.user AS UserWhoLiked,COUNT(otherlike.post) AS NumOfOtherLikes,userlike.post AS postID
FROM likepost AS userlike LEFT JOIN likepost AS otherlike
ON userlike.post=otherlike.post AND userlike.user!=otherlike.user
GROUP BY userlike.post,userlike.user;

-- END Q8
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q9

SELECT student.id as studentID
FROM student
Where student.id in 
	   (SELECT Student2
		FROM friendof INNER JOIN student as popular ON friendof.student1 = popular.id
		INNER JOIN student as friend ON friendof.Student2 = friend.id
		WHERE Student1 = 
		    (SELECT student.ID
			 FROM likepost INNER JOIN post ON likepost.post = post.Id 
			 INNER JOIN student ON post.PostedBy = student.ID 
			 GROUP BY post.postedby
			 ORDER BY COUNT(*) DESC
			 LIMIT 1)
		AND popular.Degree=friend.Degree 
		AND friendof.WhenConfirmed is not null And friendof.WhenUnfriended is null
		UNION
		SELECT Student1
		FROM friendof INNER JOIN student as popular ON friendof.student2 = popular.id
		INNER JOIN student as friend ON friendof.Student1 = friend.id
		WHERE Student2 =
			(SELECT student.ID
			 FROM likepost INNER JOIN post ON likepost.post = post.Id 
			 INNER JOIN student ON post.PostedBy = student.ID 
			 GROUP BY post.postedby
			 ORDER BY COUNT(*) DESC
			 LIMIT 1)
		AND popular.Degree=friend.Degree 
		AND friendof.WhenConfirmed is not null And friendof.WhenUnfriended is null);
                    
                                    

-- END Q9
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q10


SELECT post.id as postID,post.whenposted as WhenPosted
FROM post INNER JOIN user on post.postedby =user.id
INNER JOIN student ON student.id=user.Id
Where post.forum is not null AND post.PostedBy=student.id
AND post.id not in 
    (SELECT toplevel.id
	FROM post as toplevel INNER JOIN post as reply ON toplevel.id=reply.parentpost
    INNER JOIN forum ON toplevel.forum=forum.Id
	WHERE TIMESTAMPDIFF(HOUR,toplevel.WhenPosted,reply.WhenPosted)<=48
	AND forum.createdby = reply.PostedBy);


-- END Q10
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- END OF ASSIGNMENT Do not write below this line