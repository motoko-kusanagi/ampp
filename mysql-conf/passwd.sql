UPDATE mysql.user SET password=PASSWORD("my-new-password") WHERE User='root';
FLUSH PRIVILEGES;