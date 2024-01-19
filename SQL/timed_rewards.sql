SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for timed_rewards
-- ----------------------------
DROP TABLE IF EXISTS `timed_rewards`;
CREATE TABLE `timed_rewards`  (
  `Type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Item` int NOT NULL,
  `Amount` int NOT NULL,
  `Item1` int NOT NULL,
  `Amount1` int NOT NULL,
  `Item2` int NOT NULL,
  `Amount2` int NOT NULL,
  `Item3` int NOT NULL,
  `Amount3` int NOT NULL,
  PRIMARY KEY (`Type` DESC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of timed_rewards
-- ----------------------------
INSERT INTO `timed_rewards` VALUES ('Weekly', 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `timed_rewards` VALUES ('Daily', 0, 0, 0, 0, 0, 0, 0, 0);

SET FOREIGN_KEY_CHECKS = 1;
