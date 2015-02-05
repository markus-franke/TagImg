#include "applogic.h"

#include <QtDebug>

#include <QFileInfo>
#include <QDir>
#include <QProcess>
#include <QGuiApplication>
#include <QUrl>
#include <QImage>
#include <QFile>

// define some keys for the default settings
#define KEY_SCALE_PCT           "scale_pct"
#define KEY_WATERMARK           "watermark"
#define KEY_WATERMARK_POSX      "watermark_posx"
#define KEY_WATERMARK_POSY      "watermark_posy"
#define KEY_WATERMARK_SCALE     "watermark_scale"
#define KEY_WATERMARK_OPACITY   "watermark_opacity"

// define some ImageMagick binaries
#define BIN_MOGRIFY     "mogrify"
#define BIN_COMPOSITE   "composite"
#define BIN_CONVERT     "convert"

// define
static const QStringList constNameFilters = (QStringList() << "*.JPG" << "*.JPEG" << "*.jpg" << "*.jpeg");

AppLogic::AppLogic(QObject *parent) :
    QObject(parent),
    m_pP4UProcess(NULL),
    m_pDefaultSettings(NULL),
    m_iImageScalePct(0),
    m_iWatermarkOpacity(0)
{
    m_pP4UProcess = new QProcess(this);

    m_pDefaultSettings = new QSettings("Private", "P4UGUI", this);
}

AppLogic::~AppLogic()
{
    writeDefaultSettings();

    delete m_pDefaultSettings;
    delete m_pP4UProcess;
}

void AppLogic::readDefaultSettings()
{
    qDebug() << "read def settings";

    setWatermark(m_pDefaultSettings->value(KEY_WATERMARK, "").toString());
    setImageScale(m_pDefaultSettings->value(KEY_SCALE_PCT, 50).toInt());
    setWatermarkPos(m_pDefaultSettings->value(KEY_WATERMARK_POSX, 0).toInt(), m_pDefaultSettings->value(KEY_WATERMARK_POSY, 0).toInt());
    setWatermarkSize(m_pDefaultSettings->value(KEY_WATERMARK_SCALE, 50).toInt(), m_pDefaultSettings->value(KEY_WATERMARK_SCALE, 50).toInt());
    setWatermarkOpacity(m_pDefaultSettings->value(KEY_WATERMARK_OPACITY, 50).toInt());
}

void AppLogic::writeDefaultSettings() const
{
    qDebug() << "write def settings";

    m_pDefaultSettings->setValue(KEY_WATERMARK, m_strWatermark);
    m_pDefaultSettings->setValue(KEY_SCALE_PCT, m_iImageScalePct);
    m_pDefaultSettings->setValue(KEY_WATERMARK_POSX, m_WMGeometry.getPosPct().first);
    m_pDefaultSettings->setValue(KEY_WATERMARK_POSY, m_WMGeometry.getPosPct().second);
    m_pDefaultSettings->setValue(KEY_WATERMARK_SCALE, m_WMGeometry.getSizePct().first);
    m_pDefaultSettings->setValue(KEY_WATERMARK_OPACITY, m_iWatermarkOpacity);
}

