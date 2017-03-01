<?php

/* 
 * By Alvin Lee
 * Establishes a connection with the database 
 */

class DBConnect{
    private $connection;
            
    function __construct()
    {
    }
    
    function connect()
    {
        $host_name  = "[HOST NAME]";
        $database   = "[DATABASE]";
        $user_name  = "[USERACCOUNT]";
        $password   = "[PASSWORD]";
        
        $this->connection = new mysqli($host_name, $user_name, $password, $database);
    
        if(mysqli_connect_errno())
        {
            echo 'Failed to connecto to MySQL'.mysqli_connect_error().'</p>';
        }
        
        return $this->connection;
    }
}
