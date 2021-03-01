/*
SQLyog Ultimate v12.5.0 (64 bit)
MySQL - 5.7.32 : Database - crm
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`crm` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `crm`;

/*Table structure for table `department` */

DROP TABLE IF EXISTS `department`;

CREATE TABLE `department` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sn` varchar(50) COLLATE utf8_bin DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_bin DEFAULT NULL,
  `mananger_id` bigint(20) DEFAULT NULL,
  `parent_id` bigint(20) DEFAULT NULL,
  `state` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*Data for the table `department` */

insert  into `department`(`id`,`sn`,`name`,`mananger_id`,`parent_id`,`state`) values 
(1,'boss','总经办',NULL,NULL,NULL),
(2,'market','市场部',NULL,NULL,NULL),
(3,'business','业务部',NULL,NULL,NULL);

/*Table structure for table `emp_role` */

DROP TABLE IF EXISTS `emp_role`;

CREATE TABLE `emp_role` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `r_id` bigint(20) DEFAULT NULL,
  `e_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_m_emp` (`e_id`),
  KEY `FK_m_role` (`r_id`),
  CONSTRAINT `FK_m_emp` FOREIGN KEY (`e_id`) REFERENCES `employee` (`id`),
  CONSTRAINT `FK_m_role` FOREIGN KEY (`r_id`) REFERENCES `role` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8;

/*Data for the table `emp_role` */

insert  into `emp_role`(`id`,`r_id`,`e_id`) values 
(18,7,39),
(22,6,1),
(23,7,1),
(24,6,38),
(25,7,38),
(26,7,40),
(29,7,2);

/*Table structure for table `employee` */

DROP TABLE IF EXISTS `employee`;

CREATE TABLE `employee` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8_bin DEFAULT NULL,
  `realname` varchar(50) COLLATE utf8_bin DEFAULT NULL,
  `password` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  `tel` varchar(13) COLLATE utf8_bin DEFAULT NULL,
  `email` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  `dept_id` bigint(20) DEFAULT NULL,
  `inputtime` date DEFAULT NULL,
  `state` tinyint(1) DEFAULT NULL,
  `admin` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_dept` (`dept_id`),
  CONSTRAINT `FK_dept` FOREIGN KEY (`dept_id`) REFERENCES `department` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

/*Data for the table `employee` */

insert  into `employee`(`id`,`username`,`realname`,`password`,`tel`,`email`,`dept_id`,`inputtime`,`state`,`admin`) values 
(1,'admin','然锅','123','19800000000','xxxxxx@xx.com',1,'2020-01-01',1,1),
(2,'test01','张三','123','15100000000','test01@xx.com',2,'2020-07-14',1,0),
(38,'ran','然锅','123','19800000000','xxxxxx@xx.com',2,'2020-11-10',1,0),
(39,'test02','李四','123','13100000000','xxxxxx@xx.com',2,'2020-10-05',0,0),
(40,'test','测试','123','13100000000','test000@qq.com',3,'2020-10-13',1,0);

/*Table structure for table `log` */

DROP TABLE IF EXISTS `log`;

CREATE TABLE `log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `opUser_id` bigint(20) DEFAULT NULL,
  `opTime` datetime DEFAULT NULL,
  `opIp` varchar(255) DEFAULT NULL,
  `function` varchar(255) DEFAULT NULL,
  `params` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_log` (`opUser_id`),
  CONSTRAINT `FK_log` FOREIGN KEY (`opUser_id`) REFERENCES `employee` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=316 DEFAULT CHARSET=utf8;

/*Data for the table `log` */

/*Table structure for table `menu` */

DROP TABLE IF EXISTS `menu`;

CREATE TABLE `menu` (
  `id` bigint(20) NOT NULL,
  `text` varchar(100) DEFAULT NULL COMMENT '菜单名称',
  `iconCls` varchar(100) DEFAULT NULL,
  `checked` tinyint(1) DEFAULT NULL,
  `state` varchar(10) DEFAULT NULL,
  `attributes` varchar(500) DEFAULT NULL COMMENT '点击当前菜单请求的url',
  `parent_id` bigint(20) DEFAULT NULL,
  `function` varchar(255) DEFAULT NULL COMMENT '决定当前菜单能不能被展示',
  PRIMARY KEY (`id`),
  KEY `FK_parent` (`parent_id`),
  CONSTRAINT `FK_parent` FOREIGN KEY (`parent_id`) REFERENCES `menu` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `menu` */

insert  into `menu`(`id`,`text`,`iconCls`,`checked`,`state`,`attributes`,`parent_id`,`function`) values 
(1,'系统管理',NULL,NULL,NULL,NULL,NULL,NULL),
(2,'员工管理',NULL,NULL,NULL,'{\"url\": \"/employee\"}',1,'com.ran.web.controller.EmployeeController:index'),
(3,'部门管理',NULL,NULL,NULL,'{\"url\": \"/department\"}',1,'com.ran.web.controller.DepartmentController:index'),
(4,'营销管理',NULL,NULL,NULL,NULL,NULL,NULL),
(5,'潜在客户管理',NULL,NULL,NULL,NULL,4,NULL),
(6,'角色管理',NULL,NULL,NULL,'{\"url\": \"/role\"}',1,'com.ran.web.controller.RoleController:index'),
(7,'权限管理',NULL,NULL,NULL,'{\"url\": \"/permission\"}',1,'com.ran.web.controller.PermissionController:index');

/*Table structure for table `permission` */

DROP TABLE IF EXISTS `permission`;

CREATE TABLE `permission` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `resource` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

/*Data for the table `permission` */

insert  into `permission`(`id`,`name`,`resource`) values 
(1,'员工新增','com.ran.web.controller.EmployeeController:save'),
(2,'员工更新','com.ran.web.controller.EmployeeController:update'),
(3,'员工删除','com.ran.web.controller.EmployeeController:delete'),
(4,'角色页面','com.ran.web.controller.RoleController:index'),
(5,'员工页面','com.ran.web.controller.EmployeeController:index'),
(6,'部门页面','com.ran.web.controller.DepartmentController:index'),
(7,'权限页面','com.ran.web.controller.PermissionController:index');

/*Table structure for table `role` */

DROP TABLE IF EXISTS `role`;

CREATE TABLE `role` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `sn` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

/*Data for the table `role` */

insert  into `role`(`id`,`name`,`sn`) values 
(6,'超级管理员','001'),
(7,'普通管理员','002');

/*Table structure for table `role_permission` */

DROP TABLE IF EXISTS `role_permission`;

CREATE TABLE `role_permission` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `r_id` bigint(20) DEFAULT NULL,
  `p_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_role` (`r_id`),
  KEY `FK_permission` (`p_id`),
  CONSTRAINT `FK_permission` FOREIGN KEY (`p_id`) REFERENCES `permission` (`id`),
  CONSTRAINT `FK_role` FOREIGN KEY (`r_id`) REFERENCES `role` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8;

/*Data for the table `role_permission` */

insert  into `role_permission`(`id`,`r_id`,`p_id`) values 
(27,6,1),
(28,6,2),
(29,6,3),
(30,6,4),
(31,6,5),
(32,6,6),
(33,6,7),
(34,7,1),
(35,7,2),
(36,7,5),
(37,7,6),
(38,7,7),
(39,7,4);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
