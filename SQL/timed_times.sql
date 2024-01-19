SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for timed_times
-- ----------------------------
DROP TABLE IF EXISTS `timed_times`;
CREATE TABLE `timed_times`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `daily` int NOT NULL,
  `weekly` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
