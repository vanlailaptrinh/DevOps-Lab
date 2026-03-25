CREATE TABLE acct_v4 (
agent_id INT NOT NULL DEFAULT 0, 
ip_src INET NOT NULL DEFAULT '0.0.0.0',
 	ip_dst INET NOT NULL DEFAULT '0.0.0.0',
ip_proto SMALLINT NOT NULL DEFAULT 0,
packets INT NOT NULL, 
bytes BIGINT NOT NULL,
stamp_inserted TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
stamp_updated TIMESTAMP WITHOUT TIME ZONE,
country_ip_src CHAR(2) NOT NULL DEFAULT '--',
country_ip_dst CHAR(2) NOT NULL DEFAULT '--',
PRIMARY KEY (agent_id, ip_src, ip_dst, ip_proto, stamp_inserted)  
);

GRANT ALL PRIVILEGES ON TABLE acct_v4 TO pmacct_user;
