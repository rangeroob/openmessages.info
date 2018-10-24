function displayformContent() {
    var x = document.getElementById("editForm");
    var y = document.getElementById("page_content");
    if (x.style.display === "none" && y.style.display === "block") {
        x.style.display = "block";
        y.style.display = "none";
    }
    else {
        x.style.display = "none";
        y.style.display = "block";
    }
}