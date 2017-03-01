<?php

/* 
 * Alvin Lee
 * adds pins to the pins table in the online database
 */

$response = array();

if ($_SERVER['REQUEST_METHOD'] === 'POST')
{
    $pinTitle = $_GET["title"];
    $pinHint = $_GET["hint"];
    $pinCodeword = $_GET["codeword"];
    $pinCoordLong = $_GET["coordLong"];
    $pinCoordLat = $_GET["coordLat"];
    $pinPointVal = $_GET["pointVal"];
    $pinPackID = $_GET["packID"];

    require_once '../includes/DBOperation.php';
    
    $database = new DBOperation();
    if ($database->addPin($pinTitle, $pinHint, $pinCodeword, $pinCoordLong, $pinCoordLat, $pinPointVal, $pinPackID))
    {
        $response['error'] = false;
        $response['message'] = 'Pin added sucessfully';
    }
    else
    {
        $response['error'] = true;
        $response['message'] = 'Could not add pin';
        $response['title'] = $pinTitle;
        var_dump($GLOBALS);

    }
}
else
{
    $response['error'] = true;
    $response['message'] = 'You are not authorised';
}
echo json_encode($response);