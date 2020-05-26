CREATE DATABASE `web_kernel` ;

USE `web_kernel` ;

CREATE TABLE `UG` (
`u_id` INT UNSIGNED NOT NULL REFERENCES users(u_id),
`g_id` INT UNSIGNED NOT NULL REFERENCES groups(g_id)
) ENGINE = INNODB ;


CREATE TABLE `groups` (
`g_id` INT UNSIGNED NOT NULL PRIMARY KEY ,
`gname` VARCHAR( 200 ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL 
) ENGINE = INNODB ;

CREATE TABLE `users` (
`u_id` INT UNSIGNED NOT NULL ,
`user` VARCHAR( 200 ) NOT NULL ,
`pass` VARCHAR( 200 ) NOT NULL ,
PRIMARY KEY ( `u_id` ) 
) ENGINE = innodb;

CREATE TABLE `components` (
`comp_id` INT UNSIGNED NOT NULL ,
`class_name` VARCHAR( 200 ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL ,
PRIMARY KEY ( `comp_id` ) 
) ENGINE = INNODB ;

CREATE TABLE `value_types` (
`type_id` INT UNSIGNED NOT NULL PRIMARY KEY ,
`type` VARCHAR( 200 ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL 
) ENGINE = INNODB ;

CREATE TABLE `param_names` (
`par_id` INT UNSIGNED NOT NULL PRIMARY KEY ,
`par_name` VARCHAR( 200 ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL ,
`type_id` INT UNSIGNED NOT NULL REFERENCES value_types(type_id)
) ENGINE = INNODB ;

CREATE TABLE `permissions` (
`perm_id` INT UNSIGNED NOT NULL PRIMARY KEY ,
`perm_type` VARCHAR( 200 ) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL ,
`parental_control` TINYINT(1) NOT NULL DEFAULT '0'
) ENGINE = INNODB ;

CREATE TABLE `values` (
`conf_id` INT UNSIGNED NOT NULL,
`par_id` INT UNSIGNED NOT NULL REFERENCES param_names(par_id),
`v_id` INT UNSIGNED NOT NULL
) ENGINE = INNODB ;

CREATE TABLE `conf_page` (
`page_id` INT UNSIGNED NOT NULL REFERENCES pages(page_id) ,
`comp_id` INT UNSIGNED NOT NULL REFERENCES components(comp_id) ,
`conf_id` INT UNSIGNED NOT NULL REFERENCES `values`(conf_id)
) ENGINE = INNODB ;

CREATE TABLE `other` (
`conf_id` INT UNSIGNED NOT NULL REFERENCES `values`(conf_id),
`perm_id` INT UNSIGNED NOT NULL REFERENCES permissions(perm_id)
) ENGINE = INNODB ;

CREATE TABLE `u_perm` (
`conf_id` INT UNSIGNED NOT NULL REFERENCES `values`(conf_id),
`u_id` INT UNSIGNED NOT NULL REFERENCES users(u_id),
`perm_id` INT UNSIGNED NOT NULL REFERENCES permissions(perm_id)
) ENGINE = INNODB ;

CREATE TABLE `g_perm` (
`conf_id` INT UNSIGNED NOT NULL REFERENCES `values`(conf_id),
`g_id` INT UNSIGNED NOT NULL REFERENCES groups(g_id),
`perm_id` INT UNSIGNED NOT NULL REFERENCES permissions(perm_id)
) ENGINE = INNODB ;

CREATE TABLE `session` (
`s_id` INT UNSIGNED NOT NULL ,
`user` VARCHAR( 200 ) NOT NULL ,
`pass` VARCHAR( 200 ) NOT NULL ,
`entry` INT NOT NULL ,
`expiration` INT NOT NULL ,
PRIMARY KEY ( `s_id` ) 
) ENGINE = innodb;

ALTER TABLE `session` ADD `ip` VARCHAR( 70 ) NOT NULL AFTER `s_id` ;

REATE TABLE `comp_aliases` (
`comp_id` INT UNSIGNED NOT NULL ,
`compname_alias` INT NOT NULL ,
UNIQUE (
`comp_id` ,
`compname_alias` 
)
) ENGINE = innodb;

CREATE TABLE `conf_aliases` (
`comp_id` INT UNSIGNED NOT NULL ,
`conf_id` INT NOT NULL ,
`nameconf` VARCHAR( 200 ) NOT NULL ,
UNIQUE (
`comp_id` ,
`conf_id` 
)
) ENGINE = innodb;


CREATE TABLE `conf_parents` (
`conf_id` INT UNSIGNED NOT NULL ,
`par_conf_id` INT UNSIGNED NOT NULL 
) ENGINE = innodb;


CREATE TABLE `vals_array` (
`id` INT UNSIGNED NOT NULL ,
`a_id` INT UNSIGNED NOT NULL ,
`ord` INT UNSIGNED NOT NULL ,
`par_id` INT UNSIGNED NOT NULL ,
`v_id` INT UNSIGNED NOT NULL ,
UNIQUE (
`a_id` ,
`ord` 
)
) ENGINE = innodb;


CREATE TABLE `vals_dictionary` (
`id` INT UNSIGNED NOT NULL ,
`a_id` INT UNSIGNED NOT NULL ,
`dic_key` VARCHAR( 255 ) NOT NULL ,
`par_id` INT UNSIGNED NOT NULL ,
`v_id` INT UNSIGNED NOT NULL ,
UNIQUE (
`a_id` ,
`key` 
)
) ENGINE = innodb;



CREATE TABLE `vals_longstring` (
`v_id` INT UNSIGNED NOT NULL ,
`val` LONGTEXT NOT NULL ,
PRIMARY KEY ( `v_id` ) 
) ENGINE = innodb;

CREATE TABLE `seq_vid_int` (
`counter` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 
) ENGINE = innodb;

CREATE TABLE `seq_vid_string` (
`counter` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 
) ENGINE = innodb;

CREATE TABLE `seq_vid_longstring` (
`counter` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 
) ENGINE = innodb;


CREATE TABLE `seq_vid_array` (
`counter` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 
) ENGINE = innodb;

CREATE TABLE `seq_id_array` (
`counter` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 
) ENGINE = innodb;

CREATE TABLE `seq_vid_dictionary` (
`counter` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 
) ENGINE = innodb;

CREATE TABLE `seq_id_dictionary` (
`counter` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY 
) ENGINE = innodb;




