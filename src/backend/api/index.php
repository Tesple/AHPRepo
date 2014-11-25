<?php

require 'Slim/Slim.php';

$app = new Slim();

$app->get('/examples', 'getExamples');
$app->get('/examples/:id',	'getExample');
$app->get('/example-names', 'getExampleNames');
$app->post('/examples', 'addExample');
$app->put('/examples/:id', 'updateExample');
$app->delete('/examples/:id',	'deleteExample');

$app->run();

function getExamples() {
	$sql = "select * FROM examples ORDER BY name";
	try {
		$db = getConnection();
		$stmt = $db->query($sql);  
		$examples = $stmt->fetchAll(PDO::FETCH_OBJ);
		$db = null;
		echo '{"example": ' . json_encode($examples) . '}';
	} catch(PDOException $e) {
		echo '{"error":{"text":'. $e->getMessage() .'}}'; 
	}
}

function getExample($id) {
	$sql = "SELECT * FROM examples WHERE id=:id";
	try {
		$db = getConnection();
		$stmt = $db->prepare($sql);  
		$stmt->bindParam("id", $id);
		$stmt->execute();
		$example = $stmt->fetchObject();
		$db = null;
		echo json_encode($example);
	} catch(PDOException $e) {
		echo '{"error":{"text":'. $e->getMessage() .'}}'; 
	}
}

function addExample() {
	error_log('addExample\n', 3, '/var/tmp/php.log');
	$request = Slim::getInstance()->request();
	$example = json_decode($request->getBody());
	$sql = "INSERT INTO examples (name, json) VALUES (:name, :json)";
	try {
		$db = getConnection();
		$stmt = $db->prepare($sql);  
		$stmt->bindParam("name", $example->name);
		$stmt->bindParam("json", $example->json);
		$stmt->execute();
		$example->id = $db->lastInsertId();
		$db = null;
		echo json_encode($example);
	} catch(PDOException $e) {
		error_log($e->getMessage(), 3, '/var/tmp/php.log');
		echo '{"error":{"text":'. $e->getMessage() .'}}'; 
	}
}

function updateExample($id) {
	$request = Slim::getInstance()->request();
	$body = $request->getBody();
	$example = json_decode($body);
	$sql = "UPDATE examples SET name=:name, json=:json WHERE id=:id";
	try {
		$db = getConnection();
		$stmt = $db->prepare($sql);  
		$stmt->bindParam("name", $example->name);
		$stmt->bindParam("json", $example->json);
		$stmt->bindParam("id", $id);
		$stmt->execute();
		$db = null;
		echo json_encode($example);
	} catch(PDOException $e) {
		echo '{"error":{"text":'. $e->getMessage() .'}}'; 
	}
}

function deleteExample($id) {
	$sql = "DELETE FROM examples WHERE id=:id";
	try {
		$db = getConnection();
		$stmt = $db->prepare($sql);  
		$stmt->bindParam("id", $id);
		$stmt->execute();
		$db = null;
	} catch(PDOException $e) {
		echo '{"error":{"text":'. $e->getMessage() .'}}'; 
	}
}

function getExampleNames() {
	$sql = "select id, name FROM examples ORDER BY name";
	try {
		$db = getConnection();
		$stmt = $db->query($sql);
		$examples = $stmt->fetchAll(PDO::FETCH_OBJ);
		$db = null;
		echo '{"example": ' . json_encode($examples) . '}';
	} catch(PDOException $e) {
		echo '{"error":{"text":'. $e->getMessage() .'}}'; 
	}
}

function getConnection() {
	$dbhost="127.0.0.1";
	$dbuser="root";
	$dbpass="";
	$dbname="ahpdb";
	$dbh = new PDO("mysql:host=$dbhost;dbname=$dbname", $dbuser, $dbpass);	
	$dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	return $dbh;
}

?>