--------------------------------- Indexes

01.

-- Before create Index

EXPLAIN ANALYZE SELECT * FROM posts WHERE category = 'Travel ';

-- Add Index

CREATE INDEX posts_category ON posts (category);

-- After create Index

EXPLAIN ANALYZE SELECT * FROM posts WHERE category = 'Travel';

SELECT * FROM posts;

-- Create CLUSTER index because I want to categorized posts

CLUSTER posts USING posts_category;



SELECT * FROM users WHERE age = 25;

02.

-- Before create Index

EXPLAIN ANALYZE SELECT * FROM users WHERE age = 25; 


CREATE INDEX users_age ON users (age);

--After create Index

EXPLAIN ANALYZE SELECT * FROM users WHERE age = 25;

--Create CLUSTER index

CLUSTER users USING users_age;

INSERT INTO users (username, email, password, age) VALUES
('amali_senanayake', 'amali.senanayake@example.com', 'amaliSecure123', 28),
('nuwan_karunaratne', 'nuwan.karuna@lanka.com', 'nuwanPass2024', 35),
('sanju_perera', 'sanju.perera@example.com', 'sanju_789', 31),
('tharushi_wijeratne', 'tharushi.wije@xyz.com', 'tharushi2024!', 26),
('lakmal_silva', 'lakmal.silva@lanka.com', 'lakmal_456', 29),
('poojitha_gunasekara', 'poojitha.guna@xyz.com', 'poojitha@secure', 37),
('udaya_ranasinghe', 'udaya.ranasinghe@lanka.com', 'udaya123!', 40),
('himali_abeywardena', 'himali.abey@example.com', 'himaliPass789', 24),
('nimesha_fernando', 'nimesha.fernando@lanka.com', 'nimeshaSecure2024', 27),
('kavindu_dassanayake', 'kavindu.dass@xyz.com', 'kavindu007', 30);

INSERT INTO users (username, email, password, age) VALUES
('dinesh_fernando', 'dinesh.fernando@lanka.com', 'dinesh2024!', 33),
('rashmi_silva', 'rashmi.silva@xyz.com', 'rashmiPass456', 29),
('anjali_perera', 'anjali.perera@lanka.com', 'anjaliSecure2023', 26),
('kamal_wijesekera', 'kamal.wije@xyz.com', 'kamal1234', 38),
('ishara_jayasinghe', 'ishara.jayasinghe@lanka.com', 'isharaPass@2024', 31);

SELECT * FROM users;

SELECT * FROM comments;

03.

-- Before create Index

EXPLAIN ANALYZE SELECT * FROM comments WHERE post_id = 30; 


CREATE INDEX comments_post_id ON comments (post_id);

--After create Index

EXPLAIN ANALYZE SELECT * FROM comments WHERE post_id = 30;

--Create CLUSTER index

CLUSTER comments USING comments_post_id;

SELECT * FROM comments;

04.

---- Secondary Index

CREATE INDEX comments_user_id ON comments (user_id);

SELECT * FROM comments WHERE user_id = 5;

-------------------------------------------------------------------------------

------------------------ Functions

01.

