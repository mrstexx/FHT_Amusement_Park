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