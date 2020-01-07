<?php
include "includes/header.php";
include "../model/Guest.php";
?>

<div id="content">
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <div class="container-fluid">

            <button type="button" id="sidebarCollapse" class="btn btn-light">
                <i class="fas fa-bars"></i>
            </button>

            <h3>List of Guests</h3>

        </div>
    </nav>

    <!--Page Content-->
    <table class="table" id="employeesTable">
        <thead class="thead-blue">
        <tr>
            <th scope="col">First Name</th>
            <th scope="col">Last Name</th>
            <th scope="col">Date From</th>
            <th scope="col">Date To</th>
            <th scope="col">Pension Form</th>
            <th scope="col">Room Numbers</th>
        </tr>
        </thead>
        <tbody>
        <?php
        $room = new Guest();
        $room->showGuestData();
        ?>
        </tbody>
    </table>

</div>

<?php
include "includes/footer.php";
?>
