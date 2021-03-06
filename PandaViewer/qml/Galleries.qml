import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQml.Models 2.1
import Material 0.1

Item {
    id: galleriesPage
    objectName: "galleries"
    property bool scanningMode: false
    property bool noSearchResults: false
    ListModel {
        id: galleryModel
    }

    ProgressCircle {
        id: progressCircle
        anchors.centerIn: parent
        visible: false
        color: theme.accentColor
    }

    Component.onCompleted: {
        mainWindow.removeGallery.connect(galleriesPage.removeGallery)
        mainWindow.scanningModeSet.connect(galleriesPage.setScanningMode)
        mainWindow.setGallery.connect(galleriesPage.setGallery)
        mainWindow.setNoSearchResults.connect(galleriesPage.setNoSearchResults)
        mainWindow.setUIGallery.connect(galleriesPage.setUIGallery)
        mainWindow.removeUIGallery.connect(galleriesPage.removeUIGallery)
        mainWindow.openDetailedGallery.connect(
                    galleriesPage.openDetailedGallery)
    }

    function openDetailedGallery(gallery) {
        pageStack.push(Qt.resolvedUrl("CustomizeGallery.qml"), {
                           gallery: gallery
                       })
    }

    function removeGallery(uuid) {
        galleryModel.remove(getIndexFromUUID(uuid))
    }

    function getIndexFromUUID(uuid) {
        for (var i = 0; i < galleryModel.count; ++i) {
            if (galleryModel.get(i).dbUUID === uuid) {
                return i
            }
        }
        return -1
    }

    function setGallery(uuid, gallery) {
        galleryModel.set(getIndexFromUUID(uuid), gallery)
    }

    function setUIGallery(index, gallery, resetScroll) {
        if (resetScroll) {
            galleryLoader.item.positionViewAtBeginning()
        }
        galleryModel.set(index, gallery)
    }

    function removeUIGallery(index, count) {
        if (index < galleryModel.count) {
            galleryModel.remove(index)
        }
    }

    function setNoSearchResults(noResults) {
        galleriesPage.noSearchResults = noResults
    }

    function setScanningMode(mode) {
        galleriesPage.scanningMode = mode
    }

    states: [
        State {
            when: galleriesPage.scanningMode

            PropertyChanges {
                target: centerMessage
                visible: false
            }

            PropertyChanges {
                target: galleryContent
                visible: false
            }

            PropertyChanges {
                target: progressCircle
                visible: true
            }
        },

        State {
            when: galleriesPage.noSearchResults
            PropertyChanges {
                target: progressCircle
                visible: false
            }
            PropertyChanges {
                target: centerMessage
                visible: true
            }

            PropertyChanges {
                target: galleryContent
                visible: false
            }

            PropertyChanges {
                target: messageLabel
                text: "Your search returned zero results."
            }

            PropertyChanges {
                target: messageIcon
                name: "action/search"
            }
        },

        State {
            when: galleryModel.count == 0
            PropertyChanges {
                target: progressCircle
                visible: false
            }
            PropertyChanges {
                target: centerMessage
                visible: true
            }

            PropertyChanges {
                target: galleryContent
                visible: false
            }

            PropertyChanges {
                target: messageLabel
                text: "Sorry, we couldn't find any galleries.\nPlease ensure you've added folders to your settings page and have scanned folders."
            }

            PropertyChanges {
                target: messageIcon
                name: "alert/warning"
            }
        },

        State {
            when: !galleriesPage.scanningMode
            PropertyChanges {
                target: progressCircle
                visible: false
            }
            PropertyChanges {
                target: centerMessage
                visible: false
            }

            PropertyChanges {
                target: galleryContent
                visible: true
            }
        }
    ]

    Column {
        id: centerMessage
        visible: false
        anchors.centerIn: parent

        Icon {
            id: messageIcon
            anchors.horizontalCenter: parent.horizontalCenter
            name: "alert/warning"
            size: Units.dp(100)
        }

        Label {
            id: messageLabel
            text: ""
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Item {
        id: galleryContent
        anchors.fill: parent
        function setDisplayMode(gridMode) {
            galleryLoader.sourceComponent = gridMode ? gridComponent : listComponent
            galleryLoader.item.positionViewAtBeginning()
        }
        Component.onCompleted: {
            mainWindow.setDisplayModeToGrid.connect(setDisplayMode)
        }

        Loader {
            id: galleryLoader
            sourceComponent: gridComponent
        }

        ScrollView {
            anchors.fill: parent
            id: scroll
            __wheelAreaScrollSpeed: 100
            contentItem: galleryLoader.item
        }

        Component {
            id: listComponent
            ListView {
                id: list
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    left: parent.left
                    topMargin: Units.dp(16)
                    leftMargin: Units.dp(16)
                    rightMargin: Units.dp(16)
                }
                focus: true
                boundsBehavior: Flickable.DragOverBounds
                model: galleryModel
                cacheBuffer: Units.dp((350 + 16) * 100)
                delegate: Component {
                    Loader {
                        sourceComponent: Component {
                            ListGallery {
                                width: list.width
                            }
                        }
                        asynchronous: index >= 50
                    }
                }
            }
        }

        Component {
            id: gridComponent
            GridView {
                id: grid
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                    left: parent.left
                    topMargin: Units.dp(16)
                    leftMargin: Units.dp(16)
                    bottomMargin: Units.dp(16)
                    rightMargin: 0
                }
                focus: true
                boundsBehavior: Flickable.DragOverBounds
                cellWidth: Units.dp(200 + 16)
                cellHeight: Units.dp(280 + 16)

                model: galleryModel
                cacheBuffer: Units.dp((350 + 16) * 25)
                delegate: Component {
                    Loader {
                        sourceComponent: Component {
                            GridGallery {
                            }
                        }
                        asynchronous: index >= 60
                    }
                }
            }
        }
    }
}
