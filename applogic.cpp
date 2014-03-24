#include "applogic.h"

#include <QtDebug>

#include <QFileInfo>
#include <QDir>
#include <QProcess>
#include <QGuiApplication>
#include <QUrl>

// define some keys for the default settings
#define KEY_WATERMARK "watermark"
#define KEY_SCALE_PCT "scale_pct"

// define some ImageMagick binaries
#define BIN_MOGRIFY     "mogrify"
#define BIN_COMPOSITE   "composite"

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
    QString homePath = QDir::homePath();

    homePath.prepend("file://");
    homePath.append("/Desktop");

    return homePath;
}

QString AppLogic::getPathPrefix()
{
#ifdef Q_OS_WIN
    return "file:///";
#else
    return "";
#endif
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
    if(checkForExecutable(BIN_MOGRIFY))
        return -1;

    // check for composite
    if(checkForExecutable(BIN_COMPOSITE))
        return -1;

    qDebug("ImageMagick is present!");

    return 0;
}

QString AppLogic::fixPath(QString filePath)
{
    filePath.prepend("file://");
    return filePath;
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

    QString currentFile;
    int processTimeoutMs = 10000;
    for(int i = 0; i < fileList.length() && !bError; ++i) {
        currentFile = fileList.value(i);
        qDebug() << currentFile;
        bError = true;

        m_pP4UProcess->start(QString("%1 -auto-orient -resize %2% \"%3\"").arg(BIN_MOGRIFY).arg(m_iImageScalePct).arg(currentFile));
        if(!m_pP4UProcess->waitForFinished(processTimeoutMs) || m_pP4UProcess->exitCode() != 0)
            break;

        m_pP4UProcess->start(QString("%1 -dissolve 50 -gravity northeast -geometry +50+0 %2 \"%3\" \"%4\"").arg(BIN_COMPOSITE).arg(m_strWatermark).arg(currentFile).arg(currentFile));
        if(!m_pP4UProcess->waitForFinished(processTimeoutMs) || m_pP4UProcess->exitCode() != 0)
            break;

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
