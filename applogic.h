#ifndef APPLOGIC_H
#define APPLOGIC_H

#include <QObject>
#include <QProcess>
#include <QSettings>

#include <wmgeometry.h>

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
    Q_INVOKABLE void setWatermarkPos(int posXPct, int posYPct);
    Q_INVOKABLE int getWatermarkPosX(int imageWidth);
    Q_INVOKABLE int getWatermarkPosY(int imageHeight);
    Q_INVOKABLE void setWatermarkSize(int scaleXPct, int scaleYPct);
    Q_INVOKABLE int getWatermarkSize(int imageWidth);
    Q_INVOKABLE int getWatermarkSizePct();
    Q_INVOKABLE int getWatermarkOpacity();
    Q_INVOKABLE void setWatermarkOpacity(int opacity);
    Q_INVOKABLE QString cleanPath(QString filePath);

private:
    QProcess* m_pP4UProcess;
    QSettings* m_pDefaultSettings;
    QString m_strTargetObject;
    QStringList m_lWorklist;
    QString m_strWatermark;
    int m_iImageScalePct;
    WMGeometry m_WMGeometry;
    int m_iWatermarkOpacity;

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
    void watermarkSizeChanged(int scaleXPct, int scaleYPct);
    void watermarkOpacityChanged(int opacity);

public slots:
    void applyWatermark();
    void setTargetObject(const QString &targetObject);
    void setWorklist(const QVariant &worklist);
    void setWatermark(const QString& watermark);
    void setImageScale(int percent);
};

#endif // APPLOGIC_H
