#ifndef DATAMODEL_H
#define DATAMODEL_H

#include <QObject>
#include <QStringList>

#include "wmgeometry.h"

class DataModel : public QObject
{
    Q_OBJECT
public:
    static DataModel& instance();

    Q_INVOKABLE void setWatermarkPos(int posXPct, int posYPct);
    Q_INVOKABLE int getWatermarkPosX(int imageWidth);
    Q_INVOKABLE int getWatermarkPosY(int imageHeight);

    Q_INVOKABLE void setWatermarkSize(int scaleXPct, int scaleYPct);
    Q_INVOKABLE int getWatermarkSize(int imageWidth);
    Q_INVOKABLE int getWatermarkSizePct();

    int getWatermarkPosPctX() const;
    int getWatermarkPosPctY() const;

    Q_INVOKABLE void setWatermarkOpacity(int opacity);
    Q_INVOKABLE int getWatermarkOpacity();

    void setWorklist(const QStringList& worklist);
    QStringList getWorklist() const;

    Q_INVOKABLE void setWatermark(const QString& watermark);
    QString getWatermark() const;

    Q_INVOKABLE void setImageScale(int percent);
    int getImageScale() const;

private:
    explicit DataModel(QObject *parent = 0);

    QString m_strTargetObject;
    QStringList m_lWorklist;
    QString m_strWatermark;
    int m_iImageScalePct;
    WMGeometry m_WMGeometry;
    int m_iWatermarkOpacity;

signals:
    void targetObjectChanged(const QString& targetObject);
    void watermarkChanged(const QString& watermark);
    void imageScaleChanged(int percent);
    void watermarkSizeChanged(int scaleXPct, int scaleYPct);
    void watermarkOpacityChanged(int opacity);

public slots:

};

#endif // DATAMODEL_H
