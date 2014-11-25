DROP TABLE IF EXISTS `examples`;
CREATE TABLE `examples` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `json` blob,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=latin1;

LOCK TABLES `examples` WRITE;
INSERT INTO `examples` VALUES (1,'Przykład numer 1','{
	"criteria": [
		{
			"id": "C1",
			"name": "Kryterium 1"
		},
		{
			"id": "C2",
			"name": "Kryterium 2"
		}
	],
	"criteriaComparisonArray": [
		[
			"1",
			"1/9"
		],
		[
			"9",
			"1"
		]
	],
	"options": [
		{
			"id": "O1",
			"name": "BMW"
		},
		{
			"id": "O2",
			"name": "Mercedes"
		},
		{
			"id": "O3",
			"name": "Audi"
		}
	],
	"optionComparisonArrays": [
		{
			"criteriaId": "C1",
			"array": [
				[
					"1",
					"1/9",
					"1/5"
				],
				[
					"9",
					"1",
					"1/9"
				],
				[
					"5",
					"9",
					"1"
				]
			]
		},
		{
			"criteriaId": "C2",
			"array": [
				[
					"1",
					"9",
					"7"
				],
				[
					"1/9",
					"1",
					"5"
				],
				[
					"1/7",
					"1/5",
					"1"
				]
			]
		}
	]
}');
UNLOCK TABLES;
