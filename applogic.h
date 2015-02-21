#ifndef APPLOGIC_H
#define APPLOGIC_H

#include <QObject>

#include "wmgeometry.h"
#include "settings.h"
#include "datamodel.h"

class AppLogic : public QObject
{
    Q_OBJECT
public:
    explicit AppLogic(QObject *parent = 0);

    Q_INVOKABLE QString getDefaultDir();
    Q_INVOKABLE QString fixPath(QString filePath);
    Q_INVOKABLE QString getPathPrefix();
    Q_INVOKABLE QString toNativeSeparators(QString path);
    Q_INVOKABLE QString cleanPath(QString filePath);
    Q_INVOKABLE void applyWatermark();
    Q_INVOKABLE void setWorklist(const QVariant& worklist);
    Q_INVOKABLE QString getFirstTargetObject();

#if 0
    Q_INVOKABLE void setWatermarkPos(int posXPct, int posYPct);
    Q_INVOKABLE int getWatermarkPosX(int imageWidth);
    Q_INVOKABLE int getWatermarkPosY(int imageHeight);
    Q_INVOKABLE void setWatermarkSize(int scaleXPct, int scaleYPct);
    Q_INVOKABLE int getWatermarkSize(int imageWidth);
    Q_INVOKABLE int getWatermarkSizePct();
    Q_INVOKABLE int getWatermarkOpacity();
    Q_INVOKABLE void setWatermarkOpacity(int opacity);
#endif

private:
    Settings m_Settings;
    DataModel& m_DM;

signals:
    void watermarkDone(int exitCode);
    void setProgressValue(int value);
};

#endif // APPLOGIC_H
