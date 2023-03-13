# This script connects to a MySQL database and alters a column in a specified table. The script defines the MySQL server and database information, imports the MySQL .NET connector assembly, and defines the MySQL connection string.
# The script then opens a MySQL connection, gets the current data type of the specified column, and checks if the data type is different from the desired data type. If the data type is different, the script adds a new column with the desired data type, copies the data from the old column to the new column, and drops the old column. If the data type is the same, the script outputs a message indicating that no changes are required.
# Finally, the script closes the MySQL connection. You can modify this script to perform other operations, such as adding or deleting columns or tables, by changing the queries in the script.
# creates a new column with a temporary name and the desired data type, copies the data from the old column to the new column, drops the old column, and then renames the new column to the original column name with the desired data type and nullability. This ensures that data is preserved and

# Define MySQL server and database information
$MySQLServer = "localhost"
$MySQLDatabase = "testdb"
$MySQLUsername = "root"
$MySQLPassword = "password"

# Import MySQL .NET connector assembly
Add-Type -Path "C:\Program Files (x86)\MySQL\MySQL Connector Net 8.0.25\Assemblies\v4.5.2\MySql.Data.dll"

# Define MySQL connection string
$MySQLConnectionString = "server=$MySQLServer;database=$MySQLDatabase;uid=$MySQLUsername;password=$MySQLPassword"

# Define the table and column names to be altered
$tableName = "users"
$columnName = "email"

# Define the new column data type
$newColumnType = "VARCHAR(255)"

# Open a MySQL connection
$MySQLConnection = New-Object MySql.Data.MySqlClient.MySqlConnection($MySQLConnectionString)
$MySQLConnection.Open()

# Get the current column data type and nullability
$query = "SHOW COLUMNS FROM $tableName WHERE Field = '$columnName'"
$command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $MySQLConnection)
$column = $command.ExecuteReader()
$columnType = ""
$columnNullable = ""
while ($column.Read()) {
    $columnType = $column["Type"]
    $columnNullable = $column["Null"]
}
$column.Close()

if ($columnType) {
    Write-Output "Current data type of column $columnName is $columnType"

    # If the data type is different, alter the column
    if ($columnType -ne $newColumnType) {
        # Add a new column with the desired data type
        $newColumnName = "${columnName}_new"
        $query = "ALTER TABLE $tableName ADD COLUMN $newColumnName $newColumnType"
        $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $MySQLConnection)
        $command.ExecuteNonQuery()

        # Copy data from old column to new column
        $query = "UPDATE $tableName SET $newColumnName = $columnName"
        $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $MySQLConnection)
        $command.ExecuteNonQuery()

        # Drop the old column
        $query = "ALTER TABLE $tableName DROP COLUMN $columnName"
        $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $MySQLConnection)
        $command.ExecuteNonQuery()

        # Rename the new column to the original column name
        $query = "ALTER TABLE $tableName CHANGE COLUMN $newColumnName $columnName $newColumnType $columnNullable"
        $command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $MySQLConnection)
        $command.ExecuteNonQuery()

        Write-Output "Column $columnName successfully altered to $newColumnType"
    } else {
        Write-Output "No changes required for column $columnName"
    }
} else {
    Write-Error "Column $columnName not found in table $tableName"
}

# Close the MySQL connection
$MySQLConnection.Close()