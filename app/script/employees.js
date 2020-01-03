const saveChangesBtn = $("#emplSaveChanges");

const getTableData = () => {
    let data = [];
    const tableRows = $("#employeesTable")[0].rows;
    if (tableRows && tableRows.length > 0) {
        for (let i = 1; i < tableRows.length; i++) {
            const row = tableRows[i];
            const departOption = row.cells[4].querySelector("select");
            const salaryOption = row.cells[5].querySelector("select");
            const attractionOption = row.cells[6].querySelector("select");
            data.push({
                personID: row.cells[0].id.substr(3),
                newDepartmentID: departOption.options[departOption.selectedIndex].id.substr(3),
                newSalaryID: salaryOption.options[salaryOption.selectedIndex].id.substr(3),
                newAttractionID: attractionOption.options[attractionOption.selectedIndex].id.substr(3)
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
        url: "../actions/update_personal.php",
        data: {
            'val': data
        },
        dataType: "json",
        success: (response) => {
            if (response && response.error) {
                alert("An error occurred. It may happen not all changes were saved.")
            } else {
                alert("Changes have been successfully saved.");
                location.reload();
            }
        }
    });
});