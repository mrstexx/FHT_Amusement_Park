$("#formCheckin").submit((e) => {
    e.preventDefault();
    $.ajax({
        type: "POST",
        url: "../actions/checkin.php",
        data: $("#formCheckin").serialize(),
        success: (response) => {
            if (response === "1") {
                alert("Checkin successfully finished");
                location.reload();
            } else {
                alert(response);
            }
        }
    });
});

$("#submitModalGuest").click((e) => {
    e.preventDefault();
    $.ajax({
        type: "POST",
        url: "../actions/checkin_add_guest.php",
        data: $("#formModalGuest").serialize(),
        success: (response) => {
            if (response === "1") {
                alert("Checkin - Add guest successfully finished");
                $("#modalGuest").modal('hide');
            } else {
                alert(response);
            }
        }
    });
});

$("#submitModalRoom").click((e) => {
    e.preventDefault();
    $.ajax({
        type: "POST",
        url: "../actions/checkin_add_room.php",
        data: $("#formModalRoom").serialize(),
        success: (response) => {
            if (response === "1") {
                alert("Checkin - Add room successfully finished");
                $("#modalRoom").modal('hide');
            } else {
                alert(response);
            }
        }
    });
});

$('#modalGuest').on('hidden.bs.modal', function () {
    $(this).find('form').trigger('reset');
});

$('#modalRoom').on('hidden.bs.modal', function () {
    $(this).find('form').trigger('reset');
});