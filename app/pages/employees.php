<?php
include "includes/header.php";
include "../model/Personal.php";
?>

<div id="content">
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <div class="container-fluid">

            <button type="button" id="sidebarCollapse" class="btn btn-light">
                <i class="fas fa-bars"></i>
            </button>

            <h3>List of Employees</h3>

        </div>
    </nav>

    <!--Page Content-->
    <div class="container employees-control-bar">
        <div class="row">
            <div class="col-auto ml-auto">
                <button id="emplSaveChanges" class="btn btn-light">Save changes</button>
            </div>
        </div>
    </div>

    <table class="table" id="employeesTable">
        <thead class="thead-blue">
        <tr>
            <th scope="col">#</th>
            <th scope="col">First Name</th>
            <th scope="col">Last Name</th>
            <th scope="col">Gender</th>
            <th scope="col">Department</th>
            <th scope="col">Salary(€)</th>
            <th scope="col">Attraction</th>
        </tr>
        </thead>
        <tbody>
        <?php
        $employees = new Personal();
        $employees->showPersonalData();
        ?>
        </tbody>
    </table>

</div>

<script src="../script/employees.js"></script>
<?php
include "includes/footer.php";
?>
