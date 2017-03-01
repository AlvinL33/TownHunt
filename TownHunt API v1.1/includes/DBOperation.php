<?php

/* 
 * Alvin Lee
 * Controls the database operation
 */

class DBOperation
{
    private $connection;
    
    function __construct() {
        require_once dirname(__FILE__) . '/DBConnect.php';
        
        $database = new DBConnect();
        $this->connection = $database->connect();
        
    }
    
    public function getDetailsOfUser($username, $userEmail)
    {
        $result = array();
        $stmt = $this->connection->query("SELECT * FROM `Users` WHERE `Username` = '".$username."' OR `Email` = '".$userEmail."'");
        if ($stmt != null && (mysqli_num_fields($stmt)>=1))
        {
            $row = $stmt->fetch_array(MYSQLI_ASSOC);
            if (!empty($row))
            {
                $result = $row;
            }
        }
        $stmt->close();
        return $result;
    }
    
    public function getDetailsOfUserIncPassword($userEmail, $userPassword)
    {
        $result = array();
        $stmt = $this->connection->query("SELECT `UserID`, `Username`, `Email` FROM `Users` WHERE `Email` = '".$userEmail."' AND `Password` = '".$userPassword."'");
        if ($stmt != null && (mysqli_num_fields($stmt)>=1))
        {
            $row = $stmt->fetch_array(MYSQLI_ASSOC);
            if (!empty($row))
            {
                $result = $row;
            }
        }
        $stmt->close();
        return $result;
    }
    
    public function addUser($username, $userEmail, $userPassword){
        $stmt = $this->connection->prepare("INSERT INTO `Users` (`UserID`, `Username`, `Email`, `Password`) VALUES (NULL, ?, ?, ?);");
        $stmt->bind_param("sss", $username, $userEmail, $userPassword);
        $result = $stmt->execute();
        $stmt->close();
        return $result;
    }

    public function addPin($title, $hint, $codeword, $coordLong, $coordLat, $pointVal, $packID)
    {
        $stmt = $this->connection->prepare("INSERT INTO `Pins` (`PinID`, `Title`, `Hint`, `Codeword`, `CoordLongitude`, `CoordLatitude`, `PointValue`, `PackID`) VALUES (NULL, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sssddii", $title, $hint, $codeword, $coordLong, $coordLat, $pointVal, $packID);
        $result = $stmt->execute();
        $stmt->close();
        if($result)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public function getAllPins()
    {
        $stmt = $this->connection->prepare("SELECT * FROM `Pins`");
        $stmt->execute();
        $result = $stmt->get_result();
        $stmt->close();
        return $result;
    }
}



