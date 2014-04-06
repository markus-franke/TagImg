# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

QT -= network

QT += qml quick

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    applogic.cpp \
    wmgeometry.cpp

RESOURCES += \
    qml/P4UGui/resources.qrc

OTHER_FILES += \
    qml/P4UGui/FileBrowser.qml \
    qml/P4UGui/P4U_Button.qml \
    qml/P4UGui/P4U_Page.qml \
    qml/P4UGui/P4U_Slider.qml \
    qml/P4UGui/main.qml \
    qml/P4UGui/P4U_Message.qml \
    qml/P4UGui/P4U_ProgressBar.qml \
    qml/P4UGui/ViewWatermark.qml \
    qml/P4UGui/MainWindow.qml \
    qml/P4UGui/P4U_Label.qml

HEADERS += \
    applogic.h \
    wmgeometry.h
