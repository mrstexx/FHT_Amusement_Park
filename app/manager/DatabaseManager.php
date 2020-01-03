<?php


class DatabaseManager
{
    private $connection = NULL;
    private $serverName = "127.0.0.1:11521/XE";
    private $userName = "system";
    private $password = "oracle";
    private $dbName = "";

    public function connect()
    {
        $this->connection = oci_connect($this->userName, $this->password, $this->serverName, "UTF8");
        if (!$this->connection) {
            $e = oci_error();
            trigger_error(htmlentities($e['message'], ENT_QUOTES), E_USER_ERROR);
            return null;
        }
        return $this->connection;
    }

    public function disconnect()
    {
        if ($this->connection) {
            oci_close($this->connection);
        }
    }
}