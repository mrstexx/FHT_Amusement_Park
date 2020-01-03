<?php
include "includes/header.php";
include "../model/Room.php";
?>

<div id="content">
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <div class="container-fluid">

            <button type="button" id="sidebarCollapse" class="btn btn-light">
                <i class="fas fa-bars"></i>
            </button>

            <h3>Rooms Availability</h3>

        </div>
    </nav>

    <!--Page Content-->
    <table class="table" id="employeesTable">
        <thead class="thead-blue">
        <tr>
            <th scope="col">#</th>
            <th scope="col">Room Number</th>
            <th scope="col">Description</th>
            <th scope="col">Price(€)</th>
            <th scope="col">Available</th>
        </tr>
        </thead>
        <tbody>
        <?php
        $room = new Room();
        $room->showRoomData();
        ?>
        </tbody>
    </table>

</div>

<?php
include "includes/footer.php";
?>
