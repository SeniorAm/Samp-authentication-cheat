<?php
$servername = "localhost";//host ip or name {dont need port }
$username = "root";// user database { Defult is root }
$password = " ";// pssword user Database { Defult no have pass } 
$dbname = "user_database";//database name 


$conn = new mysqli($servername, $username, $password, $dbname);


if ($conn->connect_error) {
    error_log("Connection failed: " . $conn->connect_error);
    die("Connection failed: " . $conn->connect_error);
}


if (!empty($_POST['username']) && !empty($_POST['password']) && !empty($_POST['player_name']) && !empty($_POST['server_name']) ) {
    $user = $_POST['username'];
    $pass = $_POST['password'];
    $player_name = $_POST['player_name'];
    $server_name = $_POST['server_name'];

    error_log("Received username: " . $user);
    error_log("Received player name: " . $player_name);

 
    if ($stmt = $conn->prepare("SELECT username, password, expiration_date FROM users WHERE username = ?")) {
        $stmt->bind_param("s", $user);
        $stmt->execute();
        $result = $stmt->get_result();


        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            $hashed_password = $row['password'];

// if pass you enter in menu cheat is passwordon database you can use cheat 
            if ($pass === $hashed_password) {
                $today = date('Y-m-d');

  
                if ($row['expiration_date'] >= $today) {


                    if ($stmt = $conn->prepare("SELECT id FROM player_log WHERE player_name = ? AND server_name = ?")) {
                        $stmt->bind_param("ss", $player_name, $server_name);
                        $stmt->execute();
                        $result = $stmt->get_result();

                        if ($result->num_rows > 0) {//if player connect befor 
   
                            echo "Login Baraye in Account az ghabl faal shode";
                        } else {
 
                            if ($stmt = $conn->prepare("INSERT INTO player_log (player_name, server_name) VALUES (?, ?)")) {
                                $stmt->bind_param("ss", $player_name, $server_name);
                                if ($stmt->execute()) {
                                    echo "success";
                                } else {
                                    error_log("Failed to execute INSERT statement: " . $stmt->error);
                                    echo "Failed to log player";
                                }
                            } else {
                                error_log("Failed to prepare INSERT statement: " . $conn->error);
                                echo "SQL statement";
                            }
                        }
                    } else {
                        error_log("Failed to prepare SELECT statement for player_log: " . $conn->error);
                        echo "SQL statement";
                    }
                } else {
                    echo "Subscription expired";
                }
            } else {
                error_log("Password verification failed. Input password: " . $pass . " Hash from DB: " . $hashed_password);
                echo "password Eshtebah";
            }
        } else {
            error_log("user peyda nashod: " . $user);
            echo "user peyda nashod";
        }

        $stmt->close();
    } else {
        error_log("Failed to prepare SELECT statement: " . $conn->error);
        echo "SQL statement";
    }
} else {
    error_log("POST variables are not set or empty. POST data: " . print_r($_POST, true));
    echo "user ya ramz yaft nashode";
}

$conn->close();
?>
