#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QSettings>

class Settings : public QObject
{
    Q_OBJECT
public:
    explicit Settings(QObject *parent = 0);
    ~Settings();


private:
    void writeDefaultSettings() const;

    QSettings* m_pDefaultSettings;

signals:

public slots:
    void readDefaultSettings();

};

#endif // SETTINGS_H
