#include "applogic.h"

#include <QtDebug>

#include <QFileInfo>
#include <QDir>
#include <QProcess>
#include <QGuiApplication>
#include <QUrl>
#include <QImage>
#include <QFile>
#include <QPainter>
#include <QTimer>

#include "qexifimageheader/qexifimageheader.h"

// define the filetypes being handled
static const QStringList constNameFilters = (QStringList() << "*.JPG" << "*.JPEG" << "*.jpg" << "*.jpeg");

AppLogic::AppLogic(QObject *parent) :
    QObject(parent),
    m_DM(DataModel::instance())
{
    // force reading of default settings once the main loop starts running
    QTimer::singleShot(0, &m_Settings, SLOT(readDefaultSettings()));
}

QString AppLogic::getDefaultDir()
{
#ifndef Q_OS_ANDROID
    QString homePath = QDir::homePath();

    homePath.prepend("file://");
    homePath.append("/Desktop");

    return homePath;
#else
    return "file:///";
#endif
}

QString AppLogic::getPathPrefix()
{
#ifdef Q_OS_WIN
    return "file:///";
#else
    return "";
#endif
}

QString AppLogic::toNativeSeparators(QString path)
{
    return QDir::toNativeSeparators(path);
}

QString AppLogic::fixPath(QString filePath)
{
#ifdef Q_OS_WIN
    filePath.prepend("file:///");
#else
    filePath.prepend("file://");
#endif
    filePath = QDir::cleanPath(filePath);
    return filePath;
}

QString AppLogic::cleanPath(QString resourcePath)
{
#ifdef Q_OS_WIN
    resourcePath.remove("file:///");
#else
    resourcePath.remove("file://");
#endif
    resourcePath = QDir::cleanPath(resourcePath);
    return resourcePath;
}

void AppLogic::applyWatermark()
{
    qDebug() << "Applying watermark to the following objects:" << m_DM.getWorklist();

    // reset progress bar
    emit setProgressValue(0);

    QStringList fileList;
    bool bError = false;
    QString listItem;

    foreach(listItem, m_DM.getWorklist()) {
#ifdef Q_OS_WIN
        listItem.remove("file:///");
#else
        listItem.remove("file://");
#endif
        listItem = QDir::toNativeSeparators(listItem);

        if(QFileInfo(listItem).isDir()) {
            QDir directory(listItem);
            QStringList nameFilters;
            nameFilters << constNameFilters;
            QStringList entryList = directory.entryList(nameFilters);
            QString entry;
            foreach(entry, entryList)
            {
                fileList.append(listItem + QDir::separator() + entry);
            }
        }
        else {
            fileList.append(listItem);
        }
    }

    QString currentFile;
    for(int i = 0; i < fileList.length() && !bError; ++i)
    {
        bError = true;
        currentFile = fileList.value(i);
        qDebug() << "Current file: " << currentFile;

        QString outFileDir = QFileInfo(currentFile).absolutePath() + QDir::separator() + "tagged";
        QString outFileName = QFileInfo(currentFile).fileName();
        QString outFile = QString("%1/%2").arg(outFileDir).arg(outFileName);

        // create output directory
        QDir::root().mkdir(outFileDir);

        // rotate'n'resize
        QExifImageHeader exifHeader(currentFile);
        quint32 orientation = exifHeader.value(QExifImageHeader::Orientation).toLong();
        qDebug() << "Orientation is" << orientation;

        QImage currentImg(currentFile);
        currentImg = currentImg.scaledToHeight(currentImg.height() * m_DM.getImageScale() / 100);

        if(orientation == 8)
        {
            qDebug() << "Rotating Image";
            QTransform rotateTransform;
            rotateTransform = rotateTransform.rotate(270);
            currentImg = currentImg.transformed(rotateTransform);
        }

        currentImg.save(outFile);

        // generate watermark
        QImage watermarkImg(cleanPath(m_DM.getWatermark()));
        QImage currentFileImg(outFile);
        QString tmpWatermark("watermark_tmp.png");

//        qDebug() << "Dimensions of watermarkImg: " << watermarkImg.width() << " x " << watermarkImg.height();
//        qDebug() << "Dimensions of currentFileImg: " << currentFileImg.width() << " x " << currentFileImg.height();

        // resize watermark according to image size
        if(currentFileImg.width() > currentFileImg.height())
            watermarkImg = watermarkImg.scaledToWidth(m_DM.getWatermarkSizePct() / 100.0 * currentFileImg.width());
        else
            watermarkImg = watermarkImg.scaledToWidth(m_DM.getWatermarkSizePct() / 100.0 * currentFileImg.height());
        watermarkImg.save(tmpWatermark);

//        qDebug() << "Dimensions of watermarkImg after resize: " << watermarkImg.width() << " x " << watermarkImg.height();

        // apply watermark
        int offsetX = m_DM.getWatermarkPosX(currentFileImg.width() - watermarkImg.width());
        int offsetY = m_DM.getWatermarkPosY(currentFileImg.height() - watermarkImg.height());

//        qDebug() << "Offset of watermark is: " << offsetX << ", " << offsetY;
        QPainter p(&currentFileImg);
        p.setOpacity(m_DM.getWatermarkOpacity() / 100.0);
        p.drawImage(offsetX,offsetY,watermarkImg);
        currentFileImg.save(outFile);

        // remove temporary file again
        QFile(tmpWatermark).remove();

        // set progress value
        emit setProgressValue(qRound((i+1) * 100.0 / fileList.length()));

        // reset error flag
        bError = false;
    }

    if(bError) {
        qDebug() << "There was an error. Current file =" << currentFile;
    }

    emit watermarkDone(bError);
}

QString AppLogic::getFirstTargetObject()
{
    QString firstImage;

    if(!m_DM.getWorklist().empty())
    {
        QString strFirstItem = cleanPath(m_DM.getWorklist().first());
        QFileInfo firstItem(strFirstItem);

        if(firstItem.isFile())
        {
            firstImage = firstItem.absoluteFilePath();
        }
        else // we have a directory - simply take the first image
        {
            QDir targetDir(firstItem.filePath());
            QStringList entries = targetDir.entryList(constNameFilters, QDir::Files);
            if(!entries.empty())
                firstImage = targetDir.path() + QDir::separator() + entries.first();
        }
    }

    qDebug() << firstImage;

    return firstImage;
}

void AppLogic::setWorklist(const QVariant& worklist)
{
    QStringList stringList;

    if(worklist.canConvert(QVariant::List))
    {
        stringList = worklist.toStringList();

        if(stringList.isEmpty())
        {
            QList<QUrl> list = worklist.value<QList<QUrl> >();
            qDebug() << "List is " << list << "length: " << list.length();


            // convert to stringlist
            for(int i = 0; i < list.length(); ++i)
            {
                stringList.append(list.at(i).toString());
            }
        }
    }
    else
    {
        stringList.append(worklist.toString());
    }

    m_DM.setWorklist(stringList);
}
