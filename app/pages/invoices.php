<?php
include "includes/header.php";
include "../model/Invoice.php";
?>

<div id="content">
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <div class="container-fluid">

            <button type="button" id="sidebarCollapse" class="btn btn-light">
                <i class="fas fa-bars"></i>
            </button>

            <h3>List of Invoices</h3>

        </div>
    </nav>

    <!--Page Content-->
    <?php
    $invoices = new Invoice();
    $invoices->showAllInvoices();
    ?>
    <div class="container">
        <div class="row">
            <div class="col-sm-6">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Nr-000001</h5>
                        <div class="card-text">
                            Date: 2020-01-04
                            <br>
                            Nights number: 4
                            <br>
                            Pension form: Tageskarte Kind 12-18
                            <br>
                            Price: <b>120$</b>
                            <br>
                            <hr>
                            Guest name(s): XX YY, ZZ WW
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Nr-000002</h5>
                        <div class="card-text">
                            Date: 2020-01-02
                            <br>
                            Nights number: 2
                            <br>
                            Pension form: Tageskarte Erwachsener
                            <br>
                            Price: <b>200$</b>
                            <br>
                            <hr>
                            Guest name(s): XX YY, ZZ WW
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>
<?php
include "includes/footer.php";
?>
