-- Drop Procedures and Functions if they exist
DROP FUNCTION IF EXISTS make_salt;
DROP FUNCTION IF EXISTS authenticate;
DROP PROCEDURE IF EXISTS sp_add_user;
DROP PROCEDURE IF EXISTS sp_change_password;

-- Generate a random salt for the user

CREATE FUNCTION make_salt(num_chars INT)
RETURNS VARCHAR(20) NOT DETERMINISTIC
BEGIN
    DECLARE salt VARCHAR(20) DEFAULT '';

    -- Don't want to generate more than 20 characters of salt.
    SET num_chars = LEAST(20, num_chars);

    -- Generate the salt!  Characters used are ASCII code 32 (space)
    -- through 126 ('z').
    WHILE num_chars > 0 DO
        SET salt = CONCAT(salt, CHAR(32 + FLOOR(RAND() * 95)));
        SET num_chars = num_chars - 1;
    END WHILE;

    RETURN salt;
END;

-- Procedure to add a new user to the user table

CREATE PROCEDURE sp_add_user(
    new_username VARCHAR(20), password VARCHAR(20), user_role VARCHAR(20))
BEGIN
    DECLARE new_salt CHAR(8);
    DECLARE new_hash BINARY(64);

    -- Generate a new salt and hash for the password.
    SET new_salt = make_salt(8);
    SET new_hash = SHA2(CONCAT(new_salt, password), 256);

    -- Insert the new user into the table.
    INSERT INTO user (username, password_hash, salt, user_role, date_joined)
    VALUES (new_username, new_hash, new_salt, user_role, CURDATE());
END;

-- Procedure to delete a user from the user table
DROP PROCEDURE IF EXISTS sp_delete_user;

CREATE PROCEDURE sp_delete_user(
    username VARCHAR(20), user_role VARCHAR(20))
BEGIN
    IF user_role = 'admin' THEN
        DELETE FROM user WHERE user.username = username;
    END IF;
END;

-- Procedure to update a user's role
DROP PROCEDURE IF EXISTS sp_update_user_role;

CREATE PROCEDURE sp_update_user_role(
    username VARCHAR(20), new_role VARCHAR(20))
BEGIN
    UPDATE user
    SET user_role = new_role
    WHERE user.username = username;
END;

-- Procedure to authenticate a user

CREATE FUNCTION authenticate(username VARCHAR(20), password VARCHAR(20))
RETURNS TINYINT DETERMINISTIC
BEGIN
  DECLARE user_salt CHAR(8);
  DECLARE user_hash BINARY(64);
  DECLARE given_hash BINARY(64);

  -- Get the salt and hash for the user.
  SELECT salt, password_hash INTO user_salt, user_hash
  FROM user
  WHERE user.username = username;

  -- If the user doesn't exist, return 0.
  IF user_salt IS NULL THEN
    RETURN 0;
  END IF;

  -- Hash the given password with the user's salt.
  SET given_hash = SHA2(CONCAT(user_salt, password), 256);

  -- Return 1 if the hashes match, 0 otherwise.
  RETURN user_hash = given_hash;
END;

-- Procedure to change a user's password

CREATE PROCEDURE sp_change_password(
  username VARCHAR(20), new_password VARCHAR(20))
BEGIN
  DECLARE new_salt CHAR(8);
  DECLARE new_hash BINARY(64);

  -- Generate a new salt and hash for the password.
  SET new_salt = make_salt(8);
  SET new_hash = SHA2(CONCAT(new_salt, new_password), 256);

  -- Update the user's salt and hash in the table.
  UPDATE user
  SET salt = new_salt, password_hash = new_hash
  WHERE user.username = username;
END;
