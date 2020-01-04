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
    <div class="container">
        <div class="row">
            <?php
            $invoices = new Invoice();
            $invoices->showAllInvoices();
            ?>
        </div>
    </div>

</div>
<?php
include "includes/footer.php";
?>
