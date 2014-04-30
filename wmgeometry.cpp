#include "wmgeometry.h"

#include <QDebug>

WMGeometry::WMGeometry() :
    m_SizePct(20,20),
    m_PosPct(50,50)
{
}

void WMGeometry::setSizePct(int widthPct, int heightPct)
{
    m_SizePct.first = widthPct;
    m_SizePct.second = heightPct;
}

void WMGeometry::setPosPct(int posXPct, int posYPct)
{
    // qDebug() << "posXPct: " << posXPct << ", posYPct: " << posYPct;

    m_PosPct.first = posXPct;
    m_PosPct.second = posYPct;
}

int WMGeometry::getPosX(int imageWidth) const
{
    // qDebug() << m_PosPct.first * imageWidth / 100;
    return qRound(m_PosPct.first * imageWidth / 100.0);
}

int WMGeometry::getPosY(int imageHeight) const
{
    return qRound(m_PosPct.second * imageHeight / 100.0);
}

const QPair<int, int> &WMGeometry::getPosPct() const
{
    return m_PosPct;
}

const QPair<int, int> &WMGeometry::getSizePct() const
{
    return m_SizePct;
}

int WMGeometry::getWidth(int imageWidth) const
{
    return qRound(m_SizePct.first * imageWidth / 100.0);
}

int WMGeometry::getHeight(int imageHeight) const
{
    return qRound(m_SizePct.second * imageHeight / 100.0);
}

