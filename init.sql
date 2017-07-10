CREATE TABLE `t_shorturl` (
  `c_id` int(11) NOT NULL AUTO_INCREMENT,
  `c_key` varchar(10) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `c_value` varchar(1000) NOT NULL,
  `c_remark` varchar(50) NOT NULL DEFAULT '',
  `c_add_dt` datetime NOT NULL,
  PRIMARY KEY (`c_id`),
  KEY `ix_key` (`c_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
