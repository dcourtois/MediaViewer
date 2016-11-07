#ifndef __CURSOR_H__
#define __CURSOR_H__


class Cursor
	: public QObject
{

	Q_OBJECT
	Q_PROPERTY(bool hidden READ IsHidden WRITE SetHidden NOTIFY hiddenChanged)

signals:

	void	hiddenChanged(bool hidden);

public:

	Cursor(QObject * parent = nullptr);

	// public C++ API
	bool	IsHidden(void) const;
	void	SetHidden(bool hidden);

private:

	//! Hidden state of the mouse cursor
	bool m_Hidden;

};


#endif // __CURSOR_H__
