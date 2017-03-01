<?php

/* 
 * Alvin Lee
 * 
 */

require_once '../includes/DBOperation.php';

$response = array();
        
$response['Pins'] = [];

$database = new DBOperation();

$pins = $database->getAllPins();

while($pin = $pins->fetch_assoc())
    {
        $temp = array();
        
        $temp['title'] = $pin['Title'];
        $temp['hint'] = $pin['Hint'];
        $temp['codeword'] = $pin['Codeword'];
        $temp['coordLong'] = $pin['CoordLongitude'];
        $temp['coordLat'] = $pin['CoordLatitude'];
        $temp['pointVal'] = $pin['PointValue'];
        $temp['packID'] = $pin['PackID'];
        
        array_push($response['Pins'], $temp);
    }

echo json_encode($response);