-- 数据库初始化脚本
-- 用于快速创建数据库和表结构

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `practice` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `practice`;

-- 删除已存在的表（如果存在）
DROP TABLE IF EXISTS `verification_codes`;
DROP TABLE IF EXISTS `error_records`;
DROP TABLE IF EXISTS `favorites`;
DROP TABLE IF EXISTS `answer_records`;
DROP TABLE IF EXISTS `questions`;
DROP TABLE IF EXISTS `users`;

-- 创建用户表
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `openid` varchar(255) DEFAULT NULL,
  `unionid` varchar(255) DEFAULT NULL,
  `phoneNumber` varchar(20) DEFAULT NULL,
  `nickName` varchar(100) DEFAULT NULL,
  `avatarUrl` varchar(500) DEFAULT NULL,
  `gender` int(11) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `province` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `isAdmin` tinyint(1) NOT NULL DEFAULT '0',
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `lastLoginTime` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `openid` (`openid`),
  UNIQUE KEY `phoneNumber` (`phoneNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建题目表
CREATE TABLE `questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(100) NOT NULL,
  `chapter` varchar(100) NOT NULL,
  `type` enum('单选题','多选题','判断题','填空题') NOT NULL,
  `difficulty` enum('简单','中等','困难') NOT NULL DEFAULT '中等',
  `content` text NOT NULL,
  `options` json DEFAULT NULL,
  `optionA` text,
  `optionB` text,
  `optionC` text,
  `optionD` text,
  `answer` varchar(255) NOT NULL,
  `analysis` text,
  `tags` varchar(500) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `createBy` int(11) DEFAULT NULL,
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建答题记录表
CREATE TABLE `answer_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userId` int(11) NOT NULL,
  `questionId` int(11) NOT NULL,
  `questionContent` text,
  `userAnswer` varchar(255) DEFAULT NULL,
  `correctAnswer` varchar(255) DEFAULT NULL,
  `isCorrect` tinyint(1) NOT NULL,
  `subject` varchar(100) DEFAULT NULL,
  `chapter` varchar(100) DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `timeSpent` int(11) DEFAULT NULL,
  `mode` enum('random','sequential','error','favorite') DEFAULT NULL,
  `sessionId` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建收藏表
CREATE TABLE `favorites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userId` int(11) NOT NULL,
  `questionId` int(11) NOT NULL,
  `questionContent` text,
  `subject` varchar(100) DEFAULT NULL,
  `chapter` varchar(100) DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `note` text,
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_question` (`userId`, `questionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建错题记录表
CREATE TABLE `error_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userId` int(11) NOT NULL,
  `questionId` int(11) NOT NULL,
  `questionContent` text,
  `userAnswer` varchar(255) DEFAULT NULL,
  `correctAnswer` varchar(255) DEFAULT NULL,
  `subject` varchar(100) DEFAULT NULL,
  `chapter` varchar(100) DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_question` (`userId`, `questionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建验证码表
CREATE TABLE `verification_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phoneNumber` varchar(20) NOT NULL,
  `code` varchar(10) NOT NULL,
  `used` tinyint(1) NOT NULL DEFAULT '0',
  `useTime` datetime DEFAULT NULL,
  `expireTime` datetime NOT NULL,
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 插入默认管理员用户
INSERT INTO `users` (`phoneNumber`, `nickName`, `isAdmin`, `status`, `lastLoginTime`) 
VALUES ('13800138000', '系统管理员', 1, 'active', NOW());

-- 插入一些示例题目
INSERT INTO `questions` (`subject`, `chapter`, `type`, `content`, `optionA`, `optionB`, `optionC`, `optionD`, `answer`, `analysis`, `difficulty`) VALUES
('计算机基础', '第一章', '单选题', '以下哪个是计算机的基本组成部分？', 'CPU', '鼠标', '键盘', '显示器', 'A', 'CPU是计算机的核心处理单元，是基本组成部分。', '简单'),
('计算机基础', '第一章', '单选题', 'RAM的全称是什么？', 'Random Access Memory', 'Read Access Memory', 'Real Access Memory', 'Remote Access Memory', 'A', 'RAM是随机存取存储器的缩写。', '中等'),
('计算机基础', '第二章', '判断题', 'CPU是计算机的大脑。', '正确', '错误', '', '', '正确', 'CPU负责执行指令和处理数据，是计算机的核心。', '简单'),
('网络技术', '第一章', '单选题', 'HTTP协议默认端口号是多少？', '80', '443', '21', '25', 'A', 'HTTP协议默认使用80端口。', '中等'),
('网络技术', '第一章', '单选题', 'HTTPS协议默认端口号是多少？', '80', '443', '21', '25', 'B', 'HTTPS协议默认使用443端口。', '中等');

-- 显示创建的表
SHOW TABLES;

-- 显示用户表数据
SELECT * FROM `users`;

-- 显示题目表数据
SELECT * FROM `questions`;
