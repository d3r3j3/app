-- Setup admin and client users

-- Create admin user (username: admin, password: admin, role: admin)
CALL sp_add_user('admin', 'admin', 'admin');

-- Create 1000 users and make 5000 random purchases
CALL sp_create_users(1000);
CALL sp_make_random_purchases(5000);