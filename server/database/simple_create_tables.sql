-- MySQL数据库表结构创建脚本（简化版）
-- 刷题小程序数据库表结构
-- 数据库名: practice

-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS `practice` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE `practice`;

-- 1. 用户表 (users)
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `openid` varchar(255) DEFAULT NULL COMMENT '微信openid',
  `unionid` varchar(255) DEFAULT NULL COMMENT '微信unionid',
  `phoneNumber` varchar(20) DEFAULT NULL COMMENT '手机号',
  `nickName` varchar(100) DEFAULT NULL COMMENT '用户昵称',
  `avatarUrl` varchar(500) DEFAULT NULL COMMENT '头像URL',
  `gender` int(11) DEFAULT NULL COMMENT '性别',
  `country` varchar(100) DEFAULT NULL COMMENT '国家',
  `province` varchar(100) DEFAULT NULL COMMENT '省份',
  `city` varchar(100) DEFAULT NULL COMMENT '城市',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `password` varchar(255) DEFAULT NULL COMMENT '密码（加密）',
  `isAdmin` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否为管理员',
  `status` enum('active','inactive') NOT NULL DEFAULT 'active' COMMENT '用户状态',
  `lastLoginTime` datetime DEFAULT NULL COMMENT '最后登录时间',
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `openid` (`openid`),
  UNIQUE KEY `phoneNumber` (`phoneNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 2. 题目表 (questions)
CREATE TABLE IF NOT EXISTS `questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '题目ID',
  `subject` varchar(100) NOT NULL COMMENT '科目',
  `chapter` varchar(100) NOT NULL COMMENT '章节',
  `type` enum('单选题','多选题','判断题','填空题') NOT NULL COMMENT '题目类型',
  `difficulty` enum('简单','中等','困难') NOT NULL DEFAULT '中等' COMMENT '难度等级',
  `content` text NOT NULL COMMENT '题目内容',
  `options` json DEFAULT NULL COMMENT '选项（JSON格式）',
  `optionA` text COMMENT '选项A',
  `optionB` text COMMENT '选项B',
  `optionC` text COMMENT '选项C',
  `optionD` text COMMENT '选项D',
  `answer` varchar(255) NOT NULL COMMENT '正确答案',
  `analysis` text COMMENT '解析',
  `tags` varchar(500) DEFAULT NULL COMMENT '标签（JSON格式）',
  `status` enum('active','inactive') NOT NULL DEFAULT 'active' COMMENT '题目状态',
  `createBy` int(11) DEFAULT NULL COMMENT '创建者ID',
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='题目表';

-- 3. 答题记录表 (answer_records)
CREATE TABLE IF NOT EXISTS `answer_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `userId` int(11) NOT NULL COMMENT '用户ID',
  `questionId` int(11) NOT NULL COMMENT '题目ID',
  `questionContent` text COMMENT '题目内容',
  `userAnswer` varchar(255) DEFAULT NULL COMMENT '用户答案',
  `correctAnswer` varchar(255) DEFAULT NULL COMMENT '正确答案',
  `isCorrect` tinyint(1) NOT NULL COMMENT '是否正确',
  `subject` varchar(100) DEFAULT NULL COMMENT '科目',
  `chapter` varchar(100) DEFAULT NULL COMMENT '章节',
  `timestamp` datetime DEFAULT NULL COMMENT '答题时间戳',
  `timeSpent` int(11) DEFAULT NULL COMMENT '答题用时（秒）',
  `mode` enum('random','sequential','error','favorite') DEFAULT NULL COMMENT '答题模式',
  `sessionId` varchar(255) DEFAULT NULL COMMENT '答题会话ID',
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户答题记录表';

-- 4. 收藏表 (favorites)
CREATE TABLE IF NOT EXISTS `favorites` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
  `userId` int(11) NOT NULL COMMENT '用户ID',
  `questionId` int(11) NOT NULL COMMENT '题目ID',
  `questionContent` text COMMENT '题目内容',
  `subject` varchar(100) DEFAULT NULL COMMENT '科目',
  `chapter` varchar(100) DEFAULT NULL COMMENT '章节',
  `timestamp` datetime DEFAULT NULL COMMENT '收藏时间戳',
  `note` text COMMENT '收藏备注',
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_question` (`userId`, `questionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收藏表';

-- 5. 错题记录表 (error_records)
CREATE TABLE IF NOT EXISTS `error_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '错题记录ID',
  `userId` int(11) NOT NULL COMMENT '用户ID',
  `questionId` int(11) NOT NULL COMMENT '题目ID',
  `questionContent` text COMMENT '题目内容',
  `userAnswer` varchar(255) DEFAULT NULL COMMENT '用户答案',
  `correctAnswer` varchar(255) DEFAULT NULL COMMENT '正确答案',
  `subject` varchar(100) DEFAULT NULL COMMENT '科目',
  `chapter` varchar(100) DEFAULT NULL COMMENT '章节',
  `timestamp` datetime DEFAULT NULL COMMENT '答题时间戳',
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_question` (`userId`, `questionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='错题记录表';

-- 6. 验证码表 (verification_codes)
CREATE TABLE IF NOT EXISTS `verification_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '验证码ID',
  `phoneNumber` varchar(20) NOT NULL COMMENT '手机号',
  `code` varchar(10) NOT NULL COMMENT '验证码',
  `used` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否已使用',
  `useTime` datetime DEFAULT NULL COMMENT '使用时间',
  `expireTime` datetime NOT NULL COMMENT '过期时间',
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='验证码表';

-- 插入默认管理员用户
INSERT INTO `users` (`phoneNumber`, `nickName`, `isAdmin`, `status`, `lastLoginTime`) 
VALUES ('13800138000', '系统管理员', 1, 'active', NOW())
ON DUPLICATE KEY UPDATE `nickName` = '系统管理员', `isAdmin` = 1;
