#ifndef APPLOGIC_H
#define APPLOGIC_H

#include <QObject>
#include <QProcess>
#include <QSettings>

class AppLogic : public QObject
{
    Q_OBJECT
public:
    explicit AppLogic(QObject *parent = 0);
    ~AppLogic();
    
    void readDefaultSettings();
    void checkDeps();
    Q_INVOKABLE QString getDefaultDir();
    Q_INVOKABLE QString fixPath(QString filePath);
    Q_INVOKABLE QString getPathPrefix();

private:
    QProcess* m_pP4UProcess;
    QSettings* m_pDefaultSettings;
    QString m_strTargetObject;
    QStringList m_lWorklist;
    QString m_strWatermark;
    int m_iImageScalePct;

    void writeDefaultSettings() const;
    int checkForExecutable(QString executable) const;
    int checkForImageMagick() const;

signals:
    void watermarkDone(int exitCode);
    void targetObjectChanged(const QString& targetObject);
    void watermarkChanged(const QString& watermark);
    void setProgressValue(int value);
    void imageScaleChanged(int percent);
    void dependencyError(const QString& dependencies);

public slots:
    void applyWatermark();
    void setTargetObject(const QString &targetObject);
    void setWorklist(const QVariant &worklist);
    void setWatermark(const QString& watermark);
    void setImageScale(int percent);
};

#endif // APPLOGIC_H
