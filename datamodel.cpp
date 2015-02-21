#include "datamodel.h"

#include <QDebug>

DataModel::DataModel(QObject *parent) :
    QObject(parent),
    m_iImageScalePct(0),
    m_iWatermarkOpacity(0)
{
}

DataModel &DataModel::instance()
{
    static DataModel dm;
    return dm;
}

void DataModel::setWatermarkPos(int posXPct, int posYPct)
{
    m_WMGeometry.setPosPct(posXPct, posYPct);
}

int DataModel::getWatermarkPosX(int imageWidth)
{
    return m_WMGeometry.getPosX(imageWidth);
}

int DataModel::getWatermarkPosY(int imageHeight)
{
    return m_WMGeometry.getPosY(imageHeight);
}

void DataModel::setWatermarkSize(int scaleXPct, int scaleYPct)
{
    m_WMGeometry.setSizePct(scaleXPct, scaleYPct);
}

int DataModel::getWatermarkSize(int imageWidth)
{
    return m_WMGeometry.getWidth(imageWidth);
}

int DataModel::getWatermarkSizePct()
{
    return m_WMGeometry.getSizePct().first;
}

int DataModel::getWatermarkPosPctX() const
{
    return m_WMGeometry.getPosPct().first;
}

int DataModel::getWatermarkPosPctY() const
{
    return m_WMGeometry.getPosPct().second;
}

int DataModel::getWatermarkOpacity()
{
    return m_iWatermarkOpacity;
}

void DataModel::setWatermarkOpacity(int opacity)
{
    if(m_iWatermarkOpacity != opacity)
    {
        m_iWatermarkOpacity = opacity;
        emit watermarkOpacityChanged(m_iWatermarkOpacity);
    }
}

QStringList DataModel::getWorklist() const
{
    return m_lWorklist;
}

void DataModel::setWorklist(const QStringList &worklist)
{
    if(worklist != m_lWorklist)
    {
        m_lWorklist = worklist;

        qDebug() << "Worklist: " << m_lWorklist;

        emit targetObjectChanged(m_lWorklist.empty() ? "" : m_lWorklist.first());
    }
}

int DataModel::getImageScale() const
{
    return m_iImageScalePct;
}

QString DataModel::getWatermark() const
{
    return m_strWatermark;
}

void DataModel::setWatermark(const QString &watermark)
{
    if(m_strWatermark == watermark) return;

    m_strWatermark = watermark;
    emit watermarkChanged(m_strWatermark);
}

void DataModel::setImageScale(int percent)
{
    if(m_iImageScalePct == percent) return;
    if(percent < 1 || percent > 100) return;

    m_iImageScalePct = percent;

    emit imageScaleChanged(m_iImageScalePct);
}
