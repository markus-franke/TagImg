#ifndef WMGEOMETRY_H
#define WMGEOMETRY_H

#include <QPair>

class WMGeometry
{
public:
    WMGeometry();

    void setSizePct(int widthPct, int heightPct);
    void setPosPct(int posXPct, int posYPct);

    int getPosX(int imageWidth) const;
    int getPosY(int imageHeight) const;
    const QPair<int,int>& getPosPct() const;

    const QPair<int,int>& getSizePct() const;
    int getWidth(int imageWidth) const;
    int getHeight(int imageHeight) const;

private:
    QPair<int,int> m_SizePct;
    QPair<int,int> m_PosPct;
};

#endif // WMGEOMETRY_H
