CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_followers (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body VARCHAR(255) NOT NULL,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Matt', 'Graser'), ('Minsoo', 'Kim');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('Ocean','What color is the ocean?', (SELECT id FROM users WHERE lname = 'Graser' AND fname = 'Matt')),
  ('Grass','What color is grass?', (SELECT id FROM users WHERE lname = 'Kim' AND fname = 'Minsoo'));

INSERT INTO
  replies (body, question_id, parent_id, user_id)
VALUES
  ('Blue, dumbass!', (SELECT id FROM questions WHERE title = 'Ocean'), 
  NULL, (SELECT id FROM users WHERE lname = 'Kim' AND fname = 'Minsoo')),
  ('Green!', (SELECT id FROM questions WHERE title = 'Grass'), 
  NULL, (SELECT id FROM users WHERE lname = 'Graser' AND fname = 'Matt')),
  ("That's not very nice Minsoo!", (SELECT id FROM questions WHERE title = 'Ocean'), 
  1, (SELECT id FROM users WHERE lname = 'Graser' AND fname = 'Matt'));

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE lname = 'Graser' AND fname = 'Matt'), (SELECT id FROM questions WHERE title = 'Ocean')),
  ((SELECT id FROM users WHERE lname = 'Kim' AND fname = 'Minsoo'), (SELECT id FROM questions WHERE title = 'Ocean')),
  ((SELECT id FROM users WHERE lname = 'Kim' AND fname = 'Minsoo'), (SELECT id FROM questions WHERE title = 'Grass'));

INSERT INTO
  question_followers (user_id, question_id)
VALUES
  (1, 2), (1, 1);