#include "settings.h"

#include <QDebug>

#include "datamodel.h"

// define some keys for the default settings
static const char* const KEY_SCALE_PCT          = "scale_pct";
static const char* const KEY_WATERMARK          = "watermark";
static const char* const KEY_WATERMARK_POSX     = "watermark_posx";
static const char* const KEY_WATERMARK_POSY     = "watermark_posy";
static const char* const KEY_WATERMARK_SCALE    = "watermark_scale";
static const char* const KEY_WATERMARK_OPACITY  = "watermark_opacity";

Settings::Settings(QObject *parent) :
    QObject(parent),
    m_pDefaultSettings(nullptr)
{
    m_pDefaultSettings = new QSettings("Private", "P4UGUI", this);
}

Settings::~Settings()
{
    writeDefaultSettings();
}

void Settings::readDefaultSettings()
{
    DataModel& dm = DataModel::instance();

    qDebug() << "Reading default settings";

    dm.setWatermark(m_pDefaultSettings->value(KEY_WATERMARK, "").toString());
    dm.setImageScale(m_pDefaultSettings->value(KEY_SCALE_PCT, 50).toInt());
    dm.setWatermarkPos(m_pDefaultSettings->value(KEY_WATERMARK_POSX, 0).toInt(), m_pDefaultSettings->value(KEY_WATERMARK_POSY, 0).toInt());
    dm.setWatermarkSize(m_pDefaultSettings->value(KEY_WATERMARK_SCALE, 50).toInt(), m_pDefaultSettings->value(KEY_WATERMARK_SCALE, 50).toInt());
    dm.setWatermarkOpacity(m_pDefaultSettings->value(KEY_WATERMARK_OPACITY, 50).toInt());
}

void Settings::writeDefaultSettings() const
{
    DataModel& dm = DataModel::instance();

    qDebug() << "Writing default settings";

    m_pDefaultSettings->setValue(KEY_WATERMARK, dm.getWatermark());
    m_pDefaultSettings->setValue(KEY_SCALE_PCT, dm.getImageScale());
    m_pDefaultSettings->setValue(KEY_WATERMARK_POSX, dm.getWatermarkPosPctX());
    m_pDefaultSettings->setValue(KEY_WATERMARK_POSY, dm.getWatermarkPosPctY());
    m_pDefaultSettings->setValue(KEY_WATERMARK_SCALE, dm.getWatermarkSizePct());
    m_pDefaultSettings->setValue(KEY_WATERMARK_OPACITY, dm.getWatermarkOpacity());
}
