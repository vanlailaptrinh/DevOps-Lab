--sudo -u postgres psql --

CREATE DATABASE pmacct_db;
CREATE USER pmacct_user WITH ENCRYPTED PASSWORD ‘<my-password>';
GRANT ALL PRIVILEGES ON DATABASE pmacct_db TO pmacct_user;

-- \c pmacct_db --

