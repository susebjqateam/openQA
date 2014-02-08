function loadBackground(tag) {
	window.nEditor.LoadBackground(tag.dataset.url);
	document.getElementById("needleeditor_image").setAttribute("value", tag.dataset.path);
}

function loadTags(html) {
	var tags = JSON.parse(html.dataset.tags);
	var checkboxes = document.getElementById("needleeditor_tags").getElementsByTagName('input');
	for (var i = 0; i < checkboxes.length; i++) {
		// If we need to switch
		if ( (checkboxes[i].checked && tags.indexOf(checkboxes[i].value) == -1) ||
		     (!checkboxes[i].checked && tags.indexOf(checkboxes[i].value) != -1)) {
			checkboxes[i].click();
		}
	}
}

function addTag() {
	var input = document.getElementById('newtag');
	var checkbox = window.nEditor.AddTag(input.value, false);
	input.value = '';
	checkbox.click();
	return false;
}
