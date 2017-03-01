<?php

/* 
 * Alvin Lee
 * 
 */

if ($_SERVER['REQUEST_METHOD'] === 'POST')
{
    $userEmail = htmlentities($_POST["userEmail"]);
    $userPassword = htmlentities($_POST["userPassword"]);

    $response = array();
    //var_dump($GLOBALS);
    
    if(empty($userEmail) || empty($userPassword))
    {
        $response["error"] = true;
        $response["message"] = "One or more fields are empty";
    }
    else
    {
        require_once '../includes/DBOperation.php';

        $database = new DBOperation();
    
        $secureUserPassword = hash("ripemd128", $userPassword);
        $userDetails = $database->getDetailsOfUserIncPassword($userEmail, $secureUserPassword);

        if(!empty($userDetails))
        {
            $response['error'] = false;
            $response['message'] = 'User is registered';
            $response['accountInfo'] = $userDetails;        
        }
        else
        {
            $response['error'] = true;
            $response['message'] = 'Account not found';
        }
    }
}
else
{
    $response['error'] = true;
    $response['message'] = 'You are not authorised';
}
echo json_encode($response);