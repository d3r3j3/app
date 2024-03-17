-- Drop users if they exist
DROP USER IF EXISTS 'admin'@'localhost';
DROP USER IF EXISTS 'client'@'localhost';

-- Create admin and client user
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin';
CREATE USER 'client'@'localhost' IDENTIFIED BY 'client';

-- Grant privileges to admin and client user
GRANT ALL PRIVILEGES ON games.* TO 'admin'@'localhost';
GRANT SELECT ON games.* TO 'client'@'localhost';