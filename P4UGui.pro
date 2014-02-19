# Add more folders to ship with the application, here
folder_01.source = qml/P4UGui
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

QT -= network

# add Image Magick library
unix:LIBS += -lMagick++
unix:INCLUDEPATH += /usr/include/ImageMagick

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    applogic.cpp

# Please do not modify the following two lines. Required for deployment.
include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
qtcAddDeployment()

RESOURCES += \
    qml/P4UGui/resources.qrc

HEADERS += \
    applogic.h
