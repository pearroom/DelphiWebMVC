/*
Navicat MySQL Data Transfer

Source Server         : 127.0.0.1
Source Server Version : 50623
Source Host           : 127.0.0.1:3306
Source Database       : exam

Target Server Type    : MYSQL
Target Server Version : 50623
File Encoding         : 65001

Date: 2018-01-02 21:59:58
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `tb_users`
-- ----------------------------
DROP TABLE IF EXISTS `tb_users`;
CREATE TABLE `tb_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) DEFAULT NULL,
  `pwd` varchar(10) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `sex` int(1) DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `idcard` varchar(20) DEFAULT NULL,
  `address` varchar(100) DEFAULT NULL,
  `uptime` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of tb_users
-- ----------------------------
INSERT INTO `tb_users` VALUES ('1', 'admin', 'admin', '赵四', '0', '21', '15333210748', 'xxxxxxxx', 'xxxxx', '2017-12-04 08:46:23');
INSERT INTO `tb_users` VALUES ('2', 'admin1', 'admin1', '张三1', '1', '34', '15333210748', 'xxxxxxx', 'xxxx', '2017-12-04 08:46:25');