CREATE OR REPLACE FUNCTION most_engaged_age_group()
RETURNS TABLE (
    age_group TEXT,
    total_comments BIGINT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE
            WHEN age BETWEEN 13 AND 17 THEN 'Teen (13-17)'
            WHEN age BETWEEN 18 AND 24 THEN 'Young Adult (18-24)'
            WHEN age BETWEEN 25 AND 34 THEN 'Adult (25-34)'
            WHEN age BETWEEN 35 AND 44 THEN 'Middle Age (35-44)'
            WHEN age BETWEEN 45 AND 54 THEN 'Older Adult (45-54)'
            ELSE 'Senior (55+)'
        END AS age_group,
        COUNT(comments.id) AS total_comments
    FROM users
    INNER JOIN comments ON users.id = comments.user_id
    GROUP BY age_group
    ORDER BY total_comments DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM most_engaged_age_group();

----------------- 02 

CREATE OR REPLACE FUNCTION get_comments_by_post(post_id_param INT)
RETURNS TABLE (
    comment_id INT,
    user_id INT,
    content TEXT,
    created_at TIMESTAMP
)
AS $$
BEGIN
    RETURN QUERY
    SELECT c.id, c.user_id, c.content, c.created_at 
    FROM comments c  -- Alias
    WHERE c.post_id = post_id_param
    ORDER BY c.created_at DESC;  
END;
$$ LANGUAGE plpgsql;


SELECT * FROM get_comments_by_post(12);

--------------- 03

CREATE OR REPLACE FUNCTION count_comments_by_user(user_id_param INT)
RETURNS INT AS $$
DECLARE
	total_comments INT;
BEGIN
	SELECT COUNT(*) INTO total_comments FROM comments
	WHERE user_id = user_id_param;
	RETURN total_comments;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION count_comments_by_user(user_id_param INT)
RETURNS INT AS $$
DECLARE
    total_comments INT;
BEGIN
    SELECT COUNT(*) INTO total_comments 
    FROM comments
    WHERE user_id = user_id_param;  
    RETURN total_comments;
END;
$$ LANGUAGE plpgsql;


SELECT count_comments_by_user(10);

------------ 04 

CREATE OR REPLACE FUNCTION get_comments_by_date_range(start_date TIMESTAMP, end_date TIMESTAMP)
RETURNS TABLE (
	comment_id INT,
	user_id INT,
	post_id INT,
	content TEXT,
	created_at TIMESTAMP
)
AS $$
BEGIN
	RETURN QUERY
	SELECT 
		comments.id AS comment_id, 
		comments.user_id, 
		comments.post_id, 
		comments.content, 
		comments.created_at
	FROM comments
	WHERE comments.created_at BETWEEN start_date AND end_date
	ORDER BY comments.created_at;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM get_comments_by_date_range('2024-11-15 00:00:00', '2024-12-15 23:59:59');
-------------------------------------------------------------------------------------------

------------------------- Procedures

-------------- 01

--------Create new table name delete comment and truncate the delete comments that table

CREATE TABLE delete_comments(
	id SERIAL PRIMARY KEY,
	comment_id INT NOT NULL,
	user_id INT NOT NULL,
	post_id INT,
	content TEXT,
	created_at TIMESTAMP,
	delete_at TIMESTAMP DEFAULT NOW()
);

--------Create procedure delete comments

CREATE OR REPLACE PROCEDURE delete_comment(comment_id INT) AS $$
BEGIN

-----insert the delete comment in the delete table

INSERT INTO delete_comments (comment_id, user_id, post_id, content, created_at)
SELECT id, user_id, post_id, content, created_at
FROM comments WHERE id = comment_id;

----Delete comment from original comment table
DELETE FROM comments WHERE id = comment_id;
END;
$$ LANGUAGE plpgsql;

CALL delete_comment(40);

SELECT * FROM delete_comments;

---------------------- 02

CREATE OR REPLACE PROCEDURE add_user(
	username TEXT,
	email TEXT,
	password TEXT,
	age INT
)
AS $$
BEGIN
	INSERT INTO users(username, email, password, age)
	VALUES (username, email, password, age);
END;
$$ LANGUAGE plpgsql;

CALL add_user('Matheesha Pathirana', 'mathessha@gmail.com', 'ma990', 25);

CALL add_user('Udara Lakmal Rathnayaka', 'ulrathnayake@gmail.com', 'ulr234', 25);
 
SELECT * FROM users;

--------------------- 03

CREATE OR REPLACE PROCEDURE add_comment(
	user_id INT,
	post_id INT,
	content TEXT
) 
AS $$
BEGIN
	INSERT INTO comments (user_id, post_id, content, created_at)
	VALUES (user_id, post_id, content, NOW());
END;
$$ LANGUAGE plpgsql;

CALL add_comment(2,10, 'This is amazing');

ALTER TABLE comments
ALTER COLUMN id SET DEFAULT nextval('comments_id_seq');

SELECT MAX(id) FROM comments;

SELECT setval('comments_id_seq', (SELECT MAX(id) FROM comments));

SELECT * FROM comments;
-----------------------------------------------------------------------------


-------------------------- Triggers


----------------- 01 

CREATE OR REPLACE FUNCTION notify_on_new_comment() RETURNS TRIGGER
AS $$
BEGIN
	-- Notify the post owner
	INSERT INTO notifications (user_id, message, created_at)
	VALUES(
		(SELECT user_id FROM posts WHERE id = NEW.post_id),
		'Your post received a new comment',
		NOW()
	);

	-- Notify the commenter
	INSERT INTO notifications (user_id, message, created_at)
	VALUES(
		NEW.user_id,  -- The user who made the comment
		'You commented on a post',
		NOW()
	);

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER comment_notification_trigger
AFTER INSERT ON comments
FOR EACH ROW
EXECUTE FUNCTION notify_on_new_comment();

SELECT * FROM notifications;

-- Insert a new comment

INSERT INTO comments (user_id, post_id, content, created_at)
VALUES (2, 5, 'This is a new comment', NOW());

INSERT INTO comments (user_id, post_id, content, created_at)
VALUES (5, 1, 'This is a new comment', NOW());

INSERT INTO comments (user_id, post_id, content, created_at)
VALUES (30, 15, 'Great Post', NOW());

SELECT * FROM comments;

SELECT * FROM notifications;


---------------- 02 Trigger

CREATE OR REPLACE FUNCTION notify_on_new_like()
RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO notifications (user_id, message, created_at)
	VALUES (
		(SELECT user_id FROM posts WHERE id = NEW.post_id),
		'Your post received a new like',
		NOW()
	);
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER like_notification
AFTER INSERT ON likes
FOR EACH ROW
EXECUTE FUNCTION notify_on_new_like();

INSERT INTO likes (user_id, post_id, created_at)
VALUES (20, 10, NOW());



-------------------- 02 Trigger

CREATE OR REPLACE FUNCTION notify_on_new_like() RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO notifications(user_id, message, created_at) 
	VALUES (
			(SELECT user_id FROM posts WHERE id = NEW.post_id),
			'Your post received a new like',
			NOW()
	);
	RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;

	CREATE TRIGGER like_notification
	AFTER INSERT ON likes
	FOR EACH ROW
	EXECUTE FUNCTION notify_on_new_like();

SELECT * FROM likes;
SELECT * FROM notifications;


	------------------------ Transactions

	BEGIN;

	--Insert a like into the like table

	INSERT INTO likes (user_id, post_id) VALUES (30, 10);

	-----Insert a notification for the post owner
	INSERT INTO notifications(user_id, message, created_at)
	VALUES (
		(SELECT user_id FROM posts WHERE id = 30),
		'Someone liked your post',
		NOW()
	);

	COMMIT;

	SELECT * FROM likes;

	SELECT * FROM notifications; 

-------------------------------------------------------------------------