void AppLogic::checkDeps()
{
    QString dependencies;
    bool error = false;

    // check for ImageMagick
    if(checkForImageMagick())
    {
        qDebug("Unable to find ImageMagick!");
        dependencies += "ImageMagick:";
        error = true;
    }

    if(error)
        emit dependencyError(dependencies);
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

void AppLogic::setWatermarkPos(int posXPct, int posYPct)
{
    m_WMGeometry.setPosPct(posXPct, posYPct);
}

int AppLogic::getWatermarkPosX(int imageWidth)
{
    return m_WMGeometry.getPosX(imageWidth);
}

int AppLogic::getWatermarkPosY(int imageHeight)
{
    return m_WMGeometry.getPosY(imageHeight);
}

void AppLogic::setWatermarkSize(int scaleXPct, int scaleYPct)
{
    m_WMGeometry.setSizePct(scaleXPct, scaleYPct);
}

int AppLogic::getWatermarkSize(int imageWidth)
{
    return m_WMGeometry.getWidth(imageWidth);
}

int AppLogic::getWatermarkSizePct()
{
    return m_WMGeometry.getSizePct().first;
}

int AppLogic::getWatermarkOpacity()
{
    return m_iWatermarkOpacity;
}

void AppLogic::setWatermarkOpacity(int opacity)
{
    if(m_iWatermarkOpacity != opacity)
    {
        m_iWatermarkOpacity = opacity;
        emit watermarkOpacityChanged(m_iWatermarkOpacity);
    }
}

QString AppLogic::toNativeSeparators(QString path)
{
    return QDir::toNativeSeparators(path);
}

int AppLogic::checkForExecutable(QString executable) const
{
#ifdef Q_OS_WIN
    return m_pP4UProcess->execute(QString("%1").arg(executable));
#else
    return m_pP4UProcess->execute(QString("which %1").arg(executable));
#endif
}

int AppLogic::checkForImageMagick() const
{
    // check for mogrify
    if(checkForExecutable(BIN_CONVERT))
        return -1;

    // check for composite
    if(checkForExecutable(BIN_COMPOSITE))
        return -1;

    qDebug("ImageMagick is present!");

    return 0;
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

QString AppLogic::getFirstTargetObject()
{
    QString firstImage;

    if(!m_lWorklist.empty())
    {
        QString strFirstItem = cleanPath(m_lWorklist.first());
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

void AppLogic::applyWatermark()
{
    qDebug() << "Applying watermark to the following objects:" << m_lWorklist;

    // reset progress bar
    emit setProgressValue(0);

    QStringList fileList;
    bool bError = false;
    QString listItem;

    foreach(listItem, m_lWorklist) {
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
    int processTimeoutMs = 10000;
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
        // qDebug() << QString("%1 -auto-orient -resize %2% \"%3\" %4").arg(BIN_CONVERT).arg(m_iImageScalePct).arg(currentFile).arg(outFile);
        m_pP4UProcess->start(QString("%1 -auto-orient -resize %2% \"%3\" \"%4\"").arg(BIN_CONVERT).arg(m_iImageScalePct).arg(currentFile).arg(outFile));
        if(!m_pP4UProcess->waitForFinished(processTimeoutMs) || m_pP4UProcess->exitCode() != 0)
            break;

        // generate watermark
        QImage watermarkImg(cleanPath(m_strWatermark));
        QImage currentFileImg(outFile);
        QString tmpWatermark("watermark_tmp.png");

//        qDebug() << "Dimensions of watermarkImg: " << watermarkImg.width() << " x " << watermarkImg.height();
//        qDebug() << "Dimensions of currentFileImg: " << currentFileImg.width() << " x " << currentFileImg.height();

        // resize watermark according to image size
        if(currentFileImg.width() > currentFileImg.height())
            watermarkImg = watermarkImg.scaledToWidth(m_WMGeometry.getSizePct().first / 100.0 * currentFileImg.width());
        else
            watermarkImg = watermarkImg.scaledToWidth(m_WMGeometry.getSizePct().first / 100.0 * currentFileImg.height());
        watermarkImg.save(tmpWatermark);

//        qDebug() << "Dimensions of watermarkImg after resize: " << watermarkImg.width() << " x " << watermarkImg.height();

        // apply watermark
        int offsetX = m_WMGeometry.getPosX(currentFileImg.width() - watermarkImg.width());
        int offsetY = m_WMGeometry.getPosY(currentFileImg.height() - watermarkImg.height());

//        qDebug() << "Offset of watermark is: " << offsetX << ", " << offsetY;

        m_pP4UProcess->start(QString("%1 -dissolve %2 -gravity northwest -geometry +%3+%4 %5 \"%6\" \"%7\"").arg(BIN_COMPOSITE).arg(m_iWatermarkOpacity).arg(offsetX).arg(offsetY).arg(tmpWatermark).arg(outFile).arg(outFile));
        if(!m_pP4UProcess->waitForFinished(processTimeoutMs) || m_pP4UProcess->exitCode() != 0)
            break;

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

void AppLogic::setTargetObject(const QString &targetObject)
{
    if(m_strTargetObject == targetObject) return;

    m_strTargetObject = targetObject;
    emit targetObjectChanged(m_strTargetObject);

    // qDebug() << m_strTargetObject;
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

    if(stringList == m_lWorklist)
        return;

    m_lWorklist = stringList;
    QString targetObject = "";
    if(!m_lWorklist.empty()) {
        //if(m_lWorklist.count() == 1)
            targetObject = m_lWorklist.first();
        /*else
            targetObject = "Multiple files";*/
    }

    emit targetObjectChanged(targetObject);

    qDebug() << "Worklist: " << m_lWorklist;
}

void AppLogic::setWatermark(const QString &watermark)
{
    if(m_strWatermark == watermark) return;

    m_strWatermark = watermark;
    emit watermarkChanged(m_strWatermark);
}

void AppLogic::setImageScale(int percent)
{
    if(m_iImageScalePct == percent) return;
    if(percent < 1 || percent > 100) return;

    m_iImageScalePct = percent;

    emit imageScaleChanged(m_iImageScalePct);
}
