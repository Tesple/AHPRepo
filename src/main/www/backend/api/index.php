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
	$request = Slim::getInstance()->request();
    $body = $request->getBody();
    $body = json_decode($body);
    $example = $body->example;

	$sql = "INSERT INTO examples (name, json) VALUES (:name, :json)";
	try {
	    $json = json_encode($example->json);
		$db = getConnection();
		$stmt = $db->prepare($sql);  
		$stmt->bindParam("name", $example->name);
		$stmt->bindParam("json", $json);
		$stmt->execute();
		$example->id = $db->lastInsertId();
		$db = null;
		echo json_encode($example);
	} catch(PDOException $e) {
		echo '{"error":{"text":'. $e->getMessage() .'}}'; 
	}
}

function updateExample($id) {
    $request = Slim::getInstance()->request();
    $body = $request->getBody();
    $body = json_decode($body);
    $example = $body->example;

    $sql = "UPDATE examples SET name=:name, json=:json WHERE id=:id";
    try {
        $db = getConnection();
        $stmt = $db->prepare($sql);
        $stmt->execute(array(
            ":name" => $example->name,
            ":json" => json_encode($example->json),
            ":id" => $id
        ));
        $db = null;
        echo json_encode($example);

    } catch (PDOException $e) {
        echo '{"error":{"text": '. $e->getMessage() .'}}';
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