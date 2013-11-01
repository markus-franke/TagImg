var values = []

function selectedValues() {
    return values
}

function isSelected(value) {
    return (values.indexOf(value) != -1)
}

function addValue(value) {
    if (values.indexOf(value) != -1)
        return
    values.push(value)
}

function removeValue(value) {
    var index = values.indexOf(value)

    if (index == -1)
        return
    values.splice(index, 1)
}

function clear() {
    values = []
}

function count() {
    return values.length
}
