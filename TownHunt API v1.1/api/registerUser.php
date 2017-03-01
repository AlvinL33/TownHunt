<?php

/* 
 * Alvin Lee
 * adds users to the Users table in the online database
 */

if ($_SERVER['REQUEST_METHOD'] === 'POST')
{
    $username = htmlentities($_POST["username"]);
    $userEmail = htmlentities($_POST["userEmail"]);
    $userPassword = htmlentities($_POST["userPassword"]);

    $response = array();
    
    if(empty($username) || empty($userEmail) || empty($userPassword))
    {
        $response["error"] = true;
        $response["message"] = "One or more fields are empty";
        //var_dump($GLOBALS);
    }
    else 
    {
        require_once '../includes/DBOperation.php';

        $database = new DBOperation();
        $userDetails = $database->getDetailsOfUser($username, $userEmail);
        if(empty($userDetails))
        {
            $secureUserPassword = hash("ripemd128", $userPassword);
            if ($database->addUser($username, $userEmail, $secureUserPassword))
            {
                $response['error'] = false;
                $response['message'] = 'User added sucessfully';
            }
            else
            {
                $response['error'] = true;
                $response['message'] = 'Could not add user';
                var_dump($GLOBALS);
                
            }
        }
        else
        {
            $response['error'] = true;
            $response['message'] = 'Account already exists';
        }
    }
}
else
{
    $response['error'] = true;
    $response['message'] = 'You are not authorised';
}
echo json_encode($response);
