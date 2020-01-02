const saveChangesBtn = $("#emplSaveChanges");

const getTableData = () => {
    let data = [];
    const tableRows = $("#employeesTable")[0].rows;
    if (tableRows && tableRows.length > 0) {
        for (let i = 1; i < tableRows.length; i++) {
            const row = tableRows[i];
            data.push({
                id: row.cells[0].id,
                department: row.cells[4].querySelector("[selected]").innerHTML,
                salary: row.cells[5].querySelector("[selected]").innerHTML,
                attraction: row.cells[6].querySelector("[selected]").innerHTML
            });
        }
    }
    return data;
};

saveChangesBtn.on("click", (e) => {
    e.preventDefault();
    const data = getTableData();
    $.ajax({
        type: "POST",
        url: "../actions/action.php",
        data: data,
        dataType: "json",
        contentType: "application/json; charset=utf-8",
        success: (response) => {
            alert(response);
        }
    });
});