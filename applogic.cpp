#include "applogic.h"

#include <QtDebug>

#include <QFileInfo>
#include <QDir>
#include <QProcess>
#include <QGuiApplication>
#include <Magick++.h>

// define some keys for the default settings
#define KEY_WATERMARK "watermark"
#define KEY_SCALE_PCT "scale_pct"

AppLogic::AppLogic(QObject *parent) :
    QObject(parent),
    m_pP4UProcess(NULL),
    m_pDefaultSettings(NULL),
    m_iImageScalePct(0)
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
}

void AppLogic::writeDefaultSettings() const
{
    qDebug() << "write def settings";

    m_pDefaultSettings->setValue(KEY_WATERMARK, m_strWatermark);
    m_pDefaultSettings->setValue(KEY_SCALE_PCT, m_iImageScalePct);
}

void AppLogic::checkDeps()
{
    QString dependencies;
    bool error = false;

    if(error)
        emit dependencyError(dependencies);
}

QString AppLogic::getDefaultDir()
{
    QString homePath = QDir::homePath();

    homePath.prepend("file://");
    homePath.append("/Desktop");

    return homePath;
}

int AppLogic::checkForExecutable(QString executable) const
{
#ifdef Q_OS_WIN
    return m_pP4UProcess->execute(QString("%1").arg(executable));
#else
    return m_pP4UProcess->execute(QString("which %1").arg(executable));
#endif
}

QString AppLogic::fixPath(QString filePath)
{
    filePath.prepend("file://");
    return filePath;
}

bool AppLogic::applyWatermark(const QString &imageFile) const
{
    Magick::Image image(qPrintable(imageFile));
    Magick::Image watermark(qPrintable(m_strWatermark));

    watermark.opacity(QuantumRange / 2);

    image.autoOrient();
    image.scale(Magick::Geometry(qPrintable(QString("%1\%x%2\%").arg(m_iImageScalePct).arg(m_iImageScalePct))));
    image.composite(watermark, Magick::NorthEastGravity, Magick::DissolveCompositeOp );

    image.write(qPrintable(imageFile + "_out.jpg"));

    return true;
}

void AppLogic::applyWatermarks()
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
        if(QFileInfo(listItem).isDir()) {
            m_pP4UProcess->setWorkingDirectory(listItem);
            QDir directory(listItem);
            QStringList nameFilters;
            nameFilters << "*.JPG" << "*.jpg";
            fileList.append(directory.entryList(nameFilters));
        }
        else {
            fileList.append(listItem);
        }
    }

    QString imageFile;

    for(int i = 0; i < fileList.length() && !bError; ++i)
    {
        imageFile = fileList.value(i);
        qDebug() << imageFile;
        bError = !applyWatermark(imageFile);

        // set progress value
        emit setProgressValue(qRound((i+1) * 100.0 / fileList.length()));
    }

    if(bError) {
        qDebug() << "There was an error. Current file =" << imageFile;
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

void AppLogic::setWorklist(const QVariant &worklist)
{
    if(worklist.toStringList() == m_lWorklist) return;

    m_lWorklist = worklist.toStringList();
    QString targetObject = "";
    if(!m_lWorklist.empty()) {
        if(m_lWorklist.count() == 1)
            targetObject = m_lWorklist.first();
        else
            targetObject = "Multiple files";
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
