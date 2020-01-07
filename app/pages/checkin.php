<?php
include "includes/header.php";
include "../model/CheckIn.php";
?>

<div id="content">
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <div class="container-fluid">

            <button type="button" id="sidebarCollapse" class="btn btn-light">
                <i class="fas fa-bars"></i>
            </button>

            <h3>Check In</h3>

        </div>
    </nav>

    <!--Page Content-->
    <div class="container checkin-toolbar">
        <div class="row justify-content-end">
            <div class="">
                <button id="addGuest" class="btn btn-light" data-toggle="modal" data-target="#modalGuest"><i
                            class="fas fa-plus"></i> Add guest
                </button>
            </div>
            <div class="">
                <button id="addRoom" class="btn btn-light" data-toggle="modal" data-target="#modalRoom"><i
                            class="fas fa-plus"></i> Add room
                </button>
            </div>
        </div>
    </div>
    <div class="container cont-checkin">
        <form id="formCheckin">
            <div class="form-row">
                <div class="form-group col-md-6">
                    <label for="firstName">First Name</label>
                    <input type="text" class="form-control" id="firstName">
                </div>
                <div class="form-group col-md-6">
                    <label for="lastName">Last Name</label>
                    <input type="text" class="form-control" id="lastName">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group col">
                    <label for="roomType">Room</label>
                    <select id="roomType" class="form-control">
                        <option selected>Choose...</option>
                        <option>...</option>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group col">
                    <label for="pensionType">Pension Form</label>
                    <select id="pensionType" class="form-control">
                        <option selected>Choose...</option>
                        <option>...</option>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group col-md-6">
                    <label for="datetime">Arrival date</label>
                    <input class="form-control" type="date" id="datetime">
                </div>
                <div class="form-group col-md-6">
                    <label for="nightsNumber">Nights</label>
                    <input type="number" class="form-control" id="nightsNumber" value="1" min="1">
                </div>
            </div>
            <button class="btn btn-block btn-primary" type="submit">Checkin</button>
        </form>
    </div>
</div>


<div class="modal fade" id="modalGuest" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Add guest</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form id="formModalGuest">
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <input type="text" class="form-control" id="modalNewFirstName" placeholder="New first name">
                        </div>
                        <div class="form-group col-md-6">
                            <input type="text" class="form-control" id="modalNewLastName" placeholder="New last name">
                        </div>
                    </div>
                    <hr>
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <input type="text" class="form-control" id="modalPrimFirstName"
                                   placeholder="Primary first name">
                        </div>
                        <div class="form-group col-md-6">
                            <input type="text" class="form-control" id="modalPrimLastName"
                                   placeholder="Primary last name">
                        </div>
                    </div>
                    <hr>
                    <div class="form-row">
                        <div class="form-group col">
                            <label for="modalDatetime">Arrival date</label>
                            <input class="form-control" type="date" id="modalDatetime">
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" id="submitModalGuest">Submit</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalRoom" tabindex="-1" role="dialog">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Add room</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form id="formModalRoom">
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <input type="text" class="form-control" id="modalRoomPrimFirstName"
                                   placeholder="Primary first name">
                        </div>
                        <div class="form-group col-md-6">
                            <input type="text" class="form-control" id="modalRoomPrimLastName"
                                   placeholder="Primary last name">
                        </div>
                    </div>
                    <hr>
                    <div class="form-row">
                        <div class="form-group col">
                            <label for="modalRoomDatetime">Arrival date</label>
                            <input class="form-control" type="date" id="modalRoomDatetime">
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group col">
                            <label for="modalRoomType">Room type</label>
                            <select id="modelRoomType" class="form-control">
                                <option selected>Choose...</option>
                                <option>...</option>
                            </select>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" id="submitModalRoom">Submit</button>
            </div>
        </div>
    </div>
</div>


<script src="../script/checkin.js"></script>

<?php
include "includes/footer.php";
?>
