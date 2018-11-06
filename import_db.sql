PRAGMA foreign_keys = ON;
DROP TABLE IF EXISTS questions;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  f_name TEXT NOT NULL,
  l_name TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  associated_author INTEGER,
  
  FOREIGN KEY (associated_author) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER,
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,
    
  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(parent_id) REFERENCES replies(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER,
  
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES question(id)
  
);

INSERT INTO
  users (f_name, l_name)
VALUES
  ('Savio', 'Rodrigues'),
  ('Jerrick', 'Shaw');
  
INSERT INTO
  questions (title, body, associated_author)
VALUES
  ('How do you use SQL?', 'I''m having trouble with SQL. Can anyone please help?', 2),
  ('How do you set up an ORM DB?', 'The video was hard to follow.', 1);
  
INSERT INTO
  question_follows (user_id, question_id)
VALUES
  (1,2),
  (1,1),
  (2,1),
  (2,2);
  
INSERT INTO
  replies (question_id, user_id, parent_id, body)
VALUES
  (2,2,NULL,'I''m having a hard time myself'),
  (1,1,NULL,'Watch the videos from W3D1.'),
  (2,1,1,'I''m glad I''m not the only one.');
  
INSERT INTO 
  question_likes (user_id, question_id)
VALUES
  (1,1),
  (2,2);
  
  
  
  
  
