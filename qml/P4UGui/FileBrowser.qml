import QtQuick 2.0
import Qt.labs.folderlistmodel 2.1
import "MultiSelect.js" as MultiSelect

P4U_Page {
    id: fileBrowser

    property bool bChooseFolder : true
    property bool bMultiSelect  : false

    Rectangle {
        id: fileBrowserFrame
        color: "white"
        width: parent.width
        height: parent.height - okButton.height - 20
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 5 }
        border.width: 0
        radius: 5
        antialiasing: true

        Text {
            id: currentFolderText
            text: "Folder:"
            anchors { left: parent.left; leftMargin: 5 }
            font.bold: true
        }

        Text {
            id: currentFolder
            text: setFolder(foldermodel.folder)
            anchors { left: currentFolderText.right; leftMargin: 5 }

            function setFolder(folder) {
                console.log("setFolder: ", folder)
                text = AppLogic.cleanPath(folder.toString())
            }
        }

        FolderListModel {
            id: foldermodel
            folder: AppLogic.getDefaultDir()
            sortField: FolderListModel.Name
            showDirsFirst: true
            nameFilters: ["*.*"]
            showDotAndDotDot: true
            onFolderChanged: currentFolder.setFolder(folder)
        }

        ListView {
            id: listView
            width: parent.width
            height: parent.height - currentFolder.height - 20

            anchors.top: currentFolder.bottom
            anchors.topMargin: 5
            highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
            focus: true

            onCurrentItemChanged: {
                if(!bChooseFolder && foldermodel.isFolder(listView.currentIndex))
                    okButton.enabled = false
                else
                    okButton.enabled = true

                console.debug("Current Item is:", currentItem.myData.fileName)
            }

            Component {
                id: filedelegate

                Item {
                    id: item
                    width: parent.width
                    height: listView.height / 15

                    property variant myData: model
                    property bool bSelected: false

                    function folderSelected()
                    {
                        if (ListView.view.model.isFolder(index)) {
                            var folder = AppLogic.fixPath(filePath)
                            ListView.view.model.folder = folder
                            MultiSelect.clear()
                            if(ListView.view.count > 0)
                                ListView.view.currentIndex = 0
                            console.debug("Changing to folder: ", folder)
                        }
                        else {
                            console.debug("File", fileName, "has been chosen")
                            MultiSelect.addValue(foldermodel.folder + "/" + fileName)
                            processWorklist(MultiSelect.selectedValues())
                            pageStack.pop()
                        }
                    }

                    Text {
                        id: itemText
                        text: fileName
                        font.bold: true
                        anchors { left: parent.left; right: parent.right; margins: 5 }
                        color: item.bSelected ? "red" : "black"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                item.ListView.view.currentIndex = index
                                if(bMultiSelect) {
                                    if(mouse.modifiers && Qt.ControlModifier) {
                                        item.bSelected = !item.bSelected
                                        if(item.bSelected)
                                            MultiSelect.addValue(filePath)
                                        else
                                            MultiSelect.removeValue(filePath)
                                    }
                                    /*else {
                                        // remove all selections on unmodified click
                                        MultiSelect.clear()
                                    }*/
                                }
                            }
                            onDoubleClicked: item.folderSelected()
                        }
                    }

                    Keys.onReturnPressed: item.folderSelected()
                    Keys.onEscapePressed: fileBrowser.hide()
                }
            }

            model: foldermodel
            delegate: filedelegate
        }
    }

    Row {
        anchors { bottom : parent.bottom; margins: 10; horizontalCenter: parent.horizontalCenter }
        spacing: 20

        P4U_Button {
            id: okButton
            text: "Ok"
            onClicked: {
                if(MultiSelect.count() > 0) {
                    console.debug(MultiSelect.selectedValues())
                    processWorklist(MultiSelect.selectedValues())
                }
                else
                    processWorklist(foldermodel.folder + "/" + listView.currentItem.myData.fileName)

                MultiSelect.clear()
                pageStack.pop()
            }
        }

        P4U_Button {
            id: cancelButton
            text: "Cancel"
            onClicked: {
                MultiSelect.clear()
                processWorklist(MultiSelect.selectedValues())
                pageStack.pop()
            }
        }
    }

    signal processWorklist(var worklist)

    onVisibleChanged: {
        console.debug("FileBrowser is", visible ? "visible" : "invisible")

        if(visible) {
            // delete all previous selectings
            // length - 1 because last children is a rectangle (bad hack but as my qml knowledge is limited....what to do ;-))
            for(var i = 0; i < listView.contentItem.children.length - 1; i++) {
                var curItem = listView.contentItem.children[i]
                //console.debug(i, ":", curItem, "=", curItem.itemText)
                curItem.bSelected = false
            }
        }
    }
}
